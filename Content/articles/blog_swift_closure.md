---
title: Swift 之闭包
date: 2019-11-22
comments: true
path: closure-in-swift
categories: iOS
tags: ⦿swift, ⦿closure
updated:
---

Swift 中闭包相关使用要点

<!-- more -->

- 在闭包环境中的 `self` 不可省略, 否则报错!
- 闭包在传递的时候是不执行的, 传递时只作为参数传递, 只有在后面加上 `()` 才会确定要执行.
- `storyboard` 创建视图控制器必须通过 `storyboard` 的方式或者 `segue` 的 `destination` 的方式去获得, 仅仅通过 `ViewController()` 的方式去获得是没用的.
- 闭包即是没有名字的函数, 方法转为闭包的步骤:
    - 删除名字
    - 将参数和回传值放入大括号内
    - 加入 `in`
- 闭包原始状态

    ```swift
    {(parameters: type) -> return type in
        return statements
    }
    ```

## 简写 `Closure` 步骤

1. 已经能够确认参数与回传值的类型的话可以删除 closure 里面参数跟回传值的类型
2. 代码只有一行的情况下可以删除 `return`
3. 可以用 `$0,` `$1`, `$2` 等代替传进来的参数名称
4. 如果是最后一个参数, 可以把 closure 移至参数小括号外 (尾随闭包概念)
5. 进一步, 如果还是唯一一个参数, 可以省略小括号 (尾随闭包概念)

## 尾随闭包

```swift
var names = ["li", "wang", "zhang"]
// 完整写法
var reversedNames = names.sorted {(n1, n2) -> Bool in
    n1 > n2
}
// 在明确传入的参数及返回类型后, 可以直接省略参数名称及 return, 改用 $0 及 $1 代替
reversedNames = names.sorted(by: {$0> $1})
// 尾随闭包: 可以把 closure 移至参数小括号外
reversedNames = names.sorted() {$0 < $1}
// 尾随闭包: 闭包是函数唯一参数时, 可以省掉参数括号
reversedNames = names.sorted {$0 < $1}
```

## 闭包传值

```swift
// 目标: 从 ` 第二个界面 ` 将值传递到 ` 第一个界面 `

// 第一个界面

import UIKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! MyViewController
        desti.myClosure = {(str) -> () in
            print(str)
        }
    }
}

// 第二个界面

import UIKit

typealias customClosure = (_ paramOne: String) -> ()
class MyViewController: UIViewController {
    var myClosure: customClosure?

    @IBAction func confirmButton(_ sender: UIButton) {
        if self.myClosure != nil {
            self.myClosure!("成功打印")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
```

## 逃逸闭包与非逃逸闭包

当闭包作为一个实际参数传递给一个函数或者变量的时候, 我们就说这个闭包逃逸了, 可以在形式参数前写 `@escaping` 来明确闭包是允许逃逸的. 非逃逸闭包, 逃逸闭包, 一般都是当做参数传递给函数

- *非逃逸闭包*: 闭包调用发生在函数结束前, 闭包调用在函数作用域内
- *逃逸闭包*: 闭包有可能在函数结束后调用,

闭包调用逃离了函数的作用域, 需要通过 `@escaping` 声明

除了作为函数的即时参数传入的闭包是非逃逸的, 其他类型的都是逃逸的. **逃逸闭包的生命周期长于函数, 函数退出的时候, 逃逸闭包的引用仍被其他对象持有, 不会在函数结束时释放**

非逃逸闭包不会产生循环引用, 它会在函数作用域内释放, 编译器可以保证在函数结束时闭包会释放它捕获的所有对象.  使用非逃逸闭包可以使编译器应用更多强有力的性能优化, 例如, 当明确了一个闭包的生命周期的话, 就可以省去一些保留 (`retain`) 和释放 (`release`) 的调用. 非逃逸闭包它的上下文的内存可以保存在栈上而不是堆上

下面是使用逃逸闭包的 2 个场景:

- 异步调用: 如果需要调度队列中异步调用闭包,  这个队列会持有闭包的引用, 至于什么时候调用闭包, 或闭包什么时候运行结束都是不可预知的.
- 存储: 需要存储闭包作为属性, 全局变量或其他类型做稍后使用.

    ```swift
    class ViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            getData {(data) in
                print("闭包结果返回 --\(data)--\(Thread.current)")
            }
        }
        func getData(closure:@escaping (Any) -> Void) {
            print("函数开始执行 --\(Thread.current)")
            DispatchQueue.global().async {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2, execute: {
                    print("执行了闭包 ---\(Thread.current)")
                    closure("345")
                })
            }
            print("函数执行结束 ---\(Thread.current)")
        }
    }
    ```

    输出结果

    ```swift
    函数开始执行 --\<NSThread: 0x600000072f40\>{number = 1, name = main}
    函数执行结束 ---\<NSThread: 0x600000072f40\>{number = 1, name = main}
    执行了闭包 ---\<NSThread: 0x600000072f40\>{number = 1, name = main}
    闭包结果返回 --345--\<NSThread: 0x600000072f40\>{number = 1, name = main}
    ```

    ``` swift
    class ViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            handleData {(data) in
                print("闭包结果返回 --\(data)--\(Thread.current)")
            }
        }
        func handleData(closure:(Any) -> Void) {
            print("函数开始执行 --\(Thread.current)")
            print("执行了闭包 ---\(Thread.current)")
            closure("4456")
            print("函数执行结束 ---\(Thread.current)")
        }
    }
    ```

    输出结果

    ```swift
    函数开始执行 --\<NSThread: 0x6000000fe8c0\>{number = 1, name = main}
    执行了闭包 ---\<NSThread: 0x6000000fe8c0\>{number = 1, name = main}
    闭包结果返回 --4456--\<NSThread: 0x6000000fe8c0\>{number = 1, name = main}
    函数执行结束 ---\<NSThread: 0x6000000fe8c0\>{number = 1, name = main}
    ```

