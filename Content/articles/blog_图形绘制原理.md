---
title: iOS 的图形绘制原理
date: 2019-11-26
comments: true
path: principle-of-graphic-rendering-in-ios
categories: iOS
tags: ⦿ios, ⦿graphic, ⦿render
updated:
---

图形绘制是 iOS App 开发中不经常涉及到的知识点, 但如果需要进行深层次的动画设计或显示效果优化, 那么图形绘制的原理还是要掌握的.

在学习了图形绘制原理之后, 我总结了以下知识点

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145148.jpg?x-oss-process=style/WaMa)

<!-- more -->

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145131.jpg?x-oss-process=style/WaMa)

## 我遇到的坑 (写在最前面)

App 内容静止时, `CoreAnimation` 不需要提交内容, CPU 与 GPU 不进行任何相关图像操作!

## VSync 垂直同步信号

`vertical synchronization`, 每帧画面由上至下从左至右一个一个像素点进行扫描并显示, 每行开始从左至右要扫描显示的时候就会发出一个水平同步信号 `HSync`, 当一个画面所有行全部扫描完成后, 视频控制器的指针会重新回到显示器的最左上角开始一个全新空白画面的绘制, 此时会向系统发送一个垂直同步信号.  图形显示过程全部是基于此信号进行工作的.

1. `VSync` 频率由硬件层面决定, 始终不会改变.
2. iOS 的 `VSync` 为 60hz, 即每秒刷新 60 次, 那么每 1/60 秒 (16.67 毫秒) 其视频控制器就会去帧缓存上读取数据一次.
3. 类比到桌面 PC 的话, 144hz 显示器的 VSync 就是 144hz, 其内部的视频控制器每 1/144 秒 (6.94 毫秒) 就会去帧缓存上读取数据一次
4. 每个 `VSync` 时间点到来时视频控制器就会去读取一次, 但是 GPU 的计算时间不是一定相等的, 有可能第一帧被读取之后

## 屏幕卡顿原因

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145154.jpg?x-oss-process=style/WaMa)

因为 iOS 设备每 16.7 毫秒就需要读取一次帧缓存. 即在 16.7 毫秒内要完成 CPU 与 GPU 共同的工作, 具体如下:

1. 当 `VSync` 通知到 CPU 时, 系统图形服务会通过 `CADisplayLink` 等机制通知 App, App 会根据当前状态进行处理, 如果 `CoreAnimation` 有未提交的内容则执行提交操作.
2. 通过 `context` 将数据写入 `backing store` (因此如果要使用 `drawRect` 方法的话首先要调用 `context`, 而且也只能在 `drawRect` 中调用). 在 `backing store` 中写完数据后 CPU 部分的工作就完成了
3. 之后就是 `GPU` 的工作, 通过 `render server` 将工作交给交给 GPU, GPU 将数据转移到 `VRAM` 中, 然后分析对多个 view 进行拼接 (`compositing`), 纹理的渲染 (`texture`). 最终放入到帧缓存.

如果在在此期间, CPU 的工作过多, 或 GPU 的工作过多, 导致不能在 16.7ms 内完成一次完整的操作, 那么这一帧就会被丢弃, 也就是丢帧, 在视觉看来就会有卡顿的效果.

## 屏幕撕裂原因及对策

如果只有一个 `帧缓存`, 那么渲染流程是这样的: GPU 渲染好后让 `视频控制器` 读取, 读取完后 GPU 才能再去渲染下一帧.  因为 `视频控制器` 读取 `帧缓存` 也是需要时间的. 这样的话时间就会被浪费, `VSync` 之间的间隔时间留给 GPU 的余地就不多了. 此时如果 GPU 碰到复杂的图像花费了较长时间的话就很容易错过下一次 `VSync` 信号, 造成丢帧.

因此为了解决这种问题就有了 `双帧缓存` 和 `三重帧缓存` 等技术.

