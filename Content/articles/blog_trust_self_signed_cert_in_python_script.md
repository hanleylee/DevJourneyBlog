---
title: 在 Python 脚本中信任自签名证书
date: 2023-05-05
comments: true
urlname: trust_self_signed_certificate_in_python_script
tags: ⦿python,⦿https,⦿ssl,⦿certificate
updated:
---

最近在全局代理情况下遇到了 python 报错 `[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1002)`, 经过一番资料查找后解决了问题, 我觉得这个问题也是属于计算机网络的一个基本知识了, 掌握以后可以举一反三, 值得分享一下 🤭

<!-- more -->

## 背景

1. 本机上使用了 Surge 的全部域名解密(已经在 mac 上信任了 Surge 的证书)

    ![himg](https://a.hanleylee.com/HKMS/2023-05-06123935.png?x-oss-process=style/WaMa)

2. 使用工具 [translator](https://github.com/skywind3000/translator), 执行命令 `translator --engine=google "hello world"` 报错

具体报错信息如下:

```txt
Traceback (most recent call last):
  File "/Users/hanley/.zsh/bin/py/translator", line 829, in <module>
    main()
  File "/Users/hanley/.zsh/bin/py/translator", line 727, in main
    res = translator.translate(sl, tl, text)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/Users/hanley/.zsh/bin/py/translator", line 352, in translate
    r = self.http_get(url)
        ^^^^^^^^^^^^^^^^^^
  File "/Users/hanley/.zsh/bin/py/translator", line 201, in http_get
    return self.request(url, data, False, header)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/Users/hanley/.zsh/bin/py/translator", line 195, in request
    r = self._session.get(url, **argv)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/Users/hanley/.pyenv/versions/3.11.3/Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages/requests/sessions.py", line 600, in get
    return self.request("GET", url, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/Users/hanley/.pyenv/versions/3.11.3/Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages/requests/sessions.py", line 587, in request
    resp = self.send(prep, **send_kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/Users/hanley/.pyenv/versions/3.11.3/Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages/requests/sessions.py", line 701, in send
    r = adapter.send(request, **kwargs)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/Users/hanley/.pyenv/versions/3.11.3/Library/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages/requests/adapters.py", line 563, in send
    raise SSLError(e, request=request)
requests.exceptions.SSLError: HTTPSConnectionPool(host='translate.google.com.hk', port=443): Max retries exceeded with url: /translate_a/single?client=gtx&sl=en-US&tl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&q=hello+world (Caused by SSLError(SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1002)')))
```

可以看到我们应该关注的重点是报错信息的最后一段: `[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1002)`. 经过分析, 我们知道是证书验证失败导致异常. 将 Surge 针对所有域名解密关闭, 再次使用命令 `translator --engine=google "hello world"` 可得到正常结果:

```txt
$ translator --engine=google "hello world"
hello world
你好世界
 * 你好，世界
 * 世界，你好
```

依此我们确认了错误是由于 Surge 证书验证失败导致的. 可是明明我已经在 `Keychain Access.app` 中信任了证书, 为什么 Python 还是会验证失败呢?

![himg](https://a.hanleylee.com/HKMS/2023-05-06124259.png?x-oss-process=style/WaMa)

## 解决方案

经过搜索, 我找到了 `requests` 库文档的 [CA Certificates](https://requests.readthedocs.io/en/latest/user/advanced/#ca-certificates), 原来 `requests` 库不使用 mac 的证书库进行验证, 而是默认使用 `certifi` 库提供的证书库进行验证, 所以如果我们想将将 Surge 证书设置为信任, 必须在将其加入到 `certifi` 的证书库中, 步骤如下

1. 使用 `python -m certifi` 找到 certifi 的证书库, 例如 `path/to/certifi/cacert.pem`
2. 将 Surge 证书从 `Keychain Access.app` 中以 `.pem` 格式导出, 文件名为 `surge.pem`

    ![himg](https://a.hanleylee.com/HKMS/2023-05-06124522.png?x-oss-process=style/WaMa)

3. 将 `surge.gem` 内容添加到 `path/to/certifi/cacert.pem` 中, `cat surge.pem >> path/to/certifi/cacert.pem`

此时我们再验证 translator 结果, 正确输出翻译结果 ✅

## 解决方案优化 - 使用 `REQUESTS_CA_BUNDLE` 变量灵活配置

上面这种方法可以解决问题, 但是并不优雅. 问题在于

1. certifi 库升级时可能会覆盖 `path/to/certifi/cacert.pem` 文件
2. `cacert.pem` 文件的位置由 certifi 默认指定, 不能被加入版本管理, 这样就不能在多台电脑同步

进一步阅读 [doc](https://requests.readthedocs.io/en/latest/user/advanced/#proxies), 我发现更完美的解决方法是使用 `REQUESTS_CA_BUNDLE` 环境变量

1. 将我们需要信任的证书库制作为一个 `pem` 文件, 例如 `path/to/cacert.pem`
2. 在 `~/.bash_profile` / `~/.zshrc` 中设置环境变量 `REQUESTS_CA_BUNDLE` 值

    ```zsh
    # ~/.bash_profile or ~/.zshrc
    export REQUESTS_CA_BUNDLE="path/to/cacert.pem"
    ```

3. 重启 shell

## REQUESTS_CA_BUNDLE 变量在源码中的逻辑

从 [源码](https://github.com) 中我们可以看到:

```python
# requests/sessions.py > https://github.com/psf/requests/blob/2ad18e0e10e7d7ecd5384c378f25ec8821a10a29/requests/sessions.py#L765-L770
if verify is True or verify is None:
    verify = (
        os.environ.get("REQUESTS_CA_BUNDLE")
        or os.environ.get("CURL_CA_BUNDLE")
        or verify
    )

# requests/adapters.py > https://github.com/psf/requests/blob/2ad18e0e10e7d7ecd5384c378f25ec8821a10a29/requests/adapters.py#L253C23-L258
# Allow self-specified cert location.
if verify is not True:
    cert_loc = verify

if not cert_loc:
    cert_loc = extract_zipped_paths(DEFAULT_CA_BUNDLE_PATH)
```

`DEFAULT_CA_BUNDLE_PATH` 是 certifi 库默认 `.pem` 文件位置, 因此我们可以得出结论, requests 库会优先使用我们设置的 `REQUESTS_CA_BUNDLE` / `CURL_CA_BUNDLE` 环境变量, 如果找不到那么再使用 `certifi` 提供的默认的证书库

## 导出证书到 `.pem` 文件

那么我们如何制作一个证书库呢?

### 导出 mac 上已有的证书库

- `security export -t certs -f pemseq -k /System/Library/Keychains/SystemRootCertificates.keychain -o bundleCA.pem`: mac 下导出系统根证书
- `security export -t certs -f pemseq -k /Library/Keychains/System.keychain -o selfSignedCAbundle.pem`: mac 下导出用户安装的证书

然后将两个文件合并 `cat bundleCA.pem selfSignedCAbundle.pem >> allCABundle.pem`, 这样我们就得到了目前 mac 上系统及用户证书的合集

### 导出网站对应的证书

使用如下命令均可导出 `google.com` 的证书文件

- `true | openssl s_client -connect google.com:443 2>/dev/null | openssl x509 >google.pem`
- `echo -n | openssl s_client -connect google.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >google.pem`

## Ref

- [How to make Python use CA certificates from Mac OS TrustStore?](https://stackoverflow.com/questions/40684543/how-to-make-python-use-ca-certificates-from-mac-os-truststore)
- [requests doc](https://requests.readthedocs.io/en/latest/user/advanced/)
- [python-certifi](https://github.com/certifi/python-certifi)
- [python-requests](https://github.com/psf/requests)
