---
title: 简述网络协议与 iOS 下的网络请求
date: 2019-12-08
comments: true
path: communications-protocol-and-network-request-under-ios
categories: iOS
tags: ⦿ios, ⦿network, ⦿tcp/ip, ⦿websocket
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-01-19-101301.jpg?x-oss-process=style/WaMa)

<!-- more -->

在学习网络协议过程中, 我一直很迷惑各个协议之间的关系, 本文就是为了理解各协议的作用及联系. 下面的一段引用我认为非常经典, 多读几遍会让你有一个直观的印象

> 在我大万维网世界中, TCP 就像汽车, 我们用 TCP 来运输数据, 它很可靠, 从来不会发生丢件少件的现象. 但是如果路上跑的全是看起来一模一样的汽车, 那这个世界看起来是一团混乱, 送急件的汽车可能被前面满载货物的汽车拦堵在路上, 整个交通系统一定会瘫痪. 为了避免这种情况发生, 交通规则 HTTP 诞生了. HTTP 给汽车运输设定了好几个服务类别, 有 GET, POST, PUT, DELETE 等等, HTTP 规定, 当执行 GET 请求的时候, 要给汽车贴上 GET 的标签 (设置 method 为 GET), 而且要求把传送的数据放在车顶上 (url 中) 以方便记录. 如果是 POST 请求, 就要在车上贴上 POST 的标签, 并把货物放在车厢里. 当然, 你也可以在 GET 的时候往车厢内偷偷藏点货物, 但是这事很不光彩; 也可以在 POST 的时候在车顶上也放一些数据, 让人觉得傻乎乎的. HTTP 只是个行为准则, 而 TCP 才是 GET 和 POST 怎么实现的基本.
>
> 但是, 我们只看到 HTTP 对 GET 和 POST 参数的传送渠道 (url 还是 requrest body) 提出了要求. "标准答案"里关于参数大小的限制又是从哪来的呢?
>
> 在我大万维网世界中, 还有另一个重要的角色: 运输公司. 不同的浏览器 (发起 http 请求) 和服务器 (接受 http 请求) 就是不同的运输公司. 虽然理论上, 你可以在车顶上无限的堆货物 (url 中无限加参数). 但是运输公司可不傻, 装货和卸货也是有很大成本的, 他们会限制单次运输量来控制风险, 数据量太大对浏览器和服务器都是很大负担. 业界不成文的规定是, (大多数) 浏览器通常都会限制 url 长度在 2K 个字节, 而 (大多数) 服务器最多处理 64K 大小的 url. 超过的部分, 恕不处理. 如果你用 GET 服务, 在 request body 偷偷藏了数据, 不同服务器的处理方式也是不同的, 有些服务器会帮你卸货, 读出数据, 有些服务器直接忽略, 所以, 虽然 GET 可以带 request body, 也不能保证一定能被接收到哦.
>
> 好了, 现在你知道, GET 和 POST 本质上就是 TCP 链接, 并无差别. 但是由于 HTTP 的规定和浏览器 / 服务器的限制, 导致他们在应用过程中体现出一些不同.

## TCP/IP 协议族

互联网中各个设备要进行通信需要遵守统一的协议, 类比于人的话就像是说着不同语言的人如果没有一个能共同理解的语言, 则没有交流的可能性.  因此在网络协议中由国际标准化组织 ISO 定义了网络协议的框架 *OSI*, 这个框架分为 7 层, *应用层*, *表示层*, *会话层*, *传输层*, *网络层*, *数据链路层*, *物理层*. 目前网络中广泛采用的是 *TCP/IP* 协议, *TCP/IP* 协议有四层组成, *应用层*, *传输层*, *互联网络层*, *网络连接层*. 虽然层次减少了, 但是功能上并没有缩水. *TCP/IP* 协议中的应用层对应了 *OSI* 中的 *应用层*, *表示层*, *会话层*.

在 *TCP/IP* 协议中传输层的 TCP 协议与互联网络层的 IP 协议最为关键重要, 因此整个协议族被称为 *TCP/IP* 协议

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145026.jpg?x-oss-process=style/WaMa)

## TCP/IP 协议层次划分

在整个 *TCP/IP* 协议族中, *应用层* 负责内容的格式, *传输层* 负责内容的传输方式, *互联网络层* 负责网络的连接方式, *网络接口层* 负责网络设备的连接. iOS 开发中只需要关注 *应用层* 和 *传输层* 就足够了, 就好像写信的时候只需要关心书写的格式以及邮寄的方式 (使用快递还是邮局), 并不需要关注快递的路线及配送 ( 互联网络层 与 *网络接口层*).

### 应用层

相比于其它层 (*传输层*, *互联网络层*, *网络连接层*) 负责处理网络通信细节, *应用层* 只负责处理应用程序的逻辑. 其它层的实现位于 **内核** 中, 这样可以保证稳定高效. 而应用层则在 **用户空间** 中实现, 因为应用层逻辑众多, 如 `文件传输`, `名称查询`, `网络管理`, 如果全部在 `内核` 中实现的话会使得 `内核` 体积剧增.

- *HTTP*: Hypertext Transfer Protocol, 超文本传输协议, 主要用于普通浏览
- *HTTPS*: Hypertext Transfer Protocol over Secure Socket Layer, 安全超文本传输协议
- *FTP*: File Transfer Protocol, 文件传输协议
- *POP3*: Post Office Protocol, version3, 邮局协议, 用于收取邮件
- *SMTP*: Simple Mail Transfer Protocol, 简单邮件传输协议, 用于发送电子邮件
- *TELNET*: Teletype over the Network, 网络电传, 通过 Terminal 登录到服务器
- *SSH*: Secure Shell, 加密安全登录协议, 用于替代安全性差的 TELNET
- *BOOTP*: Boot Protocol, 启动协议
- *NTP*: Network Time Protocol, 网络时间协议, 用于网络同步
- *DHCP*: Dynamic Host Configuration, 动态主机配置协议, 用于动态配置 ip 地址
- *DNS*: Domain Name Service, 域名服务, 用于完成地址查找, 邮件转发等工作
- *ECHO*: Echo Protocol, 回绕协议, 用于查错及测量应答时间
- *SNMP*: Simple Network Management Protocol, 简单网络管理协议, 用于网络协议的收集和网络管理
- *ARP*: Address Resolution Protocol, 地址解析协议, 用于动态解析以太网硬件的地址

注: ping 是应用程序而不是协议

### 传输层

*传输层* 为两端上的应用程序提供 **端到端** 的通信. *传输层* 只关心通信的 **本地端** 和 **目的端**, 不在乎数据的中转过程.

