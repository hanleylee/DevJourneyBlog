---
title: Mac 声音输入输出原理及虚拟声卡工具 Loopback 的使用
date: 2020-02-08
comments: true
path: principle-of-sounds-transfer-in-macos
categories: Tools
tags: ⦿mac, ⦿loopback, ⦿tool
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-02-08-Mac%20%E5%A3%B0%E9%9F%B3%E8%BE%93%E5%85%A5%E8%BE%93%E5%87%BA%E5%8E%9F%E7%90%86.png?x-oss-process=style/WaMa)

<!-- more -->

## Mac 声音输入输出原理

Mac 的声音输入输出原理其实很简单, 我根据自己的理解做了一张图片, 如上所示:

外部硬件(比如麦克风等)直接作为输入设备将其声音信号传入系统音源进行处理, 自定义外部硬件声音信号传入在系统的 `Preference` → `Sound` → `Input` 中直接设定

![himg](https://a.hanleylee.com/HKMS/2020-02-08-071544.png?x-oss-process=style/WaMa)

软件的声音信号产生后也是直接传入系统音源进行处理.

信号传入系统音源后根据 `Preference` → `Sound` → `Output` 中的设定传出到指定的外放设备

![himg](https://a.hanleylee.com/HKMS/2020-02-08-072106.png?x-oss-process=style/WaMa)

## 声音录制的原理及可能遇到的问题

Mac 的声音输入输出原理了解了之后, 我们可以想想, 如果现在开启了一个录音软件进行录音, 声音是如何处理的呢?

答案是录音软件都会让使用者选择声音输入来源, 比如 Mac 的 QuickTime 录音选项如下

![himg](https://a.hanleylee.com/HKMS/2020-02-08-073008.png?x-oss-process=style/WaMa)

QuickTime 会让用户选择一个声音的输入来源, 列表就是各个麦克风设备[包括MacBook内置麦克风在内].

但是如果你在 Mac 上认真地用过几次这样的录制方式后你就会有如下疑问:

- 如何才能录制软件的声音(比如浏览器视频声音, 音乐软件的声音)?
- 在一些不提供音源输入选项的通讯软件(比如 QQ for Mac)中, 如何才能在通话中让对方清晰地听到当前系统正在播放的音乐?
- 如何在直播时将自己的说话声音与系统的软件声音混合推流到直播平台?

这些问题都涉及到一个核心: 内录. 在理解了 Mac 声音输入输出原理后, 我们知道软件的声音是直接传到系统音源中的, 并不会经过输入设备, 但是绝大部分录音或通讯软件都是通过监听一个输入设备来进行工作的(有些强大的软件允许监听多个输入设备). 因此, 通过一般的方式是无法实现录制软件声音的.

有了需求, 自然就有解决方案, 在Mac 平台上存在一些软件, 将软件的声音捕捉到一个虚拟声卡设备中, 然后在声音采集时选择这个虚拟的声卡设备, 这样就能实现内录.  目前广泛使用的软件有 SoundFlower, Loopback 等, 这里不推荐使用 SoundFlower , 原因如下:

- 已经基本停止了开发
- 没有自定义采集功能
- 没有图形界面, 不直观
- 目前已经不太兼容最新版的 Mac 系统了, 在使用过程中时灵时不灵

与 SoundFlower 相比, Loopback 是一款更加强大的软件, 是上面几个缺点的完全相反面.

## 虚拟声卡工具 Loopback 使用

![himg](https://a.hanleylee.com/HKMS/2020-02-08-081113.png?x-oss-process=style/WaMa)

Loopback 软件使用非常简单, 其核心思想就是创建一个 **虚拟声卡设备**, 自定义采集各种源(包括各种声卡以及软件的声音), 将所有的源的声音混合后输出到系统音源中.

### 使用步骤

1. 按照上图所示自定义创建一个虚拟声卡设备
2. 在 `Preference` → `Sound` → `Input` 中选择上一步创建好的虚拟声卡设备

    ![himg](https://a.hanleylee.com/HKMS/2020-02-08-081557.png?x-oss-process=style/WaMa)

3. 完成

### 特色功能

1. Pass-Thru

    部分软件可以设置声音输出源(比如 Skype), 在开启了 Pass-Thru 功能的前提下, 如果将由 Loopback 自定义的 **虚拟声卡设备** 设为其输出源, 那么 Skype 的声音将直接传入该 **虚拟声卡设备**

2. 监听的源默认在本机被静默

    比如设置监听了 a 软件, 那么 a 软件所发出的任何音效都不会在本机被听到(但是能被正常录制).  这是为了避免啸叫(如果监听的软件通过扬声器所发出的声音不被静默, 那么软件会再次通过内置麦克风采集到发出的声音, 这会造成啸叫现象).

    如果使用耳机的情况下是没有必要担心啸叫的, 这时可以:

    - 在 Monitors 中添加希望不被静默的源(Monitors 的原理就是将声音信号直接传递到系统音源中, 让系统音源输出到默认的 Output 设备并播放)
    - 将`Mute when capturing` 取消勾选状态
