---
title: 使用 ssh 协议连接远程主机
date: 2019-08-31
comments: true
path: connect-remote-server-by-using-ssh-key
categories: Terminal
tags: ⦿terminal, ⦿ssh, ⦿server
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-02-27-flowchart-of-connection-between-client-and-server-2.png?x-oss-process=style/WaMa)

ssh 是连接远程主机的一种协议, ssh 认证有三种模式:

- 密码认证
- 证书认证
- 公钥认证

> 默认的认证顺序: `publickey` → `gssapi-keyex` → `gssapi-with-mic` → `password`

本文主要尝试讨论 *ssh 公钥认证* 流程

<!-- more -->

## SSH 链接创建

不管是何种认证, 首先必须建立链接, 下面是链接建立的过程

1. 客户端发起链接请求
2. 服务端返回自己的公钥, 以及一个会话 ID(这一步客户端得到服务端公钥)
3. 客户端生成密钥对
4. 客户端用自己的公钥异或会话 ID, 计算出一个值, 并用服务端的公钥加密
5. 客户端发送加密后的值到服务端, 服务端用私钥解密
6. 服务端用解密后的值异或会话 ID, 计算出客户端的公钥 (这一步服务端得到客户端公钥)
7. 至此, 双方各自持有三个秘钥, 分别为自己的一对公, 私钥, 以及对方的公钥, 之后的所有通讯都会被加密

这里有一个有趣的地方, 两台机器第一次使用 SSH 链接时, 当服务端返回自己的公钥 (第 2 步) 的时候, 客户端会有一条信息提示, 大意是无法验证对方是否可信, 并给出对方公钥的 MD5 编码值, 问是否确定要建立链接.

这是因为 SSH 虽然传输过程中很安全, 但是在首次建立链接时并没有办法知道发来的公钥是否真的来自自己请求的服务器, 如果有人在客户端请求服务器后拦截了请求, 并返回自己的公钥冒充服务器, 这时候如果链接建立, 那么所有的数据就都能被攻击者用自己的私钥解密了. 这也就是所谓的中间人攻击.

## *ssh 密码认证* 登录流程

