---
title: iOS 编程零碎要点
date: 2019-07-28
comments: true
path: ios-programming-outline
categories: iOS
tags: ⦿ios, ⦿peanuts
updated:
---

本文总结了我在学习 Swift 开发 iOS App 过程中的零碎知识

![img](https://a.hanleylee.com/HKMS/2020-01-07-212642.jpg?x-oss-process=style/WaMa)

<!-- more -->

## UIKit

- UIView 的 `convert(_ rect: CGRect, to view: UIView?) -> CGRect` 可以将 `receiver` 中的 `rect` 转换到 `to view` 的坐标系上

    比如 `priceView` 的坐标为 `(10, 10, 20, 20)`, `priceView.inputField` 的坐标为 `(5, 5, 10, 10)`, 那么:

    ```swift
    var rect1 = vc.priceView.inputField.convert(vc.priceView.inputField.bounds, to: vc.view) // (15, 15, 10, 10)
    var rect2 = vc.priceView.inputField.convert(CGRect.zero, to: vc.view) // (15, 15, 0, 0)
    ```

- `UIDatePicker` 继承自 `UIControl`, 其通过 `addTarget()` 方法来添加用户交互事件. 其不是 `UIPickerView` 的子类, 不可通过协议的方式进行配置或用户交互.
- 设置 `layer` 的层次可以使用 `layer.zPosition = Int`, 数字越大层次越高, 越不被遮挡
- 设置 `view` 的层级可以使用 `bringSubview(toFront view: UIView)` 和 `sendSubview(toBack view: UIView)` 两个方法调整层次
- 代码中但凡以 `UI` 开头的都属于 `UIKit` 的一部分
- `scrollView` 最重要的就是 `contentSize` 属性, 设置时将其内的 `view` 上下左右全部对齐到 `contentSize`, 然后将 `view` 的宽度对齐到 `frameSize` 就可以保证视图只能上下移动.
- 将图片上方覆盖一层视图, 调整视图为黑色, 透明度为 0.2, 可以上图片上的文字标签更加易读
- Xcode 中的视图顺序为最下方在最上层.
- 每个单元格都最好设置独立的相对应的 view 文件
- 动态形态即 iOS 系统中的字体放大功能, 苹果推荐开发者开发的 `APP` 都支持动态形态, 即字体的 `Text Style`
- `CALayer` 与 `UIView` 区别
    - 每个 `UIView` 内部都有一个 `CALayer` 在背后提供内容的绘制和显示, 并且 `UIView` 的尺寸样式都由内部的 `Layer` 所提供. 两者都有树状层级结构, `CALayer` 内部有 `SubLayers`, `UIView` 内部有 `SubViews`. 但是 `CALayer` 比 `UIView` 多了个 AnchorPoint
    - `UIView` 显示的时候, `UIView` 做为 Layer 的 CALayerDelegate, View 的显示内容由内部的 CALayer 的 display
    - `CALayer` 是默认修改属性支持隐式动画的, 在给 `UIView` 的 `CALayer` 做动画的时候, `UIView` 作为 `CALayer` 的代理, Layer 通过 `actionForLayer: forKey:` 向 View 请求相应的 action(动画行为)
    - layer 内部维护着三分 `layer tree`, 分别是 `presentLayer Tree` (动画树), `modelLayer Tree` (模型树), `Render Tree` (渲染树), 在做 iOS 动画的时候, 我们修改动画的属性, 在动画的其实是 `CALayer` 的 `presentLayer` 的属性值, 而最终展示在界面上的其实是提供 `UIView` 的 `modelLayer`
    - 两者最明显的区别是 `UIView` 可以接受并处理事件, 而 `CALayer` 不可以
    - 总结: `UIView` 负责了与人的动作交互以及对 `CALayer` 的管理, `CALayer` 则负责了所有能让人看到的东西.
- 如果要展示或弹出某个操作的话一定要用到 `present` 命令
- `Storyboard` 中项目变多后会变得难以管理, 这时可以将项目中与其他视图没有关联的视图独立出来. 一是为了方便管理, 二也可以分配给专人进行设计, 互不打扰.  命令为 `Editor -> Refactor to Storyboard`. 注: 重构之后标签的名称不可再改变! 可能是 Xcode 的 bug
- 如果要在 `APP` 中嵌入一个有良好体验的网页, 可以使用 `SFSafariViewController`, 如果想简单方便可以使用 `WKWebView`.
- `UIPickerView` 与 `UITableView` 类似, 需要与普通控制器建立 `DataSource` 和 `delegate`
- `UIScrollView` 与 `UIImageView` 会截获 `touch`, 传递不到父视图 `view` 上, 需要 `extension` 里面对 `touchesBegan` 方法进行重载后将其能传递到父视图 `view` 中.
- 代码设置字体

    ```objc
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];// 加粗
    label.font = [UIFont fontWithName:@"Helvetica-Oblique" size:20];// 加斜
    label.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:20];// 又粗又斜
    ```

- `UIViewController` 可以 `addChild`, `UIView` 也可以 `addSubview`, 如果一个 `vc` 的 `view` 只添加了子 `vc` 的 `view`, 并没有 `vc.addChild(subVC)`, 那么这个 `subVC` 的 `viewDidAppear` 等不会被触发 (`viewDidLoad` 会被触发)
- 设置一个 `view` 位于屏幕的三分之一处, 可以设置屏幕的 `bottom` 与 view 的 `top` 或 `bottom` 对齐, 然后设置 multiplier. 以下图为例:

    ![himg](https://a.hanleylee.com/HKMS/2020-02-23-164101.png?x-oss-process=style/WaMa)

    在图中的例子中, 可以理解为将 view 的 `bottom` 与屏幕的 `bottom` 合并为一条线附着于 view 上, 然后依据 multiplier 的值设置此线在屏幕中的位置

- Xcode 中的默认可以使用的字体与 macOS 的安装字体不同, Xcode 中的所有可显示的字体都在 iPhone 中默认存在
- 除了系统的字体有 `systemFontWeight` 方法, 其他的所有自定义字体的粗细都只能通过字体的文件来区分, 比如细字体是一个字体文件, 粗字体是一个字体文件
- [导入自定义字体并使用](https://www.jianshu.com/p/29b8d82d2867)
- `LaunchScreen` 修改图片无响应
    - 判断 `Info.plist` 中 `launchscreen` 的名称是否设置正确
    - 修改 `LaunchScreen` 的图片后, 需要删除 app, 再重新安装
- `UIButton` 的 `titleLabel` 设置: 必须使用 `setTitle("", for:.touchUpInside)` 指定状态, 然后才可以使用 titleLabel.  <https://www.jianshu.com/p/53dcf361236b>
- `UITableView` 的 `sectionHeaderView` 的背景颜色不可通过 `backgroundColor` 直接进行设置, 可以通过 `contentView.backgroundColor` 进行设置, 但是由于 `contentView` 是与 safeArea 对齐的, 超出 safeArea 区域的其他地方的背景颜色仍然是默认的白色, 因此最直接的办法是 `backgroundView = LineView(UIColor.red)`
- `UITableView` 的 cell 中有, 自身, `backgroundView`, `selectedBackgroundView`, `contentView` 他们层次的上下关系是: `自身 backgroundView selectedBackgroundView contentView 其他添加的 view`, 在布局时, 我们切记记得一定要将自定义添加的 `subview` 添加到 `contentView` 上, 因为系统对 `editStyle` 的 `cell` 进行处理时都是针对 `contentView` 进行
- `contentView` 默认是根据 `safeArea` 对齐的, 因此如果添加的 `subview` 对齐了 `contentView`, 那么就不用操心对齐到 `safeArea` 了
- 在长按 `UITableviewCell` 弹出菜单的方法中, 我们必须要设置 `canBecomeFirstResponder` 与 `canPerformAction`, 然后在长按手势方法中声明 `recognizer.view?.becomeFirstResponder()`, 切记不要在 cell 每次赋值时指定 `cell.becomeFirstResponder`, 否则会发生 `AXError` 错误!
- 在 `UITableView` 的 `reloadRows` 方法执行时, 如果我们同时使用了 `tableView.reloadData()`, 那么将会出现单元格缺失的现象, 这应该与单元格的复用有关.  相应的 iOS 13 的方法 `UITableViewDiffableDataSource` 在增量更新时如果进行 `tableView.reloadData()` 也会发生 `cell` 的断层现象
- `UITableView` 的复用机制

    通常, 我们会在 `tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "tableCell")` 进行注册 cell, 之后在 `cellForRowAt` 方法中使用 `let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! HomeTableViewCell` 来进行复用后.

    想象一下, 如果不进行复用, 而是直接在 `cellForRowAt` 中返回一个我们自定义的 cell, 可不可以呢?

    答案是可以的, 但是这样的话每次向下滑动, 显示一个新的 cell 时, 系统就会对那一个新的 cell 进行初始化, 对旧的进行释放, 这样是极其浪费系统计算资源的.  而使用了复用机制后, 系统就可以直接调用指定标识符 (指定类型) 的 cell, 不用涉及到初始化, 大大减轻了系统负担.

    复用的简单流程如下:

    > 假设一个屏幕 (显示范围) 只能显示 tableView 的 5 个 cell

    1. 在添加一个 tableView 到主 view 的时候会随之创建一个复用池, 用于存放通过标识符和指定类型创建的 `注册 cell`
    2. 系统在显示 tableView 的第一个 cell 时调用其代理方法 `cellForRowAt`, 因为代理方法中使用了 `dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)`, 那么会检测当前复用池有无 cell, 没有则新建 (初始化) 一个, 返回此 cell 到屏幕并将此 cell 添加到复用池
    3. 系统在显示第 2 个 cell 的时候, 再次调用代理方法 `cellForRowAt`, 检查复用池有无 cell, 虽然有 cell, 但是当前屏幕 (显示范围) 还没有被铺满, 因此再次创建 (即初始化) 一个 cell, 返回此 cell 到屏幕并将其添加到复用池
    4. 重复第 3 步, 直至显示到第 7 个 cell, 此时屏幕 (显示范围) 已经被填满, 显示新的 cell 的同时对旧 cell 进行回收到复用池并从复用池拉取之前被回收的 cell 进行复用.

       ![himg](https://a.hanleylee.com/HKMS/2020-03-31-tableView-reuse.gif)

       > UITableViewCell 的复用机制是, 在 tableview 中存在一个复用池. 这个复用池是一个队列或一个链表. 然后通过 dequeueReusableCellWithIdentifier: 获取一个 cell, 如果当前 cell 不存在, 即新建一个 cell, 并将当前 cell 添加进复用池中. 如果当前的 cell 数量已经到过 tableview 所能容纳的个数, 则会在滚动到下一个 cell 时, 自动取出之前的 cell 并设置内容.

    `tableView`, `tableView` 的 `headerView`, `collectionView`, `collectionView` 的 `headerView` 都是这个套路

- UIView 的如下属性是可以有动画效果的, 其他的则不行, 比如 `isHidden` 属性

    - `frame`
    - `bounds`
    - `center`
    - `transform`
    - `alpha`
    - `backgroundColor`
    - `contentStretch`

    [UIView Animation](https://developer.apple.com/library/archive/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/AnimatingViews/AnimatingViews.html)

    [Core Animation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Key-ValueCodingExtensions/Key-ValueCodingExtensions.html)

- 组透明

    `UIView` 有一个叫做 `alpha` 的属性来确定视图的透明度. `CALayer` 有一个等同的属性叫做 `opacity`, 这两个属性都是影响子层级的. 也就是说, 如果给一个图层设置了 opacity 属性, 那它的子图层都会受此影响.

    iOS 常见的做法是把一个控件的 `alpha` 值设置为 0.5(50%) 以使其看上去呈现为不可用状态. 对于独立的视图来说还不错, 但是当一个控件有子视图的时候就有点奇怪了, 下图展示了一个内嵌了 `UILabel` 的自定义 `UIButton`; 左边是一个不透明的按钮, 右边是 50% 透明度的相同按钮.  可以注意到, 里面的标签的轮廓跟按钮的背景很不搭调.

    ![himg](https://a.hanleylee.com/HKMS/2021-05-02230345.jpg?x-oss-process=style/WaMa)

    这是由透明度的混合叠加造成的, 当显示一个 50% 透明度的图层时, 图层的每个像素都会一半显示自己的颜色, 另一半显示图层下面的颜色.  这是正常的透明度的表现. 但是如果图层包含一个同样显示 50% 透明的子图层时, 所看到的视图,  50% 来自子视图, 25% 来了图层本身的颜色, 另外的 25% 则来自背景色.

    可以设置 CALayer 的一个叫做 `shouldRasterize` 属性来实现组透明的效果, 如果它被设置为 YES, 在应用透明度之前, 图层及其子图层都会被整合成一个整体的图片, 这样就没有透明度混合的问题了

    ```swift
    button2.layer.shouldRasterize = true
    ```

- `UITableView` 代理方法呼叫的顺序:

    1. 首先执行 `numberOfRowsInSection:` 方法, 返回 cell 个数为 10.
    2. 其次执行的就是 `heightForRowAtIndexPath:` 方法, 如上图, 此时执行该方法会将所有 cell 的高度全部返回.
    3. 这时候就开始执行 `cellForRowAtIndexPath:` 方法, 因为当前页面只能布局 3 条 cell, 所以该方法会被执行三次. 并且, 执行一次 `cellForRowAtIndexPath:` 方法紧接着就会执行一次 `heightForRowAtIndexPath:` 方法返回 cell 高度.

    因此, 当我们从网络或者本地缓存中获取到所需数据 (array) 后, 可以直接执行代码: `self.tableView reloadData`, 然后就会调用 `cellForRowAtIndexPath:` 方法和 `heightForRowAtIndexPath:` 方法.

- `UIView` animate 的动画选项

    - `layoutSubviews`
    - `allowUserInteraction`: 允许在动画执行过程中对用户交互进行反馈
    - `beginFromCurrentState`: 从当前状态继续执行另一动画
    - `repeat`: 让动画一直重复执行
    - `autoreverse`: 配合. repeat 使用, 使动画反转并持续执行
    - `overrideInheritedDuration`: 强制使用提交动画时使用的动画时长
    - `overrideInheritedCurve`: 强制使用提交动画时使用的曲线
    - `overrideInheritedOptions`: 强制使用提交动画时使用的选项
    - `allowAnimatedContent`: 允许在动画过程中直接动态改变 view 的属性 (默认不设置此值时动画过程中使用的是此 view 的快照)
    - `showHideTransitionViews`: 允许在动画过程中隐藏或显示正在进行动画的 view
    - `curveEaseInOut`: 相当于 `[.curveEaseIn,.curveEaseOut]` 的组合, 在开始加速和在结束动画时减速
    - `curveEaseIn`: 在动画开始时加速
    - `curveEaseOut`: 在动画结束时减速
    - `curveLinear`: 让动画保持匀速
    - `transitionFlipFromLeft`: 从左边翻转
    - `transitionFlipFromRight`: 从右边翻转
    - `transitionCurlUp`: 卷上去
    - `transitionCurlDown`: 卷下去
    - `transitionCrossDissolve`: 交叉溶解
    - `transitionFlipFromTop`: 从顶部翻转
    - `transitionFlipFromBottom`: 从底部翻转
    - `preferredFramesPerSecond60`: 每秒 60 帧
    - `preferredFramesPerSecond30`: 每秒 30 帧

    ```swift
    UIView.animate(withDuration: 1, // 动画总时长
                   delay: 2, // 执行动画前的延时
                   options: [.curveEaseIn,.curveEaseOut], // 动画的属性, 可以使多个属性配合, 也可以是单个属性, 如果是 [] 的话则使用默认
                   animations: {print(1) }, // 闭包, 动画作用的目标
                   completion: nil) // 动画执行结束后的回调闭包

    UIView.animate(withDuration: 1,
                   delay: 1,
                   usingSpringWithDamping: 0.5, // 设置弹性动画的阻尼 (范围: 0.0～1.0), 越接近 0.0 弹性越大, 反之则越小.
                   initialSpringVelocity: 0.5, // 控制动画初始速度.
                   options: [.curveEaseIn],
                   animations: {print(2) },
                   completion: nil)
    ```

### `backgroundColor`, `alpha`, `isHidden`, `opaque` 区别

- `hidden`: 此属性为 `BOOL` 值, 用来表示 `UIView` 是否隐藏. 关于隐藏大家都知道就是让 `UIView` 不显示而已, 但是需要注意的是:
    - 当前 `UIView` 的所有 `subview` 也会被隐藏, 忽略 `subview` 的 `hidden` 属性. `UIView` 中的 `subview` 就相当于 `UIView` 的死忠小弟, 老大干什么我们就跟着老大, 同进同退, 生死与共!
    - 当前 `UIView` 也会从响应链中移除. 你想你都不显示了, 就不用在响应链中接受事件了.
- `alpha`: 此属性为浮点类型的值, 取值范围从 0.0 到 1.0, 表示从完全透明到完全不透明, 其特性有:
    - 当前 `UIView` 的 `alpha` 值会被其所有 `subview` 继承. 因此, `alpha` 值会影响到 `UIView` 跟其所有 `subview`.
    - `alpha` 具有动画效果. 当 `alpha` 为 0 时, 跟 `hidden` 为 `YES` 时效果一样, 但是 `alpha` 主要用于实现隐藏的动画效果, 在动画块中将 `hidden` 设置为 `YES` 没有动画效果.
- `backgroundColor` 的 `alpha` (Clear Color): 此属性为 `UIColor` 值, 而 `UIColor` 可以设置 `alpha` 的值, 其特性有:
    - 设置 `backgroundColor` 的 `alpha` 值只影响当前 `UIView` 的背景, 并不会影响其所有 `subview`. 这点是同 `alpha` 的区别, `Clear Color` 就是 `backgroundColor` 的 `alpha` 为 0.0.
    - `alpha` 值会影响 `backgroundColor` 最终的 `alpha`. 假设 `UIView` 的 `alpha` 为 0.5, `backgroundColor` 的 `alpha` 为 0.5, 那么 `backgroundColor` 最终的 `alpha` 为 0.25(0.5 乘以 0.5).
- `opaque`: 此属性为 BOOL 值. 要搞清楚这个属性的作用, 就要先了解绘图系统的一些原理: 屏幕上的每个像素点都是通过 RGBA 值 (Red, Green, Blue 三原色再配上 Alpha 透明度) 表示的, 当纹理 (`UIView` 在绘图系统中对应的表示项) 出现重叠时, GPU 会按照下面的公式计算重叠部分的像素 (这就是所谓的 **合成**):

    ```bash
    Result = Source + Destination * (1 - SourceAlpha)
    ```

    `Result` 是结果 `RGB` 值, `Source` 为处在重叠顶部纹理的 RGB 值, `Destination` 为处在重叠底部纹理的 RGB 值. 通过公式发现: 当 `SourceAlpha` 为 1 时, 绘图系统认为下面的纹理全部被遮盖住了, Result 等于 Source, 直接省去了计算! 尤其在重叠的层数比较多的时候, 完全不同考虑底下有多少层, 直接用当前层的数据显示即可, 这样大大节省了 GPU 的工作量, 提高了效率. (多像现在一些 "美化墙", 不管后面的环境多破烂, "美化墙" 直接遮盖住了, 什么都看不到, 不用整治改进, 省心省力). 更详细的可以读下 objc.io 中 < 绘制像素到屏幕上 > 这篇文章.

    那什么时候 `SourceAlpha` 为 1 呢? 这时候就是 `opaque` 上场的时候啦!  当 `opaque` 为 YES 时, `SourceAlpha` 为 1. `opaque` 就是绘图系统向 `UIView` 开放的一个性能开关, 开发者根据当前 `UIView` 的情况 (这些是绘图系统不知道的, 所以绘图系统也无法优化), 将 `opaque` 设置为 `YES`, 绘图系统会根据此值进行优化. 所以, 如果在开发时某 UIView 是不透明的, 就将 `opaque` 设置为 `YES`, 能优化显示效率.

    需要注意的是:

    - 当 `UIView` 的 `opaque` 为 `YES` 时, 其 `alpha` 必须为 `1.0`, 这样才符合 `opaque` 为 YES 的场景. 如果 `alpha` 不为 1.0, 最终的结果将是不可预料的 (`unpredictable`).
    - opaque 只对 UIView 及其 subclass 生效, 对系统提供的类 (像 UIButton, UILabel) 是没有效果的.

## `UIWindow` 操作

- 通过 `.isHidden` 来控制隐藏及显示
- `window?.makeKeyAndVisible()` 的作用是显示一个 UIWindow, 同时设置为 keyWindow, 并将其显示在同一 windowLevel 的其它任何 UIWindow 之上, 等效于:

    ```swift
    window?.makeKey()
    window?.isHidden = false
    ```

- window 的显示问题
    - 对于 `hidden` 的 `setter` 方法, 最终显示的以最后执行过 `.isHidden=false` 的 UIWindow 为准, 且执行 `.isHidden=false` 之前 `isHidden` 的值为 `true`. (`isHidden` 如果是从 `false` 改为 `false` 的不算最后改变 UIWindow 的显示状态)
    - 对于 `makeKeyAndVisible` 方法, 最终显示的以最后执行过 `makeKeyAndVisible` 的 UIWindow 为准.
    - 对于先后分别用 `makeKeyAndVisible` 方法和 `isHidden` 的 `setter` 方法, 还是先后分别用 `isHidden` 的 `setter` 方法和 `makeKeyAndVisible` 方法, 结局同样以最后改变显示状态的 UIWindow 为准.
- window level 问题
    - windowLevel 数值越大的显示在窗口栈的越上面
    - 显示层的优先级 为: `alert` > `statusBar` > `normal`
    - 系统给 UIWindow 默认的 `windowLevel` 为 `normal`

## 控制器

- 给定的导航流程只有一个导航控制器; 一个导航控制器可以管理多个视图控制器; 导航体系的每个视图控制器都有到导航控制器的引用.
- `UIPageViewController` 与 `UINavigationController` 都属于容器控制器.
- 如果控制器被包裹在 `navigationController` 中, 则必须在 `navigationController` 中设置状态列才有效果
- 为什么必须要添加 `required init?(coder decoder: NSCoder)`

    - 名称: 必要初始化器
    - 上下文: 当继承了遵守 `NSCoding protocol` 的类 (如 `UIView`, `UIViewController` 等) 时
    - 显性添加的条件: 当在子类定义了指定初始化器或 `override` 了父类的初始化器后, 那么必须显性实现 (其他情况下会隐性实现, 不需要我们管)
    - `fatalError` 含义: 默认的在必要初始化器中系统会给我们添加 `fatalError` 命令, 其含义是无条件停止执行并打印

  如果是代码实现界面, 当重写或自定义了初始化器时, 系统会自动提示我们添加此必要初始化器, 按照系统的要求进行 `fix` 即可

## target 与 project 与 xcworkspace 的关系

- 一个 `xcworkspace` 可以包含多个 `project`
- 一个 `target` 只能对应一个 `product`
- 一个 `xcworkspace` 编译时可以选择多个项目中的不同 `target`, 如图中可以选择 3 个 `target`
- 一个文件可以映射到同一个 `xcworkspace` 中的多个 `target` 中, 可以用在开发 `vip` 版本与普通版本这一需求上
- `Swift Package Manager` 是对应于一整个 `xcworkspace` 的, 即, 在同一个 `xcworkspace` 中的任意一个 `project` 中引入了第三方库, 那么在任意一个 `project` 中都可以使用

![himg](https://a.hanleylee.com/HKMS/2020-02-19-target%26project.png?x-oss-process=style/WaMa)

## MapKit

- 前向地址编码 (`Forward Geocoding`): 将文字地址转换为全球地理坐标
- 反向地理编码 (`Reverse Geocoding`): 将经纬度值转回地址
- `iOS 10` 之后规定如果要使用照片库或者相机则必须要将原因列在 `info.plist` 文件中. 这样可以在 `APP` 要使用照片或相机时给用户提醒.
- 如果要与图片选择器进行互动, 必须遵守 `UIImagePickerControllerDelegate` 和 `UINavigationControllerDelegate`

## AutoLayout

- `constrain to margin` 是 `xcode` 中 `AutoLayout` 的防触摸边缘功能, 选中后自动缩进 `20`
- `autolayout` 即设置物件的长宽以及横纵坐标
    - 长宽: 通过物件长或宽与屏幕 view 的比值确定物件长宽
    - 纵横坐标: 通过居中及物件之间相对距离确认
- `Content Hugging Priority` (视图抗拉伸优先级): 值越小, 越先被拉伸
- `Content Compression Resistance` (抗压缩优先级): 值越小, 越先被压缩
- `autolayout` 中设置百分比宽度 / 高度: 先设定等宽, 然后再属性设置面板中 `multuplier` 调整为百分比
- 纯代码写视图布局时需要注意, 要手动调用 `loadView` 方法, 而且不要调用父类的 `loadView` 方法. 纯代码和用 IB 的区别仅存在于 `loadView` 方法及其之前, 编程时需要注意的也就是 `loadView` 方法.

## 影响编译时间的因素

在 `Build Settings -> Swift Compiler -> Custom Flags -> Other Swift Flags` 中添加如下代码可查看耗时编译代码

```bash
/// <limit> 为 warning 的编译时间阈值
-Xfrontend -warn-long-function-bodies=<limit>

-Xfrontend -warn-long-expression-type-checking=<limit>
```

![himg](https://a.hanleylee.com/HKMS/2020-12-01-111134.png?x-oss-process=style/WaMa)

影响因素如下:

- 硬件
- 配置
- 代码书写方式
    - 使用 `+` 拼接可选字符串会极其耗时

        ```swift
        /* 优化前 372ms */
        let finalResult = (dbWordModel?.vocabularyModel?.justSentenceExplain?? "") +"<br/>"+ (dbWordModel?.vocabularyModel?.justSentence ?? "")

        /* 优化后 20ms */
        // let finalResult = "\(dbWordModel?.vocabularyModel?.justSentenceExplain ?? "")<br/>\(dbWordModel?.vocabularyModel?.justSentence ?? "")"
        ```

    - 可选值使用?? 赋默认值再嵌套其他运算会极其耗时.

        ```swift
        /* 优化前 372 ms */
        let finalResult = (dbWordModel?.vocabularyModel?.justSentenceExplain?? "") + "<br/>" + (dbWordModel?.vocabularyModel?.justSentence ?? "")

        /* 优化后 63 ms */
        guard let dbSentenceExp = dbWordModel?.vocabularyModel?.justSentenceExplain,
        let dbSentence = dbWordModel?.vocabularyModel?.justSentence else {return}
        // let finalResult = "\(dbSentenceExp)<br/>\(dbSentence)"
        ```

    - 将长计算式代码拆分 最后组合计算

        ```swift
        /* 优化前 736 ms */
        let totalTime = (timeArray.first?.float()?.int?? 0) * 60 + (timeArray.last?.float()?.int?? 0)

        /* 优化后 22 ms */
        let firstPart: Int = (timeArray.first?.float()?.int?? 0)
        let lastPart: Int = (timeArray.last?.float()?.int?? 0)
        let totalTime = firstPart * 60 + lastPart
        ```

    - 与或非和 `>=`, `<=`, `==` 逻辑运算嵌套 Optional 会比较耗时

        ```swift
        /* 优化前 10420 ms */
        let finalResult = (dbWordModel?.vocabularyModel?.justSentenceExplain?? "") +"<br/>"+ (dbWordModel?.vocabularyModel?.justSentence??"")

        /* 优化后 21 ms */
        let leftValue: CGFloat =  homeMainVC?.scrollview.contentOffset.y?? 0
        let rightValue: CGFloat = (homeMainVC?.headHeight?? 0.0) - (homeMainVC?.ignoreTopSpeace?? 0.0)
        if leftValue == rightValue {...}
        ```

    - 手动增加类型推断会降低编译时间.

        ```swift
        /* 优化前 21 ms */
        let leftValue =  homeMainVC?.scrollview.contentOffset.y?? 0
        let rightValue = (homeMainVC?.headHeight?? 0.0) - (homeMainVC?.ignoreTopSpeace?? 0.0)

        /* 优化后 16 ms */
        let leftValue: CGFloat =  homeMainVC?.scrollview.contentOffset.y?? 0
        let rightValue: CGFloat = (homeMainVC?.headHeight?? 0.0) - (homeMainVC?.ignoreTopSpeace?? 0.0)
        ```

## UDID & UUID

- *UDID*: *Unique Device Identifier*, 对于已越狱了的设备, UDID 并不是唯一的. 使用 Cydia 插件 UDIDFaker, 可以为每一个应用分配不同的 UDID. 所以 UDID 作为标识唯一设备的用途已经不大 了.

    ![himg](https://a.hanleylee.com/HKMS/2021-10-20180843.png?x-oss-process=style/WaMa)

    获取方法: 目前没有代码方式可以获取, 只能通过外部工具, 如 Xcode 或 `idevice_id -h`

- *UUID*: *Universally Unique Identifier*: 是基于 iOS 设备上面某个单个的应用程序生成的一个唯一标示, 只要用户没有完全删除应用程序, 则这个 UUID 在用户使用该应用程序的时候一直保持不变. 如果用户删除了这个应用程序, 然后再重新安装, 那么这个 UUID 已经发生了改变. UUID 会在用户删除了程序后再重装的时候发生改变, 解决的方案就是使用 `UUID+KeyChain` 记录设备唯一标识

  获取方法: 代码方式 `UIDevice.current.identifierForVendor`

> `UUID().uuidString` 获得的并不是设备的 UUID, 而是一个随机数, 这个随机数每次产生都不一样, 而且能保证唯一

## drawrect & layoutsubviews 调用时机

`layoutSubviews:`(相当于`layoutSubviews()`函数) 在以下情况下会被调用:

- init 初始化不会触发 `layoutSubviews`.
- addSubview 会触发 `layoutSubviews`.
- 设置 view 的 Frame 会触发 `layoutSubviews` (frame 发生变化触发).
- 滚动一个 UIScrollView 会触发 `layoutSubviews`.
- 旋转 Screen 会触发父 UIView 上的 `layoutSubviews` 事件.
- 改变一个 UIView 大小的时候也会触发父 UIView 上的 `layoutSubviews` 事件.
- 直接调用 `setLayoutSubviews`.

`drawrect:`(`drawrect()` 函数) 在以下情况下会被调用:

- `drawrect:` 是在 UIViewController 的 `loadView:` 和 `viewDidLoad:` 方法之后调用.
- 当我们调用 `[UIView sizeToFit]` 后, 会触发系统自动调用 `drawRect:`
- 当设置 UIView 的 `contentMode` 或者 Frame 后会立即触发触发系统调用 `drawRect:`
- 直接调用 `setNeedsDisplay` 设置标记或 `setNeedsDisplayInRect:` 的时候会触发 `drawRect:`

## 常见问题

### building for iOS simulator, but linking in object file built for iOS, for architecture arm64

虽然库中包含了 arm64, 但是表明了它是用在实际设备而非模拟器上的, 临时解决办法可以设置 `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`

这是一个治标不治本的"快速疗法", 加入这个设定可以让你编译通过并运行, 但是你需要清楚了解到这么做的弊端: 因为 *arm64* 被排除了, 所以在 iOS 模拟器上, 只有 `x86_64` 这一个架构选择. 这意味着你的整个 app 都会以 *x86_64* 进行编译, 然后跑在 *x86_64* 的模拟器上. 而在 Apple Silicon 的 mac 上, 这个模拟器其实是使用 Rosetta 2 跑起来的, 这意味着性能的大幅下降.

## 感悟

- 如果一些程序中使用的静态库不支持 armv7s, 而你的工程支持 armv7s 时, 就会出现"xxxx does not contain a(n) armv7s slice:xxxxx for architecture armv7s"的编译错误, 想要解决这个问题, 有两个方法:
    1. 如果是开源的, 能够找到源代码, 则可以用源代码重新打一个支持 armv7s 的 libaray, 或者在工程中直接使用源代码, 而不是静态库.
    2. 如果不是开源的, 要么就坐等第三方库的支持, 要么就暂时让你的工程不支持 armv7s.
- ios Deep Link: Deep Link 包含 URL Scheme 与 Universal Link 两种技术

    ![himg](https://a.hanleylee.com/HKMS/2021-11-05225053.jpg?x-oss-process=style/WaMa)

    delay deep link 是指当设备没有安装 app 时会指引到应用市场安装app, 安装完打开app后仍然会定位到目标页

- Universal link 本地调试

    通常情况下用户会在下载完APP后由系统请求所关联的域名, 下载相应的 json 文件, 这个请求并不是每次下载都会触发, 也并不是每次请求都会请求最新文件(而是一个CDN), 因此我们在开发时需要:

    1. 设置为开发模式, 在 associated domain 后添加 `?mode=developer`
    2. 使用 Charles 的 `Map to Local` 功能, 直接使用本地 json 文件返回(目的是每次请求的都是最新文件)

    为了验证一个指定url在app内打开的页面效果, 我们可以将url 拷贝至备忘录中, 然后在备忘录中点击url

- 显式动画与隐式动画: 隐式动画一直存在, 如需关闭需设置; 显式动画是不存在, 如需显式 要开启 (创建). UIView 动画, 又称隐式动画, 动画后 frame 的数值发生了变化. 另一种是 CALayer 动画, 又称显示动画
- 持久化存储时如果要频繁写入或读取最好使用 CoreData 或其他数据库而不是使用文件以减少 I/O 次数
    - `OS Cache`: 性能最好的一层, 使用 logical I/O, 由于是储存在内存中, 所以 I/O 操作很高效 (使用 logical I/O)
    - `Disk Cache`: 磁盘储存的物理映射. (使用 physical I/O)
    - `Permanent Storage`: 最终用于持久化数据的介质, 对于 iOS 来说, 就是闪存 (使用 physical I/O)

    缓存有以上几个层级, 对于 app 来说, 离 cpu 越近的 cache, 性能就越好, 但同时我们也希望 cache 能确实地落在磁盘中. 数据在内存当中时对于 app 而言速度是最快的, 也没有任何的 IO 开销, 但是当我们需要将数据从内存一层一层地注入到闪存时, 就需要注意 IO 开销了.

    ![himg](https://a.hanleylee.com/HKMS/2020-10-15-024803.jpg?x-oss-process=style/WaMa)

    面是单单的更新 `plist` 操作, 调用了系统的 `writeToFile` 函数, 最后再调用栈上系统为我们调用了 `fsync`, 所以数据就会直接由 `OS cache` 层一直写入到 `Disk cache` 层, 并从 `OS cache` 层被清除, 如果在写入后我们仍然要继续使用数据, 就会失去了 OS cache 这一层的缓存, 而需要重新开启 IO 去磁盘中读取数据

    因此使用 `plist` 这类文件来储存需要频繁读写的数据, 是非常不合适的

- `UITableView` 的几个交互属性

    - `isDragging`: 是否正在被手指拖动 (必须手指与屏幕接触, 需要滑动一小段距离才能使此值设为 true)
    - `isZooming`: 当前 tableView 是否正在缩放 (放大或缩小)
    - `isFocused`: 是否是当前 UIScreen 的 focusedView
    - `isTracking`: 是否被手指按住以开始一个滑动事件 (只要手指放上哪怕没有滚动也会为 true 值)
    - `isDecelerating`: 是否在惯性滑动, 即手指已经离开屏幕但是 scrollView 仍然在滚动的情况. 因此本属性与 isDragging 不可能同时为 true
    - `isDecendant(of: UIView)`: 是否是某 `view` 的 `subview`
    - `isZoomBouncing`: 是否正在缩放的惯性动画中
    - `isExclusiveTouch`: 当设置了 `isExclusiveTouch = true` 的控件 (View) 是事件的第一响应者, 那么到你的所有手指离开屏幕前, 其他的控件 (View) 是不会响应任何触摸事件的. 如果设置类别较多, 可直接设置全局 `UIView.appearance().isExclusiveTouch = true`
    - `isFirstResponder`: 是否是第一响应者

- `UITableView` 的行高

    默认情况下如果我们实现了 `cellForRowAtIndexPath` 方法, 那么如果有 500 行, 在 `reloadData` 的时候就会调用高度方法 `heightForRowAt` 500 次.

    最好的优化办法是如果 cell 高度都统一, 那么就直接使用 `tableView.rowHeight =...` 来确定高度, 这样不会调用高度方法那么多次.

    如果我们的 `tableView` 含有不同的 cell 高度, 那么可以使用自动行高来将高度计算推迟到滚动时发生

    ```swift
    // ios 10 及以下
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableView.automaticDimension

    // ios 11 及以上
    tableView.rowHeight = UITableView.automaticDimension
    ```

    然后 cell 就会依据内部的所有空间自动计算行高

    或者直接通过代理方法实现:

    ```swift
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { }
    ```

    > 设置 `func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { }` 其实是没有意义的

    自动行高与非自动行高有如下区别:

    1. 在禁用 `cell` 预估高度的情况下, 系统会先把所有 `cell` 实际高度先计算出来, 也就是先执行 `tableView:heightForRowAtIndexPath:` 代理方法, 接着用获取的 `cell` 实际高度总和来参与计算 `contentSize`, 然后才显示 `cell` 的内容. 在这个过程中, 如果实际高度计算比较复杂的话, 可能会消耗更多的性能.

    2. 在使用 `cell` 预估高度的情况下, 系统会先执行所有 `cell` 的预估高度, 也就是先执行 `tableView:estimatedHeightForRowAtIndexPath:` 代理方法, 接着用所有 `cell` 预估高度总和来参与计算 `contentSize`, 然后才显示 `cell` 的内容. 这时候从下往上滚动 `tableView`, 当有新的 `cell` 出现的时候, 如果 `cell` 预估值高度减去实际高度 (实际高度根据 `cell` 中所持有控件约束计算得出) 的差值不等于 0, `contentSize` 的高度会以这个差值来动态变化, 如果差值等于 `0`, `contentSize` 的高度不再变化. 在这个过程中, 由之前的所有 `cell` 实际高度一次性先计算变成了现在预估高度一次性先计算, 然后实际高度分步计算. 正如苹果官方文档所说, 减少了实际高度计算时的性能消耗, 但是这种实际高度和预估高度差值的动态变化在滑动过快时可能会产生跳跃现象, 所以此时的预估高度和真实高度越接近越好(为了解决这种问题, 可以使用字典缓存所有的预估高度然后在代理方法中返回当前 `cell` 的高度).

- `UIScrollView` 如果被设置 `contentOffset` 或者 `setContentOffset()` 的话, 会触发其 `scrillViewDidScroll` 代理方法
- `contencontentSize` 在 `viewDidLoad` 中设置后, 如果之后没有进行边距与宽高的约束的话是起作用的, 在 `viewdidload` 中设置是为了方便, 更严格的应该全部使用约束
- `UITableViewCell` 的 `contentView` 的 `bgColor` 位于 `self` 的 `bgColor` 之上
- `UIScrollView` 如果没有被正确释放, 并且其代理方法中会发送 Notification 的话, 那么可能会触发各种灵异事件.
- 时间戳: 格林威治时间 **1970-01-01 00:00:00** 起至现在的总秒数, 所以所有时区的时间戳都是一样的, 但是同样的时间戳在不同的时区会显示不同的日期时间, 因为中国是 `UTC+8` 时区, 因此在北京时间 **1970-01-01 08:00:00** 的时候, 时间戳为零, 一个普通的时间戳如果放到中国时区来计算的话就会以 `8:00` 为基准, 计算差值
    - `NSDate`: 网络时间, 属于 `Foundation` (单位秒, 保留到微秒)
    - `CFAbsoluteTimeGetCurrent()`: 网络时间, 属于 `CoreFoundation` (单位秒, 保留到微秒, 默认为 `the reference date is 00:00:00 1 January 2001)` 相当于 `NSDate().timeIntervalSinceReferenceDate`
    - `mach_absolute_time()`: 内建时钟 (单位秒, 保留到纳秒), 不会因为外部时间变化而变化 (例如时区变化, 夏时制, 秒突变等), 系统重启后会被重置.
    - `CACurrentMediaTime()`: 内建时钟, 属于 `QuartzCore` (单位秒, 保留到纳秒), 不会因为外部时间变化而变化 (例如时区变化, 夏时制, 秒突变等), 系统重启后 `CACurrentMediaTime()` 会被重置.
- `@IBOutlet` 与 `@IBAction` 区别
    - `IBOutlet` 只是将标签等不需要与使用者互动的原件进行连接, 通过代码控制界面
    - `IBAction` 连接的是按钮一样的与使用者互动的原件, 通过界面控制代码
- 为什么 `IBOutlet` 后面有 `!`, 类别中的属性被定义后一定要被初始化 (有值), 但如果是 `Optional` 类型则可以不初始化, 使用 `!` 表示不用进行解包一定会有值
- `addTarget` 方法和 `@IBAction` 链接的意义是相同的, 都是通过用户交互事件来执行相关方法.
- 事件区别:
    - `touch up inside` 触发: 手指按下, 在按钮区域抬起
    - `touch up outside` 触发: 手指按下, 在按钮区域外抬起
    - `touch down` 触发: 手指按下
- 在方法中 `indexPath` 可翻译为某路径, `indexPath.row` 则翻译为某路径所在的行数
- `row` 属于数据, `cell` 属于视图, 表视图控制器通过数据源和代理方法将两者关联在一起.
- `shortcutItem` 快速启动菜单思路分析:
    - 在主页面的 `viewDidload` 方法中创建相关的菜单动作, 然后注入到系统管理的 APP 中 `UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3]`
    - 创建一个 `shortcutItem` 实例, 从两个地方抓取动作信息赋值给他.
        - 从应用启动的方法中抓取场景创建信息的方法中的快捷动作 `application(_:configurationForConnecting:options:)`
        - 从后台挂起状态快捷动作激活的方法中抓取动作信息 `windowScene(_:performActionFor:completionHandler:)`
    - 然后在 `becomeActive` 方法中对 `shortcutItem` 存的信息进行分析, 进而执行相关方法.

## 参考

- [UITableviewCell 复用机制](https://www.jianshu.com/p/1046c741fce1)
- [应用测试与分发渠道简析](https://xiaozhuanlan.com/topic/2076153984)
- [You don’t always need weak self](https://medium.com/flawless-app-stories/you-dont-always-need-weak-self-a778bec505ef)
- [iOS Deferred Deep Link 延遲深度連結實作(Swift)](https://medium.com/zrealm-ios-dev/ios-deferred-deep-link-延遲深度連結實作-swift-b08ef940c196)