iOS 设备采用的是 `双帧缓存` (`前帧缓存` 和 `后帧缓存`) 机制, 即 GPU 渲染完第一帧后将数据放入 `前帧缓存`, 视频控制器开始读取 `前帧缓存`, 与此同时 GPU 开始渲染下一帧, 渲染好后将数据存入 `后帧缓存`, 然后立刻将 `前后帧缓存` 进行调换 (在整个过程中视频控制器只会对 `前帧缓存` 进行读取), 此时如果 GPU 处理速度较快, 或者 `视频控制器` 读取较慢, 以至于第一帧还没有读取完的时候就被调换 `帧缓存` 的话, 那么就会造成同一画面上下两个部分是由 `前帧缓存` 和 后帧缓存 共同组成的. 那么画面就会出现撕裂效果.

### 对策 - V-Sync 技术

垂直同步技术开启后, GPU 只会在收到 VSync 信号后才会:

1. 将 `bitmap` 数据转移到 `显存`
2. 进行渲染一系列流程并将数据实时渲染到 `后帧缓存` (如果涉及到 `离屏渲染` 的话还会先将结果渲染 `屏幕外帧缓存区`, 然后再放入 `后帧缓存`)

垂直同步能解决画面撕裂问题, 但是对比之前渲染完一帧后立刻开始渲染下一帧, 留给 GPU 的时间显然更少. 因此会造成些微掉帧.

## 渲染过程中各部分关系

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145153.jpg?x-oss-process=style/WaMa)

继承和所属关系

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145149.jpg?x-oss-process=style/WaMa)

渲染至显示到屏幕的过程

## view 及 layer 的方法

`UIView` 方法 (部分可重写但不可主动调用):

```swift
// 是给 view/layer 记标识以便下一个 drawing cycle(别忘了 runLoop) 消息 layout_and_display_if_needed 到来时能顺利往下执行与否,
// 因此这个方法是可供给开发者主动调用并起到标识的作用, 但是并不能直接触发 layout,
// 然而可以直接调用 layoutIfNeeded 方法在必要时强制执行 layout subviews/sublayers.
- setNeedsLayout
- layoutIfNeeded
- layoutSubviews
- setNeedsDisplay
// 被调用时机 1. 视图第一次将被显示的时候 2. 视图可见部分被用户交互行为触发重绘的时候
// 注: 你不能直接调用该方法, 如果需要刷新重绘可以调用 setNeedsDisplay 方法. 因为在其他时机图形上下文是不存在的, 所以也不能对屏幕进行绘制.
- drawRect:
```

`CALayer` 方法 (部分可重写但不可主动调用):

```swift
// 是给 view/layer 记标识以便下一个 drawing cycle(别忘了 runLoop) 消息 layout_and_display_if_needed 到来时能顺利往下执行与否,
// 因此这个方法是可供给开发者主动调用并起到标识的作用, 但是并不能直接触发 layout,
// 然而可以直接调用 layoutIfNeeded 方法在必要时强制执行 layout subviews/sublayers.
- setNeedsLayout
- layoutIfNeeded
- layoutSublayers
// 默认本身是没有任何绘制内容的, 除非被指定任务去绘制. 就像是一个画家, 但是没有任何想法, 别人让画什么就画什么.
- drawInContext:
// 与 setNeedsLayout 功能相似. 唯独不同的是先计算视图布局 (layout) 系列方法后再显示 (display) 系列方法.
- setNeedsDisplay
- displayIfNeeded
// 不能手动调用, 此方法会创建上下文 CGContextRef, 在上下文创建空的 bitmap(CGImageRef),
// 将此上下文以 ctx 为参数传入 drawInContext 和 drawLayer:inContext 方法中, 完成绘制后将 bitmap 放入 backing store 中.
- display
```

`CALayerDelegate` 协议方法 (可在 UIView 中实现):

