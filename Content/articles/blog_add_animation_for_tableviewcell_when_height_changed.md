---
title: 为 UITableViewCell 高度变化添加动画
date: 2022-05-22
comments: true
path: add-animation-for-tableviewcell-when-height-changed
categories: iOS
tags: ⦿ios,⦿uikit,⦿uitableview,⦿animation
updated:
---

如何让 UITableView 的 cell 高度动态变化且有动画效果呢?

<!-- more -->

如题, 要想达到目的, 我目前总结有两种方式:

1. 使用 UITableView 的 `func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)` 方法
    - 优点: 调用简单, 只需要针对指定 cell 做出高度变更, 然后将该 cell 的 indexPath 传入此方法即可
    - 缺点:
        - 会调用针对该 cell 调用 `func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell` 等代理方法
        - 刷新时界面会有闪烁现象
2. 使用 UITableView 的 `func beginUpdates()` 与 `func endUpdates()` 方法
    - 优点: 可以自定义动画时长与效果, 更加灵活, 在对指定 cell 做出改变后, 调用此方法会触发所有 cell 的高度计算并刷新, 且高度变化时有动画效果

    > 在 iOS 11 之后, 我们可以用 `func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil)` 方法来代替 `beginUpdates` 和 `endUpdates` 方法

综上, 我在实际项目中选择方法2作为动态高度动画方案, 具体效果如下:

![himg](https://a.hanleylee.com/HKMS/2022-05-21232949.gif)

## 案例

使用 `beginUpdates` 与 `endUpdates` (或 `performBatchUpdates`) 的实际案例代码如下:

- *TestTableViewCellExpandableVC.swift*

    ```swift
    import UIKit

    class TestTableViewCellExpandableVC: UIViewController {

        private var tableView: UITableView!

        override func viewDidLoad() {
            super.viewDidLoad()
            initView()
        }
    }

    // MARK: - UITableView Data Source
    extension TestTableViewCellExpandableVC: UITableViewDataSource {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = (tableView.dequeueReusableCell(withIdentifier: "Cell") as? TestTableViewCellExpandableCell) ??
            .init(style: .default, reuseIdentifier: "Cell")

            cell.setContent(with: "Row \(indexPath.row)") { [weak cell, weak tableView] in
                if #available(iOS 11.0, *) {
                    tableView?.performBatchUpdates {
                        cell?.updateHeight()
                    }
                } else {
                    cell?.updateHeight()
                    tableView?.beginUpdates()
                    tableView?.endUpdates()
                }
            }

            return cell
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 3
        }

    }

    // MARK: UI

    extension TestTableViewCellExpandableVC {
        private func initView() {

            tableView = .init()
            tableView.dataSource = self
            tableView.separatorStyle = .none
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.right.bottom.equalToSuperview()
            }

        }
    }
    ```

- *TestTableViewCellExpandableCell.swift*

    ```swift
    import UIKit

    class TestTableViewCellExpandableCell: UITableViewCell {

        enum HeightType {
            case small
            case medium
            case big

            var height: CGFloat {
                switch self {
                case .small: return 100
                case .medium: return 200
                case .big: return 300
                }
            }

            var next: HeightType {
                switch self {
                case .small: return .medium
                case .medium: return .big
                case .big: return .small
                }
            }
        }

        // MARK: Subviews
        private var titleLb: UIButton!

        // MARK: Data
        private var heightType: HeightType = .small
        private var tapClosure: () -> Void = {}

        // MARK: Life Cycle

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            initUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    // MARK: - Custom Method

    extension TestTableViewCellExpandableCell {
        func setContent(with title: String?, tapClosure: @escaping () -> Void) {
            titleLb.setTitle(title, for: .normal)
            self.tapClosure = tapClosure
        }

        func updateHeight() {
            heightType = heightType.next
            titleLb.snp.updateConstraints { make in
                // 这里必须使用 .low 以上的优先级, 否则会约束报错
                make.height.equalTo(heightType.height).priority(.high)
            }
        }

        @objc private func tap() {
            tapClosure()
        }
    }


    // MARK: - UI

    extension TestTableViewCellExpandableCell {
        private func initUI() {
            backgroundColor = UIColor.gray

            titleLb = .init()
            titleLb.addTarget(self, action: #selector(tap), for: .touchUpInside)
            titleLb.setTitleColor(.white, for: .normal)
            titleLb.backgroundColor = UIColor.red
            contentView.addSubview(titleLb)

            titleLb.snp.makeConstraints { make in
                make.height.equalTo(heightType.height).priority(.high)
                make.width.equalTo(200)
                make.centerX.equalToSuperview()
                make.top.bottom.equalToSuperview().inset(5)
            }

            let bottomLine = UIView()
            bottomLine.backgroundColor = .black
            contentView.addSubview(bottomLine)
            bottomLine.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(5)
                make.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }
    }
    ```

## Reference

- [Adjusting custom Tableviewcell - NSLayoutConstraint conflict](https://stackoverflow.com/questions/68011473/adjusting-custom-tableviewcell-nslayoutconstraint-conflict-uiview-encapsulate)
