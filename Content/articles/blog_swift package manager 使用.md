---
title: Swift Package Manager 使用
date: 2020-03-02
comments: true
path: usage-of-SPM
categories: iOS
tags: ⦿ios, ⦿SPM, ⦿swift
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-03-02-target%26product.png?x-oss-process=style/WaMa)

<!-- more -->

Swift Package Manager(以下简称 SPM) 是苹果官方的包管理工具, 相比于 Cocoapods, 它不仅支持 macOS, 也支持 Linux 平台, 并且在 Xcode 11 中作为内置的包管理工具.

Swift Package Manager 使用极其方便, 在 xcode 内置的 Swift Package Manager 中, 我们只需要将对应包的 url 地址加入进来既可以使用.

## 使用 SPM 创建 Package

在制作一个 `package` 时, 最重要的就是对 `Package.swift` 文件的定义.

`Package.swift` 使用了 Xcode 工程的 product, target, dependency 概念, 如果你对这些概念非常了解, 那么使用 SPM 对你来说应该是手到擒来.  暂时不理解也没有关系, 我按照他们的关系做了一张图, 应该能很形象的表现出 target 与 product 的关系了

![himg](https://a.hanleylee.com/HKMS/2020-03-02-target%26product.png?x-oss-process=style/WaMa)

可以这么理解, `Package.swift` 的目的就是最终产生一个或者多个 product, 与 xcode 的 product 概念相同, SPM 的 product 也是由一个 (或几个) target 来生成的, 同时 target 的源可以是:

- 本 package 的其他 target(经常用)
- 外部其他 package(即 dependencies, 本地开发工程时导入时常用)
- 本 package 的源文件 (package 作者开发 package 时会经常用)

最后, 通过 `package generate-xcodeproj` 生成 `library` 或者 `executable`(可执行文件). 这样我们就生成了一个项目文件, 我们可以将这个项目文件导入我们的工程项目中, 在我们的工程文件根目录下单击, 选择 `TARGETS` → `我们的 target` → `General`, 点击 `Frameworks, Libraries, and Embedded Content` 区域的 `+` 号, 将我们在 `Package.swift` 中定义的 `product` 导入进来.

下面示范一个比较全面的 `Package.swift` 文件

```swift
import PackageDescription

let package = Package(

    name: "HLPackages", // package 的名, 但是与生成的最终 product 无关, 就像 iOS 工程与生成的软件名关系一样, 此名决定了 swift package
    // generate-xcodeproj 生成的工程名

    platforms: [ // 本 Package 适用的平台
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v10),
        .watchOS(.v3)
    ],

    products: [ // 最后生成的 product, name 是 product 的名称, targets 是产生此 product 的源
        // SPM 的结果默认是静态库
        .library(name: "HLPackage", type: .static, targets: ["HLPackage"]), // 推荐, 原因见下方使用步骤 -> 注意点
        .library(name: "product2", type: .static, targets: ["target2", "target3"]) // 原因见下方 使用步骤 → 注意点
        .executable(name: "EXEC", targets: ["EXEC"]) // 产生的是可执行文件
    ],

    dependencies: [ // 外部依赖 (外部依赖的全部作用是被 targets 中的 target 使用)
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")), // 外部的 Alamofire 库
        .package(url: "../LCLib", from: "1.0.0") // 本地库, 只在本地, 使用的是相对路径

        // 外部依赖的其他配置方法
        // .package(url:"https://github.com/test/test.git", from: "1.0.0")                               (1.0.0 ..< 2.0.0)
        // .package(url:"https://github.com/test/test.git", .exactItem(Version(stringLiteral: "1.2.0"))  (==1.2.0)
        // .package(url:"https://github.com/test/test.git", .revisionItem("74663ec"))                    某次提交的 revision 的值
        // .package(url:"https://github.com/test/test.git", .branchItem("develop"))                      分支名
        // .package(url:"https://github.com/test/test.git", .localPackageItem)                           本地依赖
        // .package(url:"https://github.com/test/test.git", Version(stringLiteral: "1.2.3")..<Version(stringLiteral: "1.2.8"))   (>=1.2.3 && <1.2.8)
        // .product(name: "Bluetooth", condition: .when(platforms: [.macOS])),                          // 指定生效平台Mac
        // .product(name: "BluetoothLinux", condition: .when(platforms: [.linux])),                     // 指定生效平台Linux
        // .target(name: "DebugHelpers", condition: .when(configuration: .debug)),                      // 指定在Debug下生效
    ],

    targets: [
        .target( // 最简单的 target, 无外部依赖, 其源文件都位于 "Sources" 文件夹下的 "target1" 文件夹
            name: "target1",
            dependencies: [],
            resources: [.copy("Resources"), .process("logo.png")] // 定义资源文件夹或文件, copy 表示不需要优化直接拷贝, process 会针对不同平台不同类型进行优化

        ),
        .target( // 开发中最频繁的用法, 外部依赖为 Alamofire
            name: "target2",
            dependencies: ["Alamofire"] // Alamofire 是上方 dependencies 部分第一个 package 的一个 product
        ),
        .executableTarget( // 开发中最频繁的用法, 外部依赖为 Alamofire
            name: "target3",
            dependencies: ["Alamofire"], // Alamofire 是上方 dependencies 部分第一个 package 的一个 product
            path: "Sources"
        ),
        .target(
            name: "EXEC", // target 的名称
            path: "Custom", // target 的路径, 如果自定义文件夹需要设置此参数, 如果不设置此项的话默认路径是 "Sources" 文件夹下的 "target2" 文件夹
            exclude: ["SwiftUI"] // 希望在 path 中排除的 "SwiftUI" 文件夹
        ),
//      .testTarget( // 用于测试的 target, iOS 开发一般不使用, 使用场景在服务器端开发
//      name: "OC2SwiftTests",
//      dependencies: ["OC2Swift"]
//      ),
    ]
)
```

## 手动创建并导入外部 Package

1. 创建一个用于存储库的文件夹 (因为之后要将由本 package 生成的 Xcode 工程文件放入到我们的 iOS 工程文件中, 因此最好直接建立在 iOS 工程项目的根目录下)

    ```bash
    cd ~/Desktop/MyApp
    mkdir HLPackage && cd HLPackage
    ```

2. 初始化 package

    ```bash
    swift package init --type [empty|library|executable|system-module]
    ```

    注意: 这个命令下有四个选项, library 代表初始化一个库类型的包, executable 代表初始化一个可执行二进制的包, system-module 代表初始化一个系统库的包.  iOS 开发来说, 使用 library 就可以了 (在仅 swift package init 的情况下就是初始化一个 library 静态库)

3. 在 `HLPackage/Package.swift` 中按照上面的范例填写内容
4. 由于每个 target 都必须对应源目录 (即使是完全使用外部依赖, 也要对应一个文件夹, 文件夹中放一个空文件), 因此为每个 target 创建一个对应的目录

    ```bash
    cd ~/Desktop/MyApp/Sources
    mkdir target1 && mkdir target2 && mkdir target3
    touch target/temp.swift && touch target/temp.swift && touch target/temp.swift
    ```

5. 生成 Xcode 项目文件, 并将项目文件拖入到我们的 iOS 工程中

    ```bash
    swift package generate-xcodeproj
    ```

    在我们的工程文件根目录下单击, 选择 `TARGETS` → `我们的 target` → `General`, 点击 `Frameworks, Libraries, and Embedded Content` 区域的 `+` 号,
    将我们在 `Package.swift` 中定义的 `product` 导入进来.

    注意: **在导入时仅需导入我们自定义的 product, 其他的外部 dependencies 已经被聚合到我们自定义的 product**

### 注意点

- 当 product 的名称与 Target 相同时, 由于 library 的 product 最终生成结果将位于 Xcode 项目的 `General` → `TARGETS` 中, 而 target 也会生成结果位于其中, 因此当 product 只有一个 target, 且名称相同时, 在 `General` → `TARGETS` 只会生成一个结果, 就是一个 `TARGETS` 包含多个外部依赖框架, 如下图:

    ![himg](https://a.hanleylee.com/HKMS/2020-03-02-183447.png?x-oss-process=style/WaMa)

- 当 product 的名称与 Target 不相同, 或 product 对应了两个 target, 任何一种情况都会生成一个聚合框架, 在 iOS 工程中导入的时候不能导入聚合框架, 还是要导入框架 "target2" 与框架 "target3", 下图演示为 product 名称与单个 target 不相同的情况:

    ![himg](https://a.hanleylee.com/HKMS/2020-03-02-184133.png?x-oss-process=style/WaMa)

- `Package.swift` 中的 `target` 与最终对应生成的 `product` 尽量名称一致, 否则会生成聚合框架, 不方便在 iOS 工程中导入.
- 如果一个 `Package A` 被项目及项目的依赖同时依赖了, 那么 `Package A` 只能保留一个版本, 否则会报错
- `swift package update` 可以手动更新所依赖的 SPM 库

## 使用资源

### 添加资源

在 target 中直接使用 `resource` 即可指定资源位置及引用方式

```swift
resources: [.copy("Resources"), .process("logo.png")] // 定义资源文件夹或文件
```

- `.process`: 使用 SwiftPM 预设的规则自动进行处理:

    不需要特殊处理的话绝大部分场景都推荐使用它.  如果没有对应的规则处理的话, 就会回退到 .copy.  这个选项会递归应用到目录下的所有文件.

- `.copy`: 没有规则, 只是单纯的复制:

    可以用来覆盖预设的规则. 目录的复制会递归进行 (深复制) .

### 使用资源

在我们为 package 添加了 `resource` 时, 系统会自动创建并添加到 module 中一个文件:  `resource_bundle_accessor.swift`, 里面的内容大概等价于下面这样:

```swift
import Foundation
extension Bundle {
    static let module = Bundle(path: "\(Bundle.main.bundlePath)/path/to/this/targets/resource/bundle")
}
```

在调用时可以按照如下方法进行调用

```swift
import Foundation

let picturePath = Bundle.module.path(forResource: "image", ofType: "png")
print(picturePath) // Optional("/Users/wendyliga/resource-spm/.build/x86_64-apple-macosx/debug/resource-spm_resource-spm.bundle/image.png")
```

由于 module 是内部属性, 所以这种方式只能访问自己模块内部的资源文件, 无法跨模块访问. 如果想在一个公共模块提供外部模块使用的资源, 则需要自己创建一个资源访问器. 关于这一点, 使用过 Cocoapods 的 resource_bundle 功能的开发者可能比较了解, 可以采用 bundle 路径方式访问.  如果不单独建立一个公共资源模块, 则不需要考虑这么多.

## 自动导入 Package

相比于手动创建并添加 `package`, Xcode 内置了 SPM 功能, 只需要按照下图操作即可

![himg](https://a.hanleylee.com/HKMS/2020-03-02-140954.png?x-oss-process=style/WaMa)

## 参考

- [生產力再提升: 利用 Swift Package Manager 製作自動化開發者工具](https://www.appcoda.com.tw/swift-package-manager/)
- [iOS 中的库与框架](https://kingcos.me/posts/2019/libraries_in_ios/)
- [Xcode 工程结构详解](https://segmentfault.com/a/1190000017278975)
- [陈捷大佬](https://kemchenj.github.io/)
- [在 Xcode 中使用 Swift Package](https://xiaozhuanlan.com/topic/9635421780)