- *TCP*: *TCP* 协议为 *应用层* 提供稳定的, 面向连接的 **基于流** 的服务. **超时重传**, **数据确认**(握手 & 挥手) 以保证数据被准确地传送到 **目的端**.  因此 *TCP* 协议及其可靠. 由于 *TCP* 协议是基于流的, 基于流的数据没有边界长度限制, 因此 *TCP* 协议可以源源不断地从一段传输到另一端.  因此发送端可以逐个字节的将数据写入流中, 与此同时的另一端 (目的端) 也可以逐个字节地接受数据并读出.
- *UDP*: *UDP* 协议与 *TCP* 协议天生相反, 为应用层提供的是不稳定, 无连接, 基于数据报的服务. 不稳定的含义是在传输过程中 *UDP* 不能保证由 *本地端* 发出的数据完整无错误地被目的端接收到. 如果数据丢失或者目的端通过数据校验发现数据错误而将其丢弃, *UDP* 协议会简单地通知本地端发送失败. 因此在使用 *UDP* 时需要手动编写处理数据确认以及超时重传等逻辑. *UDP* 协议是无连接的, 因此通信双方不保持长久的联系, 本地端发送数据需要明确目的端地址. 基于数据报的的服务是相对于基于流的服务而言的. 每个 *UDP* 数据报都有一个长度, 目的端必须以该长度的最小单位将其 **一次性** 输出, 否则数据将被切断.
- *SCTP*: 一种新型的传输层协议, 为了因特网上传输 **电话信号** 而设计的.
- *TLS/SSL*

### 互联网络层 (网络层)

*互联网络层* 实现数据包的选路和转发, 即数据在 `本地端` 发出后如何在广域网中选择合适的路线到达 `目的端`. 最核心协议为 IP 协议.

- *IP* (*IPv4* & *IPv6*): `IP` 协议根据数据的 `目的端` & `IP` 地址决定如何投递. 如果数据包不能直接发送到 `目的端`, 那么 *IP* 协议根据数据包的目的端 `IP` 地址寻找下一跳路由器, 并将数据包交付给该路由器转发, 多次重复这一过程直至数据包到达目的端, 或由于发送失败而被丢弃.
- *ICMP*: *IP* 协议的重要补充协议, 用于检测网络连接.

### 网络接口层 (数据链路层)

*网络接口层* 实现了网卡接口的网络驱动程序, 以处理数据在物理媒介上的传输. 不同的物理网络具有不同的电气特性, 网络驱动程序将这些不同的细节特性进行统一,
为上层协议提供统一接口, 以便于数据传输.

- *ARP*: *数据链路层* 使用 `物理地址` 寻址一台机器, *互联网络层* 使用 `IP 地址` 寻址一台机器, 因此 `ARP` 协议会将数据链路层传入的 `IP 地址` 转换为 物理地址, 然后 *网络接口层* 才能对数据进行正确传送.
- *RARP*: 仅适用于网络上某些无盘工作站上.

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145022.jpg?x-oss-process=style/WaMa)

## 各网络协议特点 & 区别

### HTTP 与 TCP 的关系与区别

首先, *HTTP* 协议中文译名为"超文本传输协议", 听起来是 *传输层*, 但是其定制者明确 Transfer 含义为"状态的转移", 因此 *HTTP* 协议属于 *应用层* 无误.

在我们传输数据的过程中, 可以不使用 *HTTP* 协议, 而只使用 *TCP* 协议, 这样的话数据确实可以传输到目的地, 但是传输的数据没有任何格式, 无法识别数据的内容, 这样的数据传输是没有意义的.

*HTTP* 协议只负责对数据格式进行封装, 其格式包括请求头, 请求行, 请求体等. *TCP/IP* 作为 *传输层* 协议将数据传输到目的地.

*HTTP* 协议是运行在 *TCP* 协议上的协议 (应用层协议都运行在传输层协议上), *TCP* 协议负责建立连接, 传输数据, 断开连接. 在 *TCP* 协议经过握手建立连接后, 即开始根据 HTTP 的给的指定标签 (get, post 等) 按照对应的方式传输数据

在 *HTTP* 数据交互的过程中, 每次请求都会要求服务器返回响应数据 (包括 *HTTP* 状态码等), 在一次请求结束后会主动释放连接 (即断开 *TCP* 连接).  这样的一次从建立到关闭连接的过程称为串行连接 (这里只讨论串行连接, 还有持久连接与管道化持久连接, 可以在请求结束后不立即断开 TCP 连接).  在这个过程中可以认为 *TCP* 协议就是一个车, 数据是车上的运输物品, *HTTP* 协议为车打上 `get`, `post` 等标签以区分状态 (这些标签决定了车辆是如何运送物资的).

既然 *HTTP* 是运行在 *TCP* 协议上的协议, 那么 *HTTP* 协议是否可以运行在其他的 *传输层* 协议上呢? 答案是可以的, *HTTP* 可以运行在任何能建立可靠连接的协议上, 所以理论上是不能建立在 *UDP* 协议上的 (但是如果硬要建立在 *UDP* 上理论上也是可以的, 但是估计没人会这么做)

### TCP 与 UDP 协议区别

- *TCP*: 流式, 需要建立连接, 复杂, 可靠, 有序, 可以进行大数据长时传输.
- *UDP*: 单个数据报, 不用建立连接, 简单, 不可靠, 会丢包, 会乱序, 最大传输数据为 64kB

*TCP* 与 *UDP* 的区别关键在于 *TCP* 需要三次握手才能建立连接, 因为需要三次握手, *TCP* 的效率比 *UDP* 慢, 但是可靠性高, 虽说网络的不安全不稳定特性决定了握多少次手都不能绝对保证可靠, 但是相对来说是很可靠了. 相比于 *TCP*, *UDP* 发送一个数据并不与对方建立连接, 而是直接丢过去, 发完后本地端也不知道是否发送成功, 当然也就不需要重发了.

MSN 采用的是 TCP 传输协议, QQ 采用 UDP 协议, 因此 MSN 传输文件比 QQ 慢, 但是不能说 QQ 是不安全的通信, 因为程序员可以对 UDP 的数据收发进行验证.

运行在 TCP 协议上的应用层协议:

- *HTTPS*: Hypertext Transfer Protocol over Secure Socket Layer, 安全超文本传输协议
- *FTP*: File Transfer Protocol, 文件传输协议
- *POP3*: Post Office Protocol, version3, 邮局协议, 用于收取邮件
- *SMTP*: Simple Mail Transfer Protocol, 简单邮件传输协议, 用于发送电子邮件
- *TELNET*: Teletype over the Network, 网络电传, 通过 Terminal 登录到服务器
- *SSH*: Secure Shell, 加密安全登录协议, 用于替代安全性差的 TELNET

