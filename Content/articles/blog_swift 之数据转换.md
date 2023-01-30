---
title: Swift 之数据转换
date: 2020-04-04
comments: true
path: type-transform-of-data-in-swift
categories: iOS
tags: ⦿swift, ⦿convert, ⦿type
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-04-05-DataTypeConvert.png?x-oss-process=style/WaMa)

<!-- more -->

## 基础数据类型转换

基础数据类型在初始化时被确定, 一旦被确定, 就不能改变了, 比如:

```swift
var a = 1
var b:String = a // error: 永远是失败的, 因为 Int 永远不能转为 String
```

如果希望一个变量的类型可以被改变, 那么可以声明类型为 `Any`, 然后在具体使用时使用 `as?` 进行转型

### String <-> Character

```swift
// MARK: - Character -> String
/*
注意: 如果不声明 Character 类型则会自动推断为 String. 而且声明了 Character 之后, 后面只能传入一个字符
如果使用 let cha: Character = "我的" 则会报错
*/
let cha: Character = "我"
let str = String(cha) // 我

// MARK: - String -> Character
/*
注意: 如果 str 中的字符为一个以上, 那么在编译时第二行会报错!
*/
let str = "我"
let cha = Character(str) // 我
```

### Int <-> String

```swift
// MARK: - Int -> String
// 一定能成功
let int = 1
let str = String(int) // 1

// MARK: - String -> Int
// 注意: 如果 str 是字符串, 比如 str = "a", 那么最终的 int 将为 nil
let str = "1"
let int = Int(str) // Optional(1)
```

### Int <-> Double

```swift
// MARK: - Float -> Int
let float = 1.1
let int = Int(float) // 1

// MARK: - Int -> Float
let int = 1
let float = Float(int) // 1.0
```

### Int <-> Float

```swift
// MARK: - Float -> Int
let double = 1.1
let int = Int(double) // 1

// MARK: - Int -> Float
let int = 1
let double = Double(int) // 1.0
```

### Data <-> String

```swift
let str: String = "意大利"
let data = str.data(using: String.Encoding.utf8) // 字符串转Data
let newStr = String(data: data!, encoding: String.Encoding.utf8) // Data转字符串
print("data=", data!, "\n", "newStr=", newStr!)

// 输出: data = 9 bytes
// newStr = 意大利
```

## 其他

### MD5 转换

```swift
extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
}
```
