---
title: 如何在 Swift 命令行程序执行异步代码
date: 2024-01-11
comments: true
path: swift-run-command-line-tools-without-exit
tags: ⦿swift, ⦿cli, ⦿async
updated:
---

最近在学习多线程底层源码, 为了方便验证各种多线程案例, 我是直接在一个 `main.swift` 文件中编写异步代码, 然后终端中使用 `swift main.swift` 命令来执行看输出的. 然后就遇到了一个很基础的问题: 命令行程序不像 iOS 或 macOS 应用, 默认是没有 runloop 的, 这就代表提交到主线程的同步代码执行完成后整个程序就退出了, 我们添加到其他线程的或者在主线程异步执行的代码就没有机会被执行了.

这个问题解决不了的话就无法使用终端程序验证多线程代码了, 经过一番学习, 发现是有多种方式能使终端程序不退出执行的, 这篇文章将我谈索道的这些方式做一下总结

![himg](https://a.hanleylee.com/HKMS/2024-01-13213659.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 开启 runloop

我们命令行程序运行完即结束是因为没有 runloop 运行, 那我们手动调用一下 runloop 运行就可以了

```swift
import Foundation

setbuf(stdout, nil)

DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
    while true {
        print(Date().timeIntervalSince1970)
        sleep(1)
    }
}

RunLoop.main.run(mode: .default, before: .distantFuture)
// CFRunLoopRun() // 与上面功能相同
// CFRunLoopStop(CFRunLoopGetMain())
```

## `dispatchMain`

`dispatchMain` 是系统提供的 API, 其文档描述是这样的:

> This function "parks" the main thread and waits for blocks to be submitted to the main queue.

简言之, 这个方法会停在主线程上, 然后等待执行后续提交到主线程上的任何闭包

```swift
import Foundation

setbuf(stdout, nil)

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    while true {
        print(Date().timeIntervalSince1970)
        sleep(1)
    }
}

dispatchMain()
```

之后在需要退出的地方调用 `exit()` 即可退出程序

## `@main`

swift 5.5 之后支持了通过使用 `@main` 关键字指定程序启动入口, 因此我们可以结合 `@main` 与异步静态方法 `main()` 实现

```swift
import Foundation

@main
struct AsyncCLI { // the name is arbitrary 
    static func main() async throws {
        setbuf(stdout, nil)
        while true {
            sleep(1)
            print(123)
        }
        // your code goes here
    }
}
```

使用这种方式要注意, 如果编译时报错 "'main' attribute cannot be used in a module that contains top-level code", 那么要使用 `swiftc -parse-as-library main.swift && ./main` 的方式编译执行

bug: <https://github.com/apple/swift/issues/55127>

## 信号量

还有一种信号量的方式, 我们都知道使用 `signal()` 使信号量加一, `wait()` 使信号量减一, 同时如果减一后的信号量为负则会一直等待直到信号量大于等于 0

```swift
import Foundation

let semaphore = DispatchSemaphore(value: 0)

// 这里不能使用主队列, 否则不执行
DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
    while true {
        print(Date().timeIntervalSince1970)
        sleep(1)
        semaphore.signal()
    }
}

semaphore.wait()
```

不过这种方式有一个缺点, 就是 `wait()` 方法是通过使当前所在线程阻塞的方式实现等待, 所以如果我们在主线程上调用了 `wait()`, 那我们就必须在其他线程执行 `signal()` 才能解除主线程的等待状态了.

## Ref

- [How to prevent a Command Line Tool from exiting before asynchronous operation completes](https://stackoverflow.com/questions/31944011/how-to-prevent-a-command-line-tool-from-exiting-before-asynchronous-operation-co)