运行在 UDP 协议上的应用层协议:

- *BOOTP*: Boot Protocol, 启动协议
- *NTP*: Network Time Protocol, 网络时间协议, 用于网络同步
- *DHCP*:  Dynamic Host Configuration, 动态主机配置协议, 用于动态配置 ip 地址
- *DNS*: Domain Name Service, 域名服务, 用于完成地址查找, 邮件转发等工作
- *ECHO*:  Echo Protocol, 回绕协议, 用于查错及测量应答时间
- *SNMP*: Simple Network Management Protocol, 简单网络管理协议, 用于网络协议的收集和网络管理
- *ARP*: Address Resolution Protocol, 地址解析协议, 用于动态解析以太网硬件的地址

### HTTP 与 HTTPS 的区别

- *HTTPS* = *HTTP* + *ssl*
- *HTTP* 是明文传输, *HTTPS* 是具有安全性的加密传输
- *HTTP* 端口是 `80`, *HTTPS* 端口是 `403`
- *HTTPS* 协议需要到 CA 申请证书, 一般需要付费, 而且证书有认证期限

## HTTPS 原理及特点

> 公钥加密, 私钥解密; 私钥签名, 公钥验签 <https://www.zhihu.com/question/25912483/answer/46649199>

因为非对称加密比较耗费资源, 因此 *HTTPS* 的解决方案是只对 `sessionKey` 进行非对称加密, 当两端都持有 `sessionKey` 后就都是用对称加密对信息进行加密

### HTTPS 连接流程

1. 浏览器首先向服务器发起请求
2. 服务器响应浏览器, 并将自己的证书传递给浏览器,
3. 浏览器验证根据系统已信任的证书机构确定是否是有效证书, 如果有效则从证书得到公钥
4. 浏览器生成 `sessionKey`, 用证书中的公钥加密这个 `sessionKey`, 然后将其发送到服务器 (这个 key 今后会被用来用作对称加密)
5. 服务器使用自身私钥解密出 `sessionKey`
6. 后续的传输只需要建立在 *http* 上, 双方都使用这个 `sessionKey` 做对称加解密就能完成整个通信

