---
title: 在 iOS 16 上一次字符串崩溃的复盘
date: 2022-11-07
comments: true
path: review_of_string_crash_in_ios16
categories: iOS
tags: ⦿ios, ⦿ios16, ⦿crash, ⦿string
updated:
---

运行下面的一段 Swift 代码会发生什么?

```swift
let total = "hello"
let sub = "he"
if let ran = total.range(of: sub) {
    let range = NSRange(ran, in: "")
    print(range)
}
```

答案是不确定, 这与运行时的 iOS 版本和打包的 Xcode 版本都有关系.

<!-- more -->

这个问题也是我们在最近一次线上崩溃中发现的, 在不知道原因的情况下, 我们做了很多测试, 发现如下的结果:

1. Xcode 13 打包出来的 app 运行在任何 iOS 版本系统上都不会崩溃 ✅
2. Xcode 14 打包出来的 app 运行在 iOS 15 及以前的系统上都不会崩溃 ✅
3. Xcode 14 打包出来的 app 运行在 iOS 16 上, 会崩溃 ❌

## 推测

为什么会发生这种现象呢? 尽管当时发现问题之后立刻将代码使用方式进行了改变, 从而避免了崩溃, 但是我们仍对这个崩溃的原因感到莫名其妙. 这段代码在线上运行了数年, 偏偏在我们升级了 Xcode 14 之后运行在最新的 iOS 16 上会出现崩溃现象.

