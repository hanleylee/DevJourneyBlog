---
title: 快速实现 iOS 全局黑白主题
date: 2022-12-03
comments: true
path: ios_global_gray_theme
categories: iOS
tags: ⦿ios, ⦿ui
updated:
---

近期很多 app 都使用了黑白主题悼念领导人离世. 缅怀的同时, 作为技术人我实现的技术方案也很感兴趣, 网上搜索了下, 目前无外乎有如下方案:

1. 统一根据后台接口返回信息对 `UIImage` `UIColor` 做统一处理
2. 在 window 上加一层黑白滤镜, 该 window 上面的所有 UI 元素都会被应用次滤镜

<!-- more -->

第一种方案不需要多说, 只要保证全局调用 UIImage 和 UIColor 调用的是同一个公共 API, 然后在 API 中根据后台下发的主题做相应逻辑变换即可, 如果之前没有统一 API 调用, 那么使用 runtime 方法交换也能达到相同目的.

不过本文的重点不在于第一种方案, 我在看某些 app 的时候, 发现 app 内所有内容都是黑白的(包括弹窗都是黑白的)

通过一些逆向手段看到图片以及颜色其实在底层并没有改变, 只是在 window 上添加了一层滤镜, 在 StackOverflow 上搜索了一下, 果然找到了有用信息: [Draw a UIView in greyscale?](https://stackoverflow.com/a/67436327/11884593)

在 Appdelegate 中使用如下方式即可:

```swift
func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // ...
    let grayLayer = CALayer()
    grayLayer.frame = .init(x: 0, y: 0, width: 300, height: 300)
    grayLayer.compositingFilter = "colorBlendMode"
    grayLayer.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
    grayLayer.zPosition = .infinity
    window?.layer.addSublayer(grayLayer)
    return true
}
```

以上方式会将 window 上面的所有 UI 元素都应用黑白滤镜, 不留死角, 黑白地更彻底

## Ref

- [Draw a UIView in greyscale?](https://stackoverflow.com/a/67436327/11884593)
