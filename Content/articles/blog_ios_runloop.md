---
title: iOS 之 Runloop
date: 2019-12-02
comments: true
path: Runloop-of-iOS
categories: iOS
tags: ⦿ios, ⦿runloop
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-02-29-Runloop.png?x-oss-process=style/WaMa)

`runloop` 是一个圆环, 应用在启动时即开启一个 `runloop`, `runloop` 控制着整个 App 的生命周期.

用户点击屏幕时, 设备传递信号给 App 的 `runloop`, `runloop` 即将被唤醒 -> `runloop` 被唤醒 -> 开始检查事件 -> 将事件添加到队列中 -> 运行事件 -> 移除事件 -> `runloop` 即将休眠 -> App 进入休眠状态.

联想: 图形的显示极大地依赖于 `runloop`, 其在 `runloop` 中的即将休眠 `beforeWaiting` 和退出 `exit` 两个状态中注册了检查方法, 这个检查方法在 `runloop` 进入到这两个状态时会遍历所有需要更新的视图 (需要更新的图形标记 `setNeedDisplay`), 然后对需要更新的图形执行图形绘制的相关方法 `display`

<!-- more -->

## 定义

`Runloop` 是通过内部维护的事件循环来对时间消息进行管理的一个 **对象**

## runloop 的作用

1. 保证程序不会退出
2. 监听事件, 自动让程序进入睡眠状态, 只在有需要的时候唤醒 (节省 CPU 开销)
3. 并保证在用户交互时传递事件, 以及监听一些计时器事件

## 线程与 runloop 的关系

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145427.jpg?x-oss-process=style/WaMa)

- 线程与 `runloop` 并不是包含的关系, 而是对应的关系.
- 而且每个线程只能有一个对应的 `runloop`.
- 线程被创建出来后如果不创建不调用 `runloop` 的话其是没有对应的 `runloop` 的; 如果你需要更多的线程交互的话可以手动调用 `runloop` (调用时即被创建了出来), 否则的话如果只是想执行一个长时间的已确定的任务则不需要创建 runloop
- 主线程在创建时默认已经被创建了一个 `mainRunLoop`
- 线程被销毁时, 对应的 `runloop` 也会跟着销毁
- `RunLoop` 并不保证线程安全. 我们只能在当前线程内部操作当前线程的 `RunLoop` 对象, 而不能在当前线程内部去操作其他线程的 `RunLoop` 对象方法.

## Runloop 与 CFRunloop 的关系

![himg](https://a.hanleylee.com/HKMS/2020-02-29-RunloopVSCFRunloop.png?x-oss-process=style/WaMa)

iOS 提供了两个 api 来管理 runloop

- `Runloop` (在 objc 中也叫 `NSRunloop`)
- `CFRunloop` (在 objc 中也叫 `CFRunLoopRef`)

先说结论: `Runloop` 是 `CFRunloop` 的部分封装 (不是全部封装, 有些操作还是只能通过 `CFRunloop` 来执行)

```swift
print(CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent())) // __C.CFRunLoopMode(rawValue: kCFRunLoopDefaultMode)
print(RunLoop.current.currentMode) // __C.NSRunLoopMode(_rawValue: kCFRunLoopDefaultMode)
```

刚开始感觉很混乱, 有了一个为什么还要提供第二个, 看了下实现的方法发现, 封装是为了更好用, 更易用. 比如:

- 在默认的 `CFRunloop` 中是没有普通模式, 滑动模式的区分的, 只有 `default` 与 `common` 区分, 但是 `Runloop` 中设置了 `tracking` 模式, 用于滑动时使用.

有些功能在 `Runloop` 中不能完成, 需要借助 `CFRunloop`, 比如:

- 将自定义 `mode` 添加到 `commonMoode` (`Runloop` 中的 `common` 模式只是对 `CFRunloop` 中 `common` 模式的调用, 目前还没有在 `Runloop` 中实现添加 `mode` 的方法)

一般情况下, 均使用 `Runloop` 类别, 因为其 api 也更简单易读, 是经过优化封装的部分 `CFRunloop`, 只有在 Runloop 不能实现相关功能时才使用 `CFRunloop`

## runloop 涉及的类别

因为 `Runloop` 只是对 `CFRunloop` 的部分封装, 因此这里按照 `CFRunloop` 列出相应类别

- `CFRunLoop`: 代表 `RunLoop` 的对象
- `CFRunLoopMode`: 代表 `RunLoop` 的运行模式
- `CFRunLoopTimer`: 就是 `RunLoop` 模型图中提到的定时源
- `CFRunLoopSource`: 就是 `RunLoop` 模型图中提到的输入源 / 事件源
- `CFRunLoopObserver`: 观察者, 能够监听 `RunLoop` 的状态改变

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145423.jpg?x-oss-process=style/WaMa)

一个 `runloop` 可以被设置为不同的 `mode` (同一时间只能使用一个, 如果想改变只能退出, 然后以新模式进入), 不同的模式下有各自的事件, 观察器, 计时器.

