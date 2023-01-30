---
title: 一种简单的 iOS 暗黑模式实现方案(支持低版本)
date: 2021-01-09
comments: true
path: implementation-of-dark-mode
categories: iOS
tags: ⦿ios, ⦿theme, ⦿dark
updated:
---

说说最近对于 iOS 系统黑暗主题适配(兼容iOS 13 以下版本)的方案研究.

![himg](https://a.hanleylee.com/HKMS/2021-01-10192257.jpg?x-oss-process=style/WaMa)

<!-- more -->

`iOS 13` 开始 Apple 在系统层面支持了黑暗模式, 现在很多 App 也都支持了黑暗模式. 也有关于黑暗模式的很多成熟的开源实现方案, 按道理我没有必要再去自己实现一套了. 但是在调查了相关方案实现后我发现还是有一种更轻量, 代码侵入更小, 更符合 Apple 风格而且学习及迁移成本都很小的方案.

## 方案概述: 原生 + 置换 window 的 rootViewController

这套方案的核心思想是非常简单的:

- 利用对系统版本的判断来生成一个颜色
    - `iOS 13` 及以上返回系统支持的动态颜色 `init(dynamicProvider: @escaping (UITraitCollection) -> UIColor)`,
    - 其他低版本系统则使用根据用户所设置的主题所对应的颜色.
- 在切换的时候也会判断版本
    - `iOS 13` 及以上版本直接设置 `window` 的 `overrideUserInterfaceStyle`
    - 其他低版本整个初始化 VC 然后将 VC 设置为 `window` 的 `rootViewController`

具体代码实现如下

## 设置可切换的主题

在这一步我们设置需要支持的主题数量

```swift
enum Theme: Int, CaseIterable {
    case none = 0
    case light = 1
    case dark = 2

    var title: String {
        switch self {
            case .none: return "Follow"
            case .light: return "Light"
            case .dark: return "Dark"
        }
    }

    @available(iOS 13.0, *)
    var mode: UIUserInterfaceStyle {
        switch self {
            case .none: return .unspecified
            case .light: return .light
            case .dark: return .dark
        }
    }
}
```

## 设置颜色/图片

```swift
class Tools {
    @UserDefaultStorage(keyName: "appTheme")
    static var _style: Int? // 此处用于全局存储 UserDefaults 属性

    static var style: Theme {
        get { return Theme(rawValue: (_style ?? 0)) ?? .dark }
        set { _style = newValue.rawValue }
    }

    /// 创造颜色, 核心方法
    static func makeColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { $0.userInterfaceStyle == .light ? light : dark }
        } else {
            return Tools.style == .light ? light : dark
        }
    }

    /// 创造 img, 核心方法
    static func makeImage(light: UIImage, dark: UIImage) -> UIImage {
        if #available(iOS 13.0, *) {
            let image = UIImage()
            image.imageAsset?.register(light, with: .init(userInterfaceStyle: .light))
            image.imageAsset?.register(dark, with: .init(userInterfaceStyle: .dark))
            return image
        } else {
            return Tools.style == .light ? light : dark
        }
    }
```

## 切换主题

```swift
func changeTheme(theme: Theme) {
    Tools.style = theme
    guard let window = UIWindow.hl.getKeyWindow() else { return }
    if #available(iOS 13.0, *) {
        window.overrideUserInterfaceStyle = theme.mode
    } else {
        guard let rootVC = window.rootViewController else { return }
        let tabbar = Tools.setTabVC(withIndex: self.index)
        window.rootViewController = tabbar
    }
}
```

## 系统启动时检查全局设置的 `style` 属性

很多产品的要求是可以自由切换黑暗与白天模式, 在使用自定义模式的时候就不跟随系统了, 因此如果有这样的需求的话就需要在启动时进行判断并设置

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
                 -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)

    // 如果是 iOS
    if #available(iOS 13.0, *) {
        window?.overrideUserInterfaceStyle = Tools.style.mode
    }

    window?.rootViewController = Tools.getTabVC(withIndex: 0)
    window?.makeKeyAndVisible()

    return true
}
```

## 其他主流方案

在主题调研的这几天内也看了一些开源实现的第三方库, 说说对于这几个库的看法吧, 也可以让以后人少走点弯路

### [RxTheme](https://github.com/RxSwiftCommunity/RxTheme)

- 属于 Rx 社区的一个产品, 其方案的实现基于 `RxSwift`.
- 实现的方式是通过 `Rx` 的绑定建立关系, 每个 view 的颜色的绑定关系有该 view 进行持有, 在收到信号后进行改变主题颜色
- 因为其实现是基于协议, 因此如果是组件化开发的话必须把所有颜色全部集中管理在一个组件中, 其他组件很难进行颜色的扩展添加.
- 该库缺少很多属性的扩展, 如果碰到一个自己需要的且恰好该库没有的属性时需要进行相应二次扩展

### [SwiftTheme](https://github.com/wxxsw/SwiftTheme)

`SwiftTheme` 是一个很经典的 Swift 语言写的主题方案了.

- 实现的方式是对 `NSObject` 扩展出一个 `Dictionary` 存储属性, 在其中存储所有的要调用的方法, 然后在用户触发开关后以 `Notification` 的方式进行 notify, 收到 `Notification` 后对`Dictionary` 进行遍历, 将其中含的所有方法名在 `runtime` 中进行呼叫, 这样就达到了属性值改变的效果
- 属性扩展较全面, 很少有属性是该库没有考虑到的
- 因为扩展了所有原生控件的属性(前缀名是 `theme_`, 我们在赋值时就是对自定义出来的属性进行赋值, 因此如果使用了某些不支持暗黑模式的第三方 UI 控件库, 处理会很麻烦, 大概率需要手动修改源码
- 因为其实现方案基于通知, 在 `view` 数量级较多情况下性能可能会存在问题

## 本方案总结

基于对上面几种开源主流方案的对比, 本方案有着以下的优缺点:

- 优点

    - 代码侵入(改动成本)小
    - 性能无压力
    - 无第三方库依赖
    - 以后可以平滑切换到 iOS 13
    - 系统级动画

- 缺点

    - 只支持黑暗与明亮模式(也可以支持到其他主题, 但是那样的话即使是 iOS 13 以上设备也需要使用置换 `rootViewController` 的方案了)
    - 所有涉及到 CGColor 的 view 需要实现 `traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)` 方法
    - `iOS 12` 及以下系统切换时需要重置 `rootViewController`, 因此所有 vc 都会被释放掉再重建, 即如果其他页面有正在操作的逻辑, 那么就会丢失现场

总的来说, 本方案相当于提供了一种实现主题的精简型方案.

## Demo

`Talk is cheap, show me the code!`

基于本文思路的实现 Demo: <https://github.com/HanleyLee/DarkModeDemo>

## 最后

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow
