---
title: Swift 结构化并发
date: 2024-07-03
comments: true
path: swift-structure-concurrent
tags: ⦿swift, ⦿async, ⦿concurrent
updated:
---

<!-- more -->

## Swift 异步函数

Swift 异步函数是构成 Swift 结构化并发的基石之一. Swift 异步函数对我们使用者最大的感受就是调用语法的简化. 以前当我们需要异步加载一个数据时, 我们通常会使用回调的方式:

```swift
func loadSignature(_ completion: @escaping (String?, Error?) -> Void) {
    DispatchQueue.global().async {
        do {
            let d = try Data(contentsOf: someURL)
            DispatchQueue.main.async {
                completion(String(data: d, encoding: .utf8), nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
}
```

`DispatchQueue.global` 负责将任务添加到全局后台派发队列. 在底层, GCD 库 (Grand Central Dispatch) 会进行线程调度, 为实际耗时繁重的 `Data.init(contentsOf:)` 分配合适的线程. 耗时任务在主线程外进行处理, 完成后再由 `DispatchQueue.main` 派发回主线程, 并按照结果调用 `completion` 回调方法. 这样一来, 主线程不再承担耗时任务, UI 刷新和用户事件处理可以得到保障.

异步操作虽然可以避免卡顿, 但是实际使用起来存在不少问题, 包括:

- 对回调函数的调用没有编译器保证, 调用者可能会忘记调用 `completion`, 或者多次调用 `completion`.
- 错误处理隐藏在回调函数的参数中, 无法用 `throw` 的方式明确地告知并强制调用侧去进行错误处理.
- 通过 `DispatchQueue` 进行线程调度很快会使代码复杂化. 特别是如果线程调度的操作被隐藏在被调用的方法中的时候, 不查看源码的话, 调用者在回调函数中几乎无法确定代码当前运行的线程状态.
- 对于正在执行的任务, 没有很好的取消机制.

Swift 5.5 之后, Swift 语言中有了真正异步函数的概念, 通过 `async` `await` 等关键字的引入, 我们可以将 `loadSignature` 写法转换为:

```swift
func loadSignature() async throws -> String? {
    let (data, _) = try await URLSession.shared.data(from: someURL)

    return String(data: data, encoding: .utf8)
}
```

异步函数的 `async` 关键字会帮助编译器确保两件事情:

1. 它允许我们在函数体内部使用 `await` 关键字;
2. 它要求其他人在调用这个函数时, 使用 `await` 关键字.

这和与它处于类似位置的 `throws` 关键字相似: 在使用 `throws` 时, 它允许我们在函数内部使用 `throw` 抛出错误, 并要求调用者使用 `try` 来处理可能的抛出. `async` 也扮演了这样一个角色, 它要求在调用时使用 `await` 进行标记, 这是对于开发者的一种明确的提示, 表明这个函数有一些特别的性质: `try` 代表了函数可以被抛出, 而 `await` 则代表了函数在此处可能会放弃当前线程, 它是程序的潜在暂停点.

放弃线程的能力, 意味着异步方法可以被 "暂停", 这个线程可以被用来执行其他代码. 如果这个线程是主线程的话, 那么界面将不会卡顿. 被 `await` 的语句将被底层机制分配到其他合适的线程, 在执行完成后, 之前的 "暂停" 将结束, 异步方法从刚才的 `await` 语句后开始, 继续向下执行.

### `async` 与 `await` 的原理

```swift
func load() -> Int {
    let initial = 0
    let result = calculate()
    return initial + result
}

func load() async -> Int {
    let initial = 0
    let result = await calculateAsync()
    return initial + result
}
```

如下是使用 `swiftc -emit-sil tmp.swift -o tmp.sil` 生成 SIL(Swift Intermediate Language) 文件中关于 `load()` 的部分 (为了方便阅读, 对 SIL 结果进行了简化和调整):

```swift
// load()
%0 = function_ref calculate : $@convention(thin) () -> Int
%1 = apply %0() : $@convention(thin) () -> Int
// load() async
%0 = function_ref calculateAsync : $@convention(thin) @async () -> Int
%1 = apply %0() : $@convention(thin) @async () -> Int
```

可以看到, 在调用 calculate 时唯一的区别只在于被调用函数是否被标记为 `@async`, `await` 在 SIL 中是被完全忽略的: 不论是同步函数还是异步函数, 对它们的调用只是最简单的 `apply` 指令.

`await` 充当的角色, 就是标记出一个潜在的暂停点 (suspend point). 在异步函数中, 可能发生暂停的地方, 编译器会要求我们明确使用 `await` 将它标记出来. 除此之外, `await` 并没有其他更多的语义或是运行时的特性. 当控制权回到异步函数中时, 它会从之前停止的地方开始继续运行. 但是 Swift 并不保证返回时的执行线程是之前的线程, 比如原来的输入参数等, 在 `await` 前后会被保留, 但是返回到当前异步函数时, 它并不一定还运行在和之前同样的线程中, 异步函数所在类型中的实例成员也可能发生了变化. `await` 是一个明确的标识, 编译器强制我们写明 `await` 的意义, 就是要警示开发者, `await` 两侧的代码会处在完全不同的世界中.

`await` 仅仅只是一个潜在的暂停点, 而非必然的暂停点. 实际上会不会触发"暂停", 需要看被调用的函数的具体实现和运行时提供的执行器是否需要触发暂停. 很多的异步函数并不仅仅是异步函数, 它们可能是某个 `actor` 中的同步函数, 但作为 `actor` 的一部分运行, 在外界调用时表现为异步函数. Swift 会保证这样的函数能切换到它们自己的 actor 隔离域里完成执行.

## `Task`

在调用异步函数时, 需要在它前面添加 `await` 关键字; 而另一方面, 只有在异步函数中, 我们才能使用 `await` 关键字. 那么问题在于, 第一个异步函数执行的上下文, 或者说任务树的根节点, 是怎么来的?

答案是 `Task`

```swift
struct Task<Success, Failure> where Failure: Error {
    init(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    )
}
```

它继承当前任务上下文的优先级等特性, 创建一个新的任务树根节点, 我们可以在其中使用异步函数:

