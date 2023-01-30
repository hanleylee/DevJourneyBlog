---
title: Swift 5.x 实用新特性分享
date: 2020-10-31
comments: true
path: new-feature-of-swift-after-5
categories: iOS
tags: ⦿ios, ⦿feature, ⦿swift, ⦿swift5
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-11-10-121808.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 多尾闭包

```swift
// old, 传统完整写法
UIView.animate(withDuration: 0.3, animations: {
    self.view.alpha = 0
}, completion: { _ in
    self.view.removeFromSuperview()
})
// still old, 单尾闭包精简写法
UIView.animate(withDuration: 0.3, animations: {
    self.view.alpha = 0
}) { _ in
    self.view.removeFromSuperview()
}

// new(Swift 5.3)

UIView.animate(withDuration: 0.3) {
    self.view.alpha = 0
} completion: { _ in
    self.view.removeFromSuperview()
}
```

闭包现在都可以放在圆括号外面了, 但是, 这些尾闭包中的第一个闭包的标签会被强制省略, 即 `animations` 标签被强制省略 (加上了是编译不过的).

改动的原因还是为了让 `SwiftUI` 更方便地使用含多个闭包值的一些 `View`, 比如 `Button` 等

多尾闭包是 `Swift 5.3` 发布的所有新特性中引起争议最大的, 因为现在当我们写一个含多闭包的方法时会有三种选择 (因为兼容原因, 第二种写法是不可能被废弃掉的)

## implict self(self 的隐式声明)

在 `Swift 5.2` 之前, 如果我们要在 `escaping closure` 中使用 `instance method` 或 `property`, 那么我们必须显式声明 `self`

在 `Swift 5.3` 之后, 两种情况下我们可以不再显式声明 `self`

- 当 `self` 是 `value type` 时

    ```swift
    struct ContentView: View {
        @State private var number = 1
        var body: some View {
            Button(action: {
                number = Int.random(in: 1...6)
            }, label: {
                Image(systemName: "\(number).circle")
                    .resizable()
                    .scaledToFit()
            })
            .onAppear {
                number = Int.random(in: 1...6)
            }
        }
    }
    ```

- `capture list` 中捕获了 `self` 时 (但如果加入了 `weak` 的话还是需要声明 `self` 的)

    ```swift
    // capture list 中捕获了 self 时
    DispatchQueue.main.async {[self] in
        imageView.image = image
    }

    // 但是如果加上了 weak 的话还是需要声明 self 的
    DispatchQueue.main.async {[weak self] in
        self?.imageView.image = image
    }
    ```

## 属性包装器

### 定义

```swift
import Foundation

@propertyWrapper
struct UserDefaultStorage<T: Codable> {
    var value: T?

    let keyName: String

    let queue = DispatchQueue(label: (UUID().uuidString))

    init(keyName: String) {
        value = UserDefaults.standard.value(forKey: keyName) as? T
        self.keyName = keyName
    }

    // 必须实现
    var wrappedValue: T? {

        get {value}

        set {
            value = newValue
            let keyName = self.keyName
            queue.async {
                if let value = newValue {
                    UserDefaults.standard.setValue(value, forKey: keyName)
                } else {
                    UserDefaults.standard.removeObject(forKey: keyName)
                }
            }
        }
    }

    // 映射值, 可不实现
    var projectedValue: UserDefaultStorage<T> { return self }

    // var projectedValue: Int {
    //     get {return 2}
    //     set {print(newValue) }
    // }


    func foo() { print("Foo") }
}
```

- `wrappedValue`

    调用包装属性时的直接交互项, 通过 `set` 和 `get` 可以取值及赋值

- `projectedValue`

    通过 `$` 进行调用, 也可以设置 `set` 与 `get` 来控制取值及赋值

### 用法

```swift
@UserDefaultStorage(keyName: "monitorBarRatio")
var monitorBarRatioKey: Double?

monitorBarRatioKey = Double(monitorBar.center.y / view.bounds.height)

// 通过调用 projectedValue, 从而获得其本身, 进而调用 foo() 函数
$monitorBarRatioKey.foo() // "Foo"
```

### 何时使用

任何涉及到多个部分统一逻辑处理属性值的地方都可以使用属性包装器进行代码语法的优化.

## Opaque Result Type(不透明结果类型)

写法: `some + 协议名`

### 前菜

一般情况下我们可以将协议作为一个函数的返回值

```swift
protocol P { }

struct T: P { }

func makeA() -> P {
    return T()
}
```

但是一个协议中含有 `associatedType` 或 `Self` 时, 那么将其作为返回值就是有问题的

```swift
func makeInt() -> Equatable {
    return 1 // ❌ Protocol 'Equatable' can only be used as a generic constraint because it has Self or associated type requirements
}
```

