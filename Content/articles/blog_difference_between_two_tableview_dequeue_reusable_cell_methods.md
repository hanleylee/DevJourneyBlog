---
title: UITableView 的两种复用 cell 方法的区别
date: 2022-01-18
comments: true
path: difference-between-two-tableview-dequeue-reusable-cell-methods
categories: ios
tags: ⦿uikit, ⦿ios
updated:
---

做过 iOS 开发的人都知道, iOS 的 UITableView 的 Cell 需要复用, 复用的时候有两种方法可以调用

- [`dequeueReusableCell(withIdentifier:)`][4]
- [`dequeueReusableCell(withIdentifier:for:)`][5]

那么他们到底有什么区别?

![himg](https://a.hanleylee.com/HKMS/2022-01-24000544.jpg?x-oss-process=style/WaMa)

<!-- more -->

之前没有深究过这个问题, 每次用的时候只要使用了 [`register(_:forCellReuseIdentifier:)`][6] 就能保证 App 的效果绝对不会有问题. 前两天心血来潮, 总觉得他们一定有什么不同, 尽管他们只差了一个参数而已

从 Apple 的 Documentation 中是很难看不出区别的, 直到我看了 [stackoverflow][1] 上的答案. 区别有两点:

1. 如果没有使用 [`register(_:forCellReuseIdentifier:)`][6]

    - [`dequeueReusableCell(withIdentifier:)`][4] : 会返回 `nil`
    - [`dequeueReusableCell(withIdentifier:for:)`][5] : 会直接 crash!

2. [`dequeueReusableCell(withIdentifier:for:)`][5] 会在初始化时寻找代理方法 [`tableView(_:heightForRowAt:)`][7] 返回的高度, 从而使我们的cell 在 cell 初始化时就可以知道其本身的高度(有时这会非常有用).

得到答案之后, 我们再回头看 Apple 的文档

- [`dequeueReusableCell(withIdentifier:)`][4]

    > ... This method dequeues an existing cell if one is available or creates a new one using the class or nib file you previously registered. If no
    > cell is available for reuse and you did not register a class or nib file, this method returns nil.
    >
    > If you registered a class for the specified identifier and a new cell must be created, this method initializes the cell by calling its
    > `init(style:reuseIdentifier:)` method. For nib-based cells, this method loads the cell object from the provided nib file. If an existing cell
    > was available for reuse, this method calls the cell's `prepareForReuse()` method instead.

- [`dequeueReusableCell(withIdentifier:for:)`][5]

    > Important: You must specify a cell with a matching identifier in your storyboard file. You may also register a class or nib file using the
    > `register(_:forCellReuseIdentifier:)` method, but must do so before calling this method.

很明显, [`dequeueReusableCell(withIdentifier:for:)`][5] 的文档着重强调我们一定要在使用该方法前调用 [`register(_:forCellReuseIdentifier:)`][6], 为的就是防止 crash!

## 示例

我们可以像下面这样使用 [`dequeueReusableCell(withIdentifier:)`][4], 在没有 register 的情况下手动调用指定 `UITableViewCell` 的初始化方法:

```swift
class TestTableViewVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - TableView Delegate & Data Source

extension TestTableViewVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as? TestTableViewCell ?? .init(style: .default, reuseIdentifier: "TableViewCell")
        cell.setContent(with: indexPath.row.description)
        return cell
    }
}
```

但是如果使用 [`dequeueReusableCell(withIdentifier:for:)`][5] 的话, 必须与 [`register(_:forCellReuseIdentifier:)`][6] 配合使用

```swift
class TestTableViewVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TestTableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    }
}

// MARK: - TableView Delegate & Data Source

extension TestTableViewVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TestTableViewCell
        cell.setContent(with: indexPath.row.description)
        return cell
    }
}
```

## 总结

啰嗦了那么多, 其实总结下来很简单:

- 从初始化角度来看
    - 如果在调用两者之前已经使用了 [`register(_:forCellReuseIdentifier:)`][6], 两者没区别;
    - 如果在调用两者之前没有使用 [`register(_:forCellReuseIdentifier:)`][6], 那么 [`dequeueReusableCell(withIdentifier:)`][4] 还可以给你一次自我拯救的
      机会, 但是 [`dequeueReusableCell(withIdentifier:for:)`][5] 则会直接 crash, 不会给你任何机会
- 从约束布局角度来看
    - [`dequeueReusableCell(withIdentifier:)`][4] 进行初始化时直接使用默认行高 44
    - [`dequeueReusableCell(withIdentifier:for:)`][5] 会在初始化时寻找代理方法 [`tableView(_:heightForRowAt:)`][7](如果有的话) 返回的高度

## 坑

在看到这个 [stackoverflow][3] 时, 一个回答说:

- [`dequeueReusableCell(withIdentifier:)`][4]: 在 [`tableView(_:cellForRowAt:)`][8] 方法返回 cell 后添加到 superview 中
- [`dequeueReusableCell(withIdentifier:for:)`][5]: 在 [`tableView(_:cellForRowAt:)`][8] 方法返回 cell 前添加到 superview 中

经过我的验证, 这是完全错误的, 两种方法都是在 [`tableView(_:cellForRowAt:)`][8] 返回 cell 后才会被添加到 superview 上, 可能在之前的某个系统版本上出现过这样的 bug, 但是现在这个 bug 已经被解决了

## Ref

- [iOS: What is a difference between dequeueReusableCell(withIdentifier:for:) and dequeueReusableCell(withIdentifier:)?][1]
- [iOS learning-the difference between the two reuse methods of UITableViewCell][2]
- [dequeueReusableCellWithIdentifier:forIndexPath: VS dequeueReusableCellWithIdentifier:][3]

[1]: https://stackoverflow.com/questions/44213804/ios-what-is-a-difference-between-dequeuereusablecellwithidentifierfor-and-d
[2]: https://blog.fireheart.in/a?ID=01450-576ebe76-ebea-47b8-8158-4c7e6e3f5240
[3]: https://stackoverflow.com/questions/35984091/dequeuereusablecellwithidentifierforindexpath-vs-dequeuereusablecellwithidenti/36000801#36000801
[4]: https://developer.apple.com/documentation/uikit/uitableview/1614891-dequeuereusablecell
[5]: https://developer.apple.com/documentation/uikit/uitableview/1614878-dequeuereusablecell
[6]: https://developer.apple.com/documentation/uikit/uitableview/1614888-register
[7]: https://developer.apple.com/documentation/uikit/uitableviewdelegate/1614998-tableview
[8]: https://developer.apple.com/documentation/uikit/uitableview/1614983-cellforrow