### 为什么要分逃逸闭包和非逃逸闭包

为了管理内存, 闭包会强引用它捕获的所有对象, 比如你在闭包中访问了当前控制器的属性, 函数, 编译器会要求你在闭包中显示 `self` 的引用, 这样闭包会持有当前对象, 容易导致循环引用.

而对于非逃逸闭包:

- 非逃逸闭包不会产生循环引用, 它会在函数作用域内释放, 编译器可以保证在函数结束时闭包会释放它捕获的所有对象.
- 使用非逃逸闭包可以使编译器应用更多强有力的性能优化, 例如, 当明确了一个闭包的生命周期的话, 就可以省去一些保留 (`retain`) 和释放 (`release`) 的调用.
- 非逃逸闭包它的上下文的内存可以保存在栈上而不是堆上.

综上所述, 如果没有特别需要, 开发中使用非逃逸闭包是有利于内存优化的, 所以苹果把闭包区分为两种, 特殊情况时再使用逃逸闭包.

## 闭包的循环引用

Swift 中类型对其中拥有的属性都是强引用类型, 如果类型强引用了闭包, 然后在闭包内又指定声明了 `self.xxx`, 那么就会造成循环引用, 导致类型与闭包均不能被释放.

### 典型案例

下面这个例子中, 闭包 `printName` 被 `Person` 持有 (强引用), 然后在闭包 `printName` 中又指定声明了 `self.name`, 因此会造成强引用, `test()` 方法结束后,
方法内部的 `person` 实例也不会被释放

```swift
class Person {
    var name: String
    lazy var printName: () -> () = {
        print("\(self.name)")
    }

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) 被销毁")
    }
}

func test() {
    let person = Person.init(name: "小明")
    person.printName()
}

test()

// result: 小明
```

### 闭包循环引用的解决办法

导致循环引用的根本原因在于两者之间相互强引用, 因此我们可以使用在一方引用另一方时声明弱引用或无主引用来解决强引用问题, 关键字为 `weak`, `unowned`.

> 苹果官方建议: 如果可以确定 self 在访问时不会被释放的话, 使用 unowned, 如果 self 存在被释放的可能性就使用 weak

```swift
class Person {
    var name: String
    lazy var printName: () -> () = { [weak self] in
        print("\(self?.name)")
    }

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) 被销毁")
    }
}

func test() {
    let person = Person.init(name: "小明")
    person.printName()
}

test()

// result:
// Optional("小明")
// 小明 被销毁
```

解决循环引用的方法就是在闭包中加入 `[weak self]` 弱引用声明, 这样能保证在 `test()` 方法执行完后, 方法中的 `person` 实例被释放

### 闭包不会被循环引用的情况

> 原则: 只有在 `self` 持有闭包的时候 (即闭包是 `self` 的属性), 且闭包又引用了 `self` 时才会发生循环引用

- 当闭包作为方法参数的时候, 即便闭包中会持有 self, 也不会引起循环引用.
- `DispatchQueue`, `UIView 的动画` 等闭包

    我们使用的 `UIView 的动画`, `DispatchQueue` 等其实都是闭包被系统所持有的, 并不是被 `self` 持有, 因此闭包与 `self` 之间不构成循环关系

    ```swift
    UIView.animate(withDuration: TimeInterval) { }
    DispatchQueue.main.async { }
    ```

    示例如下:

    ```swift
    class Person {
        var name: String
        lazy var printName: () -> Void = {
             print(self.name)
            self.printName = {}
        }

        init(name: String) {
            self.name = name
        }

        deinit {
            print("\(name) 对象被销毁")
        }

        func delay2(_ duration: Int) {
            let times = DispatchTime.now() + .seconds(duration)
            DispatchQueue.main.asyncAfter(deadline: times) {
                print("------- 开始执行闭包 --------")
                print(self.name)
                print("------- 结束执行闭包 ---------")
            }
        }
    }

    func test2() {
        let person = Person.init(name: "小明")
        person.delay2(2)
    }

    test2()

    // result:
    // ------- 开始执行闭包 --------
    // 小明
    // ------- 结束执行闭包 ---------
    // 小明对象被销毁
    ```

    在上面的例子中, `DispatchQueue` 中的闭包持有了 `self`, 但是其并没有被 `self` 持有此闭包, 而是被系统持有, 因此不构成循环引用, `self` 可以被正确释放

## 闭包的值拷贝与引用

一般情况下, 闭包捕获的是引用, 当闭包执行时 `closure()`, 对值进行调用, `i` 此时的值为几, 所捕获到的 `i` 就是几.

```swift
    var i = 1
    let closure = {
        i += 1
        print("closure \(i)")
    //    return i
    }
    i += 1
    print("out1 \(i)") //out1 2
    closure() //closure 3
    print("out2 \(i)") //out2 3
```

如果需要在定义时即开始捕获其值 (值拷贝), 则需要用到捕获列表概念. 闭包在定义时⽴即捕获列表中所有变量, 并将捕获的变量⼀律改为常量, 供⾃己使用.

```swift
    var i = 1
    let closure = {[i] in
        print("closure \(i)")
    }
    i += 1
    print("out1 \(i)") //out1 2
    closure() //closure 1
    print("out 2 \(i)") //out2 2
```

另一个佐证示例:

```swift
var test = {
    print("first")
}

DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
    test()
}

test = {
    print("second")
}

// result: second
```