```swift
var results: [String] = []
func someSyncMethod() {
    Task {
        try await processFromScratch()
        print("Done: \(results)")
    }
}

func processFromScratch() async throws {
    let strings = try await loadFromDatabase()
    if let signature = try await loadSignature() {
        for string in strings {
            results.append(string.appending(signature))
        }
    } else {
        throw NoSignatureError()
    }
}
```

注意, 在 `processFromScratch` 中的处理依然是串行的: 对 `loadFromDatabase` 的 `await` 将使这个异步函数在此暂停, 直到实际操作结束, 接下来才会执行 `loadSignature`

我们当然会希望这两个操作可以同时进行, 使用 `async let` 绑定可以做到这一点

```swift
func processFromScratch() async throws {
    async let loadStrings = loadFromDatabase()
    async let loadSignature = loadSignature()
    results = []
    let strings = try await loadStrings
    if let signature = try await loadSignature {
        for string in strings {
            addAppending(signature, to: string)
        }
    } else {
        throw NoSignatureError()
    }
}
```

`async let` 被称为异步绑定, 它在当前 `Task` 上下文中创建新的子任务, 并将它用作被绑定的异步函数 (也就是 `async let` 右侧的表达式) 的运行环境. 和 `Task.init` 新建一个任务根节点不同, `async let` 所创建的子任务是任务树上的叶子节点. 被异步绑定的操作会立即在其他线程执行, 在使用 `await` 语句行获取结果时, 如果已经得出执行结果则会立即返回, 如果没有则暂停执行后续代码等待返回.

```asciiart
                      +------------------+       |
               +----> | loadFromDataBase |       |
+-----------+  |      +------------------+       | +--------------+
| Task.init +--+                                 | | addAppending |
+-----------+  |      +------------------------+ | +--------------+
               |----> | loadSignature          | |
                      +------------------------+ |
```

除了 `async let` 外, 另一种创建结构化并发的方式, 是使用任务组 (Task group). 比如, 我们希望在执行 `loadResultRemotely` 的同时, 让 `processFromScratch` 一起运行, 可以用 `withThrowingTaskGroup` 将两个操作写在同一个 task group 中:

```swift
func loadResultRemotely() async throws {
    // 模拟⽹络加载的耗时
    try? await Task.sleep(for: .seconds(2))
    results = ["data1^sig", "data2^sig", "data3^sig"]
}

func someSyncMethod() {
    Task {
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.loadResultRemotely()
            }
            group.addTask(priority: .low) {
                try await self.processFromScratch()
            }
        }
        print("Done: \(results)")
    }
}
```

`withThrowingTaskGroup` 和它的非抛出版本 `withTaskGroup` 提供了另一种创建结构化并发的组织方式. 当在运行时才知道任务数量时, 或是我们需要为不同的子任务设置不同优先级时, 我们将只能选择使用 Task Group. 在其他大部分情况下, `async let` 和 `task group` 可以混用甚至互相替代:

```asciiart
                    +--------------------------------------------+
                    |            processFromScratch              |
                    |  +------------------+  |                   |
                    |  | loadFromDataBase |  |                   |
               +--->|  +------------------+  | +--------------+  |
               |    |                        | | addAppending |  |
               |    |  +------------------+  | +--------------+  |
               |    |  | loadSignature    |  |                   |
               |    |  +------------------+  |                   |
+-----------+  |    +--------------------------------------------+
| Task.init +--+
+-----------+  |    +-------------------------------------------+
               |    |            loadResultRemotely             |
               |    |   +--------------+      +-------------+   |
               +--->|   | async process|      | set result  |   |
                    |   +--------------+      +-------------+   |
                    +-------------------------------------------+
```

## 什么是结构化并发

2016 年, ZeroMQ 的作者 Martin Sústrik 于在其 C 语言结构化并发库 libdill 中首次提出了 *结构化并发* 的概念. 事实上, 这个概念其实是受到了更早期 Dijkstra 所提出的 *结构化编程 (Structured Programming)* 的启发. 那什么是结构化编程呢? 这一切要从 `GOTO` 说起.

### `GOTO`

计算机发展的早期, 程序员使用汇编语言进行编程, 在之后的一段时期, 诞生了比汇编略微高级的编程语言, 如 FORTRAN, COBOL 等. 这些语言虽然在一定程度上提高了可读性, 但是仍然存在很大的局限性. 这些语言一般支持两种执行方式:

- 顺序执行
- 跳转执行, 即 `GOTO` 语句

顺序执行的逻辑非常简单, 它总是能够找到执行入口与出口. 与之相反, 跳转执行则充满了不确定性. 如果程序中存在 `GOTO` 语句, 那么它可以在任何时候跳转至任何指令位置. 一旦程序大量使用了 `GOTO` 语句, 那么最终将变成面条式代码 (Spaghetti code).

```fortran
PROGRAM SpaghettiCode
    INTEGER :: i, j, n
    PARAMETER (n = 3)
    INTEGER :: matrix(n, n)

    i = 1
    j = 1
init_loop:
    IF (i .GT. n) GOTO end_init
    IF (j .GT. n) THEN
        j = 1
        i = i + 1
        GOTO init_loop
    END IF
    matrix(i, j) = i * j
    j = j + 1
    GOTO init_loop
end_init:
    i = 1
    j = 1
find_loop:
    IF (i .GT. n) GOTO end_find
    IF (j .GT. n) THEN
        j = 1
        i = i + 1
        GOTO find_loop
    END IF
    IF (matrix(i, j) .EQ. 4) THEN
        PRINT *, "Found a 4 at position: ", i, j
        GOTO done
    END IF
    j = j + 1
    GOTO find_loop
end_find:
    PRINT *, "Value not found"
done:
    PRINT *, "Matrix processing complete."
END PROGRAM SpaghettiCode
```

这段代码有如下缺点:

1. 过度跳转: 代码大量使用 `GOTO` 语句在不同的标签之间跳转, 使得逻辑流程变得非常复杂和难以跟踪.
2. 嵌套逻辑: 循环和条件语句嵌套在一起, 通过 `GOTO` 实现, 使得程序流变得难以理解.
3. 维护困难: 由于 `GOTO` 跳转使得程序的执行路径不直观, 修改代码或排除故障变得非常困难.

