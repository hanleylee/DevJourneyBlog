---
title: iOS 之控件约束
date: 2020-04-03
comments: true
path: constraints-of-view-in-ios
categories: iOS
tags: ⦿ios, ⦿layout, ⦿constraints, ⦿ui
updated:
---

iOS 的布局方式有

- 绝对布局
- 约束方式进行 `autoLayout` 布局

在这两种布局基础上, 我们可以使用

- `stroryboard` / `xib` 布局

    更加直观, 缺点则一大堆, 比如 `view` 稍多的情况下打开 `storyboard` 界面都会非常卡顿, 团队合作经常发生冲突需要进行协调.

- 纯代码进行布局.

    适合团队, 条理清晰, (可能) 约束计算速度更快

因此使用纯代码布局是一劳永逸的一种方法. 其实 `storyboard` / `xib` 布局的原理和思想都是相同的, 无非就是对上下左右, 宽高进行约束, 当一个控件的约束足够时
则约束完成.

本文所有的讨论都基于纯代码布局, 以及代码布局库 `SnapKit`.

![himg](https://a.hanleylee.com/HKMS/2020-04-04-constraints-in-iOS.png?x-oss-process=style/WaMa)

<!-- more -->

## 概念先行

### 什么是约束

iOS 开发中所涉及到的屏幕上显示的图形是在二维空间中表示的, 如果要在二维空间中描述一个图形, 坐标和形状是两个最最重要的参数, 有了这两个参数, 我们就能根据描述出这个图形.

说的再简单点, 对于一个矩形来说, 形状就是他的宽和高, 因此知道了一个矩形的坐标与宽高, 那么在一个二维平面上我们就能描述出此矩形.

约束的原理就是根据一个已经确定了位置的控件根据一元方程求解另一个控件的各个参数, 如果另一个控件是矩形, 那么就需要知道宽高及 `x` 和 `y`, 缺少一个都不行, 条件不足会导致约束失败从而使此控件不能显示在屏幕中.

### frame 与 bound 区别

`bounds` 与 `frame` 区别: 尺寸很容易理解, 就是长宽, 主要理解坐标.

- 本控件的 `frame` 的坐标是相对于父视图的 `bound` 原点坐标
- 本控件的 `bound` 的坐标默认为零 (当本控件有 `subview` 时, 改变本控件的 `bound` 坐标可导致 `subview` 位置发生改变)

如果 子视图 `a` 在父视图 `A` 上, 那么如果改变 `A` 视图 的 `bound` 会使 `a` 视图 的位置改变, 因为当改变 `bound` 时是将 bound 由 0, 0 进行改变.

子视图依据父视图的 `bound` 坐标进行定位 `frame`, 所以父视图 `bound` 坐标动, 子视图 `frame` 动, `frame` 坐标即位置的实际体现, 因此位置就动了.

`bound` 的这一属性经常用在 `scrollView` 中, 屏幕视图的 `frame` 是没有变的, 变化的是 `bound` 的原点, 比如屏幕视图的 `bound` 原点由 `0, 0` 变为 `0, 100`, 那么所有子视图的 `frame` y 坐标就要向上移动 `100`, 向上滑动屏幕的效果就出现了.

所以, `bounds` 的有这么一个特点: 它是参考自己坐标系, 它可以修改自己坐标系的原点位置, 进而影响到 `subview` 的显示位置.

### leading 与 left 的区别 (同 trailing 与 right 的区别)

`leading` 的含义是头部, `left` 的含义是左.

对所有人来说, `left` 都是 `left`. 对中国人来说, 一行文字的 `leading` 是 `left`, 但是对一些其他文化的人 (比如穆斯林) 来说, 一行文字的 `leading` 则是 `right`

### marginTop 与 top

`Auto Layout` 为每一个 `view` 都定义了 `margin`. margin 指的是控件显示内容部分的边缘和控件边缘的距离. 就像 `回` 这个汉字一样, 外面的 `口` 就是控件的外边缘, 里面的 ` 口 ` 是控件显示内容的部分的边缘, 我暂且称它为内边缘, 这两个边缘之间的距离就是 `margin`.

因此, `marginTop` 是内侧上边缘 (` 回 ` 字的内侧 ` 口 ` 的上侧), `top` 是外侧上边缘 (` 回 ` 字的外侧 ` 口 ` 的上侧).

当在 `Interface Builder` 中编辑约束时, `First Item` 和 `Second Item` 的弹出菜单中可以选择 `Relative to margin`. 如果勾选, 会在 `top`, `leading` 等属性后面加上 `Margin`, 变成 `topMargin`, `leadingMargin` 等, 意味着约束的设置参照 `View` 的内边缘而不是外边缘.

### 约束类型

- 约束有边距约束 (上下左右), 宽高约束, 居中约束
- 在 `view` 中设置 `scrollView` 的上下左右宽高是相对于 `view` 的 `contentView` 进行设置的, 因为 `view` 的 `contentView` 与 `view` 相等, 因此就是相当于直接对 `view` 的 `frame` 约束. 此设置将会固定 `scroll` 的显示范围
- 与边距约束不同, 宽高约束不是相对于 `contentSize` 的, 而是直接相对与父控件的 `frame` 的

### 约束的 priority

priority 可以理解为约束的重要性, 取值范围为 `1~1000`. 每个约束都有默认的 priority, 其值为 1000, 表示最高级, 不可被忽略. 如果一个约束的 priority 被设置为 `1~999` 中的任意一个数值, 则表示如果与其他约束发生冲突时优先选择级别高的约束, ignore 级别低的约束

![himg](https://a.hanleylee.com/HKMS/2021-04-20-10-38-18.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2021-04-20-10-39-59.jpg?x-oss-process=style/WaMa)

### 安全区域 safeArea

![himg](https://a.hanleylee.com/HKMS/2020-06-17-150331.png?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-09-22-114707.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-09-22-114815.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-09-22-114929.jpg?x-oss-process=style/WaMa)

safeArea 是 ios11 的新功能, 取代了 `topLayoutGuide` 与 `bottomLayoutGuide`

> 只有 vc 的自带 view 有 safeArea 这么一说

```swift
// 1. 这里 tableview 的顶部是对齐到 safeArea 的顶部, nextBtn 的底部是对齐到 safeArea 的底部, 如果是在中间存在 subview, 那么此 subview 还是原来的写法, 看 2
tableview.snp.makeConstraints {(make) in
    if #available(iOS 11.0, *) {
        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
    } else {
        make.top.equalTo(self.topLayoutGuide.snp.top)
    }

    make.centerY.equalTo(view)
    make.width.equalTo(view)
    make.bottom.equalTo(view).inset(-60)
}

view.addSubview(nextBtn)
nextBtn.snp.makeConstraints {(make) in
    make.left.equalTo(tableview)
    make.right.equalTo(tableview)
    if #available(iOS 11.0, *) {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    } else {
        make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom)
    }
    make.height.equalTo(60)
}

// 2. 非边缘的 subview 的约束写法还和原来一样
titleLabel.snp.makeConstraints {(make) in
    make.left.equalTo(view).offset(24)
    make.top.equalTo(view).offset(24) }

// 3. 使用 iOS 原生 VFL(Visual Format Language) 设置 subview 与 safeArea 做约束
   if #available(iOS 11.0, *) {
       tableview.translatesAutoresizingMaskIntoConstraints = false
       tableview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
       tableview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }

// 4. 使用 safeArea 的尺寸进行绝对布局
topSubview.frame.origin.x = view.safeAreaInsets.left
topSubview.frame.origin.y = view.safeAreaInsets.top
topSubview.frame.size.width = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
topSubview.frame.size.height = 300
```

## ScrollView 的约束与 contentSize

- `scrollView` 比较特殊, 其可以滚动, 而滚动的内容范围由 `contentSize` 决定, 其 `frame` 决定了其在 `view` 的显示范围 (很难理解?  我们的边距约束都是针对于父 `view` 的 `contentView` 进行计算的, 通常情况下一个 `view` 的 `contentView` 与 `view` 相等, 可以认为是一个, 但是对于 `scrollView` 就不同了, 因为他会滚动!)
- `scrollView` 在加载时, 会自动根据内部子控件来计算 `contentSize` 的值. 因此, 在 `viewDidLoad` 中设置 `contentSize` 然后在 `viewDidAppear` 中打印出来发现设置是没有作用的
- 正确的 `scrollView` 中的子控件布局应该是子控件有相对于 `scrollView` 的上下左右边距约束, 以及相对于 `scrollView` 的宽高约束, 这样才能让 `scrollView` 的 `contentSize` 被自动计算出
- 这里有一个要点, 如果要设置上下可滚动, 那么高度约束是必须的, 但是顶部约束和底部约束只需要一个就行了, 当然也可以添加两个更加完善

    其实很容易理解这一点, 因为 `scrollView` 的 `contentSize` 是根据内部子控件来确定的, 但是内部子控件如果只设置相对于 `scrollView` 的 `contentView` 的边距约束的话, 两者之间相互依赖, 最后谁都约束不出来

    因为宽高约束不是相对于 `scrollView` 的 `contentView` 来进行约束的, 而是相对于 `scrollView` 的 `frame` 直接进行约束的, 因此可以摆脱 "循环约束" 这个怪圈, 使得子控件的宽被约束出来, 紧接着 `contentSize` 的宽也就被约束出来了.

- `contentSize` 的宽 = 子 view 的宽 + 左右边距
- `contentSize` 的高 = 子 view 的高 + 上下间距
- `scrollView` 可滑动的必要条件 (缺一不可):
    - `contentSize` 的高 `height` 可被计算出
    - 计算出的 `contentSize` 的 `height` 大于 `frame` 的 `height`

### 约束 scrollView 的多种实现方式

- 设置 `containerView`, 使 `containerView` 到 `scrollView` 的边距约束确定, 然后 **固定** `containerView` 的宽高约束, 以后的控件在 `containerView` 中添加并相对于 `containerView` 做设置即可
- 设置 `containerView`, 使 `containerView` 到 `scrollView` 的边距约束确定, 然后 **不固定** `containerView` 的宽高约束, 以后的控件在 `containerView` 中添加并相对于 `containerView` 做设置, 因为没有手动固定 `containerView` 的宽高, 因此 `containerView` 的所有子控件设置完毕后必须可根据子控件的约束推出 `containerView` 的宽高约束, 这样 `scrollView` 才可以滚动.
- 直接在 `scrollView` 内部设置多个子控件, 设置边距约束及所有控件的宽高约束 (宽高约束是必须的)

### 实际案例演示

```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =.black

        let scrollView = UIScrollView()
        scrollView.backgroundColor =.cyan
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {(make) in
            // 设置在主 view 中 scrollView 的可见范围. 这一步与普通 view 的约束相同, 可以用
            // 1. 纯边距约束确定
            // 2. 边距约束 + 宽高约束确定
            // 3. 宽高约束 + 居中约束确定
            // 总而言之就是确定其纵横坐标及宽高使之可见
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(400)
        }

        let redView = UIView()
        redView.backgroundColor =.red
        scrollView.addSubview(redView)
        redView.snp.makeConstraints {(make) in
            // 设置左右的边距约束
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-100)
            // 设置宽 width 约束, 此项完成后 scrollview 的 contentSize 的宽被确定.
            // 可以想象为 scrollView 中的 redView 的宽确定了 (300 + 200)
            // redView 左侧在 scrollView 的 contentView 的左侧的右方 1 处, redView 的右侧在 scrollView 的 contentView 的右侧的左方 100 处
            // 相当于确定了 redView 的宽及 redView 的左右侧距 scrollView 的 contentView 的左右侧距离, 因此 contentView 的 width 就被 "撑" 开了
            // scrollView.contentSize.width = 左边距 (10) + redView.width(300 + 200) + 右边距 (100) = 610
            make.width.equalToSuperview().offset(200)

            // 设置上下的边距约束及高 height 约束, 此项完成后 scrollview 的 contentSize 的宽被确定.
            // scrollView.contentSize.heigh = 上边距 (0) + redView. height(400) + 右边距 (0) = 400
            // 因为 contentSize.heigh 小于可见范围 (即 frame) 的高 400, 因此不会有滚动效果
            make.top.bottom.height.equalToSuperview()
        }
    }
}
```

![himg](https://a.hanleylee.com/HKMS/2020-04-03-redView.gif)

```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scrollView = UIScrollView()
        view.backgroundColor =.black
        scrollView.backgroundColor =.cyan
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {(make) in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(400)
        }

        let redView = UIView()
        redView.backgroundColor =.red
        scrollView.addSubview(redView)
        redView.snp.makeConstraints {(make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-100)
            make.width.equalToSuperview().offset(200)
            make.top.bottom.equalToSuperview()
            make.height.equalToSuperview()
        }

        let blueView = UIView()
        blueView.backgroundColor =.blue
        redView.addSubview(blueView)
        blueView.snp.makeConstraints {(make) in
            // 设置 blueView 的中心与 redView 的中心对齐
            make.center.equalToSuperview()
            // 设置 blueView 的宽和高都比 redView 小 200, 即 blueView.size = (100, 200)
            make.size.equalToSuperview().offset(-200)
            // 谨记, 本例中的 scrollView 的 contentSize 已经被直接子控件 redView 确定了,
            // 那么 redView 中再添加任何的子控件也不会再影响到 scrollView 的 contentSize 了
        }
    }
}
```

![himg](https://a.hanleylee.com/HKMS/2020-04-03-blueView.gif)

### 知识点

- *SnapKit* 的 `makeConstrains` 的方法中不能使用 `view.frame.size.height = 100` 这样的设置, 这样的设置不会起作用, 只有 `make.height.equalTo(100)` 才能设置约束 (在 `viewWillAppear` 方法中直接使用 frame 方法是起作用的)
- 约束时遵从 **上下左右 -> 宽高** 的顺序进行约束
- 为了更好地控制 `subview` 被添加的顺序及初始化的时间, 可以先使用隐式解包, 然后用 `UIView(frame: .zero)` 进行初始化, 然后进行配置并约束, 详细做法如下:

## 初始化控件与为控件设置约束的顺序

```swift
class MyViewController: UIViewController {
    var myView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        myView = UIView(frame: .zero)
        myView.backgroundColor =.red
        self.view.addSubview(myView)
        myView.snp.makeConstraints { make in
            make.edges.equalToSuperview
        }
    }
}
```

在此基础上, `collectionView` 的 `delegate` 与 `DataSource` 要设置在 `addSubview` 之前, 然后 `addSubview` 设置在约束之前

## SnapKit 基础使用

snapkit 是代码布局库, 其用法与 storyboard 的 Autolayout 完全相同, 都是基于控件的 ` 上下左右 ` & ` 宽高 ` 来进行布局, 基本用法完整写法如下

```swift
label.snp.makeConstraints {(make) in
    make.centerX.equalTo(view.snp.centerX).multiplyBy(1).labeled("label6.centerX")
            |.top    |         同左            |.offset(10)  |
            |.bottom |                         |.inset(10)   |
            |.left   |                         |.dividedBy(1)|
            |.right  |                         |             |
            |.centerX|                         |             |
            |.centerY|                         |             |
            |.center |                         |             |
}
```

Snapkit 可以简化书写流程, 最主要的一点就是如果只是相对于 super 有约束, 那么约束可以写为:

```swift
label.snp.makeConstrains {(make) in
    make.right.equalTo(10) // label.right = super.right - 10
    make.left.equalTo(10) // label.left = super.left + 10
    make.right.left.equalTo(10) // label.right = super.right - 10 && label.left = super.left + 10
    make.height.equalToSuperview().multipliedBy(0.5) // label.height = super.height * 0.5
    make.height.equalToSuperview().offset(100) // label.height = super.height + 100
    make.center.equalToSuperview().offset(100) // label.centerX = super.centerX + 100 && label.centerX = super.centerX + 100
    make.left.lessThanOrEqualTo(10) // label.left <= 10
    make.left.greaterThanOrEqualTo(label1) // label.left >= label.left
    make.left.greaterThanOrEqualTo(label1.snp.left) // label.left >= label.left
    }
```

## UIStackView 使用

### 属性

`UIStackView` 有四个最重要的属性, 只要设置好这四个属性就可以完美显示自动约束

1. `Axls`: 子视图的布局方向, 可选值有:
    - `Vertical`: 垂直
    - `Horizontal`: 水平

2. `Alignment`: 子视图的对齐方式, 可选值有:
    - `Fill`: 子视图填充 StackView.
    - `Leading`: 所有子视图的左侧与 stackview 的左侧对齐
    - `Trailing`: 所有子视图的右侧与 stackview 的右侧对齐
    - `Center`: 所有子视图的中心线与 stackview 的中心线对齐
    - `Top`: 所有子视图的顶部与 stackview 的顶部对齐
    - `Bottom`: 所有子视图的顶部与 stackview 的底部对齐
    - `First Baseline`: 按照第一个子视图中文字的第一行对齐.
    - `Last Baseline`: 按照最后一个子视图中文字的最后一行对齐.

3. `Distributlon`: 子视图的分布比例 (大小), 可选值有:
    - `Fill`: 默认分布方式.

        > 不能再设置控件的宽高约束, 否则会约束冲突.

    - `Fill Equally`: 每个子视图的高度或宽度保持一致.

        使每个子视图的宽度或高度相等

        > 不能再设置控件的宽高约束, 否则会约束冲突.

        ![himg](https://a.hanleylee.com/HKMS/2020-04-20-155453.jpg?x-oss-process=style/WaMa)

    - `Fill Proportionally`: StackView 自己计算出它认为合适的分布方式.

        系统将完全不考虑空间自身的宽高, 完全依据控件的内容自行布置出系统认为合适的布局

        > 不能再设置控件的宽高约束, 否则会约束冲突

        ![himg](https://a.hanleylee.com/HKMS/2020-04-20-155552.jpg?x-oss-process=style/WaMa)

    - `Equal Spacing`: 每个子视图保持同等间隔的分布方式.

        横向布局前提下, 如果设置的 spacing 值加上横向三个控件的总宽度小于 stackview 的宽度时, 三个控件的间距相等, 即最左最右各一个, 中间居中一个. 如果
        总宽度大于 stackview 的宽度, 则控件间的间距为 spacing 值

        如果只有两个控件横向布局时, 且 spacing 与控件宽度之和小于 stackview 的宽度, 则两个空间一左一右靠边对齐

        > 可为控件通过自动布局指定宽高, 如果不设置宽度的话使用此选项会优先拉伸子控件的宽度, 而不是使用等距设置

        ![himg](https://a.hanleylee.com/HKMS/2020-04-20-155608.jpg?x-oss-process=style/WaMa)

    - `Equal Centering`: 每个子视图中心线之间保持一致的分布方式.

        > 可为控件通过自动布局指定宽高, 如果不设置宽度的话使用此选项会优先拉伸子控件的宽度, 而不是使用等距设置

        ![himg](https://a.hanleylee.com/HKMS/2020-04-20-155627.jpg?x-oss-process=style/WaMa)

4. `Spacing`: 子试视图间的间距

> UIStackView 中只有 `Distribution` 为 `Equal Spacing` 或 `Equal Centering` 时才可设置子控件的宽高约束, 而且不能通过 frame 指定宽高, 必须使用自动布局.

## 参考

- [最近很火的 Safe Area 到底是什么](https://www.jianshu.com/p/63c0b6cc66fd)
- [Auto Layout 和 Constraints](https://segmentfault.com/a/1190000004386278)
- [利用 SnapKit 约束 - tableView 动态计算 cell 高度 (Swift)](https://www.jianshu.com/p/9f189d78642a)
- [iOS 之 UIScrollview 添加约束图文详解](https://www.jianshu.com/p/e4a12061776d)
