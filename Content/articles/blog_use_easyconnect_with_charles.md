---
title: EasyConnect 连接的情况下使用 Charles 抓包
date: 2022-03-15
comments: true
path: use-easyconnect-with-charles
categories: Tools
tags: ⦿mac, ⦿easyconnect, ⦿charles, ⦿proxy
updated:
---

疫情期间, 我开始了居家办公. 由于需要用到公司内网, 于是在电脑上安装了 EasyConnect. 同时由于我是一名 iOS 开发者, 我必须能在设备上抓网络请求包. 在没有 EasyConnect 的情况下这是非常简单的, 我只使用 Charles 就可以很好地完成抓包这个需求. 但是在 EasyConnect 连接的情况的完全抓不了包!

经过我的不断摸索尝试, 我总结了以下方法使我能在 EasyConnect 连接的情况下使用 Charles 进行抓包, 希望对看到此文章的你也有一定帮助.

<!-- more -->

1. 在系统网络设置打开两种网络连接方式, 我使用的是 以太网 与 wifi 这两种
2. 开启 EasyConnect
3. 开启 Charles
4. 在手机上按照 Charles 的指导设置网络的代理服务器地址和端口, 注意, 这一步我们必须使用网络连接方式的次要连接类型的 ip 地址!

以上方法, 核心其实就是设置两个网络连接方式, 然后让 Charles 使用次要连接方式作为代理服务器地址.

这种方式也属于我无意中发现的, 至于具体原理我也不甚了解, 如果你知道原理的话欢迎交流.