### 结构化编程

Dijkstra 发表了 [Notes on Structured Programming](https://www.cs.utexas.edu/users/EWD/ewd02xx/EWD249.PDF) 表达了其理想的编程范式, 提出了 *结构化编程* 的概念.

结构化编程在现在看来是理所当然的, 但是在当时并不是. 结构化编程的核心是 **基于块语句, 实现代码逻辑的抽象与封装, 从而保证控制流具有单一入口和单一出口**. 现代编程语言中的条件语句, 循环语句, 函数定义与调用都是结构化编程的体现.

相比 `GOTO` 语句, 基于块的控制流有一个显著的特征: 控制流从程序入口进入, 中途可能会经历条件, 循环, 函数调用等控制流转换, 但是 **最终控制流都会从程序出口退出**. 这种编程范式使得代码结构变得更加结构化, 思维模型变得更加简单, 也为编译器在低层级提供了优化的可能.

因此, 完全禁用 `GOTO` 语句已经成为了大部分现代编程语言的选择. 虽然, 少部分编程语言仍然支持 `GOTO`, 但是它们大都支持高德纳 (Donald Ervin Knuth) 所提出的前进分支和后退分支不得交叉的理论, 依然遵循结构化的基本原则: **控制流拥有单一的入口与出口**.

如今, 我们基于现代编程语言所编写的程序, 绝大部分都是结构化的, 结构化编程范式早已深入人心.

### 并发编程

在单线程编程模型中, 编程语言通过代码块避免控制流随意跳转, 从而实现程序的结构化. 但是, 在多线程编程 (并发编程) 模型中, 线程之间控制和归属关系仍然存在很多问题, 其面临的问题与 `GOTO` 的问题非常相似, 这也是结构化并发所要解决的问题.

#### 非结构化并发

```swift
func main() {
    DispatchQueue.global().async {
        foo(completion: {
            print("main get \($0)")
        })
    }
}

func foo(completion: @escaping (Int) -> Void) {
    DispatchQueue.global().async {
        bar(completion: {
            print("foo get \($0)")
            completion($0)
        })
    }
}

func bar(completion: @escaping (Int) -> Void) {
    let result = Int(arc4random())
    print("bar get \(result)")
    completion(result)
}

// 主线程执行
main()
```

上述代码中, 主线程执行 `main` 方法是一个结构化的过程. 而 `main` 和 `foo` 内部则以非阻塞的方式执行并发任务, 并通过 `completion` 回调获取结果. `bar` 内部则以阻塞的方式执行计算任务, 并调用 `completion` 返回结果.

进一步分析这段代码中各个方法, 可以发现 `main` 和 `foo` 中的并发任务派发其实是一种函数间的无条件 "跳转" 行为. 虽然, `main` 和 `foo` 都会立即将控制流返回至调用者, 但是它们各自生成了新的并发任务. 这些并发任务并不知道自己从哪里来, 它们的初始调用不存在于其所属线程的调用栈中, 其生命周期也与调用者的作用域完全无关.

这样的非结构化并发不仅使得代码的控制流变得非常复杂, 而且还会带来了一个致命的后果: 由于和调用者具有不同的调用栈, 因此无法得知原始的调用者, 进而无法以抛出的方式向上传递错误.

在非结构化并发的编程范式下, 我们在调用任意一个方法, 我们都会存在很多担忧:

- 方法是否会产生一个后台任务?
- 方法虽然返回了, 它所产生的后台任务是否仍然在运行? 什么时候完成? 其又会产生什么行为?
- 作为调用者, 应该在哪里处理回调? 如何处理回调?
- 是否保持这个方法用到的资源? 后台任务是否会自动持有这些资源? 还是要手动释放资源?
- 后台任务是否可以被管理? 如果取消这些后台任务?
- 后台任务是否会产生其他后台任务? 这些任务是否可以被正确管理? 当任务取消时, 二次派发的任务是否也会被取消?

这些问题都是非结构化并发可能存在的问题, 而结构化并发正是为了解决这些问题而提出的.

#### 结构化并发

如果要用一句话定义结构化并发, 那就是: **即使进行并发操作, 也能保证控制流路径的单一入口和单一出口. 程序可以产生多个控制流来实现并发, 但是所有的并发路径在出口时都应该处于完成 (或取消) 状态, 并合并到一起**.

![himg](https://a.hanleylee.com/HKMS/2024-06-26150011.jpg?x-oss-process=style/WaMa)

在结构化并发的编程范式下, `foo` 方法将所产生的并发控制流最终都会收束至 `foo` 方法中. 此时, 我们调用黑盒方法, 能够确信即使方法会产生额外的并发任务, 控制流最终也会回归到方法调用的位置, 一切尽在掌握之中!

## 协作式任务取消

对于结构化并发, 由于子任务的作用域和生命周期被完全限制, 结构化的父任务和子任务之间有着天然的层级联系. 父任务取消可以非常容易地传递到作用域内的子任务中, 这样子任务就可以及时地对取消作出响应, 进行清理资源等操作.

不过, 需要注意的是, 结构化并发中取消的传递, 并不意味着在任务取消时那些需要手动释放的资源可以被 "自动" 回收, 任务本身在被取消后也并不会自动停止. Swift 并发和任务的取消, 是一种基于协作式 (cooperative) 的取消: **组成任务层级的各个部分, 包括父任务和子任务, 往往需要通力协作, 才能共同达到我们最终想要的效果**. 结构化并发可以帮助在任务间传递取消信号, 但这仅仅只是协作式取消中的一个部分, 任务的具体实现中也必须包含对取消操作的处理, 整个取消系统才能运作.

实际上, Swift 并发中对某个任务调用 `cancel()`, 做的事情只有两件:

- 将自身任务的 `isCancelled` 标识置为 `true`.
- 在结构化并发中, 如果该任务有子任务, 那么取消子任务.

子任务在被取消时, 同样做这两件事. 因此, 在结构化并发中, 取消操作会被传递给任务树中当前任务节点下方的所有子节点.

```asciiart
                         cancel()
                            |               ② +---------+
                      ①     V            +--->|         |
                      +-----------+      |    +---------+
               +----->| SubTask1  |------+
               |      +-----------+      |    +---------+     +----------+
+--------+     |                         +--->|         |---->|          |
|  Root  |-----+                              +---------+   ③ +----------+
+--------+     |
               |      +-----------+       +----------+
               +----->| SubTask2  +------>|          |
                      +-----------+       +----------+
```

1. `SubTask 1` 和 `SubTask 2` 都是 Root 任务的子任务. 如果对 `SubTask1` 调用 `cancel()`, `SubTask1` 的 `isCancelled` 被标记为 `true`.
2. 接下来取消被传递给 `SubTask1` 的所有子任务, 这些子任务的 `isCancelled` 也被标记为 `true`.
3. 取消操作在结构化任务树中一直向下传递, 直到最末端的叶子节点.

综上, `cancel()` 调用只负责维护一个布尔变量, 仅此而已. 它不会涉及其他任何事情: 任务不会因为被取消而强制停止, 也不会让自己提早返回. 这也是为什么我们把 Swift 并发中的取消叫做 "协作式取消" 的原因: 各个任务需要合作, 才能达到最终停止执行的目标. 父任务要做的工作就是向子任务传递 `cancel()`, 并将自身的 `isCancelled` 状态设置为 `true`. 当父任务已经完成它自己的工作后, 接下来的事情就要交给各个子任务的实现, 它们要负责检查 `isCancelled` 并作出合适的响应. 换言之, 如果谁都没有检查 `isCancelled` 的话, 协作式的取消就不成立了, 整个任务层级向外将呈现出根本不支持取消操作的状态.

### 如何实现任务取消

我们通常会借助 `throw` 抛出错误来实现取消逻辑, 我们把函数声明为 `throws`, 在检查到任务被取消时, 异步函数不再返回部分值或 nil, 而是直接抛出一个 `CancellationError` 值:

```swift
func work() async throws -> String {
    var s = ""
    for c in "Hello" { // 检查取消状态
        guard !Task.isCancelled else {
            throw CancellationError()
        }
        // ...
    }
}
```

> CancellationError 是 Swift 内建的一个 Error 类型, 其定义如下:
>
> ```swift
> /// An error that indicates a task was canceled.
> ///
> /// This error is also thrown automatically by `Task.checkCancellation()`,
> /// if the current task has been canceled.
> @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
> public struct CancellationError : Error {
>     public init()
> }
> ```

这样, 调用者在获取错误时, 都可以使用一个共同的方式来检查这个抛出是不是由于任务取消所造成的, 调用方式如下:

```swift
do {
    let value = try await work()
    print(value)
} catch is CancellationError {
    print("任务被取消")
} catch {
    print("其他错误：\(error)")
}
```

由于在处理任务取消时, 这种 **检测 `isCancelled` 布尔值** 然后 **抛出 `CancellationError` 错误** 的模式十分常用, Swift 进一步把它们封装成了一个单独的方法, 并放到了标准库中. 在需要检查取消状态并抛出错误的时候, 我们只需要调用 `Task.checkCancellation` 就可以了:

```swift
func work() async throws -> String {
    var s = ""
    for c in "Hello" { // 检查取消状态
        try Task.checkCancellation()
        // ...
    }
}
```

## actor 模型

为了确保资源在不同运算之间被安全地共享和访问, 以前通常的做法是将相关的代码放入一个串行的 dispatch queue 中, 然后以同步的方式把对资源的访问派发到队列中去执行, 这样我们可以避免多个线程同时对资源进行访问. 其中一种典型用法如下:

```swift
class Holder {
    private let queue = DispatchQueue(label: "resultholder.queue")
    private var results: [String] = []
    func getResults() -> [String] {
        queue.sync { results }
    }

    func setResults(_ results: [String]) {
        queue.sync { self.results = results }
    }

    func append(_ value: String) {
        queue.sync { self.results.append(value) }
    }
}
```

之后, 我们再按照如下方式对 `Holder` 中的数据进行存取:

```swift
var holder = Holder()
holder.setResults([])
holder.append(data.appending(signature))

// print("Done: \(results)")
print("Done: \(holder.getResults())")
```

在使用 GCD 进行并发操作时, 这种模式非常常见. 但是它存在一些难以忽视的问题:

1. **大量且易错的模板代码**: 凡是涉及 `results` 的操作, 都需要使用 `queue.sync` 包围起来, 但是编译器并没有给我们任何保证. 在某些时候忘了使用队列, 编译器也不会进行任何提示, 这种情况下内存依然存在危险. 当有更多资源需要保护时, 代码复杂度也将爆炸式上升.
2. **小心死锁**: 在一个 `queue.sync` 中调用另一个 `queue.sync` 的方法, 会造成线程死锁. 在代码简单的时候, 这很容易避免, 但是随着复杂度增加, 想要理解当前代码运行是由哪一个队列派发的, 它又运行在哪一个线程上, 往往会伴随着严重的困难. 必须精心设计, 避免重复派发.

Swift 并发引入了一种在业界已经被多次证明有效的新的数据共享模型, actor 模型, 来解决这些问题. 最简单的理解, 可以认为 `actor` 就是一个 "封装了私有队列" 的 `class`. 将 `Holder` 由 `class` 改为 `actor`, 并把 `queue` 的相关部分去掉, 我们就可以得到一个 `actor` 类型. 这个类型的特性和 `class` 很相似, 它拥有引用语义, 在它上面定义属性和方法的方式和普通的 `class` 没有什么不同:

```swift
actor Holder {
    var results: [String] = []
    func setResults(_ results: [String]) {
        self.results = results
    }

    func append(_ value: String) {
        results.append(value)
    }
}
```

对比由私有队列保护的 "手动挡" 的 `class`, 这个 "自动档" 的 `actor` 实现显然简洁得多. `actor` 内部会提供一个隔离域: 在 `actor` 内部对自身存储属性或其他方法的访问, 比如在 `append(_:)` 函数中使用 `results` 时, 可以不加任何限制, 这些代码都会被自动隔离在被封装的 "私有队列" 里. 但是从外部对 `actor` 的成员进行访问时, 编译器会要求切换到 `actor` 的隔离域, 以确保数据安全. 在这个要求发生时, 当前执行的程序可能会发生暂停. 编译器将自动把要跨隔离域的函数转换为异步函数, 并要求我们使用 `await` 来进行调用.

```swift
await holder.setResults([])
await holder.append(data.appending(signature))
print("Done: \(await holder.results)")
```

现在, 在并发环境中访问 `holder` 不再会造成崩溃了

在底层, 每一个 actor 对信箱中的消息处理是顺序进行的, 这确保了在 `actor` 隔离的代码中, 不会有两个同时运行的任务. 也就确保了 `actor` 隔离的状态, 不存在数据竞争. 从实现角度来看: 消息是一个异步调用的局部任务, 每个 `actor` 实例都包含了它自己的串行执行器, 这个执行器实际对作用域进行了限制. 串行执行器负责在某个线程内循序执行这些局部任务 (包括处理消息, 实际访问实例上的状态等). 从概念上, 这和将操作都封装到一个串行派发的 `DispatchQueue` 中类似, 但是 `actor` 在实际运行时, 是基于协作式的线程派发和 Swift 异步函数续体的, 相比于传统的线程调度, 它是一个更轻量级的实现.

对于 Swift 中的 `actor` 模型, 最重要的就是理解隔离域, 并记住两个结论:

- 某个隔离域中的声明, 可以无缝访问相同隔离域中的其他成员;
- 某个隔离域外的声明, 不论它位于传统的非隔离中, 还是位于其他 `actor` 的隔离域中, 都无法直接访问这个隔离域的成员. 只有通过异步消息的方法, 才能跨越隔离域进行访问.

## 异步方式迁移

一般情况下, 我们可以将一些基于回调的方法方便地转换为基于异步函数的代码:

```swift
func calculate(input: Int, completion: @escaping (Int) -> Void) // 转换为
func calculate(input: Int) async -> Int

func load(completion: @escaping ([String]?, Error?) -> Void) // 转换为
func load() async throws -> [String]
```

> 有些情况下, 带有闭包的异步操作函数本身也具有返回值, 这种情况会相对比较棘手, 需要针对特定情况进行分析

### 使用 `@completionHandlerAsync` 标记异步版本

异步函数具有极强的 "传染性": 一旦你把某个函数转变为异步函数后, 对它进行直接调用的函数都需要转变为异步函数. 为了保证迁移的顺利, Apple 建议进行从下向上的迁移: 先对底层负责具体任务的最小单元开始, 将它改变为异步函数, 然后逐渐向上去修改它的调用者.

为了保证迁移的顺利, 一种值得鼓励的做法是, **在为一个原本基于回调的函数添加异步函数版本的同时, 暂时保留这个已有的回调版本**. 这样可以保证项目始终能够编译, API 的使用者能进行逐步迁移. 另外, 如果是框架维护者, 还需要考虑到框架的用户并不一定具有迁移到 Swift 并发的条件, 或者因为某种原因不得不继续使用原本的回调版本. 这时, 同时保留原来的回调版本和新的异步函数版本, 就成为了必须项.

为了让迁移顺利, 我们可以为原本的回调版本添加 `@completionHandlerAsync` 注解, 告诉编译器存当前函数存在一个异步版本. 这样, 当使用者在其他异步函数上下文中调用了这个回调版本时, 编译器将提醒使用者可以迁移到更合适的异步版本:

```swift
@completionHandlerAsync("calculate(input:)")
func calculate(input: Int, completion: @escaping (Int) -> Void) {
    completion(input + 100)
}

func calculate(input: Int) async -> Int {
    return input + 100
}
```

`@completionHandlerAsync` 和 `@available` 标记很类似. 它接收一个字符串, 并在检测到被标记的函数在异步环境下被调用时, 为编译器提供信息, 帮助使用者用 "fix-it" 按钮迁移到异步版本. 和一般的 `@available` 的不同之处在于, **在同步环境下 `@completionHandlerAsync` 并不会对 `calculate(input:completion:)` 的调用发出警告, 它只在异步函数中进行迁移提示**, 因此提供了更为准确的信息.

### 使用续体改写函数

如果想要提供一套异步函数的接口, 但在内部依然复用闭包回调或代理方法的话, 最方便的迁移方式就是捕获续体并暂停运行, 然后在异步操作完成时告知这个续体结果, 让异步函数从暂停点重新开始.

Swift 提供了一组全局函数, 让我们暂停当前任务, 并捕获当前的续体:

```swift
func withUnsafeContinuation<T>(_ fn: (UnsafeContinuation<T, Never>) -> Void) async -> T
func withUnsafeThrowingContinuation<T>(_ fn: (UnsafeContinuation<T, Error>) -> Void) async throws -> T
func withCheckedContinuation<T>(function: String = #function, _ body: (CheckedContinuation<T, Never>) -> Void) async -> T
func withCheckedThrowingContinuation<T>(function: String = #function, _ body: (CheckedContinuation<T, Error>) -> Void) async throws -> T
```

普通版本和 `Throwing` 版本的区别在于这个异步函数是否可以抛出错误, 如果不可抛出, 那么续体 `Continuation` 的泛型错误类型将被固定为 `Never`. 在结构化并发的部分 API 中 (比如 `withTaskGroup` 和 `withThrowingTaskGroup`), 我们也可以看到类似的设计.

典型情况下, 利用 `withUnsafeThrowingContinuation` 进行包装:

```swift
func load() async throws -> [String] {
    try await withUnsafeThrowingContinuation { continuation in
        load { values, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else if let values = values {
                continuation.resume(returning: values)
            } else {
                assertFailure("Both parameters are nil")
            }
        }
    }
}
```

`resume(throwing:)` 和 `resume(returning:)` 分别对应了发生错误的情况和正确返回的情况, 当 `continuation` 上的这两者任一被调用时, 整个异步函数要么抛出错误, 要么返回正常值.

### oc 函数的自动转换

如果一个 Objective-C 函数存在函数参数, 且该参数的返回值和整个函数本身的返回值类型都为 `void` 的话, 该 Objective-C 函数就被推断为包含潜在的基于回调的异步操作. 对于这类潜在异步回调, 如果它的闭包参数的参数名包含特定关键字, 比如 `completion`, `withCompletion`, `completionHandler`, `withCompletionHandler`, `completionBlock`, `withCompletionBlock` 等, 那么这个闭包的输入将被提取出来, 自动映射成为异步函数的返回值.

在某些特定情况下, 你可能会不想要这样的自动转换, 通过为 Objective-C 的方法添加 `NS_SWIFT_DISABLE_ASYNC`, 可以避免编译器为满足条件的方法生成 `async` 版本的 Swift 接口. 比如 `UIView` 中常用的创建动画的方法:

```objc
// UIView.h
+ (void)animateWitDuration:(NSTimeInterval)duration
                            animations:(void (^)(void))animations
                            completion:(void (^)(BOOL finished))completion
                            NS_SWIFT_DISABLE_ASYNC;
```

对于像是创建动画这样的大部分 UI 操作来说, 我们希望的是提交动画, 然后立即继续进行其他操作, 而不会是等待动画结束后再继续其他操作. 如果这个函数也提供了异步版本, 那么大概率我们会这样使用它:

```swift
Task {
    let finished = await UIView.animate(
        withDuration: 1.0,
        animations: { /* animation */ }
    )
    print("Animation done: \(finished)")
}

print("Other operations.")
```

相比起等效的非异步版本:

```swift
UIView.animate(withDuration: 1.0) {
    /* animation */
} completion: { finished in
    print("Animation done: \(finished)")
}

print("Other operations.")
```

额外的 Task 反而让事情变得更复杂了. 这也是 `UIView` 和 `UIViewController` 上大部分 UI 相关的操作明确标明了不进行异步函数转换的原因.

## Swift 并发模型

我们已经看到, 为了高效地进行并发, Swift 并发提供了三种工具:

- 异步函数可以帮助我们写出简单的异步代码, Swift 并发中很多 API 也都是通过异步函数提供的;
- 通过组织结构化并发, 可以保证任务的执行顺序, 正确的生命周期和良好的取消操作;
- 利用 `actor` 和 `Sendable` 等, 编译器能保证数据的安全.

有了这些工具, 我们可以构建出一套安全有效的并发机制. 但是我们有时候可能会好奇, 这套机制背后是怎么运行的, 它的效率究竟如何, 我们怎么才能保证并发程序运行良好? 这些将会是本章想要尝试解释的话题.

一段代码, 无论它位于同步函数中还是异步函数中, 最终都必须由某个具体线程来运行. 但是和始终运行在同一个线程上的同步函数不同, 异步函数可能被 `await` 分割, 并由多个不同的线程协同运行. Swift 并发在底层使用的是一种新实现的协同式线程池 (cooperative thread pool) 的调度方式: **由一个串行队列负责调度工作, 它将函数中剩余的运行内容抽象为更轻量的续体 (continuation) 来进行调度. 实际的工作运行由一个全局的并行队列负责, 具体的工作可能会被分配到至多为 CPU 核心数量的线程中去**.

**协同式线程池之所以要限制线程数量, 是为了避免线程级别的切换, 进而提高效率**. 具体来说, Swift 并发中的续体代表了一个运行时的状态包, `await` 将函数的剩余部分 "注册" 为一个续体并暂存起来, 然后在某个工作线程执行当前的语句. Swift 并发的运行时可以轻易地在多个续体间进行切换, 它更像一个轻量级的线程. 在续体间切换的性能消耗, 与普通的方法调用可以等价. 这种续体切换要比在线程间进行切换容易得多.

### 线程切换和线程爆炸

在 Swift 并发被引入之前, GCD 是最主流的线程调度方式: 它以 "抢占式" 的方式管理一个线程池, 在需要的时候, GCD 会尝试从线程池里获取已经创建但闲置的线程, 但如果有需要或者线程池中已经没有可用线程时, 它则会尝试创建新的线程. 一个线程可能会被耗时操作占用或者需要等待某个锁, 此时这个线程就处于被阻塞的 "不可被分配" 状态. 这种时候, 有新任务需要处理时, 新的线程将被创建, 并分配给某个 CPU 核心去执行新任务中的指令.

理想状况下, 如果正在运行的线程数小于或等于 CPU 的核心数, 那么每个线程会被分配到一个它单独占有的核心上, 这个 CPU 核心可以 "专心地" 运行和处理该线程中的指令. 不过, 如果线程数量超过了核心数的话, 新创建的线程将会被分配给已经正在运行其他线程的核心. 这时, 一个 CPU 核心将会同时处理两个或更多的线程.

传统意义上, 线程是操作系统进行运算调度的最小单位. 线程们可以共享它所在进程中的内存堆等资源, 同时它也拥有属于自己的一些资源: 比如调用栈, 自己的寄存器环境, 以及动态申请的栈空间上的内存等. CPU 核心只是一个简单的指令执行器, 在同一个 CPU 核心上同时执行两个线程的事实, 决定了需要通过分时复用的策略让这两个线程共享 CPU 核心的计算资源, 这也意味着在运行不同线程时, 执行环境需要从一个线程切换到另一个线程. 这种切换涉及了整 个线程资源的切换, 包括像是寄存器, 栈指针和栈内存等. 它相对轻量, 但是也还是需要消耗时间.

在 GCD 中, 调度库对并行队列和串行队列能够创建的线程总数是有限制的. 不同的运行环境下限制会有不同, 以 iOS 15 和 iPhone 13 来说, 单个并行队列最多可以创建 64 个线程, 而串行队列可以创建 512 个线程. 移动设备的 CPU 核心数和内存容量都是有限的, 它们无法承载无限多的线程, 这也是 Apple 在文档中要求我们避免创建过多线程的原因.

太多线程不仅意味着更多的内存压力, 更严重的是, 这些线程在有限的 CPU 核心上的运行, 会伴随着非常多的线程上下文切换. 有时候, 相比于实际执行我们需要的指令, 这些切换所耗费的资源和时间反而成了主要部分. 这种由于线程被阻塞的同时, 又不断有新的任务被以 `async` 方式提交到并行队列, 并造成过多新线程创建的行为, 被称为 *线程爆炸* (*thread explosion*):

线程爆炸造成了过多的线程上下文切换, 是传统并发编程中导致性能退化的重要原因之一. 在 GCD 中, 调度库对线程数量进行了限制, 相比于直接使用 `NSThread` 的 API, 通过 GCD 进行调度已经为性能优化带来了很大改善, 但这并不十分理想: 作为开发者, 我们依然需要把精力分配给线程创建这样的细节, 特别是在 GCD 中, 线程的分配和创建细节是被隐藏起来的, 稍不留意就可能造成问题.

下面的一段代码会造成典型的线程爆炸. 由于 `sQueue` 被阻塞, 导致并行队列 `.global()` 使用 `async` 所调用的闭包无法及时完成, 新的 `async` 将一直创建新的线程, 直到上限:

```swift
let sQueue = DispatchQueue(label: "serial-queue")

for i in 0 ..< 10000 {
    DispatchQueue.global().async {
        print("Start \(i).")
        self.sQueue.sync {
            Thread.sleep(forTimeInterval: 0.1)

            print("End: \(i).")
        }
    }
}
```

在 Swift 并发中, Apple 对线程调度进行了进一步的封装, 把 "线程" 的概念整个隐藏到了幕后. 但实际上, 不论是 `Task` 相关结构化任务 API 的调度, 还是 `actor` 隔离域之间的切换, 在幕后都会涉及到执行线程的问题. 甚至可以说, 如果使用原有的线程调度方式来支撑 Swift 并发的新一套 API, 在底层可能会带来更多的潜在的线程切换的机会. 这种切换带来的性能上的问题, 将会摧毁 Swift 并发被大规模使用的可能. 为此, Apple 需要一套相应的手段来避免线程爆炸和它所带来的问题.

### 协同式调度线程模型

Swift 并发在所有平台上底层都还是使用 GCD 进行调度, 但是这并不是旧版本系统搭载的原味 GCD 库, 而是一个带有全新的协同式实现的闭源版本. 除非设定了 `@MainActor`, 否则我们通过 `Task` API 提交给 Swift 并发运行的闭包, 都会交给一个 cooperative 的串行队列进行处理. 如果我们在一段异步代码中设置断点, 很有可能会在栈列表中看到这个队列的名字:

![himg](https://a.hanleylee.com/HKMS/2024-06-26180053.jpg?x-oss-process=style/WaMa)

> 异步函数执行的另一个可能的队列是绑定了主线程的 main queue. 当异步代码需要被隔离在 `MainActor` 时, 将等效于 `DispatchQueue.main` 的派发, 这个派发会选择主线程来执行指令.

为了能把线程数控制在设备上 CPU 的核心数以内, 我们不能让 cooperative 串行队列对应的线程被阻塞. 运行在这个线程上的异步函数需要具有放弃线程的能力, 这样该线程才能保持向前, 去执行其他操作. 为了做到这一点, **串行调度队列需要具有额外的能力, 把还未执行的函数部分和必要的变量包装起来, 作为续体暂存到其他地方 (比如堆上), 然后等待空闲的线程去执行它. Swift 并发的全局执行器会组织这些续体, 让它们在线程上运行**

### 图示异步线程模型

我们通过一些图解来仔细看看这个串行队列 (以及对应它的线程) 是如何做到保持不阻塞的. 假设我们有下面的代码:

```swift
func bar1() {}

func bar2() async {}

func bar3() async {
    await baz()
}

func baz() async {
    bar1()
}

func foo() async {
    bar1()

    await bar2()
    await bar3()
}

func method() {
    Task {
        await foo()
    }
}
```

1. 当某个线程执行 `method` 时, `Task.init` 首先被入栈, 它是一个普通的初始化方法, 在执行完毕后立即出栈, `method` 函数随之结束 (`Task` 提交的任务是由 **串行调度队列** 直接执行的, 因此最好不要有重型任务). 通过 `Task.init` 参数闭包传入的 `await foo()`, 被提交给协同式线程池, 如果 **协同式调度队列** 正在执行其他工作, 那么它被存放在堆上, 等待空闲线程:

    ```asciiart
          STACK                    HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      |                |
    |                |      |                |
    |                |      |                |
    | +------------+ |      | +------------+ |
    | |   method   | |      | |     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

2. 当有适合的线程可以运行协同式调度队列中的工作时, 执行器读取 `foo` 并将它推入这个线程的栈上, 开始执行. 需要注意的是, 这里的 "适合线程" 和 `method` 所在的线程并不需要一致, 它可能是另外的空闲线程:

    ```asciiart
          STACK                    HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      |                |
    |                |      |                |
    |                |      |                |
    | +------------+ |      | +------------+ |
    | |    foo     |<+------+-+     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

3. `foo` 中的第一个调用是一个同步函数 `bar1`. 在异步函数中调用同步函数并没有什么不同, `bar1` 将被作为新的 frame 被推入栈中执行:

    ```asciiart
          STACK                    HEAP
    +----------------+      +----------------+
    |                |      |                |
    | +------------+ |      |                |
    | |    bar1    | |      |                |
    | +------------+ |      |                |
    |                |      |                |
    | +------------+ |      | +------------+ |
    | |    foo     |<+------+-+     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

4. 当 `bar1` 执行完毕后, 它对应的 frame 被出栈, 控制权回到 `foo`
5. 接下来我们会在这个线程中执行到 `await bar2()`, 它是一个异步函数调用. 为了不阻塞当前线程, 异步函数 `foo` 可能会在此处暂停并放弃线程. 当前的执行环境 (如 `bar2` 和 `foo` 的关系) 会被记录到堆中, 以便之后它在调度栈上继续运行.

    ```asciiart
          STACK                    HEAP
    +----------------+      +----------------+
    |                |      |                |
    | +------------+ |      | +------------+ |
    | |    bar2    | |  +---+>|    bar2    | |
    | +------------+ |  |   | +-----+------+ |
    |                |  |   |       |        |
    |                |  |   |       V        |
    | +------------+ |  |   | +------------+ |
    | |    foo     +-+--+   | |     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

6. 此时, 执行器有机会到堆中寻找下一个需要执行的工作. 在这里, 我们假设它找到的就是 `bar2`. 它将被装载到栈上, 替换掉当前的栈空间, 当前线程就可以继续执行, 而不至于阻塞了:

    ```asciiart
          STACK                    HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      | +------------+ |
    |                |  +---+-+    bar2    | |
    |                |  |   | +-----+------+ |
    |                |  |   |       |        |
    |                |  |   |       V        |
    | +------------+ |  |   | +------------+ |
    | |    bar2    |<+--+   | |     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

    当然, 执行器也有可能寻找到其他的工作 (比如最近有优先级更高的任务被加入), 这种情况下 `bar2` 就将被挂起一段时间. **不论如何, 串行调度队列都不会停止工作, 它要么会去执行 `bar2`, 要么会去执行其他找到的工作, 唯独不会傻傻等待**.

7. 当 `bar2` 执行完毕后, 它被从堆上移除. 因为在执行 `bar2` 前, 我们在堆上保持了 `foo` 和 `bar2` 的关系, 因此在 `await bar2()` 结束后, 执行器可以从堆中装载 `foo`, 并发现接下来需要运行的指令. 在我们的例子中, `await bar3()` 将被运行. 和 `bar2` 时的情况类似, 当前执行环境被记录到堆中, 等到执行器有机执行到 `bar3` 时, `bar3` 奖杯装载到栈上, 替换掉栈的内容, 并继续在堆上维护返回时要继续执行的续体:

    ```asciiart
          STACK                   HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      | +------------+ |
    |                |  +---+-+    bar3    | |
    |                |  |   | +-----+------+ |
    |                |  |   |       |        |
    |                |  |   |       V        |
    | +------------+ |  |   | +------------+ |
    | |    bar3    |<+--+   | |     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

    > 需要注意, `await bar2()` 前后代码可能会运行在不同线程上, 除非指定了 `MainActor`, 否则协作式调度队列并不会对具体运行的线程作出保证.

8. `bar3` 中的第一个调用是 `await baz()`. 这是一个在异步函数中调用其他的异步函数的情况, 实质上它的情况和 `foo` 中调用 `await bar2()` 或 `await bar3()` 是相同的. `baz` 会替换调度队列所对应的线程的栈:

    ```asciiart
          STACK                   HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      | +------------+ |
    |                |  +---+-+    baz     | |
    |                |  |   | +------------+ |
    |                |  |   |                |
    |                |  |   | +------------+ |
    |                |  |   | |    bar3    | |
    |                |  |   | +------------+ |
    |                |  |   |                |
    | +------------+ |  |   | +------------+ |
    | |    baz     |<+--+   | |     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

9. 在这个栈中, 同步方法 `bar1` 的调用依然在当前栈上进行普通的入栈和出栈:

    ```asciiart
          STACK                   HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      | +------------+ |
    |                |  +---+>|    baz     | |
    |                |  |   | +------------+ |
    |                |  |   |                |
    | +------------+ |  |   | +------------+ |
    | |    bar1    | |  |   | |    bar3    | |
    | +------------+ |  |   | +------------+ |
    |                |  |   |                |
    | +------------+ |  |   | +------------+ |
    | |    baz     |-+--+   | |     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

    在异步函数定义的栈上调用同步函数, 所执行的是普通的出入栈操作. 因此在 Swift 异步函数中, 我们是可以透明地调用 C 或者 Objective-C 的同步函数的. 在底层, 这种调用就是普通的同步调用.

10. 当 `baz` 完成后, 执行器从堆中找到接下来的续体部分, 也就是 `bar3`, 并将它替换到某个线程的栈中. 虽然已经多次说明, 但再强调一次, 此时 `bar3` 的执行线程可能会和 `baz` 不同, 也可能和 `bar3` 最早的执行线程不同, (虽然大部分情况下是一致的, 但这是一个实现细节) **我们不应该对具体的执行线程进行任何假设**:

    ```asciiart
          STACK                   HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      | +------------+ |
    |                |  +---+-+    bar3    | |
    |                |  |   | +-----+------+ |
    |                |  |   |       |        |
    |                |  |   |       V        |
    | +------------+ |  |   | +------------+ |
    | |    bar3    |<+--+   | |     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

11. 最后, `bar3` 的执行也结束了, 执行器最终寻找到一开始的 `foo`, 并最终完成整个 `Task` 的执行:

    ```asciiart
          STACK                   HEAP
    +----------------+      +----------------+
    |                |      |                |
    |                |      | +------------+ |
    |                |      | |    bar3    | |
    |                |      | +-----+------+ |
    |                |      |       |        |
    |                |      |       V        |
    | +------------+ |      | +------------+ |
    | |    foo     |<+------+-+     foo    | |
    | +------------+ |      | +------------+ |
    +----------------+      +----------------+
    ```

### 调度队列的阻塞

非阻塞队列是协同式调度的基础, 因此任何破坏这个假设, 并让该调度队列阻塞的操作, 都可能导致 Swift 并发的性能退化甚至是完全卡死.

Swift 在语言层面上, 使用 `await` 和 `Task` 相关的 API 来在编译期间保证非阻塞线程的约定: 当我们在使用这些语言特性时, 线程模型可以在堆上追踪执行工作所需的依赖, 并按需替换栈上内容, 保持线程在某个方法暂停后, 能找到接下来的工作并继续执行.

但是引入 Swift 并发之前的其他一些线程同步手段, 可能会造成不同程度的问题.

### 全局并发执行器

为了合理地管理线程数, **在运行时全局只有一个并发执行器**. **通过 Task API 提交的任务以及调度队列中加入的任务, 都将由协同式线程池的调度队列进行派发**. 不同于传统的 GCD, 这是一个基于 GCD 的闭源实现. **当协同式线程池中出现空闲线程时, 这些工作将被并发队列实际分配到线程池中的线程上执行**.

### Swift 并发执行器的原理

<https://github.com/swiftlang/swift/blob/d844d0b82b4542040648f25f1a396f7014f784a5/stdlib/public/Concurrency/GlobalExecutor.cpp>