### CFRunLoop

可以通过如下方式获得 / 创建当前 `runloop`

1. `Runloop.current`: 返回 `Runloop`
2. `Runloop.current.getCFRunloop`: 返回 `CFRunloop`
3. `CFRunLoopGetCurrent()`: 返回 `CFRunloop`

### CFRunLoopMode

所有的 `runloop` 都有有五种模式, 同一时间只能使用一种模式. 如果要切换运行模式只能退出当前 `runloop`, 然后再重新指定一个运行模式进入.

1. `defaultMode`

    默认的 `mode`, 主线程在此 `mode` 下运行

2. `UITrackingRunLoopMode`

    界面跟踪 `mode`, 用于 `scrollView` 追踪触摸滑动, 保证界面滑动时不受其他 `mode` 影响.

3. `commonMode`

    一种占位用的 mode, 不是一种真正的 `mode`, 而是一种模式组合. 一个操作 `Common` 标记的字符串.

    一个 `Mode` 可以将自己标记为 `Common` 属性 (通过将其 `ModeName` 添加到 `RunLoop` 的 `commonModes` 中). 每当 RunLoop 的内容发生变化时, RunLoop 都会自动将添加到 `commomMode` 里的 `Source` / `Observer` / `Timer` 同步到具有 `Common` 标记的所有 `Mode` 里. `commonMode` 中默认已经添加了除 `UIInitializationRunloopMode` 以外的所有 mode(`UITrackingRunLoopMode`, `kCFRunLoopDefaultMode`, `GSEventReceiveRunLoopMode`, `kCFRunLoopCommonModes`), 可以创建自定义 `mode` 然后添加到 `commonMode`

    ```swift
    let customMode = CFRunLoopMode.init("custom" as CFString) // 创建一个新的自定义 mode
    CFRunLoopAddCommonMode(CFRunLoopGetCurrent(), customMode) // 将自定义 mode "custom" 添加到 common 中
    let modes = CFRunLoopCopyAllModes(CFRunLoopGetCurrent()) // 取得当前 runloop 下的所有 mode
    print(modes) // <__NSArrayM 0x6000026d9b60>(UITrackingRunLoopMode, GSEventReceiveRunLoopMode, kCFRunLoopDefaultMode, kCFRunLoopCommonModes, custom)

    let timer = Timer(timeInterval: 2, target: self, selector: ##selector(logCurrentRunloopMode), userInfo: nil, repeats: true)
    // 将 timer 添加到 commom 中, commonModes 中的所有 mode 都会执行此 timer; 比如现在添加打印 mode 方法不仅在正常模式下会打印
    // 在滑动模式下也可以正常打印
    RunLoop.current.add(timer, forMode: .common)

    @objc func logCurrentloopMode() { // 不间断打印当前 mode
        Log(Runloop.current.currentMode)
    }
    ```

    例如可以将一个持续事件添加到主线程的 `commomModeItems` 中, 那么这个持续事件在两种模式 `defaultMode` 与 `UITrackingRunLoopMode` 下都会无缝地连续运行

4. `UIInitializationRunLoopMode`

    在刚启动 App 时第进入的第一个 `Mode`, 启动完成后就不再使用

5. `GSEventReceiveRunLoopMode`

    接受系统事件的内部 `Mode`, 通常用不到

### CFRunLoopTimer

基于时间的触发器, 基本上就是 `NSTimer`. 如果要在 `runloop` 的某个模式下添加定时器, 可以用如下方法.

```swift
let timer = Timer(timeInterval: 2,
                  target: self,
                  selector: #selector(logCurrentRunloopMode),
                  userInfo: nil,
                  repeats: true)
RunLoop.current.add(timer, forMode: .common) // 将 timer 添加到 commom 中, commonModes 中的所有 mode 都会执行此 timer

@objc func logCurrentloopMode() { // 不间断打印当前 mode
    Log(Runloop.current.currentMode)
}
```

`Timer` 类有一个 `scheduledTimer` 方法, 这个方法就是将计时器加入到 `runloop` 的 `default` 模式下, 因此如果想在 `default` 模式下添加计时器的话此方法与上述方法等效, 而且还更为简便.

```swift
func scheduledTimer(timeInterval ti: TimeInterval, target aTarget: Any, selector aSelector: Selector, userInfo: Any?, repeats yesOrNo: Bool) -> Timer
```

### CFRunLoopSource

按照函数调用栈来分来一共有两种 `source`

- `source0`: 非基于 `mach_port` 的处理事件, 什么叫非基于 `mach_port` 的呢? 就是说你这个消息不是其他进程或者内核直接发送给你的(二手的!).
- `source1`: 基于 `mach_port` 的, 来自系统内核或者其他进程或线程的事件, 可以主动唤醒休眠中的 RunLoop(iOS 里进程间通信开发过程中我们一般不主动使用). `mach_port` 大家就理解成进程间相互发送消息的一种机制就好.

