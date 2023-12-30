---
title: Flexbox 框架 - FlexLayout 使用总结
date: 2023-09-17
comments: true
path: ios-flexlayout-usage
tags: ⦿ios, ⦿flexbox, ⦿flexlayout
updated:
---

[FlexLayout](https://github.com/layoutBox/FlexLayout) 是 iOS 上的盒式布局框架, 拥有高性能, 接口灵活易用, 职责单一等特点. 最近在组内推行了该框架的使用, 这篇文章对该框架做简要总结

![himg](https://a.hanleylee.com/HKMS/2023-09-17195307.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 背景

团队中之前一直在使用 SnapKit 作为代码布局方案, SnapKit 是基于原生的 Auto Layout 技术进行的封装, 之前也没有遇到某些不能实现的场景, 但是还是有一些通点:

- 在需要隐藏页面某一元素且让下侧元素位置进行相应变化的时候就很痛苦, 需要手动再次调用 `remakeConstraints`, 很麻烦. 如果使用 UIStackView 的话, item 属性设置比较有限, 且 UIStackView 在不同 iOS 版本上兼容性并不好
- 语法啰嗦, 在学习了 Flutter 和 SwiftUI 的盒式布局思想后, 我发现原有的 SnapKit 布局语法比较啰嗦, 调试也比较不容易排查问题
- Auto Layout 在页面嵌套层级较高的情况下性能较差

基于这几点因素, 我开始调研 flexbox 布局在 iOS 上的应用, 然后就发现了 yoga 这个开源框架, 进而发现了 FlexLayout, 经过一番探索及试用, 我发现 FlexLayout 这个解决方案能完美解决以上我遇到的各个问题, 进而在团队内进行推广并得到不错的效果

## Flexbox 概念

2009 年, W3C 提出了一种新的方案——Flex 布局, 可以简便, 完整, 响应式地实现各种页面布局. 目前, 它已经得到了所有浏览器的支持. [yoga](https://github.com/facebook/yoga) 是 Facebook 在 React Native 里引入的一种跨平台的基于 CSS 的布局系统, 它实现了 Flexbox 规范, 随着该系统不断完善, Facebook 对其进行重启发布, 并取名为 yoga.

yoga 有如下特性:

- 完全兼容 Flexbox 布局, 遵守 W3C 的规范
- 支持 C, Java, C#, Objective-C, Swift 等语言
- 底层代码使用 C++ 语言编写, 性能不是问题, 并且可以更容易跟其他平台集成
- 支持流行框架如 React Native

[FlexLayout](https://github.com/layoutBox/FlexLayout) 是基于 yoga 库的对于 Swift 的浅封装, 语法上更加贴近 Swift 风格, 由于使用了链式编程的思想, 因此更加直观易用.

> SwiftUI Flutter 的布局与 flex 布局也基本一致, 可以说 flexbox 布局是真正的跨平台概念了

## FlexLayout 的优势

### 性能高

![benckmark](https://a.hanleylee.com/HKMS/2023-09-04155444.jpg?x-oss-process=style/WaMa)

### 与 iOS 兼容性好

不引入任何额外视图元素, 仍然使用原有的 UIKit 元素, 仅仅作为布局框架存在

### 简洁

![himg](https://a.hanleylee.com/HKMS/2023-09-05112228.png?x-oss-process=style/WaMa)

<table>

<tr>
    <td> <center><strong>Before(SnapKit)</strong></center> </td>
    <td> <center><strong>After(FlexLayout)</strong></center> </td>
</tr>

<tr>
<td>

```swift
contentView.addSubview(titleLb)
titleLb.snp.makeConstraints { make in
    make.top.equalToSuperview().inset(16)
    make.centerX.equalToSuperview()
}

contentView.addSubview(amountLb)
amountLb.snp.makeConstraints { make in
    make.top.equalTo(titleLb.snp.bottom).offset(8)
    make.centerX.equalToSuperview()
}

contentView.addSubview(transferToLb)
transferToLb.snp.makeConstraints { make in
    make.top.equalTo(amountLb.snp.bottom).offset(32)
    make.left.equalToSuperview().inset(12)
}

contentView.addSubview(infoContainerView)
infoContainerView.snp.makeConstraints { make in
    make.top.equalTo(amountLb.snp.bottom).offset(32)
    make.left.equalTo(transferToLb.snp.right).offset(12)
    make.right.equalToSuperview().inset(12)
    make.bottom.equalToSuperview().inset(16)
}

infoContainerView.addArrangedSubview(receiverNameLb)
infoContainerView.addArrangedSubview(bankNameLb)
infoContainerView.addArrangedSubview(accountNoLb)

separator.snp.makeConstraints { make in
    make.left.right.equalToSuperview().inset(12)
    make.bottom.equalToSuperview()
    make.height.equalTo(0.5)
}
```

</td>

<td>

```swift
contentView.flex.define { flex in
    flex.addItem().paddingHorizontal(12).define { flex in
        flex.addItem(titleLb).marginTop(16)
        flex.addItem(amountLb).marginTop(8)
        flex.addItem().direction(.row).marginTop(32).define { flex in
            flex.addItem(transferToLb).marginRight(16)
            flex.addItem().shrink(1).grow(1).alignItems(.end).define { flex in
                flex.addItem(receiverNameLb)
                flex.addItem(bankNameLb).marginTop(4)
                flex.addItem(accountNoLb).marginTop(4)
            }
        }
    }
    flex.addItem().marginLeft(16).height(0.5).marginTop(16)
}
```

</td>
</tr>

<!-- <tfoot> -->
<!--     <tr> -->
<!--         <td colspan="2"> -->
<!--             <center><img src="" width="600"/></center> -->
<!--         </td> -->
<!--     </tr> -->
<!-- </tfoot> -->
</table>

## Flexbox 快速入门

基础概念:

- 被包裹的元素称之为 `flex item`, 包裹着 `flex item` 的称为 `flex container`
- `flex item` 与 `flex container` 是相对的概念, 一个 `flex item` 相对于他的父容器又是一个 `flex item`.
- `flex container` 中默认存在两条轴:

    - 垂直主轴 (**main axis**)
    - 水平的交叉轴 (**cross axis**)

    ![himg](https://a.hanleylee.com/HKMS/2023-09-05162610.jpg?x-oss-process=style/WaMa)

    > 这是默认的设置, 当然你可以通过修改使水平方向变为主轴, 垂直方向变为交叉轴

- 每一个 `flex item` 都有 `padding`, `border`, `margin`(从内到外) 这三个概念

    ![himg](https://a.hanleylee.com/HKMS/2023-09-06172510.jpg?x-oss-process=style/WaMa)

布局原则:

1. `flexRootContainer` 必须有固定的 frame
2. `flex container` 中的 `flex item` 会沿着主轴方向进行排列
3. 每个 `flex item` 都可以设置自身的 `size`, `border`, `padding`, `margin` 等属性, 所有 `flex item` 这些属性综合起来可以支撑开其 `flex container`

## FlexLayout 重要方法

- 布局相关
    - for container
        - `direction()`: 决定主轴方向, 即项目的排列方向
        - `justifyContent()`: flex item 在主轴上的对齐方式
        - `alignItems()`: flex item 在交叉轴的对齐方式
        - `alignContent()`: 多根轴线在交叉轴上的对齐方式
    - for item
        - `width()`: 自身的宽度
        - `height()`: 自身的高度
        - `size()`: 自身的尺寸
        - `padding()`: 内部缩进
        - `margin()`: 边缘扩展
        - `border()`: 边缘厚度
        - `grow()`: 当 container 存在多余宽度时, 占有这些空间的能力
        - `shrink()`: 当 container 宽度不足时, 缩小自身宽度的能力
        - `basis()`: 分配多余空间之前, item 占据的主轴空间
- 其他
    - `addItem()`
    - `define()`
    - `layout()`
    - `markDirty()`

模拟: <https://yogalayout.com>

## FlexLayout 实践

### 常规使用 - ViewController

```swift
import UIKit
import FlexLayout

class ResultVC: ViewController, ResultProtocol {
    // MARK: Data
    var traxId: String = ""

    private var vm: ResultVM!

    // MARK: Subviews
    private let rootFlexContainer = UIView()
    private lazy var tableView: UITableView = .init().then {
        $0.backgroundColor = Color.background
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.delegate = self
        $0.dataSource = self
    }
    private let bottomView: DetailBottomView = .init()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()

        vm.fetchDataAction.execute()

        showStateView(for: .loading)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        rootFlexContainer.frame = .init(x: 0, y: navigationBarHeight, width: screenWidth, height: rootFlexContainer.frame.height)
        rootFlexContainer.flex.layout()
    }
}

extension ResultVC {
    private func setupBinding() {
        vm = .init(traxId: traxId)

        vm.fetchDataAction.executing
            .bind(to: HUD.rx.isLoading(on: self.view))
            .disposed(by: rx.disposeBag)

        vm.fetchDataAction.underlyingError
            .bind(to: Binder(self) { vc, error in
                vc.hideStateView()
                vc.bottomView.hideOrderDetail()
                vc.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)

        vm.fetchDataAction.elements
            .bind(to: Binder(self) { vc, _ in
                vc.hideStateView()
                vc.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)

        navigationBar.leftButton.rx.tap
            .bind(to: Binder(self) { vc, _ in
                vc.popToHome()
            })
            .disposed(by: rx.disposeBag)

        bottomView.doneTapSubject
            .bind(to: Binder(self) { vc, _ in
                vc.popToHome()
            })
            .disposed(by: rx.disposeBag)

        bottomView.detailTapSubject
            .bind(to: Binder(self) { vc, _ in
                let detailVC = DetailVC()
                detailVC.traxId = vc.traxId
                vc.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
}

extension ResultVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = vm.uiDataSource[indexPath.row]
        switch item {
        // ...
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.uiDataSource.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ResultVC : StatefulPage { }

// MARK: - UI

extension ResultVC {
    private func setupUI() {
        navigationBar.leftButton.setImage(UIImage.by.image(sourceNamed: "detail_back"), for: .normal)

        view.backgroundColor = .white

        view.addSubview(rootFlexContainer)
        rootFlexContainer.flex.width(screenWidth).height(screenHeight - navigationBarHeight).paddingBottom(safeBottomMargin).define { flex in
            flex.addItem(tableView).grow(1)
            flex.addItem(bottomView)
        }
    }
}
```

### 如何使 UITableViewCell 自动高度

关键在于 `sizeThatFits()` 方法. 在不设置 cellHeight 且不实现 `func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat` 的情况下, UITableView 会主动调用 要显示 cell 的 `sizeThatFits()` 方法, 此方法返回的高度会被 `UITableView` 用作为该 cell 的高度

```swift
import UIKit
import FlexLayout

class ReceiverCell: UITableViewCell {
    // MARK: Subviews

    private let titleLb = UILabel().then {
        $0.font = UIFont.by.themeRegular(size: 16)
        $0.text = "Amount"
        $0.textColor = UIColor.by.color(hexString: "#333333")
        $0.textAlignment = .center
    }

    private let transferToLb = UILabel().then {
        $0.font = UIFont.by.themeRegular(size: 14)
        $0.text = "Transfer To"
        $0.textColor = UIColor.by.color(hexString: "#666666")
        $0.textAlignment = .left
    }

    private let amountLb: UILabel = .init().then {
        $0.font = UIFont.by.themeBold(size: 24)
        $0.text = "--"
        $0.textColor = UIColor.by.color(hexString: "#333333")
        $0.textAlignment = .center
    }

    private let receiverNameLb: UILabel = .init().then {
        $0.font = UIFont.by.themeRegular(size: 14)
        $0.text = "--"
        $0.textColor = UIColor.by.color(hexString: "#131313")
        $0.textAlignment = .right
        $0.numberOfLines = 2
    }

    private let bankNameLb: UILabel = .init().then {
        $0.font = UIFont.by.themeRegular(size: 14)
        $0.text = "--"
        $0.textColor = UIColor.by.color(hexString: "#131313")
        $0.textAlignment = .right
        $0.numberOfLines = 2
    }

    private let accountNoLb: UILabel = .init().then {
        $0.font = UIFont.by.themeRegular(size: 14)
        $0.text = "--"
        $0.textColor = UIColor.by.color(hexString: "#131313")
        $0.textAlignment = .right
    }

    // MARK: Data

    // MARK: Life Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initUI()
        bindSubject()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.flex.layout(mode: .adjustHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.frame.size.width = size.width
        contentView.flex.layout(mode: .adjustHeight)
        return contentView.frame.size
    }
}

// MARK: - Custom Method

extension ReceiverCell {
    func setContent(with receiver: ConfirmReceiverProtocol) {
        amountLb.text = receiver.amount?.description.by.money ?? "--"

        receiverNameLb.text = data.receiverName ?? "--"
        bankNameLb.text = data.name ?? "--"
        accountNoLb.text = data.accountNo ?? "--"

        receiverNameLb.flex.markDirty()
        bankNameLb.flex.markDirty()
        accountNoLb.flex.markDirty()

        contentView.flex.layout(mode: .adjustHeight)
    }
}

// MARK: - UI

extension ReceiverCell {
    private func initUI() {
        contentView.flex.define { flex in
            flex.addItem().paddingHorizontal(12).define { flex in
                flex.addItem(titleLb).marginTop(16)
                flex.addItem(amountLb).marginTop(8)
                flex.addItem().direction(.row).marginTop(32).define { flex in
                    flex.addItem(transferToLb)
                    flex.addItem().shrink(1).grow(1).marginLeft(16).alignItems(.end).define { flex in
                        flex.addItem(receiverNameLb)
                        flex.addItem(bankNameLb).marginTop(4)
                        flex.addItem(accountNoLb).marginTop(4)
                    }
                }
            }
            flex.addItem().marginLeft(16).backgroundColor(Color.dividing_line).height(0.5).marginTop(16)
        }
    }
}
```

### 如何进行等分布局?

![himg](https://a.hanleylee.com/HKMS/2023-09-05175253.png?x-oss-process=style/WaMa)

如上图, 两个按钮中有间距, 要求其中一个隐藏后, 会自动将剩余宽度进行填充

```swift
import UIKit
import FlexLayout

final class DetailBottomView: UIView {
    
    // MARK: Subviews
    private let detailBtn: ThemeButton = .init(.grayBorder).then {
        $0.titleLabel?.font = .by.themeBold(size: 16.by.fitToWidth)
        $0.setTitle(Language.order_detail, for: .normal)
    }
    private let doneBtn: ThemeButton = .init().then {
        $0.titleLabel?.font = .by.themeBold(size: 16.by.fitToWidth)
        $0.setTitle(Language.done, for: .normal)
    }

    // MARK: Data
    let doneTapSubject: PublishRelay<Void> = .init()
    let detailTapSubject: PublishRelay<Void> = .init()

    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        initUI()
        bindSubject()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Bind

extension DetailBottomView {
    private func bindSubject() {
        doneBtn.rx.tap
            .bind(to: doneTapSubject)
            .disposed(by: rx.disposeBag)

        detailBtn.rx.tap
            .bind(to: detailTapSubject)
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - Custom Method

extension DetailBottomView {
    func hideOrderDetail() {
        detailBtn.flex.display(.none)
        flex.layout()
    }
}

// MARK: - UI

extension DetailBottomView {
    private func initUI() {
        self.backgroundColor = .white

        flex.direction(.row).padding(12, 6).define { flex in
            flex.addItem(detailBtn).marginHorizontal(6).height(44).basis(0).grow(1)
            flex.addItem(doneBtn).marginHorizontal(6).height(44).basis(0).grow(1)
        }
    }
}
```

### 使用 `shrink()` 在超出父 view 后在主轴上缩小

<table>

<tr>
    <td> <center><strong>Before</strong></center> </td>
    <td> <center><strong>After</strong></center> </td>
</tr>

<tr>
<td>

<img src="https://a.hanleylee.com/HKMS/2023-09-04154752.png?x-oss-process=style/WaMa"/>

</td>

<td>

<img src="https://a.hanleylee.com/HKMS/2023-09-04154526.png?x-oss-process=style/WaMa"/>

</td>
</tr>

<!-- <tfoot> -->
<!--     <tr> -->
<!--         <td colspan="2"> -->
<!--             <center><img src="" width="600"/></center> -->
<!--         </td> -->
<!--     </tr> -->
<!-- </tfoot> -->
</table>

```diff
contentView.flex.paddingHorizontal(12).define { flex in
    flex.addItem(titleLb).marginTop(16)
    flex.addItem(amountLb).marginTop(8)
    flex.addItem().direction(.row).marginTop(32).define { flex in
        flex.addItem(transferToLb)
-        flex.addItem().marginLeft(16).grow(1).alignItems(.end).define { flex in
+        flex.addItem().marginLeft(16).grow(1).shrink(1).alignItems(.end).define { flex in
            flex.addItem(receiverNameLb)
            flex.addItem(bankNameLb).marginTop(4)
            flex.addItem(accountNoLb).marginTop(4)
        }
    }
}
```

一开始, 因为包围着 `receiverNameLb` & `bankNameLb` & `accountNoLb` 三个 item 的 container 的 `shrink` 值为 0, 因此不具备缩小能力, 在其 item 内容较短时不会发生异常, 但是如果其 item 内容宽度超出了 container 宽度, 就会造成异常, 如上图左所示, 可以通过 `shrink(1)` 来保证 item 内容超出 container 边缘时, container 能进行收缩

## 总结

yoga 这一套盒式布局框架的原理可以理解我们对元素的 yoga 属性设置后, yoga 内部基于这些设置综合计算出每个元素应该展示的 frame, 进而给各个元素设置 frame. 因此我们的视图本质上还是基于 frame 进行的绝对布局, 只是计算的这个过程被 yoga 在背后帮我们做了. 因此时刻注意在改变视图时记得调用 `view.flex.layout()`, 这是重新计算布局的关键