```swift
- layoutSublayersOfLayer:
- displayLayer: // 与 drawLayer:inContext: 作用基本相同, 两者只能存一
- drawLayer:inContext: // 在方法内部会呼叫 view 的 drawRect 方法. 当 layer 的内容需要被重载时被呼叫.
                        // 比如调用了 setNeedsDisplay() 方法, 但是如果在代理中呼叫了 displayLayer() 的话不会再执行本方法. 两者间只能存一
- layerWillDraw:
```

## 绘制界面的两种方式

1. 使用图片: `contents image`, 是指通过 `CALayer` 的 `contents` 属性来配置图片

    ```swift
    // Contents Image
    UIImage *image = [UIImage imageNamed:@"cat.JPG"];
    UIView *v = [UIView new];
    v.layer.contents = (__bridge id _Nullable)(image.CGImage);
    v.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:v];
    ```

2. 手动绘制: `custom drawing`

    通过继承 UIView 并实现 -drawRect: 方法来自定义绘制

    1. UIView 有一个关联图层, 即  `CALayer`.
    2. CALayer 有一个可选的 delegate 属性, 实现了  `CALayerDelegate`  协议. UIView 作为 CALayer 的代理实现了 `CALayerDelegae`  协议.
    3. 当需要重绘时, 即调用  `-drawRect:`, CALayer 请求其代理给予一个寄宿图来显示.
    4. CALayer 首先会尝试调用  `-displayLayer:`  方法, 此时代理可以直接设置 contents 属性. `- (void)displayLayer:(CALayer *)layer;`
    5. 如果代理没有实现 -displayLayer: 方法, CALayer 则会尝试调用  `-drawLayer:inContext:` 方法. 在调用该方法前, CALayer 会创建一个空的寄宿图 (尺寸由 bounds 和 contentScale 决定) 和一个 Core Graphics 的绘制上下文, 为绘制寄宿图做准备, 作为 ctx 参数传入.

        ```swift
        - (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
        ```

    6. 最后, 由 Core Graphics 绘制生成的寄宿图会存入 backing store.

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-145135.jpg?x-oss-process=style/WaMa)

## view 的绘制详细过程

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145151.jpg?x-oss-process=style/WaMa)

注: 在调用 `drawRect` 之前的都在 cpu 中执行, 然后 GPU 将 bitmap 从 RAM 移动到 VRAM 将按像素计算将一层层图层合成成一张图然后显示. CPU 将 view 变成了 bitmap 完成自己工作, 剩下就是 GPU 的工作了.

## drawRect 方法调用的时机

1. `drawRect` 调用是在 `Controller->loadView`, `Controller->viewDidLoad` 两方法之后调用的. 所以不用担心在控制器中这些 View 的 drawRect 就开始画了. 这样可以在控制器中设置一些值给 View(如果这些 View draw 的时候需要用到某些变量值).
2. 如果在 UIView 初始化时没有设置 rect 大小, 将直接导致 drawRect 不被自动调用.
3. 该方法在调用 sizeToFit 后被调用, 所以可以先调用 sizeToFit 计算出 size. 然后系统自动调用 drawRect: 方法.
4. 通过设置 contentMode 属性值为 UIViewContentModeRedraw. 那么将在每次设置或更改 frame 的时候自动调用 drawRect:.
5. 直接调用 setNeedsDisplay, 或者 setNeedsDisplayInRect: 触发 drawRect:, 但是有个前提条件是 rect 不能为 0.
6. 若使用 UIView 绘图, 只能在 `drawRect:` 方法中获取相应的 `contextRef` 并绘图. 如果在其他方法中获取将获取到一个 `invalidate` 的 ref 并且不能用于画图. `drawRect:` 方法不能手动显示调用, 必须通过调用 `setNeedsDisplay`  或者  `setNeedsDisplayInRect`, 让系统自动调该方法.
7. 若使用 calayer 绘图, 只能在 `drawInContext:` 中 (类似于 `drawRect`) 绘制, 或者在 delegate 中的相应方法绘制. 同样也是调用 `setNeedDisplay` 等间接调用以上方法
8. 若要实时画图, 不能使用 gestureRecognizer, 只能使用 touchbegan 等方法来掉用 `setNeedsDisplay` 实时刷新屏幕

