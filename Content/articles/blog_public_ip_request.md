---
title: 深圳天威家庭宽带公网 IP 申请
date: 2023-06-18
comments: true
path: public-ip-request-record
tags: ⦿network, ⦿ip
updated:
---

这篇文章记录下我是如何如运营商斗智斗勇最终让我的家庭宽带获得公网 IP 的.

<!-- more -->

话说我很早就想拥有一个公网 IP 了, 很多想法都需要使用公网 IP 才能更好地实现, 比如:

- 在外访问家庭文件资源
- 在外远程控制家庭电脑

我一直使用的是深圳天威视讯的家庭宽带套餐, 天威的家庭宽带默认是不给公网 IP 的, 在刚使用天威的服务的时候就发现了这个问题, 也打电话找他们的客服人员申请过公网 IP, 得到的回复是只针对政企用户提供公网 IP 服务, 我当时也认为可能天威在我住的地方确实没有公网 IP 能分配, 于是就妥协了.

最近一年多经常遇到在公司想访问家庭资源的场景, 网上搜了下解决办法, 在没有公网 IP 的情况下可以有如下解决方案:

1. 使用花生壳进行内网穿透

    确实可行, 大部分人也都推荐使用花生壳, 但是贵啊, 去花生壳官网看了下价格, 价格贵, 而且带宽才 1Mbps? 也就是 128KB/s? 那我在公司看个家里的视频文件岂不是会卡死啊

    ![himg](https://a.hanleylee.com/HKMS/2023-06-18190102.jpg?x-oss-process=style/WaMa)

2. 使用中转服务器进行 ssh 端口转发

    具体方案是使用 `ssh -fNTR 7788:localhost:22 temp@39.108.XXX.XXX` 将家庭电脑的 22 端口转发到云服务器的 7788 端口, 那么我们在公司电脑上就可以登录到云服务器进而使用 `ssh -p 7788 hanley@localhost` 登录到家庭电脑了

    我有一台腾讯云丐版服务器, 实践了一下确实可行, 能达到我文件访问的目的, 但是也有很大的缺陷:

    - 不能远程桌面
    - 文件访问速度受云服务器的限制, 我的服务器是丐版配置, 只有 1C2G 1Mpbs, 看了一下如果要给服务器加带宽的话随便就是几百块上千块一年了

3. 使用 Surge Ponte 进行穿透

    我个人是 Surge 的忠实用户了, iPhone & iPad & Mac 都安装有 Surge, Surge 在 Mac 5.0 版本退出了 Ponte 功能, 该功能能让两台启动了 Surge 的设备进行互相访问, 我尝试了一下, 确实也可行, 能访问文件资源也能桌面管理了, 但是也有缺陷:

    - 必须要有一台代理服务器做中转, 访问的速度与延迟取决于中转服务器的速度, 我尝试了用我的代理节点做连接, 速度很快, 延迟很低, 但是会占用我的节点流量啊, 我一个月一共就 200G 可用流量, 经不起这样消耗, 如果用我腾讯云服务器做代理的话, 网速和延迟又成为了一大问题

综上, 各种方案都无法比较完美地解决我的需求, 还是需要一个公网 IP 才能从根本上解决我的问题. 因此我做了一个决定, 今年宽带续费的时候换一家运营商吧!

六月份我办理了联通的手机套餐, 该套餐附带了 200Mbps 的家庭宽带, 跟他们反复确认过可以安装宽带到我住的小区.

到了安装宽带那一天, 宽带小哥上门进行宽带安装. 在我的观察下, 宽带小哥把我原来的天威光猫换成了一个一模一样的另一个天威光猫, 我当时真是懵逼了

我就问宽带小哥: "你们不是联通吗? 为什么要用天威的线和光猫啊?"

宽带小哥说: "你们这个楼全部是我们天威的光缆, 我也是天威的工作人员, 联通是和我们合作的啦"

我当时真的是有点懵逼, 绕来绕去最后用的还是天威的线路. 我有点不死心, 安装完之后我问小哥我这个能不能申请公网 IP, 小哥说的和我预期的一样: 不行.

事后我在网上仔细研究了下运营商开通公网 IP 的一些教程, 然后我决定和天威再沟通一下, 如果实在不行, 我就投诉到工信部

## 投诉

投诉流程比较波折

1. 我打电话给天威客服 A, 我说我没有公网 IP, 希望天威给我开通, 客服说只给政企套餐才能开通, 我问他是不是说我居住的地方有公网 IP 资源, 只是我的套餐不允许? 客服回答是的. 我说我确实有在外访问家庭资源的需求, 如果天威不能提供公网 IP, 我不能实现我的需求, 到时候我会投诉给工信部. 客服听到投诉工信部后明显重视了, 说会将我的问题进行记录, 48 小时内有人会回电我.
2. 其实我没报希望让天威主动给我解决了, 所以我打完电话就直接找到 [工信部网址](https://yhssglxt.miit.gov.cn/web/appealInformation) 进行举报, 但是工信部的投诉要求必须等待企业 15 天之内不解决问题的情况下才能向其投诉, 估计是为了筛选出真正需要解决的问题吧, 我想等等也行, 看天威怎么给我回复吧
3. 过了一天, 天威的客服 B 回电给我, 说他们的用户条款里面不包括提供公网 IP 这个服务, 所以他们不能提供. 我说我们小区现在只能用你们的宽带, 其他运营商可以申请公网 IP, 但是你们天威就是不行, 我确实有需要, 而且是不需要固定的公网 IP, 动态的也能接受, 如果实在不能提供, 我还是会向工信部投诉的. 客服说他会安排他们的技术人员与我沟通, 看能不能给我解决问题, 我答应了
4. 过了一会儿, 一个天威的宽带安装师傅给我打电话, 我向他说明了我需要的是公网 IP, 这个师傅算比较好说话, 所以和他多聊了一会儿, 他说他就是个最底层的安装人员, 真正的 ip 分配都是他们的技术员操作的, 他协调一下试试
5. 又过了两天, 正上班的时候, 上一个与我沟通的宽带师傅打过来电话问我现在宽带有没有公网 IP, 我说没有啊, 路由器里面看到的分配 ip 和百度查出来的 ip 不一致, 他说不应该啊, 我说我现在不在电脑旁, 等我回去再看一下

当天晚上加班, 11 点回家家的时候我登录了路由器管理页面, 竟然有了公网 IP 了!

![himg](https://a.hanleylee.com/HKMS/2023-06-18195820.jpg?x-oss-process=style/WaMa)

我当时还有点怀疑是不是眼花了, 反复查了一下, 百度搜出来的和路由器显示的一致了

![himg](https://a.hanleylee.com/HKMS/2023-06-18200049.png?x-oss-process=style/WaMa)

当时真的是睡意全无了, 困扰几年的问题终于解决了, 那么很多想法就可以落地了😄

## 坑

拿到公网 IP 之后, 在实现一些想法的时候也经历了一些小坑, 这里也记录一下

### 运营商端口屏蔽

之前我是不知道运营商会屏蔽一些 TCP 端口的, 我发现我内网连接 smb 都是好好的, 但是使用公网方式连接 smb 就不行, 经过很长时间的踩坑, 我发现 smb 默认使用的是 445 端口进行通信, 如果我改为其他端口就可以进行连接了. 当时得出这个结论的时候我真是想骂娘, 又上网搜了下为什么公网的端口要被屏蔽, 发现很多运营商都会封禁一些常用端口:

- 25
- 80
- 135
- 136
- 137
- 138
- 139
- 445
- 593

封禁的原因应该是政策, 作为普通消费者就尽量使用其他端口进行通信吧, 不要一棵树上吊死

### iOS Files 不能使用指定端口的 smb 服务

之前在内网情况下都是通过 iOS `Files.app` 访问 Mac 通过 smb 共享的文件, 之前一直用没什么问题, 但是在上一个端口屏蔽问题中发现, 即使我在连接时使用了一个自定义端口, Files.app 请求的仍然是 445 端口, ChatGPT 确认了这一问题 🤣

![himg](https://a.hanleylee.com/HKMS/2023-06-18202928.png?x-oss-process=style/WaMa)

### Mac vnc 不能通过公网 IP + 端口号访问

我一直使用的是 Mac 自带的 "Screen Sharing.app" 来进行远程桌面管理, 其用的是 vnc 协议, 之前在内网情况下使用 "Screen Sharing.app" 一直没有问题, 但是直接使用公网 IP 后一直无法连接成功, 即使更改了自定义端口也不可以成功连接, 但是通过第三方 vnc 工具 RealVNC 是可以成功连接的, 具体原因未知

## Ref
