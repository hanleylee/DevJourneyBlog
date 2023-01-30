---
title: iOS 中的静态库与动态库
date: 2021-05-24
comments: true
path: various-libraries-in-ios
categories: iOS
tags: ⦿ios, ⦿dynamic-library, ⦿static-library, ⦿cocoapods
updated:
---

如果你经常困惑 iOS 开发中的静态库和动态库的作用与区别, 那么这篇文章可以为你解惑

![himg](https://a.hanleylee.com/HKMS/2020-11-17-012010.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-11-17-012035.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 静态库 (Static Libraries)

静态库简单的理解是多个目标文件 (`object file`, 以 `.o` 为后缀) 的打包集合. 静态库的存在形式:

- Mac/iOS: `.a` 或封装成 `.framework`
- Linux: `.a`
- Windows: `.lib`

> 查看 object file 格式: `objdump -macho -section-headers /bin/ls`

### 优势

- 提供的是目标文件, 所以不需要重新编译, 只需要链接即可
- 加载 App 速度更快, 因为在编译时已经进行了链接, 因此启动时不需要进行二次查找启动

<!-- - 编译出来的 `app` 相比与 `动态库` 体积较小, 链接器会保留用到的代码, 未用的代码会被删除 -->

## 动态库 (Dynamic Libraries)

动态库 (`Dynamic Libraries`, 也称作 `Shared Library`, `Shared object`, `动态链接库`), 跟静态库一样是多个 `object files` 封装起来的, 但是动态库并不会在编译时直接置入 app, 而是将动态库的信息置入 app, 然后 app 在被运行的时候去动态查找动态库并进行链接, 这一步也叫做 ` 动态链接 `.

根据动态库的载入时间 (`load time`) 我们将动态库分为以下两种:

- `动态链接库`: 在启动 app 时立刻将动态库进行加载 (随程序启动而启动)
- `动态加载库`: 当需要的时候再使用 `dlopen` 等通过代码或者命令的方式来加载 (在程序启动之后)

以上行为是由动态链接器 (`Dynamic linker`, macOS 称 `dyld`) 来完成

动态库的存在形式分为以下几种:

- MacOS/iOS: `.tbd`, `.dylib` 或封装成 `.framework`
- Linux: `.so`
- Windows: `.DLL`

macOS 大规模地使用 `shared libraries`, 可以前往路径 `/usr/lib` 文件夹查看系统的动态库.

![himg](https://a.hanleylee.com/HKMS/2020-11-24-090551.png?x-oss-process=style/WaMa)

然而在运行时进行才做链接其实是一个笨重的负担, 应合理安排哪些库需要 `load` 以及时机.

### 优势

因为动态库不需要在编译时置入 app 中, 因此理论上体积会更小, 而且可以做到动态库内容改变所有结果文件不需要重新编译即可获得最新功能

> 以上只是对于标准的系统动态库来说的, 对于 iOS 开发来说, 因为我们只能使用 `Embedding Frameworks` 来使用动态库, 这样的动态库并不是真正的动态库, 其会在编译时全部置入 app, 然后在 app 启动时全部加载, 这样的话会导致体积大, 加载速度慢.

## iOS 开发中 `.framework` 及动 / 静态库的区分

标准的动态库与静态库定义如上, 但是在 iOS 系统中, Apple 为我们提出了另一种可以包含依赖库的模式 -- `.framework`

一个 `.framework` 其实就是一个有着特定结构的文件夹装着各种共享的资源. 这些资源通常是 **图片**, **Xibs**, **动态库**, **静态库**, **文档** 等,
`.framework` 毫不掩饰的表明它纯粹就是一个文件夹.

![himg](https://a.hanleylee.com/HKMS/2020-11-25-074324.png?x-oss-process=style/WaMa)

- `Headers`: 包含了 `Framework` 对外公开的 `C & Obj-C headers`, Swift 并不会用到这些 `Headers`, 如果你的 `framework` 是用 `Swift` 写的, Xcode 会自动帮你创建这个文件夹以提供互用性.
- `ZRCoreKit.swiftmodule`: 包含了 LLVM, Swift 的 Module 信息. .modulemap 档案是给 Clang 使用的.

    `.swiftmodule` 文件夹下的档案类似 `headers`, 但是不像是 `headers`, 这些档案是二进制的且 **无格式也有可能会改变**, 在你 `Cmd-click` 一个 `Swift` 函数时 Xcode 就是利用这些档案去定位其所属的 module.

    尽管这些都是二进制文件, 但他们仍是一种叫 `llvm bitcode` 的结构, 正因如此, 我们能用 `llvm-bcanalyzer and llvm-strings` 取得相关信息.

- `ZRCoreKit`: 虽然他被 `finder` 标注成 `Unix executable File`, 但他其实是一个 `relocatable shared object file`
- `CoreKit.bundle`: `bundle` 文件

由于有 `.framework` 的存在, 我们在判断一个库到底是静态库还是动态库就有了麻烦, 因为一个 `.framework` 既可以是动态库也可以是静态库, 依赖于其内部的文件类型, 而`.framework` 中的二进制文件有可能有后缀, 也有可能没有后缀.

![himg](https://a.hanleylee.com/HKMS/2020-11-25-081147.png?x-oss-process=style/WaMa)

为了区分其类型我们可以借助`MachOView`, 或者是在 Xcode 的 `Targets` -> `build setting` 中查找 `mach-o type` 选项.

![himg](https://a.hanleylee.com/HKMS/2020-11-25-080000.png?x-oss-process=style/WaMa)

## 动静态库以 .framework 形式被 `embed` 或 `not embed` 对包体积的影响

前面说了, `.framework` 只是一个文件夹而已, 里面可以存放静态库/动态库, embed 的含义即是在 .ipa 包里使用 `Frameworks` 文件夹将所有 `.framework` 库存放起来

![himg](https://a.hanleylee.com/HKMS/2021-10-28115338.png?x-oss-process=style/WaMa)

以下总结了不同库类型不同方式组合会产生的效果

| Library Type    | Embed                                                                  | Not Embed                                |
|-----------------|------------------------------------------------------------------------|------------------------------------------|
| Dynamic Library | 运行时链接, 所有 framework 文件位于 `Frameworks` 文件夹中              | 会 Crash!                                |
| Static Library  | 编译时链接, 库代码会在 `主Mach-O` 文件中, 同时 `Frameworks` 也会有一份 | 编译时链接, 库代码会在 `主Mach-O` 文件中 |

以下总结了在项目中以不同方式使用不同类型库产生的包大小对比

| Library Type    | Embed | Not Embed      |
|-----------------|-------|----------------|
| Dynamic Library | 84KB  | 33KB(会 crash) |
| Static Library  | 371KB | 64KB           |

## 动静态库的混用

我们可以在一个项目中使用一部分动态库, 再使用一部分静态库, 如果涉及到第三方库与库之间的依赖关系时, 那么遵守如下原则:

- 静态库可以依赖静态库
- 动态库可以依赖动态库
- 动态库不能依赖静态库! 动态库不能依赖静态库是因为静态库不需要在运行时再次加载, 如果多个动态库依赖同一个静态库, 会出现多个静态库的拷贝, 而这些拷贝本身只是对于内存空间的消耗.

## 结合实际 - CocoaPods 中的动态库静态库使用

### 静态库使用

默认情况下, 当我们在 `Podfile` 文件中写下:

```ruby
platform :ios, '10.0'
source 'https://cdn.cocoapods.org/'

target 'HLTest' do
  pod 'AsyncSwift'
end
```

的时候, cocoapods 默认会使用静态库, 我们可以在 `Products` 文件夹中看到编译出的 `.a` 文件

![himg](https://a.hanleylee.com/HKMS/2020-11-24-093428.jpg?x-oss-process=style/WaMa)

在项目的 `.app` 中, 我们可以看到静态库被编译进入可执行文件 (`mach-o` 文件), 导致文件大小为 14.9M

![himg](https://a.hanleylee.com/HKMS/2020-11-24-093613.png?x-oss-process=style/WaMa)

### 动态库使用

cocoapods 提供了 `use_frameworks!` 选项让我们可以以 `.framework` 的形式导入第三方库, cocoapods 默认我们开启了此选项后在 `.framework` 文件夹中放的是动态库, 因此我们可以在 `Podfile` 中加入 `use_frameworks!` 来达到引入动态库的效果, 如下:

```ruby
platform :ios, '10.0'
source 'https://cdn.cocoapods.org/'
use_frameworks!

target 'HLTest' do
  pod 'AsyncSwift'
end
```

然后经过 `pod update` 之后, 结果如下:

![himg](https://a.hanleylee.com/HKMS/2020-11-24-094201.png?x-oss-process=style/WaMa)

cocoapods 编译生成的结果文件已经变为了 `.framework` 文件夹

再来看项目结果文件 `.app`:

![himg](https://a.hanleylee.com/HKMS/2020-11-24-094925.png?x-oss-process=style/WaMa)

我们可以看到

- 由于动态库未被编译进入可执行文件 (`mach-o` 文件), 导致文件大小减小到 14.8M
- 多了一个 `Frameworks` 文件夹用于存放 `.framework` 文件

### cocoapods 中混合使用动静态库

在 [动静态库的混用](#动静态库的混用) 中我们我们知道动态库不能依赖静态库, 因此在实际项目中会有一种需要特别注意的情况: 如果项目中有一个库必须是静态库时, 那么其整个依赖链路上的所有库都必须以静态库被引入, 如下图:

![himg](https://a.hanleylee.com/HKMS/2021-01-25-img-1.png?x-oss-process=style/WaMa)
<!-- ![himg](https://a.hanleylee.com/HKMS/2020-11-24-zhuorui-relationship.png?x-oss-process=style/WaMa) -->

在 `库 4` 为静态库的情况下, 整个依赖链路上的所有库(`库 5` 与`库 3`)都必须以静态库形式被项目依赖

这时我们需要使用 cocoapods 在版本 1.5 之后推出的新功能: `s.static_frameworks = true`. 这个命令使用在库的 `.podspec` 文件中, 用来指定本库作为静态库被其他项目作为 **包含静态库的 `.framework` 文件** 引入.  这样我们就可以在开发库的时候手动指定本库被以静态库还是动态库形式被引入了.

## 动态库的加载时机

在 iOS app 启动时系统会查找我们所依赖的所有动态库并加载, 这降低了我们 App 的启动速度, 那么可不可以将动态库的调用时间延迟到 app 运行时? 答案是可以可以!

查看苹果的 API 文档, 会发现有一个方法提供了加载可执行文件的功能, 那就是 `NSBundle` 的 `load` 方法 (底层实现为 `dlopen` 函数),  如下所示:

![img](https://a.hanleylee.com/HKMS/2020-11-25-070417.jpg?x-oss-process=style/WaMa)

然而, 这个方法的使用是有前提的. 那就是库和 app 的签名必需一致. iOS 可能是出于安全考虑, 在加载可执行代码前, 需要校验签名. `load` 方法的内部实现是调用了 `dlopen`, 而真机的 `dlopen` 内部还会调用 `dlopen_preflight` 先校验签名. 如果库不是事先打包进 app(打包进 app 的话会与 app 有相同签名), 就会报签名错误, 从而加载不成功. 如下图所示:

![himg](https://a.hanleylee.com/HKMS/2020-11-25-070714.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-11-25-070732.jpg?x-oss-process=style/WaMa)

因此, 我们可以将有相同签名(必须相同签名)的动态库放入 app, 但是不提供链接信息(就是在 *Build Phases* 的 *Link Binary With Libraries* 中去掉需要懒加载的动态库), 只在需要时使用 `dlopen` 这一函数进行懒加载

![himg](https://a.hanleylee.com/HKMS/2021-10-06215211.jpg?x-oss-process=style/WaMa)

## 总结

- 动态库不能依赖静态库!
- 对于 `Swift` 项目, `CocoaPods` 提供了 `.framework` 的支持, 通过 `use_frameworks!` 选项控制. 需要注意的是如果使用此选项那么所有依赖的 `pod` 都会以 `.framework` 包裹的动态库类型引入, 如果想让某些 `pod` 使用动态库引入, 某些 `pod` 使用静态库引入, 那么请看下面
- `.a` 是典型的静态库, 在 `Xode` -> `File` -> `New` -> `Project` 中的 `Static Library` 即可新建 `.a` 静态库
- `.framework` 可以做成静态库, 也可以做成动态库, 在工程中修改某个 target 的 `Build Setting` 的 `Mach-O Type` 即可. 在 `Xode` -> `File` -> `New` -> `Project` 中的 `Static Library` 的 `Framework` 即可新建 `.framework` 静态库
- `.a` 是纯二进制文件, `.framework` 中除了有二进制文件之外还可以有资源文件. `.a` 文件不能直接使用, 至少还要有 `.h` 文件配合, `.framework` 文件可以直接使用, 因为本身包含了 `h 文件` 和其他文件
- `.a` ＋`.h` ＋`source` = `.framework`, 建议使用 `.framework`
- 静态库与动态库区别:
    - 静态库: 链接时完整地拷贝至可执行文件中, 被多个依赖多次使用就会有多份冗余拷贝.
    - 动态库: 链接时不复制, 程序运行时由系统动态加载到内存, 供程序调用, 系统只加载一次, 多个程序共用, 节省内存.(这个优点是针对系统动态库来说的, 比如 `UIKit.framework`)
- 系统的 `Framework` 不需要拷贝到目标程序中, 我们自己做出来的 `Framework` 哪怕是动态的, 最后也还是要拷贝到 App 中, 因此苹果又把这种 `Framework` 称为 `Embedded Framework`.
- 当不想发布代码的时候, 也可以使用 `Framework` 发布 `Pod`, `CocoaPods` 提供了 `vendored_framework` 选项来使用第三方 `Framework`
- 如果想通过 `cocoapods` 制作一个静态库被其他项目依赖, 那么可以在 pod 的 `podspec` 文件中使用 `s.static_framework  =  true` 命令, 这个命令会使 pod 变为由 `.framework` 包裹的静态库 (即使项目的 `Podfile` 中使用了 `use_frameworks!` 时使用 `pod` 也会以静态库使用), 这在解决 ` 动态库不能依赖静态库 ` 的问题上非常有用.
- Mach-O 格式的几种文件和 iOS 工程 Build Settings 里面的配置项是对应的.
- 系统动态库和自己编译的动态库本质上是一样的, 只是使用方式不一样. 自己编译的动态库由于签名校验限制, 只能当作静态库一样使用; 系统的动态库不受签名校验限制, 可以动态加载.
- `.a` 与 `.framework` 都是库 (Library), 库都是二进制的, 看不到源码的, 只能看到头文件, Cocoapods 方式集成的可以看到源码是因为将源码放在一个新构建的 `Pods` 工程中了, Pods 的主目标是一个 `target`, 这个 target 依赖了我们所有导入的第三方库, 然后主项目对 Pods 工程中的这个  `target` 的生成 `product` 进行依赖, 形成了我们好像直接可以使用第三方库源码的错觉

    ![himg](https://a.hanleylee.com/HKMS/2021-01-24185902.png?x-oss-process=style/WaMa)

<!-- - Cathage 原理: 将第三方库的源码编译出的结果以 `Embedded Binary` 方式直接链接到 `App Target` -->
<!-- - SPM 原理: 通过 `llbuild`(`low level build system`) 的跨平台编译工具将 Swift 文件编译为 `.a` 的静态库 -->

## 最后

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow

## 参考

- [年轻人, 听说你想使用 Framework - 基础观念](https://jamesdouble.github.io/blog/2018/11/19/frameworkEasy/)
- [Xcode 6 制作动态及静态 Framework](http://www.cocoachina.com/articles/10322)
- [How to Use a Third Party Framework in a Private CocoaPod](https://www.telerik.com/blogs/how-to-use-a-third-party-framework-in-a-private-cocoapod)
- [iOS 开发中的『库』(一)](https://www.jianshu.com/p/48aff237e8ff)
- [通过dylib实现iOS运行时Native代码注入（动态调试）](https://juejin.cn/post/6844903635021725704)
- [浅析快手iOS启动优化方式——动态库懒加载](https://mp.weixin.qq.com/s/gNc3uK5ILbXsO8jB1O-jnQ)
- [Frameworks: embed or not embed that's the question](https://holyswift.app/frameworks-embed-or-not-embed-thats-the-question)
