---
title: Swift 中如何避免精度丢失
date: 2020-12-26
comments: true
path: precision-loss-in-swift
categories: iOS
tags: ⦿swift, ⦿precision-loss
updated:
---

如果你开发过涉及金额计算的 iOS app, 那么你很有可能经历过在使用浮点型数字时精度丢失的问题

![himg](https://a.hanleylee.com/HKMS/2020-12-26215512.png?x-oss-process=style/WaMa)

<!-- more -->

让我们来看看为什么会丢失以及如何解决吧

## 浮点型数字的数值精度为何会丢失?

这里我不想系统地讲解浮点型是如何由基数尾数指数组成的, 直接说原因: 因为用二进制能表示的以 2 为底的指数必然是 2 的倍数, 也就是说只能为 `0.5`, `0.25`, `0.125`... 以此类推, 那么我们就可以发现无论将这些数字怎么组合, 都不可能达到 `0.3` 这个值, 因此计算机这个时候会给我们一个最接近 `0.3` 且恰好是这些数字之和的一个近似值.

![himg](https://a.hanleylee.com/HKMS/2020-12-26221001.png?x-oss-process=style/WaMa)

因此, 对于精度丢失我们可以得出如下结论:

- 在 Swift 里面整数是不会有精度丢失的问题的, 因为整数的跨度为 1, 1 是可以被 2 进制表示出来的
- 由于 Swift 编程语言存储浮点型的方式问题, 浮点型 (`Double`/`Float`) 的精度丢失问题是必然会发生的

## 数值精度丢失的影响

上面我们简单的解释了为什么会丢失精度, 那么精度丢失对我们在什么时候有影响呢?

根据我的经验, 我认为主要场景集中如下:

- 在需要将数字以字面值向外界展示的时候
- 在需要将数字发向服务器进行严格对比 (每一位都不能有差别)

所以, 精度丢失并不可怕 (起码出现的场景很少). 下面让我们看下如何才能在我们真的遇到了精度丢失问题时候进行解决

## 如何应对数值精度丢失

1. 计算过程中全程使用 `Double`, 最后转为字符串

    由于 Swift 在精度丢失时会在保留很多位小数 (比如 `0.3` 存储为 `0.29999999999999999`), 这些小数与真实值的差距非常之小, 因此我们完全可以在过程中不对其进行任何操作, 仍然让其保持 `Double` 类型, 在最后时刻要发往服务器或者显示的时候我们将其四舍五入转换为字符串, 这样的结果基本不会出错.

    但是切记一定不要在计算过程中进行四舍五入, 否则极有可能会造成误差的累计, 从而导致误差变大不可接受.

2. 以 `Decimal` 格式进行接收并计算

    上面的方式简单, 只需要注意在最后时刻进行一次字符串转换即可, 但是有缺陷: **必须让服务器将原本的数字类型转为以字符串类型来接收**, 这并不是一种友好的方式. 那么我们到底有没有办法让 app 向服务器发送一个带有精度不丢失的浮点数字的 `json` 数据包呢? 比如 `{"num": 0.3}`, 而不是 `{"num": 0.29999999999999999}`

    答案是可以. Swift 为我们提供了用于十进制计算的一个类型: `Decimal`, 这个类型也带有 `+`, `-`, `*`, `/` 运算符, 并且支持 `Codable` 协议, 我们完全可以定义此类型接受服务器的参数值, 然后以此类型进行运算然后使用, 最后, 因为其支持 `Codable` 协议, 我们可以将其值直接放入 json 包中.  没有特殊情况的话我们就完全避开了二进制浮点型数字了, 这样是不会有任何的误差的

    ![himg](https://a.hanleylee.com/HKMS/2020-12-26225425.png?x-oss-process=style/WaMa)

    ![himg](https://a.hanleylee.com/HKMS/2020-12-26230733.png?x-oss-process=style/WaMa)

## NSDecimalNumber 与 Decimal 区别

`NSDecimalNumber` 是 `NSNumber` 的一个子类, 比 `NSNumber` 的功能更为强大, 四舍五入, 取整, 输入后自动去掉数值前面无用的 0 等等. 由于 `NSDecimalNumber` 精度较高, 所以会比基本数据类型费时, 所以需要权衡考虑, 苹果官方建议在货币以及要求精度很高的场景下使用.

通常情况下我们会使用 `NSDecimalNumberHandler` 这个格式化器对其需要约束的格式进行设置, 然后构建出需要的 `NSDecimalNumber`

```swift
let ouncesDecimal: NSDecimalNumber = NSDecimalNumber(value: doubleValue)
let behavior: NSDecimalNumberHandler = NSDecimalNumberHandler(roundingMode: mode,
                                                              scale: Int16(decimal),
                                                              raiseOnExactness: false,
                                                              raiseOnOverflow: false,
                                                              raiseOnUnderflow: false,
                                                              raiseOnDivideByZero: false)
let roundedOunces: NSDecimalNumber = ouncesDecimal.rounding(accordingToBehavior: behavior)
```

`NSDecimalNumber` 与 `Decimal` 基本是无缝桥接的, `Decimal` 是一个值类型 `Struct`, `NSDecimalNumber` 是一个引用类型 `Class`, 看起来 `NSDecimalNumber` 的设置功能更为丰富, 但是如果只是需要对位数, 四舍五入方式有要求的话 `Decimal` 也完全可以满足, 而且性能会更好, 所以我认为 `NSDecimalNumber` 仅在 `Decimal` 无法实现某个功能时才作为备用考虑.

总的来说, `NSDecimalNumber` 与 `Decimal` 的关系类似 `NSString` 与 `String` 的关系.

## `Decimal` 的正确使用方式

### 正确使用 `json` 反序列化对 `Decimal` 进行赋值 -- 使用 `ObjectMapper`

当我们声明一个 `Decimal` 属性后, 然后使用一个 `json` 字符串对其进行赋值, 我们会发现精度仍然丢失了, 为什么会有这样的结果呢?

```swift
struct Money: Codable {
    let amount: Decimal
    let currency: String
}

let json = "{\"amount\": 9021.234891,\"currency\": \"CNY\"}"
let jsonData = json.data(using: .utf8)!
let decoder = JSONDecoder()

let money = try! decoder.decode(Money.self, from: jsonData)
print(money.amount)
```

![himg](https://a.hanleylee.com/HKMS/2020-12-26231824.png?x-oss-process=style/WaMa)

答案是简单的: 我们使用的 `JSONDecoder()` 内部使用了 [`JSONSerialization()`](https://developer.apple.com/documentation/foundation/jsonserialization) 进行反序列化, 其逻辑非常简单, 在碰到 `9021.234891` 这个数字时, 其会毫不犹豫的将其看做 `Double` 类型, 然后再将 `Double` 转为 `Decimal` 是可以成功的, 但是这个时候已经是精度丢失的 `Double` 了, 转换得来的 `Decimal` 类型自然也是精度丢失的.

对于这个问题, 我们必须要能够控制其反序列化过程. 我现在的选择方案是使用 `ObjectMapper`, 其可以使用自定义规则灵活控制序列化与反序列化的过程.

`ObjectMapper` 默认情况下是不支持 `Decimal` 的, 我们可以自定义一个支持 `Decimal` 类型的 `TransformType`, 如下:

```swift
open class DecimalTransform: TransformType {
    public typealias Object = Decimal
    public typealias JSON = Decimal

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Decimal? {
        if let number = value as? NSNumber {
            return Decimal(string: number.description)
        } else if let string = value as? String {
            return Decimal(string: string)
        }
        return nil
    }

    open func transformToJSON(_ value: Decimal?) -> Decimal? {
        return value
    }
}
```

然后将此 `TransformType` 应用于我们需要转换的属性上

```swift
struct Money: Mappable {
    var amount: Decimal?
    var currency: String?

    init() { }
    init?(map: Map) { }

    mutating func mapping(map: Map) {
        amount <- (map["amount"], DecimalTransform())
        currency <- map["currency"]
    }
}
```

![himg](https://a.hanleylee.com/HKMS/2020-12-31-011958.png?x-oss-process=style/WaMa)

### 正确使用 `Decimal` 的初始化方式

`Decimal` 有多种初始化方式, 我们可以传入整型值, 传入浮点型, 传入字符串方式进行初始化, 我认为正确的初始化方式应该是使用字符串.

![himg](https://a.hanleylee.com/HKMS/2020-12-26233721.png?x-oss-process=style/WaMa)

上面这张图应该很简单明了的说明了我为什么这么认为了. 其原因与上个反序列问题相似, 也是因为我们传入 `Double` 时, Swift 对其进行了一次承载, 这一次承载就对其造成了精度丢失, 根据已经丢失精度的 `Double` 初始化出 `Decimal`, 这个 `Decimal` 是精度丢失的也就不难理解了

## 最后

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow

## 参考

- [Decoding money from JSON in Swift](https://medium.com/wultra-blog/decoding-money-from-json-in-swift-d61a3fcf6404)
