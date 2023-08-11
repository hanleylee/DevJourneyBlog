---
title: Apple 证书校验实践
date: 2022-06-17
comments: true
path: apple-certificate-pratice
categories: ios
tags: ⦿certificate, ⦿ios, ⦿apple
updated: 2022-06-17
---

![himg](https://a.hanleylee.com/HKMS/2022-06-19205254.png?x-oss-process=style/WaMa)

证书管理是 Apple 开发从业人员绕不过去的一个话题, 很多极有经验的老鸟也会此栽跟头.

前两天我司在证书迭代的过程中就被证书校验坑了一天, 经过与资深 iOS 开发工程师 *铁柱* & *言若* 的不断踩坑, 不断分析, 最终对证书验证的理解又上了一个层次, 这篇文章把踩坑过程中的一些点记录下来, 以示后人.

<!-- more -->

本文不涉及证书校验的基础知识, 如果不清楚相关证书检验基础知识, 建议先阅读 [iOS 证书幕后原理][1]

## 托管证书的相关坑

我司的配置文件是使用默认的托管方式进行管理的, **托管** 代表着 *指定证书列表* / *测试设备管理* 的琐事全部由 Xcode 帮我们自动管理了

### 托管方式不会使用我们在 <https://developer.apple.com/> 创建的 Profiles

我们已经说了, **托管** 就代表着 Xcode 帮助我们做很多决策, 如果还需要使用我们自己创建的 Profiles, 那托管还有什么意义呢?

因此, 我们即使不手动创建任何 Profiles, 只要使用了托管选项, 我们的打包仍然不会有问题(因为Xcode 会自动帮我们创建 Profiles)

![himg](https://a.hanleylee.com/HKMS/2022-06-19200541.png?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2022-06-19200833.png?x-oss-process=style/WaMa)

### 托管方式会在开发与发布阶段创建不同的配置文件

使用托管配置时, 会在本地的 `~/Library/MobileDevice/Provisioning Profiles` 文件夹中自动生成相关配置文件

- 当我们在开发阶段时, *Build* / *Run* 会生成名为 `iOS Team Provisioning Profile: ***` 的托管配置文件
- 当我们 `Archive` -> `Distribute App` 时:
    - `Ad Hoc` 会生成名为 `iOS Team Ad Hoc Provisioning Profile: ***` 的托管配置文件
    - `App Store Connect` 会生成名为 `iOS Team Store Provisioning Profile: ***` 的配置文件
    - ...

![himg](https://a.hanleylee.com/HKMS/2022-06-19204721.png?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2022-06-19215628.png?x-oss-process=style/WaMa)

### 托管方式下 *App Distribute* 时使用的 *Distribution Certificate* 从哪里来?

托管方式下, 当 Distribute 时, 会从 *Distribution Provisioning Profile* 的证书列表中遍历查找可用证书:

- 如果在本地找到有效的 *Distribution Certificate*, 直接使用该 *Distribution Certificate*
- 如果没有在本地找到有效的 *Distribution Certificate*, 这个时候会在 <https://developer.apple.com/> 生成一个类型为 `Distribution Managed` 的 *Distribution Certificate*, 并使用该证书

    ![himg](https://a.hanleylee.com/HKMS/2022-06-19205254.png?x-oss-process=style/WaMa)

## 为什么 Xcode 主动提示 `Revoke` Development 证书?

> Your account already has an Apple Development signing certificate for this machine, but its private key is not installed in your keychain. Xcode can create a new one after revoking your existing certificate.

![himg](https://a.hanleylee.com/HKMS/2022-06-19221530.png?x-oss-process=style/WaMa)

当我们 *Keychain Access* 中删除了 `iOS Team Provisioning Profile: ***` 中 `Certificates` 部分所列出的所有证书的私钥, 然后 `Build` / `Run` 时我们会得到上面的报错信息, 为什么会这样呢?

![himg](https://a.hanleylee.com/HKMS/2022-06-19221805.png?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2022-06-19222033.png?x-oss-process=style/WaMa)

原因很明显: 即使是在托管方式下, 仍需要一份开发证书以及证书对应的私钥用于开发阶段的签名验证, 如果我们删除了开发证书与私钥中的任何一个, 都会导致无法找到开发配置文件 `iOS Team Provisioning Profile: ***` 中所列出的证书用以签名, 这个时候 Xcode 会温馨提示它可以帮我们 `Revoke`(废弃) 掉原有的证书, 在远端生成一个新的证书并下载安装到本地以使用.

因为在这一步中, Xcode 是从 *Development Provisioning Profile* 中的证书列表中查找可用证书的, 因此如果我们在本地删除了仅有的开发证书或私钥, 但是只要我们能找到 *Development Provisioning Profile* 中列出的任一证书对应的 p12 文件并导入到本机, 那么仍然可以顺利通过编译

## Fastlane 不会自动更新生成配置文件

这两天我司进行 App 证书更新替换工作, 原以为我们使用托管方式进行证书更新会很简单, 仅将相关开发证书删除然后配置文件清空即可, 其实不然, fastlane 在打包过程中发生了如下错误

1. `No profiles for '***' were found: Xcode couldn't find any iOS App Development provisioning profiles matching '***'.`
2. `No profiles for '***' were found: Xcode couldn't find any iOS Ad Hoc provisioning profiles matching '***'`

这是因为我们将 `~/Library/MobileDevice/Provisioning Profiles` 文件夹清空了, 所有的配置文件都被删除了. 当使用 Xcode 时, 如果发现使用了托管且没有找到配置文件时, 会自动生成一个并包存在 `~/Library/MobileDevice/Provisioning Profiles` 中, 所以在 Xcode 中是不会报错的; 但是 Fastlane 默认不会生成这个配置文件, 这个时候就会报错了, 解决办法有两种:

1. 清空 `~/Library/MobileDevice/Provisioning Profiles` 内容后的第一次打包发布使用 Xcode 手动点击方式, 之后再使用 Fastlane 自动打包
2. 在 Fastfile 的 gym 方法中加入参数 `export_xcargs: "-allowProvisioningUpdates"`(这个参数最后也是加给 `xcodebuild` 了)

    ```ruby
    gym(
        scheme: target,
        configuration: configuration,
        export_method: export_method,
        export_xcargs: "-allowProvisioningUpdates",
        export_options: {
              uploadSymbols: false,
              compileBitcode: false
        }
      )
    ```

## Ref

- [iOS 证书幕后原理][1]

[1]: http://chuquan.me/2020/03/22/ios-certificate-principle/
