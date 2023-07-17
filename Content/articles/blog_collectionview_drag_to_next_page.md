---
title: 为 UICollectionView 手动添加滑动到下一页手势
date: 2023-07-05
comments: true
urlname: collectionview_drag_to_next_page
tags: ⦿ios, ⦿collectionview
updated:
---

最近接到了一个需求, 将我们 app 的账户页面将多个同类账户设为可横向滑动, 且会自动根据滑动停止时停留的位置移动到合适的账户卡片上, 横向滑动区域为图中红框区域

![himg](https://a.hanleylee.com/HKMS/2023-07-05203516.png?x-oss-process=style/WaMa)

<!-- more -->

本来我的想法挺简单的, 这个区域我肯定会使用 UICollectionView 来实现, UICollectionView 继承自 UIScrollView, 有 `isPagingEnable` 属性, 我只需要将 `isPagingEnable` 设置为 true 就行了, 尝试一下:

![himg](https://a.hanleylee.com/HKMS/2023-07-05212225.GIF)

在只有两个卡片的情况下是没有问题的, 但是测试同事反馈在三个及以上卡片的时候会出现错位问题

![himg](https://a.hanleylee.com/HKMS/2023-07-05212356.GIF)

经过分析, 出现这个问题的原因是 `isPagingEnable` 会在 view 的 bounds 宽度的整数倍位置停下来:

```txt
If the value of this property is true, the scroll view stops on multiples of the scroll view’s bounds when the user scrolls. The default value is false.
```

而我们 app 的账户卡片显示区域比较特殊, bounds 宽度就是屏幕宽度, 同时每屏右侧要稍微露出一点后一张卡片以提示用户存在更多卡片, 那么当滑动停止时, collectionView 停止的位置会落在第二张卡片区域内, 这也就导致了上面 bug 的出现

所以默认的 `isPagingEnable` 是不能用了, 需要其他的方案. 搜了下网上大家对轮播图的实现方案, 绝大部分使用的都是将 collectionView 的 `isScrollEnabled` 设为 `false`, 然后添加一个 `UIPanGestureRecognizer` 手势, 对该手势的状态进行监听然后设置 collectionView 停止的位置. 这种方案能实现需求, 但是我不太喜欢:

- 要判断手势的多种状态, 代码量太多
- UICollectionView 本来就是支持滑动的(内部也是通过滑动手势实现的), 非要把滑动禁用转而使用自己创建的手势有点太浪费

那有没有什么简单又易用的方法呢? 经过我不断调整踩坑, 最终方案如下:

```swift
class PortfolioTableViewCell: UITableViewCell {
    // MARK: Subviews

    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    private var pageControl: HLPageControl!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension PortfolioTableViewCell: UICollectionViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // disable decelerating
        targetContentOffset.pointee = scrollView.contentOffset

        let scaleIndex = (scrollView.contentOffset.x) / itemWidth
        let oldIndex = pageControl.currentPage
        var newIndex = lroundf(Float(scaleIndex))
        if newIndex == oldIndex  {
            let speedX = velocity.x
            if (speedX) > 1 {
                newIndex += 1
            } else if speedX < -1 {
                newIndex -= 1
            }
        }

        newIndex = max(0, newIndex)
        newIndex = min(newIndex, dataArr.count - 1)
        collectionView.scrollToItem(at: IndexPath(item: newIndex, section: 0), at: .centeredHorizontally, animated: true)
        pageControl.moveToPage(newIndex)
    }
}

// MARK: - UI

extension PortfolioTableViewCell {
    private func setUpUI() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.by.color(hexString: "#EFF3F6")

        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        flowLayout.itemSize = CGSize(width: itemWidth, height: 150)

        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.by.color(hexString: "#EFF3F6")
        collectionView.register(BNCPortfolioNeoCurrentCoreAccountCell.self, forCellWithReuseIdentifier: BNCPortfolioNeoCurrentCoreAccountCell.by.nameOfClass)
        collectionView.register(BNCPortfolioNeoCurrentCBSAccountCell.self, forCellWithReuseIdentifier: BNCPortfolioNeoCurrentCBSAccountCell.by.nameOfClass)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        contentView.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(150)
        }

        pageControl = HLPageControl(frame: .zero)
        pageControl.tintViewColor = .orange
        pageControl.backgroundColor = .clear
        contentView.addSubview(pageControl)
        pageControl.createWithCount(2)
        pageControl.snp.makeConstraints {
            $0.height.equalTo(4)
            $0.width.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

```

核心代码都在 `func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)` 这个方法中, 这个方案有以下优势:

- 使用 UICollectionView 的 `scrollToItem` 方法, 保证最终的卡片位置一定位于屏幕中间
- 在考虑手指离开屏幕时位移点的同时考虑到了滑动的水平速度 `velocity.x`, 可以保证及时没有滑动距离没有超过屏幕宽度的一半也可以滑动到 上一张/下一张 卡片
- 禁用了 UIScrollView 滑动时的惯性移动

![himg](https://a.hanleylee.com/HKMS/2023-07-05212413.GIF)

具体效果如上, 经过反复对比测试, 其拖拽交互效果与使用 `isPagingEnabled` 效果近乎一致, 且位移正确 🥳

好啦, 收工下班!