## 为何只有在 drawRect 方法中才能调用上下文 context

```objc
- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);

    CGRect bounds;
    bounds = CGContextGetClipBoundingBox(context);
    [self drawRect:bounds];

    UIGraphicsPopContext();
}
```

`drawRect` 方法在 `drawLayer:inContext:` 里被调用, 并且被调用前有个 `UIGraphicsPushContext(context);` 方法将视图图层对应上下文压入栈顶, 然后 `drawRect` 执行完后, 将视图图层对应上下文执行出栈操作. 系统会维护一个 `CGContextRef` 的栈, 而 `UIGraphicsGetCurrentContext()` 会取栈顶的 `CGContextRef`, 当前视图图层的上下文的入栈和出栈操作恰好将 `drawRect` 的执行包裹在其中, 所以说只在 `drawRect` 方法里才能获取当前图层的上下文.

## GPU 工作原理

GPU 的处理单元是 texture. GPU 是硬件, 与 CPU 一样. 开发者不可能直接写代码去控制 GPU, 开发者通过框架 OpenGL 来控制 GPU, 在 ios 中 Apple 有自己的 Metal 引擎, 目前 Metal 引擎可以无缝与 OpenGL 对接 (平常使用的 Core Animation 和 CoreGraphic 都是基于 Metal 引擎的), 因此 iOS 开发中调用 OpenGL 实际上都是在调用 Metal 引擎.

## GPU 渲染过程

当 GPU 要进行渲染时, 会去查找 layer 的 content, 此时 layer 的 content 是 CGImageRef(就是一个指针), 由于 GPU 的处理单元 texture CGImageRef 指向的 bitmap 类型不同, 因此不能直接使用. 这时 Core Animation 会创建一个基于 OpenGL 的 Texture, 并将此 Texture 与 bitmap 绑定, 并通过 TextureID 来进行标识, 这时 GPU 就可以将此 `Texture` 放入 `VRAM` 中, 然后再将 `Texture` 渲染到屏幕对应的帧缓存 (`frame buffer`, 是一个与屏幕像素点对点对应的缓存区域) 上, 此时屏幕上即能显示了.

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145144.jpg?x-oss-process=style/WaMa)

## Texture 要处理的问题

1. Compositing 合并

    将多个纹理合并到一起, 即将多个 view 合并到一起. 如果 view 之间没有叠加, 那么 GPU 只需要做普通渲染即可, 速度很快无延迟. 但是如果 view 中有叠加部分的话会按照下方公式进行计算

    ```swift
    R = S+D*(1-Sa)
    // R: 为最终的像素值
    // S: 代表 上面的 Texture(Top Texture)
    // D: 代表下面的 Texture(lower Texture)
    // Sa: Texture 的 alpha 值.
    ```

    如果 Sa 的值为 1(不透明), 结果直接为 S, 但是如果 Sa 值不为 1, 那么就需要进行大量计算, 计算出每一个像素点的颜色.

    因此如果 view 的层级复杂, 透明度不为 1, 都会给 GPU 带来极大的压力.

    应当尽量减少视图数量与层次, 并在确认不透明的视图里标明 opaque 属性以避免无用的 alpha 通道合成.

2. size

    如果有 400 X 400 的照片要放入 100 X 100 的 imageView 中, 如果不作任何处理直接放入会导致 GPU 要进行像素点的 sampling(抽样), 这种抽样代价极高, 计算量会飙升.

## 离屏渲染

如果 view 设置了 `shouldRasterize`(光栅化), `masks`(遮罩), `shadows`(阴影), `edge antialiasing`(抗锯齿), `group opacity`(不透明), 复杂形状, 设置圆角, 渐变等都会导致离屏渲染. 离屏渲染的原理有如下两点:

1. GPU 将渲染结果不直接写入帧缓存, 而是先放到另一个内存区域中, 之后再写入帧缓存.

    因为 GPU 遵循 `画家算法`, 即按次序将像素一个一个输出到帧缓存中, 但是如果遇到有透明度或者圆角的叠加视图时, 不会回过头来进行擦除重新渲染, 因此必须有一个中转站让 GPU 能够修改已经输出的渲染结果, 然后再从中转站将计算好的与帧缓存等大的结果转移到帧缓存中

2. GPU 每次进行离屏渲染时都会切换上下文 (上下文即 GPU 状态)

    GPU 是一个高度流水化作业的处理器, 本来所有的计算全部都在帧缓存上有条不紊的输出, 此时突然收到指令要前往另一块内存 (帧缓存区外的另一缓存区) 进行绘制, 切换到只能切圆角 (或其它) 的操作. 等到完成后再切换到帧缓存区的上下文. GPU 虽然擅长大规模并行计算, 但是频繁的上下文切换并不在其考量之中.  在表格的滑动过程中, 如果有离屏渲染, 那么每秒要进行这样的切换 60 次, 很难不卡顿.

## 善用离屏渲染

尽管离屏渲染开销很大, 但是当我们无法避免它的时候, 可以想办法把性能影响降到最低. 优化思路也很简单: 既然已经花了不少精力把图片裁出了圆角, 如果我能把结果缓存下来, 那么下一帧渲染就可以复用这个成果, 不需要再重新画一遍了.

CALayer 为这个方案提供了对应的解法: `shouldRasterize`. 一旦被设置为 `true`, Render Server 就会强制把 layer 的渲染结果 (包括其子 layer, 以及圆角, 阴影, group opacity 等等) 保存在一块内存中, 这样一来在下一帧仍然可以被复用, 而不会再次触发离屏渲染. 有几个需要注意的点:

- `shouldRasterize` 的主旨在于 **降低性能损失, 但总是至少会触发一次离屏渲染**. 如果你的 layer 本来并不复杂, 也没有圆角阴影等等, 打开这个开关反而会增加一次不必要的离屏渲染
- 离屏渲染缓存有空间上限, 最多不超过屏幕总像素的 2.5 倍大小
- 一旦缓存超过 100ms 没有被使用, 会自动被丢弃
- layer 的内容 (包括子 layer) 必须是静态的, 因为一旦发生变化 (如 resize, 动画), 之前辛苦处理得到的缓存就失效了. 如果这件事频繁发生, 我们就又回到了 *每一帧都需要离屏渲染* 的情景, 而这正是开发者需要极力避免的. 针对这种情况, Xcode 提供了 *Color Hits Green and Misses Red* 的选项, 帮助我们查看缓存的使用是否符合预期
- 其实除了解决多次离屏渲染的开销, `shouldRasterize` 在另一个场景中也可以使用: 如果 layer 的子结构非常复杂, 渲染一次所需时间较长, 同样可以打开这个开关, 把 layer 绘制到一块缓存, 然后在接下来复用这个结果, 这样就不需要每次都重新绘制整个 layer 树了

## 异步绘制

`UIKit` 和 `CALayer` 大部分只能在主线程操作, 但不代表 `CG` 的操作不能在子线程执行, 比如:

```objc
UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
UIGraphicsGetCurrentContext()
UIGraphicsGetImageFromCurrentImageContext()
UIGraphicsEndImageContext()
```

## layoutIfNeeded 与 setNeedsLayout

### layoutIfNeeded

立刻根据刷新标记调用 `layoutSubviews` 方法以刷新视图.

如果要立刻刷新一个正在显示的视图, 需要首先 `setNeedsLayout` 打上标记, 然后 `layoutIfNeeded` 根据标记立刻刷新视图. 对于一个第一次显示的视图, 其一定是被标记的, 因此可以直接 `layoutIfNeeded` 进行刷新 (即: `layoutSubviews`). `layoutIfNeeded` 遍历的不是 `superView`, 而是 `subView`