这个时候我们可以使用不透明结果泛型, 即:

```swift
func makeInt() -> some Equatable {
    return 1
}
```

### 特点

```swift
func makeInt() -> some Equatable {
    return 1
}

func makeStr() -> some Equatable {
    return "hello"
}

let int1 = makeInt() // 1
let int2 = makeInt() // 1
let str = makeStr() // "hello"
```

不透明结果泛型有以下特点:

- 尽管具体类型永远不会暴露给函数的调用者, 但返回值仍保持强类型, 即编译器知道具体的类型
- 不透明类型是一种特殊的泛型: 泛型受调用者约束, 不透明类型受实现者约束. 因此不透明类型有时称为 `反向泛型`
- 允许带有 `Self` 或者 `associatedtype` 的 `protocol` 作为返回类型
- 对于不同类型的不透明类型, 编译器会直接判断为不能比较; 同类型的不透明类型, 会根据其真正的基础类型进行判断

    ```swift
    let bool1 = int1 == int2 // ✅ // 同类型的不透明类型, 根据真正的基础类型判断为可比较
    let bool2 = int1 == str // ❌ Binary operator '==' cannot be applied to operands of type 'some Equatable' (result of 'makeInt()') and 'some Equatable' (result of 'makeStr()')

    var x: Int = 0
    x = makeInt() // ❌ 不同类型的不透明类型, 不可比较不可赋值 (Compilation error: Cannot assign value of type 'some Equatable' to type 'Int')
    ```

- 一个函数每次必须返回相同的不透明类型

    ```swift
    func makeOneOrA(_ isOne: Bool) -> some Equatable {
        return isOne ? 1 : "A" // ❌ 一个函数每次必须返回相同的不透明类型 (Compilation error: Cannot convert return expression of type 'Int' to return type 'some Equatable')
    }
    ```

### 不透明类型与协议的结合

- 我们不能从函数返回带有 `Self` 或 `associatedtype` 要求的协议. 但是却可以返回不透明类型:

    ```swift
    // Equatable protocol declaration from the Swift standard library

    public protocol Equatable {
        static func == (lhs: Self, rhs: Self) -> Bool
    }

    func makeTwo() -> Equatable { 2 } // ❌ Protocol 'Equatable' can only be used as a generic constraint because it has Self or associated type requirements

    func makeThree() -> some Equatable { 3 } // ✅
    ```

- 一个函数可以返回不同的协议类型, 但必须返回相同的不透明类型:

    ```swift
    protocol P {}

    extension Int: P {}
    extension String: P {}

    func makeIntOrString(_ isInt: Bool) -> P { isInt ? 1 : "1" } // ✅

    func makeIntOrStringOpaque(_ isInt: Bool) -> some P { isInt ? 1 : "1" } // ❌ Compilation error
    ```

## `enum comparable`

为枚举遵守 `Comparable` 协议后即可直接比较大小

```swift
enum Membership: Comparable {
    case premium(Int)
    case preferred
    case general
}

let a = Membership.premium(10)
let b = Membership.general
print(b> a) // true
```

## 在 `map`, `compactMap`, `filter` 中使用 `keyPath` 代替闭包使用

```swift
struct User {
    let firstName: String
    let lastName: String
}

let harry = User(firstName: "Harry", lastName: "Potter")
let hermione = User(firstName: "Hermione", lastName: "Granger")
let ron = User(firstName: "Ron", lastName: "Weasley")
let users = [harry, hermione, ron]

let oldFirstNames = users.map { $0.firstName } // before Swift 5.2

let newFirstNames = users.map(\.firstName) // Swift 5.2

let lastNames = users.compactMap(\.lastName)
```

### 实现原理

使用 `KeyPath<Element, Value>` 从实例属性取出属性值

```swift
// 给 Sequence 添加 KeyPath 版本的方法
extension Sequence {
  func map<Value>(keyPath: KeyPath<Element,Value>) -> [Value] {
    return self.map{$0[keyPath: keyPath]}
  }
}
```

### 缺点

- 只能用于存储属性, 不能用于计算属性或实例方法

    ```swift
    // 下面的语法会报错
    let errorSubject = Observable.merge(tacticListError.map(\.networkMsg),
                                        topTacticError.map(\.networkMsg),
                                        renameTacticError,
                                        deleteTacticError.map(\.networkMsg))
    ```

## 为下标设置默认值

`Swift` 的结构体下标方法非常强大, 但是在 `Swift 5.2` 之前我们不能为下标方法的参数指定默认值, 我们可以在下标方法中声明默认值用于 `index` 无效情况下的返回值

