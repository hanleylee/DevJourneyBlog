---
title: UIScrollView 的相关滑动代理回调方法及属性在滑动时的变化
date: 2021-05-19
comments: true
path: change-of-related-variables-of-scrollview-during-scrolling
categories: iOS
tags: ⦿ios, ⦿uiscrollview, ⦿variables
updated:
---

如题, 虽然用了很多很多次 UIScrollView, 知道它有一些滑动代理回调方法, 知道它有一些滑动状态相关的属性, 但对这些方法在每一个时间点的具体状态总是不太确定, 看官方说明文档也是一头雾水. 索性这次将所有的代理方法及属性调用一遍, 然后记录下结果.

对于这种涉及到状态变化的描述, 文字似乎有些苍白无力, 于是我尝试用图表的方式来进行记录, 以期更加直观.

<!-- more -->

## 情景一: 拖拽加速然后松开自由滑动

![himg](https://a.hanleylee.com/HKMS/2021-05-19231825.png?x-oss-process=style/WaMa)

> 如果滑动到底部, 且 `ScrollView` 有 `bounces` 回弹效果的话, 那么最后一次的 `scrollViewDidScroll` 的 `isDraging` 属性为 `false`

## 情景二: 缓慢拖拽然后松开

![himg](https://a.hanleylee.com/HKMS/2021-05-20220444.png?x-oss-process=style/WaMa)

## 总结

- `isDraging`: 表示 `scrollView` 是否在自由滑动或者当前手指在接触屏幕

    ```txt
    A Boolean value that indicates whether the user has begun scrolling the content.

    The value held by this property might require some time or distance of scrolling before it is set to true.
    ```

- `isTracking`: 表示当前手指是否与屏幕接触

    ```txt
    Returns whether the user has touched the content to initiate scrolling.

    The value of this property is true if the user has touched the content view but might not have yet have started dragging it.
    ```

- `isDecelerating`: 这个简单的多, 就是表示是否正在减速, 也就是说只有当惯性滑动的时候才会为 `true`

    ```txt
    Returns whether the content is moving in the scroll view after the user lifted their finger.

    The returned value is true if user isn't dragging the content but scrolling is still occurring.
    ```

## Code

为了便于读者独立测试验证, 这里附上完整代码

```swift
//
//  TableViewVC.swift
//  HLTest
//
//  Created by Hanley Lee on 2021/5/19.
//  Copyright © 2021 Hanley Lee. All rights reserved.
//

import UIKit

class TableViewVC: UITableViewController {

    var startTime: CFTimeInterval = .init()
    var des: String {
        return "isDragging: \(tableView.isDragging), isTracking: \(tableView.isTracking), isDecelerating: \(tableView.isDecelerating), interval: \(CACurrentMediaTime() - startTime)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 50
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        startTime = CACurrentMediaTime()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            print(self.des)
        }

        RunLoop.current.add(timer, forMode: .common)
    }

}

// MARK: - Scroll Delegate

extension TableViewVC {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll: \(des)")
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging: \(des)")
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging: \(des)")
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging: \(des)")
    }

    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating: \(des)")
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating: \(des)")
    }
}

// MARK: - TableView Delegate & Data Source

extension TableViewVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell) ?? .init(frame: .zero)
        cell.setContent(with: indexPath.row.description)
        return cell
    }
}
```