1. 服务端收到登录请求后, 首先互换公钥, 详细步骤如 [ssh 链接创建](#ssh- 链接创建) 所述.
2. 客户端用服务端的公钥加密账号密码并发送
3. 服务端用自己的秘钥解密后得到账号密码, 然后进行验证
4. 服务端用客户端的公钥加密验证结果并返回
5. 客户端用自己的秘钥解密后得到验证结果

从这可以看出, ssh 密码认证有如下致命缺点:

- 如果存在恶意攻击的话, 存在泄露风险
- 需要手动手动输入密码, 不适合管理多台机器

## *ssh 证书认证* 登录流程

SSH 证书登录之前, 如果还没有证书, 需要生成证书. 具体方法是:

1. 用户和服务器都将自己的公钥, 发给 CA;
2. CA 使用服务器公钥, 生成服务器证书, 发给服务器;
3. CA 使用用户的公钥, 生成用户证书, 发给用户.

有了证书以后, 用户就可以登录服务器了. 整个过程都是 SSH 自动处理, 用户无感知.

1. 用户登录服务器时, SSH 自动将用户证书发给服务器.
2. 服务器检查用户证书是否有效, 以及是否由可信的 CA 颁发. 证实以后, 就可以信任用户.
3. SSH 自动将服务器证书发给用户.
4. 用户检查服务器证书是否有效, 以及是否由信任的 CA 颁发. 证实以后, 就可以信任服务器.
5. 双方建立连接, 服务器允许用户登录.

## *ssh 公钥认证* 登录流程

SSH 秘钥分为两部分, 公钥与私钥, 公钥随意分布到别的远程主机上, 私钥则只放在自己电脑上, 保证连接的唯一性与安全性. ssh 公钥认证流程如下:

1. 客户端用户必须手动地将自己的公钥添加到服务器一个名叫 `authorized_keys` 的文件里, 顾名思义, 这个文件保存了所有可以远程登录的机器的公钥.
2. 客户端发起登录请求, 并且发送一个自己公钥的指纹 (具有唯一性, 但不是公钥)
3. 服务端根据指纹检测此公钥是否保存在 `authorized_keys` 中
4. 若存在, 服务端便生成一段随机字符串, 然后利用客户端公钥加密并返回
5. 客户端收到后用自己的私钥解密, 再利用服务端公钥加密后发回
6. 服务端收到后用自己的私钥解密, 如果为同一字符串, 则验证通过

在 MacOS 上, 在以上的认证流程之上, 还会有一些其他的附加逻辑, 如下图:

![himg](https://a.hanleylee.com/HKMS/2020-02-27-flowchart-of-connection-between-client-and-server-2.png?x-oss-process=style/WaMa)

重点: **会遍历认证队列的所有私钥用于验证签名, 直到认证通过或遍历完所有私钥而连接失败.**

## ssh 命令

ssh [option] destination [command]

- option
    - `-c`: 指定加密算法. `ssh -c blowfish,3des server.example.com`
    - `-C`: 压缩数据传输. `ssh -C server.example.com`
    - `-d`: 设置打印的 debug 级别, 数值越高内容越详细. `ssh -d 1 foo.com`
    - `-D`: 指定本机的 Socks 监听端口, 该端口收到的请求, 都将转发到远程的 SSH 主机, 又称动态端口转发. `ssh -D 1080 server`
    - `-f`: 表示 ssh 连接在后台进行
    - `-F`: 指定配置文件. `ssh -F /usr/local/ssh/other_config`
    - `-l`: 指定远程登录的账户名. `ssh -l sally server.example.com` (等同于 `ssh sally@server.example.com`)
    - `-L`: 设置本地端口转发. `ssh -L 9999:targetServer:80 user@remoteserver` (所有发向本地 9999 端口的请求, 都会经过 remoteserver 发往 targetServer 的 80 端口, 这就相当于直接连上了 targetServer 的 80 端口.)
    - `-m`: 指定校验数据完整性的算法. `ssh -m hmac-sha1,hmac-md5 server.example.com`
    - `-o`: 用来指定一个配置命令. `ssh -o "User sally" -o "Port 220" server.example.com` (等效于 `ssh -o User=sally -o Port=220 server.example.com`)
    - `-p`: 指定端口
    - `-q`: 安静模式, 不输出任何警告信息
    - `-R`: 指定远程端口转发. `ssh -R 9999:targetServer:902 local` (需在跳板服务器执行, 指定本地计算机 local 监听自己的 9999 端口, 所有发向这个端口的请求, 都会转向 targetServer 的 902 端口.)
    - `-t`: 提供一个互动式 shell
    - `-v`: 显示详细参数, 次数越多越详细. `ssh -vvv server.example.com`
    - `-V`: 输出 ssh 客户端版本 `ssh -V`

## ssh 实例

- `ssh <alias>`: 通过别名登录已在 `~/.ssh/config` 中配置的远程主机. alias 为 `~/.ssh/config` 中的 `Host` 名
- `ssh -l root -p 66 123.456.789`: 登录指定 ip 和端口的服务器
- `ssh -l root -p 66 -v 123.456.789`: 登录指定 ip 和端口的服务器, 并输出详细登录过程信息
- `ssh root@123.456.789`: 以 root 用户登录指定 ip 的服务器
- `ssh root@123.456.789 cat /etc/hosts`: 以 root 用户登录指定 ip 的服务器, 然后立刻执行远程命令 `cat /etc/hosts/` 的内容
- `ssh -i my-key server.example.com`: 指定秘钥登录服务器
- `ssh-add ~/.ssh/GitHub`: 将 `~/.ssh/GitHub` 秘钥添加到 `ssh agent` 中
- `ssh-add -K ~/.ssh/GitHub`: 将 `~/.ssh/GitHub` 秘钥添加到 `ssh agent` 中, 并加入到 `keychain` 中 (Mac 专有)
- `ssh-add -L`: 显示 `ssh agent` 中的所有公钥
- `ssh-add -l`: 显示 `ssh agent` 中的所有私钥
- `ssh-add -d ~/.ssh/GitHub`: 删除在 `ssh agent` 中的 `~/.ssh/GitHub` 文件 (该私钥对应的公钥也会被从 `ssh agent` 中删除)
- `ssh-add -D`: 删除 `ssh agent` 中的所有秘钥
- `ssh-keygen -t dsa`: 生成秘钥, 指定秘钥的加密算法为 `dsa` (更新: `DSA` 算法在 `Openssh` 7.0 版本之后被禁用了)
- `ssh-keygen -t rsa -b 4096 -C "your_email@domain.com"`: 生成一个 4096 位 RSA 加密算法的密钥对, 并且给出了用户名和主机名.
- `ssh-keygen -t dsa -f mykey`: 在当前目录生成私钥文件 `mykey` 和公钥文件 `mykey.pub`
- `ssh-keygen -l -f`: 输出公钥的指纹 (与本机连接过的所有服务器的公钥的指纹都存储在本机的 `~/.ssh/known_hosts` 中)
- `ssh-keygen -R host`: 将指定的主机公钥指纹移出 `known_hosts` 文件
- `cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"`: 上传公钥至服务器
- `ssh-copy-id -i key_file user@host`: 使用 `ssh` 自带的密钥上传工具将密钥上传至服务器
- `cat ~/.ssh/id_rsa.pub | ssh user@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"`: 作用同上
- `tail -100 /var/log/secure`: 查看最近100条登录日志
- `who /var/log/wtmp`: 登录成功日志

## `.ssh/config` 文件的配置选项

- `AddressFamily inet`: 表示只使用 `IPv4` 协议. 如果设为 `inet6`, 表示只使用 `IPv6` 协议.
- `BindAddress 192.168.10.235`: 指定本机的 IP 地址 (如果本机有多个 IP 地址).
- `CheckHostIP yes`: 检查 SSH 服务器的 IP 地址是否跟公钥数据库吻合.
- `Ciphers blowfish,3des`: 指定加密算法.
- `Compression yes`: 是否压缩传输信号.
- `ConnectionAttempts 10`: 客户端进行连接时, 最大的尝试次数.
- `ConnectTimeout 60`: 客户端进行连接时, 服务器在指定秒数内没有回复, 则中断连接尝试.
- `DynamicForward 1080`: 指定动态转发端口.
- `GlobalKnownHostsFile /users/smith/.ssh/my_global_hosts_file`: 指定全局的公钥数据库文件的位置.
- `AuthorizedKeysFile .ssh/authorized_keys`: 密钥文件
- `Host server.example.com`: 指定连接的域名或 IP 地址, 也可以是别名, 支持通配符. `Host` 命令后面的所有配置, 都是针对该主机的, 直到下一个 `Host` 命令为止.
- `HostKeyAlgorithms ssh-dss,ssh-rsa`: 指定密钥算法, 优先级从高到低排列.
- `HostName myserver.example.com`: 在 `Host` 命令使用别名的情况下, `HostName` 指定域名或 IP 地址.
- `IdentityFile keyfile`: 指定私钥文件.
- `LocalForward 2001 localhost:143`: 指定本地端口转发.
- `LogLevel QUIET`: 指定日志详细程度. 如果设为 `QUIET`, 将不输出大部分的警告和提示.
- `MACs hmac-sha1,hmac-md5`: 指定数据校验算法.
- `NumberOfPasswordPrompts 2`: 密码登录时, 用户输错密码的最大尝试次数.
- `PasswordAuthentication no`: 指定是否支持密码登录. 不过, 这里只是客户端禁止, 真正的禁止需要在 SSH 服务器设置.
- `Port 2035`: 指定客户端连接的 SSH 服务器端口.
- `PreferredAuthentications publickey,hostbased,password`: 指定各种登录方法的优先级.
- `Protocol 2`: 支持的 SSH 协议版本, 多个版本之间使用逗号分隔.
- `PubKeyAuthentication yes`: 是否支持密钥登录. 这里只是客户端设置, 还需要在 SSH 服务器进行相应设置.
- `RemoteForward 2001 server:143`: 指定远程端口转发.
- `SendEnv COLOR`: SSH 客户端向服务器发送的环境变量名, 多个环境变量之间使用空格分隔. 环境变量的值从客户端当前环境中拷贝.
- `ServerAliveCountMax 3`: 如果没有收到服务器的回应, 客户端连续发送多少次 `keepalive` 信号, 才断开连接. 该项默认值为 3.
- `ServerAliveInterval 300`: 客户端建立连接后, 如果在给定秒数内, 没有收到服务器发来的消息, 客户端向服务器发送 `keepalive` 消息. 如果不希望客户端发送, 这一项设为 `0`.
- `StrictHostKeyChecking yes`: `yes` 表示严格检查, 服务器公钥为未知或发生变化, 则拒绝连接. `no` 表示如果服务器公钥未知, 则加入客户端公钥数据库, 如果公钥发生变化, 不改变客户端公钥数据库, 输出一条警告, 依然允许连接继续进行. `ask` (默认值) 表示询问用户是否继续进行.
- `TCPKeepAlive yes`: 客户端是否定期向服务器发送 `keepalive` 信息.
- `User userName`: 指定远程登录的账户名.
- `UserKnownHostsFile /users/smith/.ssh/my_local_hosts_file`: 指定当前用户的 `known_hosts` 文件 (服务器公钥指纹列表) 的位置.
- `VerifyHostKeyDNS yes`: 是否通过检查 SSH 服务器的 DNS 记录, 确认公钥指纹是否与 `known_hosts` 文件保存的一致.

## `/etc/ssh/sshd_config` 文件的配置选项

- `Port: 22`: ssh 服务监听的端口
- `PasswordAuthentication no`: 禁止使用密码登陆
- `PermitEmptyPasswords no`: 禁止空密码登陆
- `AllowUsers fsmythe bnice swilson`: 允许用户登录
- `DenyUsers jhacker joebadguy jripper`: 限制用户登录
- `PermitRootLogin no`: 禁止 root 用户登录
- `all:1.1.1.1`: 在 `/etc/hosts.deny` 中设置可以禁止某些 ip 访问

## 使用 *公钥认证* 登录远程主机的具体操作步骤

### 登录远程主机时使用 *ssh 公钥认证*

#### 秘钥生成

```bash
ssh-keygen -t rsa -C "你的邮箱地址"
```

经过此命令后会在 `~/.ssh` 文件夹中生成两个文件, `id_rsa.pub` 与 `id_rsa`, 分别是公钥与私钥

#### server 端公钥分配

要想本地端与远程端通过 ssh 建立连接的话, 那么远程端必须持有一份公钥, 可以使用 ftp 上传工具将秘钥以 `authorized_keys` 名称直接上传到远程端的 `~/.ssh` 目录, 也可以使用命令工具进行上传

```bash
brew install ssh-copy-id #使用 Homebrew 指令安装 ssh-copy-id
ssh-copy-id user@host #相应替换为你的远程主机用户名和 IP
```

或

```bash
scp ~/.ssh/id_rsa.pub username@hostname:~/ #将公钥文件复制至 vps 服务器
ssh username@hostname # 使用用户名和密码方式登录至 vps 服务器
mkdir .ssh  # 若.ssh 目录已存在, 可省略此步
cat id_rsa.pub >> .ssh/authorized_keys  #将公钥文件 id_rsa.pub 文件内容追加到 authorized_keys 文件
```

#### client 端私钥分配

在 `config` 中配置 ssh 别名, 之后就可以直接使用别名进行登录

```bash
Host Tencent-1C2G  # 别名 (可任意设置)
    HostName 122.51.83.9  # 主机名
    Port 66  # 连接端口 (默认是 22, 这里做了自定义, 避免被恶意攻击)
    User root  # 远程用户名
    IdentityFile  ~/.ssh/TencentServer  # 密钥文件的路径
    IdentitiesOnly yes # 只接受 SSH key 登录
```

配置完后即可使用 `ssh Tecent-1C2G` 进行快速登录远程主机.

#### server 端禁用 password 登录

在完成以上步骤后, 我们就可以通过 *密钥认证* 进行登录 (e.g. `ssh Tencent-1C2G`), 这时我们的 server 仍然可以通过 *密码认证* 的方式进行登录, 我们需要禁用 *密码认证*, 在确保我们已经有了一个可以 `密钥认证` 登录的 `root` 用户或可以执行 `sudo` 权限的用户后, 在 `server` 端执行以下操作

```sh
sudo vim /etc/ssh/sshd_config # 1. 编辑此文件
PasswordAuthentication no     # 2. 添加此行, 如果已经有此行被注释, 可直接解开注释
sudo service ssh restart      # 3. 重启 ssh, 在 centos 上为 sudo service sshd restart
```

#' '## 连接 GitHub 使用 *ssh 公钥认证* (gitlab 同理)

与连接到远程主机过程中使用 `ssh 秘钥` 不同, GitHub 的 `ssh 秘钥` 生成出来后是需要添加到 `ssh agent` 中的, 从 GitHub 的公钥与本地 `ssh agent` 中的私钥进行配对, 如果配对成功则能正确连接

#### 秘钥生成

```bash
ssh-keygen -t rsa -C "你的邮箱地址"
```

经过此命令后会在 `~/.ssh` 文件夹中生成两个文件, `id_rsa.pub` 与 `id_rsa`, 分别是公钥与私钥

为方便辨认, 将其名称修改为 `GitHub.pub` 与 `GitHub`

#### 公钥分配

将 `id_rsa.pub` 的内容复制到 GitHub 网页端.

#### 私钥分配

1. 在后台启动 ssh-agent

    ```bash
    eval "$(ssh-agent -s)"
    ```

2. 在 `~/.ssh/config` 文件中设置自动加到到 ssh-agent 并在 `keychain` 中存储秘钥.

    ```bash
    Host *
        IdentityFile ~/.ssh/GitHub # 将这些秘钥文件添加到验证队列中
        IdentityFile ~/.ssh/TencentServer
        # 验证成功后将对应的 key 添加到 ssh agent 中. 添加到 agent 之后不用在 ssh 秘钥有密码保护的情况下每次 github 上传都需要输入密码
        # (不过重启后仍然需要输入, 因为 agent 的 session 被清除了, 不过可以使用 Mac 的 keychain 服务来解决, 如下), 并且 agent 支持转发 (即 A
        # 登录服务器 B 不 exit 的情况下直接登录服务器 C)
        AddKeysToAgent yes
        # 验证成功后将对应的 key 添加到 keychain 中. 添加到 keychain 是为了避免在刚开机且 ssh agent 的 session 未被建立时要求输入 key 的密码 来解锁 key.
        UseKeychain yes

    Host Tencent-1C2G
        HostName 122.51.83.9
        Port 66
        User root
        IdentityFile  ~/.ssh/TencentServer
        IdentitiesOnly yes
    ```

3. 手动将 ssh 私钥添加到 `ssh-agent` 高速缓存中 (私钥一旦添加后, 对应的公钥也会被添加进来)

    ```bash
    ssh-add -K ~/.ssh/GitHub
    ```

    此步骤是立刻将 ssh key 加入到 `ssh agent`, 并添加到 `keychain` 中, 默认下, ssh agent 只是一个 session, 每次关机的时候 session 就会被清除, 再次开机时需要再次使用 `ssh-add` 添加, macOS 提供了 keychain, 将 `ssh key` 添加到 `keychain` 中后即可长久保存, 不需要每次手动 `ssh-add`

4. 连接完成, 为测试连接是否成功, 可使用 `ssh -T git@github.com`

### `known_hosts` 文件作用

服务端有公钥`/etc/ssh/ssh_host_rsa_key.pub` 与私钥 `/etc/ssh/ssh_host_rsa_key`, 在建立安全连接过程中, 服务器会提供自己的公钥给客户端, 客户端将其存储在 `~/.ssh/known_hosts` 中. 当下次访问相同计算机时, OpenSSH 会核对公钥. 如果公钥不同, OpenSSH 会发出警告, 避免你受到 DNS Hijack 之类的攻击.

有些时候, 一个远程主机经常换系统, 那么本地连接的时候有可能公钥就不同了, 但是 ip 是相同的, 这就会触发 `known_host` 的规则, 会报错, 解决办法就是直接删除 `known_host` 中的对应主机地址和公钥就可以了. 或者在 `config` 文件中加入一些配置 (基本不需要用到这一步, 用到时候再查吧)

## *FTP*, *SFTP*, *SCP*, *SSH*, *OpenSSH* 关系

### *SSH* 与 *OpenSSH*

- `SSH` (`Secure Shell`) :, 由 IETF 的网络工作小组 (Network Working Group) 所制定; SSH 为建立在应用层和传输层基础上的安全协议. SSH 是目前较可靠, 专为远程登录会话和其他网络服务提供安全性的协议. 利用 SSH 协议可以有效防止远程管理过程中的信息泄露问题.

    `SSH` 是由客户端和服务端的软件组成的: 服务端是一个守护进程 (daemon), 他在后台运行并响应来自客户端的连接请求. 服务端一般是 sshd 进程, 提供了对远程连接的处理, 一般包括公共密钥认证, 密钥交换, 对称密钥加密和非安全连接; 客户端包含 ssh 程序以及像 scp (远程拷贝), slogin (远程登陆), sftp (安全文件传输) 等其他的应用程序.

    从客户端来看, SSH 提供两种级别的安全验证:

    - 第一种级别 (基于口令的安全验证);
    - 第二种级别 (基于密匙的安全验证).

    `SSH` 主要有三部分组成: 传输层协议 `[SSH-TRANS]`; 用户认证协议 `[SSH-USERAUTH]`; 连接协议 `[SSH-CONNECT]`.

- `OpenSSH`: 是 SSH (Secure SHell) 协议的免费开源实现. SSH 协议族可以用来进行远程控制, 或在计算机之间传送文件. 而实现此功能的传统方式, 如 telnet(终端仿真协议),  rcp ftp,  rlogin, rsh 都是极为不安全的, 并且会使用明文传送密码. OpenSSH 提供了服务端后台程序和客户端工具, 用来加密远程控件和文件传输过程的中的数据, 并由此来代替原来的类似服务.  OpenSSH 是使用 SSH 透过计算机网络加密通讯的实现. 它是取代由 SSH Communications Security 所提供的商用版本的开放源代码方案. 目前 OpenSSH 是 OpenBSD 的子计划. OpenSSH 常常被误认以为与 OpenSSL 有关联, 但实际上这两个计划的有不同的目的, 不同的发展团队, 名称相近只是因为两者有同样的软件发展目标──提供开放源代码的加密通讯软件.

### *FTP* 与 *SFTP*, *SCP*

- *FTP (File Transfer Protocol)*: 是 TCP/IP 网络上两台计算机传送文件的协议, FTP 是在 TCP/IP 网络和 INTERNET 上最早使用的协议之一, 它属于网络协议组的应用层. FTP 客户机可以给服务器发出命令来下载文件, 上载文件, 创建或改变服务器上的目录. 相比于 HTTP, FTP 协议要复杂得多. 复杂的原因, 是因为 FTP 协议要用到两个 TCP 连接, 一个是命令链路, 用来在 FTP 客户端与服务器之间传递命令; 另一个是数据链路, 用来上传或下载数据. FTP 是基于 TCP 协议的, 因此 iptables 防火墙设置中只需要放开指定端口 (21 + PASV 端口范围) 的 TCP 协议即可.

    FTP 工作模式: PORT (主动) 方式的连接过程是: 客户端向服务器的 FTP 端口 (默认是 21) 发送连接请求, 服务器接受连接, 建立一条命令链路.  当需要传送数据时, 客户端在命令链路上用 PORT 命令告诉服务器: "我打开了一个 1024 + 的随机端口, 你过来连接我". 于是服务器从 20 端口向客户端的 1024 + 随机端口发送连接请求, 建立一条数据链路来传送数据.

    PASV (Passive 被动) 方式的连接过程是: 客户端向服务器的 FTP 端口 (默认是 21) 发送连接请求, 服务器接受连接, 建立一条命令链路. 当需要传送数据时, 服务器在命令链路上用 PASV 命令告诉客户端: "我打开了一个 1024 + 的随机端口, 你过来连接我". 于是客户端向服务器的指定端口发送连接请求, 建立一条数据链路来传送数据.

    PORT 方式, 服务器会主动连接客户端的指定端口, 那么如果客户端通过代理服务器链接到 internet 上的网络的话, 服务器端可能会连接不到客户端本机指定的端口, 或者被客户端, 代理服务器防火墙阻塞了连接, 导致连接失败

    PASV 方式, 服务器端防火墙除了要放开 21 端口外, 还要放开 PASV 配置指定的端口范围

- *SFTP (Secure File Transfer Protocol)*: 安全文件传送协议. 可以为传输文件提供一种安全的加密方法. sftp 与 ftp 有着几乎一样的语法和功能. SFTP 为 SSH 的一部份, 是一种传输文件到服务器的安全方式. 在 SSH 软件包中, 已经包含了一个叫作 SFTP(Secure File Transfer Protocol) 的安全文件传输子系统, SFTP 本身没有单独的守护进程, 它必须使用 sshd 守护进程 (端口号默认是 22) 来完成相应的连接操作, 所以从某种意义上来说, SFTP 并不像一个服务器程序, 而更像是一个客户端程序. SFTP 同样是使用加密传输认证信息和传输的数据, 所以, 使用 SFTP 是非常安全的. 但是, 由于这种传输方式使用了加密 / 解密技术, 所以传输效率比普通的 FTP 要低得多, 如果您对网络安全性要求更高时, 可以使用 SFTP 代替 FTP.

- *SCP (Secure Copy)*: scp 就是 secure copy, 是用来进行远程文件复制的, 并且整个复制过程是加密的. 数据传输使用 ssh, 并且和使用和 ssh 相同的认证方式, 提供相同的安全保证.

#### 区别

和 *ftp* 不同的是 *sftp/scp* 传输协议是采用加密方式来传输数据的. 而 *ftp* 一般来说允许明文传输, 当然现在也有带 SSL 的加密 ftp, 有些服务器软件也可以设置成 "只允许加密连接", 但是毕竟不是默认设置需要我们手工调整, 而且很多用户都会忽略这个设置.

普通 ftp 仅使用端口 21 作为命令传输. 由服务器和客户端协商另外一个随机端口来进行数据传送. 在 pasv 模式下, 服务器端需要侦听另一个端口.  假如服务器在路由器或者防火墙后面, 端口映射会比较麻烦, 因为无法提前知道数据端口编号, 无法映射.  (现在的 ftp 服务器大都支持限制数据端口随机取值范围, 一定程度上解决这个问题, 但仍然要映射 21 号以及一个数据端口范围, 还有些服务器通过 UPnP 协议与路由器协商动态映射, 但比较少见)

当你的网络中还有一些 unix 系统的机器时, 在它们上面自带了 scp/sftp 等客户端, 不用再安装其它软件来实现传输目的.

scp/sftp 属于开源协议, 我们可以免费使用不像 FTP 那样使用上存在安全或版权问题. 所有 scp/sftp 传输软件 (服务器端和客户端) 均免费并开源, 方便我们开发各种扩展插件和应用组件.

> 小提示: 当然在提供安全传输的前提下 sftp 还是存在一些不足的, 例如他的帐号访问权限是严格遵照系统用户实现的, 只有将该帐户添加为操作系统某用户才能够保证其可以正常登录 sftp 服务器

## 常见问题

### *Skipping ssh-dss key id_dsa - not in PubkeyAcceptedKeyTypes*

*openssh* 自 7.0 之后不再支持 *DSA* 类型的加密. 为避免报错, 请改用 *RSA* 类型加密

### authorized_keys 权限问题

如果 authorized_keys 没有正确的权限的话, 那么即使配置了正确的 key 也不能正常登录, 使用如下命令赋予权限

```zsh
chmod 755 ~
chmod 755 ~/.ssh
chmod 644 ~/.ssh/authorized_keys
```

## 参考

- [网道 ssh 教程](https://wangdoc.com/ssh/index.html)
