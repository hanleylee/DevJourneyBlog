---
title: Flutter Module 调试之 attach
date: 2022-05-08
comments: true
path: how-to-use-flutter-attach-in-module-project
categories: flutter
tags: ⦿flutter
updated:
---

近来在公司项目上初步尝试了 Flutter 开发, 发觉 Flutter 的坑还是挺多, 这里记录下我使用 flutter attach 调试的一个坑

<!-- more -->

Flutter 分为以下四种工程类型

- Flutter Application: Flutter 应用
- Flutter Module: Flutter 与原生混合开发
- Flutter Plugin: Flutter 插件
- Flutter Package: 纯 Dart 组件

我司使用的 Flutter 正是 Flutter Module 类型, 也就是常说的混合开发. 使用这种方式遇到的第一个问题就是如何调试 flutter 工程的代码.  官方有说明在 [这里](https://flutter.cn/docs/development/add-to-app/debugging), 简言之, 有两种方式:

1. 直接在主工程中运行, 然后使用 flutter attach 连接到 flutter engine 来进行实时调试
2. 在 Flutter Module 工程的外界套上一个壳工程, 这个壳的目的就是用于提供 flutter 运行时的外界参数

由于我们的主工程涉及到几十个组件, 编译和运行的时间成本比较高, 所以平时我们开发组件的时候都是在 CocoaPods 提供的 Example 工程下进行调试的.  因此我选择了方法 2 建立一个壳工程来调试 Flutter 代码.

按照官方文档的说明, 我们需要启动工程后使用 `flutter attach` 连接到 flutter engine, 然后就可以 `hot reload` 了. 这里坑也就开始了

> 以下我连接的调试设备默认都是 iPhone SE 2020 手机

## 1. 使用命令行 flutter 工具

在终端中使用 `flutter attach --verbose` 连接时, 成功连接:

![himg](https://a.hanleylee.com/HKMS/2022-05-09163735.png?x-oss-process=style/WaMa)

> 如果直接使用 flutter attach 无法连接, 提示不断重试最后失败, 那么可以尝试将手机拔掉只留下模拟器, 然后在模拟器上运行程序再尝试 attach.

虽然这种方式可以正常调试, 不过如果要想使用 BreakPoint 就不行了, 因此这种方式先放一边, 尝试下其他方法

## 2. 使用 vscode flutter 工具

使用 vscode 的 `Debug: Attach to Flutter on Device` 功能, 选择这个选项后, 我们会被要求 `Enter VM Service URI`, 哪里能找到这个 URI 呢? 在 Xcode 的控制台中, 我们能看到这样一行

```txt
2022-05-09 16:38:50.257588+0800 Example_iOS_Example[18168:995843] flutter: Observatory listening on http://127.0.0.1:56726/D4jt3M-WlsU=/
```

这个 `http://127.0.0.1:56726/D4jt3M-WlsU=/` 就是我们需要的 `VM Service URI` 了, 当我们把它输入到 vscode 中后, 却发生了错误

![himg](https://a.hanleylee.com/HKMS/2022-05-09165445.jpg?x-oss-process=style/WaMa)

同样的步骤, 我们在模拟器上执行, attach 成功了

![himg](https://a.hanleylee.com/HKMS/2022-05-09165803.png?x-oss-process=style/WaMa)

为什么手机会发生错误而模拟器就能正常连接呢😖? 原来当我们把程序运行在手机上时, Xcode 输出的 `http://127.0.0.1:56726/D4jt3M-WlsU=/` 是我们手机上的 ip 地址端口, 而 vscode 会把输入的端口地址直接进行连接, 不会区分本机或手机. 这样的话 Mac 就访问不到手机上的端口了, 自然会 attach 失败. 而模拟器本身就是 Mac 的一个进程, 因此模拟器进程创建的端口可以在 Mac 上直接访问到, 自然可以 attach 成功.

其实我们在终端中执行命令 `flutter attach` 的时候, 我们可以看到有一个端口转发的步骤:

![himg](https://a.hanleylee.com/HKMS/2022-05-09170155.png?x-oss-process=style/WaMa)

Host 就是我们的 Mac, device 就是我们的手机, 在这个案例的步骤中, flutter 使用 iproxy 工具将 Mac 的 57153 端口转发到了 Device 的 56727 端口

因此, 如果我们想要使用 vscode 进行 attach, 那么我们就必须得到正确的 `VM Service URI`, 不幸的是, vscode 并没有帮我们做端口转发这个过程, 因此如果是使用模拟器的话, vscode 是完全可以胜任的. 但是我还是需要手机进行开发调试, 因此继续尝试其他方法.

> 感觉 vscode 的 flutter 工具是一个半成品, 为什么选择了 `Debug: Attach to Flutter on Device` 后需要输入 `VM Service URI` 呢?

## 3. 使用 Android Studio 的 flutter 工具

经过一位拥有丰富 Flutter 开发经验的同事指点, 我可以尝试 Android Studio 的 Flutter 套件, 按照说明文档我安装了之后只需要正确选择设备, 然后选择 `Flutter Attach` 按钮即可

![himg](https://a.hanleylee.com/HKMS/2022-05-09171414.png?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2022-05-09171805.png?x-oss-process=style/WaMa)

Android Studio 连接相比 vscode 稳定与合理了许多. 归根到底, Android Studio 与 Flutter 都是 Google 的产品, 自然联动的效果会更好一点~

这种方式断点的支持也比较好, 唯一的缺点就是太重了, 而且我是开发 iOS 程序的, 用 Android Studio 的时候内心总感觉怪怪的~. 不过因为暂时没有更优的选择, 因此目前只能选择这种方式

## 总结

经过对三种方式的逐一使用, 这几种方式各有各的优点

| 方式           | 优点                     | 缺点                   |
|----------------|--------------------------|------------------------|
| 命令行         | 轻量, 灵活, geek         | 不能设置断点           |
| vscode         | 轻量, 可断点             | flutter 插件设计有问题 |
| Android Studio | 可断点, 插件功能全且稳定 | 太重                   |

## 此次踩坑得到的教训

- 遇到错误时多观察错误日志
- 第一次做一件事时候, 不要设置太多变量, 比如在这个案例中就是不要同时连接多个设备(这个因素浪费了我很多时间去判断真正的问题所在)