![himg](https://a.hanleylee.com/HKMS/2020-03-03-160021.jpg?x-oss-process=style/WaMa)

完整的流程就是这样, 这样做的意义是什么呢? 如果使用 *HTTP* 进行信息传送的话, 上面的连接流程就很简单了, 就是客户端发送信息, 服务器接收信息, 或者相反的方向传递. 但是这样的话很容易被不法分子劫持了信息, 然后篡改, 再将篡改后的信息发送给另一方, 这样的话是极其不安全的.

### HTTPS 的中间人攻击 - MitM

*MitM* 全称为 *Man in the Middle*, 字面理解就是有一个人在中间, 以一种类似于 **传话** 的性质对信息进行传递 (当然在这个过程中信息是不安全的), 如下图:

![himg](https://a.hanleylee.com/HKMS/2020-03-03-MitM.jpg?x-oss-process=style/WaMa)

这里以 Surge 的 *MitM* 特性为例, Surge 通过提前在系统中安装一个证书并请求系统信任 (信任很重要, 信任后将会在 macOS 预装的信任清单中增加一个自定义信任证书源, 必须手动信任, 否则 Surge 的 *MitM* 功能不会生效), 然后在 *MitM Hostnames* 中加入要被 MitM 的域名 (或主机地址)

![himg](https://a.hanleylee.com/HKMS/2020-03-03-152211.png?x-oss-process=style/WaMa)

此时我们访问 <https://hanleylee.com>, 打开浏览器的证书链显示, 就可以在证书链中看到 Surge 的证书

![himg](https://a.hanleylee.com/HKMS/2020-03-03-152450.png?x-oss-process=style/WaMa)

这个证书链说明, Mac 的网络请求发送给掌管全局的 Surge, Surge 返回一个公钥 1(ssl 证书) 给系统, 因为系统信任了这个证书, 因此通道被建立. 另一方面, Surge 将从 Mac 系统来的请求发送到域名 <https://hanleylee.com> 所在的服务器, 服务器向 Surge 返回了公钥 2(ssl 证书), 这是 Surge 将公钥 2 附在了公钥 1 之下, 因此就有了我们上面看到的这张图.

> 在我们对 iOS 模拟器的网络进行调试时, 如果不在 iOS 模拟器上安装信任证书, 那么 iOS 模拟器的请求发送到 Mac 上掌管全局的 Surge 时, Surge 尝试向 iOS 模拟器返回一个公钥, 但是这个公钥并没有被 iOS 模拟器信任, 那么 iOS 的网络连接就会直接死掉, 而此时 Surge 也不会再向 iOS 模拟器要请求的服务器端发送任何请求

### HTTPS 的证书验证

网站的证书会在 https 握手过程中被传递到浏览器, 浏览器从网站证书中找到了颁发者, 从颁发者的证书又找到了 CA(Certificate Authority) 的证书 (CA 证书会在操作系统安装时就安装好, 所以每个人电脑上都有根证书), 使用 CA 证书中带的公钥来对颁发者证书做验签, 一旦匹配, 说明网站的颁发者证书不是伪造的, 同理, 再用颁发者证书中的公钥去验证网站的证书, 以此证明网站证书不是伪造的.

这样整个链状的验证, 从而确保网站的证书一定是直接或间接从 CA 签发的, 这样浏览器地址栏会显示一个绿色的盾牌, 表示你的网站能通过证书验证.

[iOS 12, macOS 10.14, watchOS 5 及 tvOS 12 可用的受信任根憑證清單](https://support.apple.com/zh-hk/HT209144)

## TCP 协议的连接建立及断开过程

![himg](https://a.hanleylee.com/HKMS/2020-03-05-085015.jpg?x-oss-process=style/WaMa)

### 建立连接 - TCP 协议的三次握手

1. **第一次握手**: 客户端向服务器端发送连接请求包 `SYN=1(seq=x)`, 等待服务器回应;
2. **第二次握手**: 服务器端收到请求包后, 将客户端的请求包 `SYN=1(seq=x)` 放入到自己的未连接队列, 此时服务器需要发送两个包给客户端 (此时服务器进入 `SYN_RECV` 状态.):
    - 向客户端发送确认自己收到其连接请求的确认包 `ACK=1(ack=x+1)`, 向客户端表明已知道了其连接请求
    - 向客户端发送连接询问请求包 `SYN=1(seq=y)`, 询问客户端是否已经准备好建立连接, 进行数据通信;
3. **第三次握手**: 客户端收到服务器的包后, 知道服务器同意建立连接; 向服务器发送连接建立的确认包 `ACK=1(ack=y+1)`, 回应服务器的 `SYN(seq=y)` 告诉服务器, 我们之间已经建立了连接, 可以进行数据通信.

`ACK=1(ack=y+1)` 包发送完毕, 服务器收到后, 此时服务器与客户端进入 `ESTABLISHED` 状态, 开始进行数据传送.

### TCP 连接三次握手原因

- 如果只有一次握手的话, client 不知道 server 是不是收到了这个请求.
- 如果只有两次握手的话, server 需要在第一次收到请求后立刻将自身置为连接状态, 这种情况下 server 有可能收到一个早已失效的报文(已经被 client 放弃了的), 并发出建立连接请求, 白白耗费资源

    client 发出的第一个连接请求报文段并没有丢失, 而是在某个网络结点长时间的滞留了, 以致延误到连接释放以后的某个时间才到达 server. 本来这是一个早已失效的报文段. 但 server 收到此失效的连接请求报文段后, 就误认为是 client 再次发出的一个新的连接请求. 于是就向 client 发出确认报文段, 同意建立连接, 新的连接就建立了. 由于现在 client 并没有发出建立连接的请求, 因此不会理睬 server 的确认, 也不会向 server 发送数据. 但 server 却以为新的运输连接已经建立, 并一直等待 client 发来数据. 这样, server 的很多资源就白白浪费掉了.

    采用三次握手的办法可以防止上述现象发生. 例如刚才那种情况, client 不会向 server 的确认发出确认. server 由于收不到确认, 就知道 client 并没有要求建立连接.

### 断开连接 - TCP 协议的四次挥手

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145023.jpg?x-oss-process=style/WaMa)

> - seq:(Sequence Number): 本报文段数据的第一个字节的序号
> - ack:(Acknowledgment Number): 确认号——期望收到对方下个报文段的第一个数据字节的序号
> - SYN(synchronize): 请求同步标志——用于建立和释放连接, 当 SYN=1 时, 表示建立连接.
> - ACK(acknowledge): 确认标志——仅当 ACK=1 时确认号字段才有效. 建立 TCP 连接后, 所有报文段都必须把 ACK 字段置为 1.
> - FIN(Finally): 结束标志——用于释放连接, 当 FIN=1, 表明发送方已经发送完毕, 要求释放 TCP 连接.

1. Client 向 Server 发送断开连接请求的报文段, `seq=m` (m 为 Client 最后一次向 Server 发送报文段的最后一个字节序号加 1), Client 进入 `FIN-WAIT-1` 状态.
2. Server 收到断开报文段后, 向 Client 发送确认报文段, `seq=n` (n 为 Server 最后一次向 Client 发送报文段的最后一个字节序号加 1), `ack=m+1`, Server 进入 `CLOSE-WAIT` 状态. 此时这个 TCP 连接处于半开半闭状态, Server 发送数据的话, Client 仍然可以接收到.
3. Server 向 Client 发送断开确认报文段, `seq=u` (u 为半开半闭状态下 Server 最后一次向 Client 发送报文段的最后一个字节序号加 1), `ack=m+1`, Server 进入 `LAST-ACK` 状态.
4. Client 收到 Server 的断开确认报文段后, 向 Server 发送确认断开报文, `seq=m+1`, `ack=u+1`, Client 进入 `TIME-WAIT` 状态.
5. Server 收到 Client 的确认断开报文, 进入 `CLOSED` 状态, 断开了 TCP 连接.
6. Client 在 `TIME-WAIT` 状态等待一段时间 (时间为 2*MSL(Maximum Segment Life)), 确认 Client 向 Server 发送的最后一次断开确认到达 (如果没有到达, Server 会重发步骤 (3) 中的断开确认报文段给 Client, 告诉 Client 你的最后一次确认断开没有收到). 如果 Client 在 `TIME-WAIT` 过程中没有再次收到 Server 的报文段, 就进入 `CLOSES` 状态. TCP 连接至此断开.

### tcp 断开连接需要四次握手原因

TCP 连接是全双工通道, 需要双向关闭. client 向 server 发送关闭请求, 表示 client 不再发送数据, server 响应. 此时 server 端仍然可以向 client 发送数据, 待 server 端发送数据结束后, 就向 client 发送关闭请求, 然后 client 确认.

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145023.jpg?x-oss-process=style/WaMa)

## HTTP 请求

### HTTP 通讯过程

每次 *HTTP* 的一个 `request` 完成后都必然会有一个对应的 `response`

#### 请求格式

- 请求行

    包含了请求方法, 请求资源路径, *HTTP* 协议版本

    格式: `GET /MJServer/resources/images/1.jpg HTTP/1.1`

- 请求头

    包含了对客户端的环境描述, 客户端请求的主机地址等信息

    - `Host: 192.168.1.105:8080` // 客户端想访问的服务器主机地址
    - `User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9) Firefox/30.0` // 客户端的类型, 客户端的软件环境
    - `Content-Type: application/xhtml+xml` // 本机发送的参数格式
        - `application/xhtml+xml`: XHTML 格式
        - `application/xml`:  XML 数据格式
        - `application/atom+xml`: Atom XML 聚合格式
        - `application/json`:  JSON 数据格式
        - `application/pdf`: pdf 格式
        - `application/msword`: Word 文档格式
        - `application/octet-stream`:  二进制流数据 (如常见的文件下载)
        - `application/x-www-form-urlencoded`: `<form encType="">` 中默认的 encType, form 表单数据被编码为 key/value 格式发送到服务器 (表单默认的提交数据的格式)
    - `Accept: text/html, */*` // 客户端所能接收的数据类型
        - `text/html`:  HTML 格式
        - `text/plain`: 纯文本格式
        - `text/xml`:   XML 格式
        - `image/gif`: gif 图片格式
        - `image/jpeg`: jpg 图片格式
        - `image/png`: png 图片格式
    - `Accept-Language: zh-cn` // 客户端的语言环境
    - `Accept-Encoding: gzip` // 客户端支持的数据压缩格式

- 请求体

    客户端发给服务器的具体数据, 比如文件数据

#### 响应格式

- 状态行

    包含了 HTTP 协议版本, 状态码, 状态英文名称

    格式: `HTTP/1.1 200 OK`

- 响应头

    包含了对服务器的描述, 对返回数据的描述

    ```txt
    Server: Apache-Coyote/1.1 // 服务器的类型
    Content-Type: image/jpeg // 返回数据的类型
    Content-Length: 56811 // 返回数据的长度
    Date: Mon, 23 Jun 2014 12:54:52 GMT // 响应的时间
    ```

- 实体内容

    服务器返回给客户端的具体数据, 比如文件数据

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-145028.jpg?x-oss-process=style/WaMa)

- 常见的响应状态码

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-145027.jpg?x-oss-process=style/WaMa)

### 发送 HTTP 请求的方法

在 HTTP/1.1 协议中, 一共定义了 8 种 HTTP 请求的方法

1. *PUT* (增): 上传资源
2. *DELETE* (删): 删除指定的资源
3. *POST* (改): 用于将实体提交到指定的资源, 通常导致在服务器上的状态变化或副作用
4. *GET* (查): 请求一个指定资源的表示形式. 使用 GET 的请求应该只被用于获取数据
5. *OPTIONS*: 返回服务器支持的 HTTP 方法
6. *HEAD*: 与 get 完全相同, 但没有响应体
7. *TRACE*: 沿着到目标资源的路径执行一个消息环回测试
8. *PATCH*: 用于对资源应用部分修改

> `CONNECT`: 将请求连接转换到透明的 tcp/ip

### GET 与 POST 区别

- *GET* 是 **安全的**, **幂等的**, **可缓存的**, *POST* 是 **不安全的**, **不幂等的**, **不可缓存的**
    - 安全: 不应引起 server 端的任何变化 (*HEAD* *OPTION* 都是安全的, 但是 *POST* 语义是提交数据, 是可能引起服务器状态变化的, 及不安全)
    - 幂等: 同一个请求方法执行多次和一次的效果完全相同
    - 可缓存: 请求是否可缓存
- *GET* 的网页会被浏览器主动 cache, 除非手动设置
- *GET* 的请求参数会完整保存在浏览器历史记录中, 但是 *POST* 不会保存完整
- *GET* 请求只能进行 url 编码, 但是 *POST* 可以使用 url 编码在内的 json 等编码方式
- *GET* 的参数会暴露在 url 上, 不仅不美观而且长

*GET* 与 *POST* 都能做到增删改查, 但是根据传递数据的不同需要选择不同的请求方法

1. 常识错误

    网上说 *GET* 数据大小不能大于 2k, 实际上不是 http 规定的, 而是浏览器和服务器通常的规定, 某些浏览器和服务器是支持的, 因此这个说法是错的

    *GET* 的数据只能放在 url 中也是错的, 可以放在 body 中, 但是很多网站一旦识别到 *GET* 请求后, 会直接忽略 body 内容. 目前我是用的是 paw, paw 会自动忽略 *GET* 请求的 body 内容!

    总结: 归根结底, *GET* 与 *POST* 没有本质的区别, 都是在 tcp 层进行传输的, HTTP 规定了 *GET* 参数在 url 中, *POST* 参数在 body 中, 但是可以不遵守规定.  这个规定导致了浏览器以及网站有了 *GET* 的 url 长度不能超过 2k 的规定.

2. 选择
    - 如果要传递大量数据, 比如文件上传, 只能用 *POST* 请求
    - *GET* 的安全性比 *POST* 要差些, 因为会在地址中将参数显示出来, 如果包含机密, 敏感信息, 建议用 *POST*
    - 如果仅仅是索取数据 (数据查询), 建议使用 *GET*
    - 如果是增加, 修改, 删除数据, 建议使用 *POST*

> 在我大万维网世界中, TCP 就像汽车, 我们用 TCP 来运输数据, 它很可靠, 从来不会发生丢件少件的现象. 但是如果路上跑的全是看起来一模一样的汽车, 那这个世界看起来是一团混乱, 送急件的汽车可能被前面满载货物的汽车拦堵在路上, 整个交通系统一定会瘫痪. 为了避免这种情况发生, 交通规则 HTTP 诞生了. HTTP 给汽车运输设定了好几个服务类别, 有 GET, POST, PUT, DELETE 等等, HTTP 规定, 当执行 GET 请求的时候, 要给汽车贴上 GET 的标签 (设置 method 为 GET), 而且要求把传送的数据放在车顶上 (url 中) 以方便记录. 如果是 POST 请求, 就要在车上贴上 POST 的标签, 并把货物放在车厢里. 当然, 你也可以在 GET 的时候往车厢内偷偷藏点货物, 但是这是很不光彩; 也可以在 POST 的时候在车顶上也放一些数据, 让人觉得傻乎乎的. HTTP 只是个行为准则, 而 TCP 才是 GET 和 POST 怎么实现的基本.
>
> 但是, 我们只看到 HTTP 对 GET 和 POST 参数的传送渠道 (url 还是 requrest body) 提出了要求. "标准答案"里关于参数大小的限制又是从哪来的呢?
>
> 在我大万维网世界中, 还有另一个重要的角色: 运输公司. 不同的浏览器 (发起 http 请求) 和服务器 (接受 http 请求) 就是不同的运输公司.  虽然理论上, 你可以在车顶上无限的堆货物 (url 中无限加参数). 但是运输公司可不傻, 装货和卸货也是有很大成本的, 他们会限制单次运输量来控制风险, 数据量太大对浏览器和服务器都是很大负担. 业界不成文的规定是, (大多数) 浏览器通常都会限制 url 长度在 2K 个字节, 而 (大多数) 服务器最多处理 64K 大小的 url. 超过的部分, 恕不处理.  如果你用 GET 服务, 在 request body 偷偷藏了数据, 不同服务器的处理方式也是不同的, 有些服务器会帮你卸货, 读出数据, 有些服务器直接忽略, 所以, 虽然 GET 可以带 request body, 也不能保证一定能被接收到哦.
>
> 好了, 现在你知道, GET 和 POST 本质上就是 TCP 链接, 并无差别. 但是由于 HTTP 的规定和浏览器 / 服务器的限制, 导致他们在应用过程中体现出一些不同.

## DNS

*DNS* 是域名到 `IP` 地址的映射, *DNS* 解析请求采用 *UDP* 数据报, 且明文

### 解析方式

- *递归查询*: 不断向上级 DNS 服务请查询请求
- *迭代查询*: 告诉用户哪个 DNS 服务器有可能知道, 让用户自己去查

### DNS 劫持

![himg](https://a.hanleylee.com/HKMS/2021-10-02213714.png?x-oss-process=style/WaMa)

#### DNS 劫持与 HTTP 关系

没有关系, DNS 解析发生在 HTTP 链接简历之前, 且 DNS 使用 UDP 数据包, 端口号 53

#### 如何避免 DNS 劫持

- **httpDNS**: 查询 dnspods 该域名对应的 ip
- **长连接**: 连接自己的代理服务器, 让没受到劫持的代理服务器去查询对应的 ip

## Socket

*Socket* 是对 TCP/IP 协议的封装, Socket 本身并不是协议, 而是一个调用接口 (API), 通过 Socket, 我们才能使用 TCP/IP 协议. 实际上, Socket 跟 TCP/IP 协议没有必然的联系.

*Socket* 编程接口在设计的时候, 就希望也能适应其他的网络协议. 所以说, *Socket* 的出现只是使得程序员更方便地使用 TCP/IP 协议栈而已, 是对 TCP/IP 协议的抽象, 从而形成了我们知道的一些最基本的函数接口, 比如 create, listen, connect, accept, send, read 和 write 等等.

网络有一段关于 socket 和 TCP/IP 协议关系的说法比较容易理解:

> TCP/IP 只是一个协议栈, 就像操作系统的运行机制一样, 必须要具体实现, 同时还要提供对外的操作接口. 这个就像操作系统会提供标准的编程接口, 比如 win32 编程接口一样, TCP/IP 也要提供可供程序员做网络开发所用的接口, 这就是 Socket 编程接口.

CSDN 上有个比较形象的描述:

> HTTP 是轿车, 提供了封装或者显示数据的具体形式; Socket 是发动机, 提供了网络通信的能力.

实际上, 传输层的 *TCP* 是基于网络层的 *IP* 协议的, 而应用层的 *HTTP* 协议又是基于传输层的 *TCP* 协议的, 而 *Socket* 本身不算是协议, 就像上面所说, 它只是提供了一个针对 *TCP* 或者 *UDP* 编程的接口.

## 短轮询, 长轮询, 长连接

### 短轮询

重复发送 Http 请求, 查询目标事件是否完成, 不论结果是否与上次有变化都会查询.

- 优点: 编写简单
- 缺点: 浪费带宽与服务器资源

### 长轮询

- `long poll`. 每次向服务器发送请求后, 如果服务器暂时没有新数据要返回, 则服务器暂时不返回 response, 直至有新数据为止 (或者 timout 了))

- 优点: 无消息情况下不会频繁请求
- 缺点: 编写复杂

### 长连接

HTTP1.1 规定了默认保持长连接 (HTTP persistent connection, 也有翻译为持久连接), 数据传输完成了保持 TCP 连接不断开 (不发 RST 包, 不四次挥手), 等待在同域名下继续用这个通道传输数据; 相反的就是短连接

如果服务器没有告诉客户端超时时间也没关系, 服务端可能主动发起四次挥手断开 TCP 连接, 客户端能够知道该 TCP 连接已经无效; 另外 TCP 还有心跳包来检测当前连接是否还活着, 方法很多, 避免浪费资源.

HTTP 请求时, `request header` 默认含有 `Connection: Keep-Alive`, 但是最终是否为长链接是由 server 返回的 `reponse header` 这些标签决定了车辆是如何运送物资的

```text
telnet my.server.net 80
Trying X.X.X.X...
Connected to my.server.net.
GET /homepage.html HTTP/1.0
Connection: keep-alive
Host: my.server.net

HTTP/1.1 200 OK
Date: Thu, 03 Oct 2013 09:05:28 GMT
Server: Apache
Last-Modified: Wed, 15 Sep 2010 14:45:31 GMT
ETag: "1af210b-7b-4904d6196d8c0"
Accept-Ranges: bytes
Content-Length: 123
Vary: Accept-Encoding
Keep-Alive: timeout=15, max=100
Connection: Keep-Alive
Content-Type: text/html
```

其中的 `Keep-Alive` 中的 `timeout=15` 表示可接受的超时长度为 15 秒 (超过就会主动断开), `max=100` 表示可使用本 tcp 连接建立 http 的最多次数 (也就是重复利用次数)

> 如果不指定 timeout 时, 默认值为 60s

## WebSocket

如上所述, 传统的 *HTTP* 是单次 `request` 对应单次 `response`, 而且每次的数据都必须由客户端发起, 服务器不会主动推送数据.

虽然 *HTTP* 也有"长连接", 即 `keep-alive`, 但是这个"长连接"并不是真正的长连接, 其只是在一次 *TCP* 连接中客户端可以发送多个 `request`, 然后获得服务端的多个 `response`, *HTTP* 的 `request = response`, 即一次请求一定对应一次回应, 这是不变的. 因此在这两种方案中, 每次的 `request` 中必然要携带 `header`, 这样就造成了客户端与服务端处理效率的低下

于是, `HTML5` 时代提供了一项新的浏览器与服务器间进行全双工通讯的网络技术 - *WebSocket*. *WebSocket* 与 *HTTP* 类似, 同样是跑在 *TCP* 协议上的一种协议.  在初始建立连接时也是先经历 *TCP/IP* 协议的握手, 然后客户端发出建立 *WebSocket* 协议连接的请求, 请求建立后就会一直存在, 然后在连接存在时服务端可不经过客户端请求而直接向客户端推送数据, 直至客户端与服务端的任意一端主动切断连接为止.

### WebSocket 与 HTTP 的关系

*WebSocket* 就是为长连接而诞生的, 可以理解为 *HTTP* 协议的持久化补充. 在 *WebSocket* 第一次与服务端连接时, 发送的是 *HTTP request* (不过这个 `request` 的 `header` 会声明使用的是 *WebSocket* 协议, 并要求服务端也升级到 *WebSocket* 协议), 在建立连接后, 之后的交换数据都不需要再发送 `HTTP request` 了.

![himg](https://a.hanleylee.com/HKMS/2020-04-06-124329.jpg?x-oss-process=style/WaMa)

上面的请求与回应只会在第一次建立 *WebSocket* 连接时执行一次, 使用的是 *HTTP* 协议进行的, 在成功建立了 *WebSocket* 连接后, *HTTP* 协议也就完成任务了 (可以理解为过河拆桥), 之后就完全按照 *WebSocket* 协议的规定进行数据流的推送了.

### WebSocket 连接流程

![himg](https://a.hanleylee.com/HKMS/2020-04-06-124356.jpg?x-oss-process=style/WaMa)

1. *Browser* 与 *WebSocket* 服务器通过 *TCP* 三次握手建立连接, 如果这个建立连接失败, 那么后面的过程就不会执行, *Web* 应用程序将收到错误消息通知.
2. 在 *TCP* 建立连接成功后, *Browser/UA* 通过 *HTTP* 协议传送 *WebSocket* 支持的版本号, 协议的字版本号, 原始地址, 主机地址等等一些列字段给服务器端.

    ```txt
    GET /chat HTTP/1.1
    Host: server.example.com
    Upgrade: websocket                                 # 声明使用的协议是 WebSocket 协议
    Connection: Upgrade                                # 要求服务端也升级到 WebSocket 协议
    Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==        # 用于验证服务器的 WebSocket 是否为真的 WebSocket 协议
    Sec-WebSocket-Protocol: chat, superchat            # 自定义的字段, 声明要支持的服务
    Sec-WebSocket-Version: 13                          # WebSocket 版本
    Origin: http://example.com
    ```

3. *WebSocket* 服务器收到 *Browser/UA* 发送来的握手请求后, 如果数据包数据和格式正确, 客户端和服务器端的协议版本号匹配等等, 就接受本次握手连接, 并给出相应的数据回复, 同样回复的数据包也是采用 *HTTP* 协议传输.

    ```txt
    HTTP/1.1 101 Switching Protocols                   # 通知客户端切换了协议
    Upgrade: websocket                                 # 声明本服务端现在使用的协议是 WebSocket 协议
    Connection: Upgrade                                # 声明已经升级了
    Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk= # 加密后的 key, 用于验证 WebSocket 协议
    Sec-WebSocket-Protocol: chat                       # 表示最终使用的协议
    ```

4. Browser 收到服务器回复的数据包后, 如果数据包内容, 格式都没有问题的话, 就表示本次连接成功, 触发 `onopen` 消息, 此时 Web 开发者就可以在此时通过 `send` 接口想服务器发送数据. 否则, 握手连接失败, Web 应用程序会收到 `onerror` 消息, 并且能知道连接失败的原因.

> 客户端的 WebSocket 对象一共绑定了四个事件:
>
> 1. onopen: 连接建立时触发;
> 2. onmessage: 收到服务端消息时触发;
> 3. onerror: 连接出错时触发;
> 4. onclose: 连接关闭时触发;

### WebSocket 心跳包的作用

*WebSocket* 虽然解决了服务器和客户端两边的问题, 但是网络应用除了服务器和客户端之外, 另一个巨大的存在是中间的网络链路. 一个 *HTTP/WebSocket* 连接往往要经过无数的路由, 防火墙. 你以为你的数据是在一个连接中发送的, 实际上它要跨越千山万水, 经过无数次转发, 过滤, 才能最终抵达终点. 在这过程中, 中间节点的处理方法很可能会让你意想不到.

比如, 有些中间节点会认为一份连接在一段时间内没有数据发送就等于失效, 这些节点会自作主张的切断这些连接. 在这种情况下, 不论服务器还是客户端都不会收到任何提示, 它们只会一厢情愿的以为彼此间的连接还在, 徒劳地发送抵达不了彼岸的信息.  而计算机网络协议栈的实现中又会有一层套一层的缓存, 除非填满这些缓存, 你的程序根本不会发现任何错误. 这样, 本来一个美好的 WebSocket 长连接, 就可能在毫不知情的情况下进入了半死不活状态.

为了处理这种问题, *WebSocket* 的设计者设计出了心跳包的存在, 心跳包是一种特殊的数据包, 其内并不包含真正的数据, 而是一些元数据, 客户端可以每隔一段时间就发送一个心跳包以维持住与服务端的稳定连接.

连接 → 数据传输 → 保持连接 (心跳) → 数据传输 → 保持连接 (心跳) → …… → 关闭连接

## 一次完整的浏览器根据 URL 请求网页的过程

1. 检查此 URL 是否有在本地 (浏览器) 的缓存; 有的话直接打开缓存 (什么 TCP 和 HTTP 连接, 啥都不用考虑了), 没有的话进入下一步

    ![himg](https://a.hanleylee.com/HKMS/2020-02-28-133905.png?x-oss-process=style/WaMa)

2. 根据 URL 中的域名按照以下顺序查找是否缓存过对应域名的 ip 地址, 最终获得对应的 ip
    1. 浏览器缓存
    2. 操作系统缓存, 电脑的 hosts 文件
    3. 本地服务器 (LDNS)
    4. Root Server

    ![himg](https://a.hanleylee.com/HKMS/2020-02-28-133005.jpg?x-oss-process=style/WaMa)

3. 与第二步的 ip 服务器建立 TCP 连接通道 (三次握手)
4. 发送 url 的请求 (一般是 get 标签), 并获得从服务器的回应 (html 格式的网页数据就包含在回应的 `实体内容` 中)

    ![himg](https://a.hanleylee.com/HKMS/2020-02-28-133432.jpg?x-oss-process=style/WaMa)

    ![himg](https://a.hanleylee.com/HKMS/2020-02-29-HTTP%20from%20Browser.png?x-oss-process=style/WaMa)

5. 一次 HTTP 请求完成, 通过四次挥手来断开 TCP 连接 (如果是 HTTP 持久连接的话也有可能不断开)

## Cookie 与 Session

- *Cookie*: 用于记录用户状态, 区分用户, 状态保存在客户端
- *Session*: 也是用来记录用户状态, 状态存放在服务器端

HTTP 是无状态协议, 就是指这一次请求和上一次请求没有任何关系, 没有关联, 这样的好处是快速. 但有时我们又需要某个域名下的所有网站能够共享某些数据 (一个用户的所有请求操作都应该属于同一个会话), 于是 `cookie` 和 `session` 就出现了.

流程:

- 客户端发送一个 HTTP 请求到服务端
- 服务端接收到客户端请求后, 建立一个 session, 并发送一个 HTTP 响应到客户端, 这个响应头, 其中包含了 Set-Cookie 头部. 该头部包含了 SessionID, 会在客户端设置一个属于这个域名下的 cookie
- 在客户端发起第二次请求时, 浏览器会自动在请求头中添加 cookie(包括 SessionID)
- 服务器接收请求, 分解 cookie, 验证信息, 核对成功后返回响应给客户端

### Cookie 与 Session 关系

- *Cookie* 数据存放在客户的浏览器上, *Session* 数据放在服务器上
- *Session* 依赖于 *Cookie*
- *Cookie* 不是很安全, Session 更加安全
- *Session* 会在一定时间保存在服务器上. 当访问增多, 会占用服务器的性能. 为减轻压力, 可使用 *Cookie*
- *Cookie* 大小有限制

### 保证 Cookie 的安全

- 对 *Cookie* 进行加密
- 只在 *HTTPS* 上携带 *Cookie*
- 设置 *Cookie* 为 `httpOnly`, 防止跨站脚本攻击

## iOS 中发送 HTTP 请求的方案

### 苹果原生

#### NSURLConnection

用法简单, 最古老最经典最直接的一种方案

#### NSURLSession

iOS 7 新出的技术, 功能比 `NSURLConnection` 更加强大

#### CFNetwork

`NSURL*` 的底层, 纯 C 语言

### 第三方

#### ASIHttpRequest

外号 `HTTP` 终结者, 功能极其强大, 可惜早已停止更新

#### AFNetworking

简单易用, 提供了基本够用的常用功能

#### Alamfire

`AFNetworking` 的 *Swift* 版本

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145025.jpg?x-oss-process=style/WaMa)

说明: `AFN` 基于 `NSURL`, `ASI` 基于 `CFHTTP`, `ASI` 的性能更好一些.

## HTTP 请求状态码

1. `1**` **信息**, 服务器收到请求, 需要请求者继续执行操作

    | 状态码 | 结果                | 描述                                                                                             |
    |:----: | ------------------- | ------------------------------------------------------------------------------------------------ |
    | `100` | Continue            | 继续. 客户端应继续其请求                                                                         |
    | `101` | Switching Protocols | 切换协议. 服务器根据客户端的请求切换协议. 只能切换到更高级的协议, 例如, 切换到 HTTP 的新版本协议 |

2. `2**` **成功**, 操作被成功接收并处理

    | 状态码 | 结果                          | 描述                                                                                               |
    |:----: | ----------------------------- | ------------------------------------------------------------------------------------------------   |
    | `200` | OK                            | 请求成功. 一般用于 GET 与 POST 请求                                                                |
    | `201` | Created                       | 已创建. 成功请求并创建了新的资源                                                                   |
    | `202` | Accepted                      | 已接受. 已经接受请求, 但未处理完成                                                                 |
    | `203` | Non-Authoritative Information | 非授权信息. 请求成功. 但返回的 meta 信息不在原始的服务器, 而是一个副本                             |
    | `204` | No Content                    | 无内容. 服务器成功处理, 但未返回内容. 在未更新网页的情况下, 可确保浏览器继续显示当前文档           |
    | `205` | Reset Content                 | 重置内容. 服务器处理成功, 用户终端 (例如: 浏览器) 应重置文档视图. 可通过此返回码清除浏览器的表单域 |
    | `206` | Partial Content               | 部分内容. 服务器成功处理了部分 GET 请求                                                            |

3. `3**` **重定向**, 需要进一步的操作以完成请求

    | 状态码 | 结果               | 描述                                                                                                   |
    |--------|--------------------|--------------------------------------------------------------------------------------------------------|
    | `300` | Multiple Choices   | 多种选择. 请求的资源可包括多个位置, 相应可返回一个资源特征与地址的列表用于用户终端 (例如: 浏览器) 选择 |
    | `301` | Moved Permanently  | 永久移动. 请求的资源已被永久的移动到新 URI, 返回信息会包括新的 URI, 浏览器会自动定向到新 URI.          |
    | `302` | Found              | 临时移动. 与 301 类似. 但资源只是临时被移动. 客户端应继续使用原有 URI                                  |
    | `303` | See Other          | 查看其它地址. 与 301 类似. 使用 GET 和 POST 请求查看                                                   |
    | `304` | Not Modified       | 未修改. 所请求的资源未修改, 服务器返回此状态码时, 不会返回任何资源. 客户端通常会缓存访问过的资源       |
    | `305` | Use Proxy          | 使用代理. 所请求的资源必须通过代理访问                                                                 |
    | `306` | Unused             | 已经被废弃的 HTTP 状态码                                                                               |
    | `307` | Temporary Redirect | 临时重定向. 与 302 类似. 使用 GET 请求重定向                                                           |

4. `4**` **客户端错误**, 请求包含语法错误或无法完成请求

    | 状态码 | 结果                            | 描述                                                                                            |
    |--------|---------------------------------|-------------------------------------------------------------------------------------------------|
    | `400` | Bad Request                     | 客户端请求的语法错误, 服务器无法理解                                                            |
    | `401` | Unauthorized                    | 请求要求用户的身份认证                                                                          |
    | `402` | Payment Required                | 保留, 将来使用                                                                                  |
    | `403` | Forbidden                       | 服务器理解请求客户端的请求, 但是拒绝执行此请求                                                  |
    | `404` | Not Found                       | 服务器无法根据客户端的请求找到资源 (网页)                                                       |
    | `409` | Conflict                        | 服务器完成客户端的 PUT 请求时可能返回此代码, 服务器处理请求时发生了冲突                         |
    | `409` | Conflict                        | 服务器完成客户端的 PUT 请求时可能返回此代码, 服务器处理请求时发生了冲突                         |
    | `409` | Conflict                        | 服务器完成客户端的 PUT 请求时可能返回此代码, 服务器处理请求时发生了冲突                         |
    | `410` | Gone                            | 客户端请求的资源已经不存在. 410 不同于 404, 如果资源以前有现在被永久删除了可使用 410 代码       |
    | `411` | Length Required                 | 服务器无法处理客户端发送的不带 Content-Length 的请求信息                                        |
    | `412` | Precondition Failed             | 客户端请求信息的先决条件错误                                                                    |
    | `413` | Request Entity Too Large        | 由于请求的实体过大, 服务器无法处理, 因此拒绝请求. 为防止客户端的连续请求, 服务器可能会关闭连接. |
    | `414` | Request-URI Too Large           | 请求的 URI 过长 (URI 通常为网址), 服务器无法处理                                                |
    | `415` | Unsupported Media Type          | 服务器无法处理请求附带的媒体格式                                                                |
    | `416` | Requested range not satisfiable | 客户端请求的范围无效                                                                            |
    | `417` | Expectation Failed              | 服务器无法满足 Expect 的请求头信息                                                              |

5. `5**` **服务器错误**, 服务器在处理请求的过程中发生了错误

    | 状态码  | 结果                       | 描述                                                                                                  |
    |:-----: | -------------------------- | ----------------------------------------------------------------------------------------------------- |
    | `500` | Internal Server Error      | 服务器内部错误, 无法完成请求                                                                          |
    | `501` | Not Implemented            | 服务器不支持请求的功能, 无法完成请求                                                                  |
    | `502` | Bad Gateway                | 作为网关或者代理工作的服务器尝试执行请求时, 从远程服务器接收到了一个无效的响应                        |
    | `503` | Service Unavailable        | 由于超载或系统维护, 服务器暂时的无法处理客户端的请求. 延时的长度可包含在服务器的 Retry-After 头信息中 |
    | `504` | Gateway Time-out           | 充当网关或代理的服务器, 未及时从远端服务器获取请求                                                    |
    | `505` | HTTP Version not supported | 服务器不支持请求的 HTTP 协议的版本, 无法完成处理                                                      |

## 参考

- [一篇搞懂 TCP, HTTP, Socket, Socket 连接池](https://segmentfault.com/a/1190000014044351)
- [WebSocket 是什么原理? 为什么可以实现持久连接?](https://www.zhihu.com/question/20215561)
- [Websocket 连接过程, 以及使用中要考虑的问题](https://blog.csdn.net/henryhu712/article/details/85090194)
- [iOS Client 与 WebSocket 通信](https://www.cnblogs.com/ederwin/articles/5316078.html)