`layoutIfNeeded` 不一定调用 `layoutSubviews` 方法, 依据是否有刷新标记而定.

- 有 `addSubview` 操作
- 设置了 `view` 的 `frame`, 当然前提是设置前后 `frame` 的值发生了变化
- 滚动一个 `UIScrollView`
- 旋转 `Screen`
- 改变一个 `UIView` 大小的时候

### setNeedsLayout

将视图标记为需要 `layoutSubviews`, 但不会立即强制执行, 而是在下一个 `runloop` 周期自动调用, 可以根据此特性将所有的布局更新合并到一个更新周期, 很适合用来优化性能.

当对一个图形的约束或 `frame` 进行再次赋值的时候都会将其调用 `setNeedsLayout` 方法 (对 frame 进行再次赋值时还会调用 `layoutIfNeeded`)

`setNeedsLayout` 一定会调用 `layoutSubviews`, 只是不会立即调用. 如果想立刻更新还需要配合使用 `layoutIfNeeded`.

```swift
layoutIfNeeded()
setNeedsLayout()
```

### layoutSubviews

iOS 中所有的视图布局都依据 `layoutSubviews` 方法, 在以下情况下会触发 `layoutSubviews` 方法.

- `addSubview` 会触发 `layoutSubviews`
- 设置 `view` 的 `Frame` 会触发 `layoutSubviews`, 当然前提是 `frame` 的值设置前后发生了变化
- 滚动一个 `UIScrollView` 会触发 `layoutSubviews`
- 旋转 `Screen` 会触发父 `UIView` 上的 `layoutSubviews` 事件

> 以上说的触发 layoutSubviews 即打上刷新标记且立即执行 layoutIfNeeded 方法. 如果更改了 view 的约束的话, 只会打上刷新标记, 而不会立即调用 layoutIfNeeded 方法, 也就是说会等待到下一个 runloop 进行刷新, 在动画闭包中更改约束时要格外注意此点.

### 应用

设置红色图块的高度增长动画

1. 直接在 `animate` 闭包中设置高度约束变化

    ```swift
        @IBAction func adjustedBtnClick(_ sender: Any) {
            UIView.animate(withDuration: 2.0) {
            if self.redViewHeight.constant == 30.0 {
                self.redViewHeight.constant = 60
            } else {
                self.redViewHeight.constant = 30.0
            }
        }
    ```

    ![himg](https://a.hanleylee.com/HKMS/2020-02-06-Kapture%202020-02-07%20at%200.02.55.gif)

    这种情况下高度会变化, 但是不会有动画. 原因在于在 `animate` 的闭包中设置高度值时触发的是约束的变化, 约束的变化只会对 `view` 打上刷新标记 `setNeedsLayout`, 但是并没有立即执行 `layoutSubviews`, 仍然需要等到下一个 `runloop` 时进行刷新视图. 可以理解为: 两秒钟的动画作用到了 `打标记` 这一动作上

2. 使用 layoutIfNeeded

    ```swift
        @IBAction func adjustedBtnClick(_ sender: Any) {
            if self.redViewHeight.constant == 30.0 {
                self.redViewHeight.constant = self.view.frame.height - 250
            } else {
                self.redViewHeight.constant = 30.0
            }

            UIView.animate(withDuration: 2.0) {
                self.view.layoutIfNeeded()
            }
        }
    ```

    ![himg](https://a.hanleylee.com/HKMS/2020-02-06-Kapture%202020-02-07%20at%200.06.25.gif)

    这种情况下高度会以动画形式发生变化. 因为之前的红色方块高度已经被重新赋值 (被打上了刷新标签), 在 animate 的闭包中设置 `layoutIfNeeded` 会立即调用 `layoutSubviews`, 这样两秒的动画就能正确作用于 `高度变化` 这一过程了