这个问题尤其让我难受, 如鲠在喉. 由于读过喵神的 [Swift ABI 稳定对我们到底意味着什么](https://onevcat.com/2019/02/swift-abi/), 因此我知道自 iOS 12 之后, iOS系统中已经内置了 Swift 运行环境, Xcode 不会再将 Swift 运行环境附带到 ipa 包中了(最低支持版本设为 iOS 13). 也就是说, 使用 Xcode 13 打出来的 app 与 Xcode 14 打出来的 app 运行在 iOS 16 上所使用的 Swift 环境是相同的, 但是为什么 Xcode 14 的 ipa 包会崩溃呢?

经过与同事的讨论分析, 我们初步认定, 可能在 iOS 系统中内置了多个 Swift 版本环境, ipa 包的某个地方有设置我们在启动时需要链接的 Swift 版本环境, 这样才能解释为什么不同版本 Xcode 打出的 ipa 包在同样的系统环境中会有不同的表现.

当然, 以上只是猜想, 我想找出证据, 结果百般搜寻无果.

## 根据源码寻找答案

也许是我找错了方向. 周末的时候, 我再一次想找出这个问题的答案, 之前我都是想通过在 Google 搜索 'app 运行时 swift 版本' 类似的关键字得到答案, 由于失败了太多次, 我这一次准备从崩溃点开始. 既然之前的版本不崩溃, 只在 iOS 16 上崩溃, 那么说明 Swift 的代码 api 肯定被改动了, 而 Swift 的代码是开源的, 我们可以在 github 上找到.

说干就干, 首先我找到崩溃点 `NSRange(ran, in: "")`, 这个是 `NSRange` 的初始化方式, 通过 Xcode 我可以看到其代码签名

```swift
extension _NSRange {
    public init<R, S>(_ region: R, in target: S) where R : RangeExpression, S : StringProtocol, R.Bound == String.Index
}
```

仅仅是代码签名还是不够的, 我们需要看到代码实现. `NSRange` 属于`Foundation` 的一部分, `Foundation` 在 github 的也是开源的, 其开源地址是 <https://github.com/apple/swift-corelibs-foundation>. 进入源码仓库, 找到文件 *./swift-corelibs-foundation/Sources/Foundation/NSRange.swift*, 我们看到如下实现:

```swift
extension NSRange {
    public init<R: RangeExpression, S: StringProtocol>(_ region: R, in target: S)
        where R.Bound == S.Index {
            let r = region.relative(to: target)
            self.init(target._toUTF16Offsets(r))
    }
}
```

因为初始化方式中又调用到了 `_toUTF16Offsets` 方法, 这个方法是 Swift 标准库中的一个方法, 进入 Swift 官方仓库 <https://github.com/apple/swift> 的 *./stdlib/public/core/StringBridge.swift* 文件, 我们看到

```swift
@_specialize(where Self == String)
@_specialize(where Self == Substring)
public // SPI(Foundation)
func _toUTF16Offsets(_ indices: Range<Index>) -> Range<Int> {
    let lowerbound = _toUTF16Offset(indices.lowerBound)
    let length = utf16.distance(
        from: indices.lowerBound, to: indices.upperBound
    )
    return Range(
        uncheckedBounds: (lower: lowerbound, upper: lowerbound + length))
}
```

这里, 又调用到了 `distance` 方法, 这个方法就是我们真正崩溃的位置了, 找到 *./stdlib/public/core/StringUTF16View.swift* 文件, 其中有 `distance` 的实现

```swift
public func distance(from start: Index, to end: Index) -> Int {
    let start = _guts.ensureMatchingEncoding(start)
    let end = _guts.ensureMatchingEncoding(end)

    // FIXME: This method used to not properly validate indices before 5.7;
    // temporarily allow older binaries to keep invoking undefined behavior as
    // before.
    _precondition(
        ifLinkedOnOrAfter: .v5_7_0,
        start._encodedOffset <= _guts.count,
        "String index is out of bounds"
    )
    _precondition(
        ifLinkedOnOrAfter: .v5_7_0,
        end._encodedOffset <= _guts.count,
        "String index is out of bounds"
    )

    if _slowPath(_guts.isForeign) {
        return _foreignDistance(from: start, to: end)
    }

    let lower = _nativeGetOffset(for: start)
    let upper = _nativeGetOffset(for: end)
    return upper &- lower
}
```

在这里我们可以看到 `_precondition(ifLinkedOnOrAfter: , _, "String index is out of bounds")` 这个方法, 这个方法的解释如下:

> FIXME: This method used to not properly validate indices before 5.7;
> temporarily allow older binaries to keep invoking undefined behavior as before.

该注释说明之前此处的范围验证是不恰当的, 但是还需要保持以前的旧二进制功能不变, 因此这个方法只针对 Xcode 编译时使用 Swift 5.7 及以后的 app 生效, 同时我们看看这段代码是什么时候提交的? [2022-05-18](https://github.com/apple/swift/commit/50c2399a949f9c8e76237290d8c10dd4fca2b589)

![himg](https://a.hanleylee.com/HKMS/2022-11-07231125.png?x-oss-process=style/WaMa)

这说明这段代码是在 5.7 版本新加的, 在 Swift 5.6 及以前的版本中是没有这个判断的.

## 结论

到这里基本已经很清晰了, **我们之前的猜想是错误的, iOS 中确实是只有一个 Swift 运行环境的, 在这一个运行环境中, Swift 又能判断 ipa 在被 Xcode 编译时使用的 Swift 版本, 因此可以在运行时条件判断执行相关方法**. 具体到我们的这个崩溃来说:

- 当使用 Xcode 13 编译出的 ipa 包运行在 iOS 16 上时, 虽然 iOS 16 有最新的 Swift 5.7 运行环境, 但是在执行到 `_precondition(ifLinkedOnOrAfter: , _, "String index is out of bounds")` 时, 由于编译时使用的 Swift 在 5.7 之前, 因此不会被其判断执行
- 当使用 Xcode 14 编译出的 ipa 包运行在 iOS 16 上时, 一切条件满足, 进入 `_precondition(ifLinkedOnOrAfter: , _, "String index is out of bounds")` 判断, 满足则通过, 不满足则崩溃
- 当使用 Xcode 14 编译出的 ipa 包运行在 iOS 15 上时, iOS 15 内置的是 Swift 5.6, 因此根本就没有 `precondition(ifLinkedOnOrAfter: , _, "String index is out of bounds")` 的判断, 自然不会崩溃

到这里还有一个问题, iOS 系统中的 Swift 运行时如何知道当前 ipa 在被 Xcode 编译时使用的 Swift 版本呢? 很简单, 每个 Xcode 发行版都会有一个自带的 iOS SDK 版本, 每一个 iOS SDK 版本中都有一个确定的 Swift 版本号, 且在 ipa 包中的 Info.plist 文件中有 `DTSDKName` 属性,  这表明了该 ipa 是在该 sdk 环境下进行编译打包的, 对应的 Swift 版本就是该 sdk 中的 Swift 版本. 这里有一个网站可以让我们方便地查询每个 Xcode 版本对应的 iOS sdk 与 Swift version: <https://xcodereleases.com>

![himg](https://a.hanleylee.com/HKMS/2022-11-07225621.png?x-oss-process=style/WaMa)

## 总结

到这里这个问题就彻底弄清楚了, 在刚开始时由于方向的错误, 导致花费了大量的时间走了弯路, 如果一开始我们就从源码方向着手, 相信会节省很多不必要的时间浪费. 现在反思一下, 平时确实是对底层源码的重视程度不够, 往往只停留在业务层面, 希望在以后的时间中加大对底层知识的挖掘与学习, 共勉!

## Ref

- [How to find the swift version used to build .ipa file](https://stackoverflow.com/questions/70167760/how-to-find-the-swift-version-used-to-build-ipa-file)
- [Swift ABI 稳定对我们到底意味着什么](https://onevcat.com/2019/02/swift-abi/)