总结来说: `source1` 基本就是系统事件, `source0` 基本就是应用层事件

简单举个例子: 一个 APP 在前台静止着, 此时, 用户用手指点击了一下 APP 界面, 那么过程就是下面这样的:

我们触摸屏幕, 先摸到硬件 (屏幕), 屏幕表面的事件会先包装成 Event, Event 先告诉 `source1`(mach_port), `source1` 唤醒 RunLoop, 然后将事件 Event 分发给 `source0`, 然后由 `source0` 来处理.

### CFRunloopObserver

观察者, 用于监听 `runloop` 的状态 (也仅用于观察状态了). 状态有以下几种:

- `entry`: 进入 `runloop` 后 -1
- `beforeTimers`: 即将处理 `Timers` 事件 -2
- `beforeSources`: 即将处理 `source` 事件 -4 (`runloop` 会连续发送这两个通知给 `observer` 然后再开始依次执行 `timer` 和 `source`)
- `beforeWaiting`: 即将进入休眠状态 -32
- `afterWaiting`: 被唤醒后 -64
- `exit`: 退出了 `runloop` -128
- `allActivities`: 监听全部状态变化

使用如下方式添加观察者

```swift
let block = { (ob: CFRunLoopObserver?, ac: CFRunLoopActivity) in
    if ac ==.entry {
        NSLog("进入 Runlopp")
    } else if ac == .beforeTimers {
        NSLog("即将处理 Timer 事件")
    } else if ac == .beforeSources {
        NSLog("即将处理 Source 事件")
    } else if ac == .beforeWaiting {
        NSLog("Runloop 即将休眠")
    } else if ac == .afterWaiting {
        NSLog("Runloop 被唤醒")
    } else if ac == .exit {
        NSLog("退出 Runloop")
    }
}
let ob = try createRunloopObserver(block: block)
CFRunLoopAddObserver(CFRunLoopGetCurrent(), ob, .defaultMode)
```

也可以使用

```swift
CFRunLoopObserverCreateWithHandler(_ allocator: CFAllocator!,
                                   _ activities: CFOptionFlags,
                                   _ repeats: Bool,
                                   _ order: CFIndex,
                                   _ block: ((CFRunLoopObserver?, CFRunLoopActivity) -> Void)!) -> CFRunLoopObserver!
```

## runloop 生命环

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145424.jpg?x-oss-process=style/WaMa)

1. 通知观察者 `RunLoop` 已经启动
2. 通知观察者即将要开始的定时器
3. 通知观察者任何即将启动的非基于端口的源 source0
4. 启动任何准备好的非基于端口的源 source0
5. 如果基于端口的源准备好并处于等待状态, 立即启动; 并进入步骤 9
6. 通知观察者线程进入休眠状态
7. 将线程置于休眠知道任一下面的事件发生:
    - 某一事件到达基于端口的源
    - 定时器启动
    - `RunLoop` 设置的时间已经超时
    - `RunLoop` 被显示唤醒
8. 通知观察者线程将被唤醒
9. 处理未处理的事件
    - 如果用户定义的定时器启动, 处理定时器事件并重启 `RunLoop`. 进入步骤 2
    - 如果输入源启动, 传递相应的消息
    - 如果 `RunLoop` 被显示唤醒而且时间还没超时, 重启 `RunLoop`. 进入步骤 2
10. 通知观察者 `RunLoop` 结束.

```objc
/// 1. 通知Observers，即将进入RunLoop
/// 此处有Observer会创建AutoreleasePool: _objc_autoreleasePoolPush();
__CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopEntry);
do {

    /// 2. 通知 Observers: 即将触发 Timer 回调。
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeTimers);
    /// 3. 通知 Observers: 即将触发 Source (非基于port的,Source0) 回调。
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeSources);
    __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);

    /// 4. 触发 Source0 (非基于port的) 回调。
    __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__(source0);

    /// 5. GCD处理main block
    __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);

    /// 6. 通知Observers，即将进入休眠
    /// 此处有Observer释放并新建AutoreleasePool: _objc_autoreleasePoolPop(); _objc_autoreleasePoolPush();
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeWaiting);

    /// 7. sleep to wait msg.
    mach_msg() -> mach_msg_trap();
    

    /// 8. 通知Observers，线程被唤醒
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopAfterWaiting);

    /// 9. 如果是被Timer唤醒的，回调Timer
    __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__(timer);

    /// 9. 如果是被dispatch唤醒的，执行所有调用 dispatch_async 等方法放入main queue 的 block
    __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(dispatched_block);

    /// 9. 如果如果Runloop是被 Source1 (基于port的) 的事件唤醒了，处理这个事件
    __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__(source1);
} while (...);
 
    /// 10. 通知Observers，即将退出RunLoop
    /// 此处有Observer释放AutoreleasePool: _objc_autoreleasePoolPop();
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopExit);
}
```

## Ref