```swift
struct Hogwarts {
    var students: [String]
    subscript(index: Int, defaultVal defaultVal: String = "Unknown") -> String {
        if index >= 0 && index < students.count {
            return students[index]
        } else {
            return defaultVal
        }
    }
}
let school = Hogwarts(students: ["Harry", "Hermione", "Ron"])
print(school[0]) // Harry
print(school[5]) // Unknown

print(school[-1, defaultVal: "Draco"]) // 使用自定义默认值
```

## callAsFunction

允许将实例作为函数进行调用, 并且可以在一个类型中重载多个 `callAsFunction` 方法

```swift
struct Adder {
    var base: Int

    func callAsFunction(_ x: Int) -> Int {
        return base + x
    }

    func callAsFunction(_ x: Float) -> Float {
        return Float(base) + x
    }

    func callAsFunction<T>(_ x: T, bang: Bool) throws -> T where T: BinaryInteger {
        if bang {
            return T(Int(exactly: x)! + base)
        } else {
            return T(Int(truncatingIfNeeded: x) + base)
        }
    }
}

let add1 = Adder(base: 1)
add1(2) // => 3
try add1(4, bang: true) // => 5
```

## 多模块初始化方法的公开性

在 `Swift 5.2` 之后没有使用 `open` 或 `public` 声明的指定初始化方法不能在其他模块被呼叫或被子类继承

如果想要在其他模块可以使用指定初始化方法, 那么必须加上 `open` 或 `public`

```swift
// Module A

public struct T1 {
    var num1: Int = 1
    var num2: Int = 2

    init(num1: Int, num2: Int) { // 这里没有使用 public 或 open
        self.num1 = num1
        self.num2 = num2
    }
}

// Module B

let t1 = T1(num1: 0, num2: 1) // error, 不能访问到未公开的指定初始化器
```

## 多模式 `catch`

```swift
do {
    try performTask()
}
catch TaskError.someRecoverableError {
    recover()
}
catch TaskError.someFailure(let msg), TaskError.anotherFailure(let msg) {
    showMessage(msg)
}
```

这消除了在 `catch` 块中使用 `switch case`.

## 为属性或方法实现 `where` 约束

`Swift 5.3` 之后我们可以只针对某一个方法添加 `where` 约束

```swift
protocol P {
    func foo()
}

extension P {
    func foo() where Self: Equatable {
        print("lol")
    }
}
```

## `didSet` 优化

 存储属性中的属性观察者有:

- `willSet`: 可访问 `newValue`
- `didSet`: 可访问 `oldValue`

> 哪怕设置的值与原来的值相同, willSet 和 didSet 都是会被调用的.

以前在为一个设置了 `didSet` 属性观察者的属性进行赋值之后, 该属性的 `getter` 总是会被调用 (调用 `oldValue`), 但是从 `Swift 5.3` 开始, 仅当我们使用 `didSet` 块中的 `oldValue` 参数时, 才调用该方法.

```swift
class Foo {
    var bar = 0 {
        didSet {print("didSet called") }
    }

    var baz = 0 {
        didSet {print(oldValue) }
    }
}

let foo = Foo()
foo.bar = 1 // 不会调用 oldValue
foo.baz = 2 // 会调用 oldValue
```

### 属性观察者特点总结

- 当前类型的 `init` 函数中. 假如有以下 `init` 函数, 在函数中对 `items` 进行赋值并不会触发 `willSet` 和 `didSet`.
- 在构造函数中, 对继承而来的属性设置值会触发父类中的属性观察者的调用.

    ```swift
    class MyContainer: Container {
        var tag: String

        override init() {
            tag = "Leon"
            super.init()
            items = [1,2,3] // 触发父类中的 willSet 和 didSet
        }
    }
    ```

- 可以给继承的属性添加属性观察者, 哪怕继承的是计算属性:

    ```swift
    class MyContainer: Container {
        override var items: [Int] {
            didSet {
            print("didSet is called in the subclass")
            }
        }
    }
    ```

- 如果属性是一个值类型, 调用它的 `mutating` 方法或者直接修改它的值的话会从内到外逐层调用属性观察者.

    ```swift
    struct Container {
        var items = [Int](repeating: 1, count: 100) {
            didSet {
            print("items didSet is called")
            }
        }
    }

    class ViewController: UIViewController {
        var container = Container() {
            didSet {
                print("container didSet is called") // container 改变后会先调用 items 的 didSet, 再调用 container 的 didSet
            }
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            container.items.append(1)
        }
    }
    ```

- 当参数是由 `inout` 修饰的时候, 我们需要知道在函数退出之前, 无论有没有修改, 属性都会被写回, 属性观察者会被调用, 这是由 Swift 内存模型所规定的.

## `SPM` 使用

- 资源: 可以将资源文件与代码打包在一起
- 本地化资源: 可以为 `Swift` 软件包声明本地化的资源
- 二进制分发及依赖: 能够将 `Package` 作为二进制形式进行分发或使用二进制依赖项
