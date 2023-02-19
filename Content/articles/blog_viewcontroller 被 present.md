---
title: ViewController 被 Present
date: 2020-01-05
comments: true
path: present-a-viewcontroller
categories: iOS
tags: ⦿ios, ⦿uikit, ⦿present, ⦿viewcontroller
updated:
---

## presentationController, presentingViewController, presentedViewController 区别

![himg](https://a.hanleylee.com/HKMS/2020-02-06-123127.jpg?x-oss-process=style/WaMa)

<!-- more -->

- UIPresentationController: 相当于一个框架, 用来管理所有的 presentedViewController, 控制从 present 到 dismiss 全过程
- presentedViewController: 要 modal 显示的视图控制器
- presentingViewController: 跳转前视图控制器

## 视图弹出的 Modal 分类及使用的动画效果

自 iOS 13 以后使用 present 方法弹出控制器然后关闭控制器后默认不会调用父控制器的 viewWillAppear() 等方法, 因为其默认的 modal 为 automatic(即 pagesheet). 使用此种 modal 时, 在弹出子控制器后, 父控制器不会被 disappear 掉.

### Modal 分类

只要视图四周任一侧有留白情况, 在视图 dismiss 后不会呼叫`viewWillDisappear` 和 `viewDidDisappear`

1. automatic

    系统默认的, 一般会映射为 pageSheet. 有例外情况

2. fullScreen

    全屏弹出, `iOS 13` 之前系统默认的样式, 弹出的视图覆盖整个屏幕, 视图消失时会呼叫 `viewWillDisappear` 和 `viewDidDisappear`

3. pageSheet

    视图顶部露出下方视图部分内容. 在垂直方向为 `compact` 的环境下显示的效果与 `fullScreen` 相同

4. formSheet

    在水平和垂直都为 `regular` 的环境下会显示在屏幕中央, 四周留白并有 `dim` 效果

    在垂直 `reguler` 但水平 `compact` 的环境下顶部留白

    在垂直 `vertical` 环境下与 `fullScreen` 的效果和功能相同

5. currentContext

    弹出上下文选单视图(小视图)

6. custom

    自定义弹出式图, 需配合 `delegate` 使用

7. overFullscreen

    覆盖整改屏幕. 下方视图在被覆盖后不会消失, 因此如果被弹出的视图是透明的, 那么下方被覆盖的内容仍可以被看到.

8. overCurrentContext

    在一个视图的内容上弹出另一个小视图

9. popover

    在水平 `regular` 的环境下, 背景被 `dim`, 四周留白, 点击空白处会 `dismiss`

    在水平 `compact` 的环境下, 与 `fullScreen` 效果相同

10. blurOverFullScreen

    在全屏展示新内容视图之前模糊被覆盖的视图

### 弹出或关闭视图时的动画 - Transition

1. coverVertical

    视图自底部弹出占据整个页面, 当 `dismiss` 时视图返回下方. 此为默认选项

2. flipHorizontal

    视图使用 `3D` 翻转, 像是从背面转过来, 当 `dismiss` 时视图原路翻转回去

3. crossDissolve

    被弹出视图淡入的时候, 下方视图同时淡出, 当 `dismiss` 时顺序相反. 效果不明显, 不建议使用

4. partialCurl

    视图从右下角被掀起向上翻页, 露出被弹出的视图.

    必须在下方视图和被弹出视图的 `modal` 都为 `fullScreen` 时才能使用此功能, 否则崩溃

    ```swift
    newFoodVC.modalPresentationStyle = .fullScreen
    newFoodVC.modalTransitionStyle = .flipHorizontal
    present(newFoodVC, animated: true, completion: nil)
    ```

## Modal 为 Automatic 时如何更新父控制器的数据并刷新界面

如果将 `modalPresentationStyle` 变更为 `.fullScreen`, 可以再不做任何其他改变的情况下获得关闭子控制器默认调用父控制器的 `viewWillAppear` 等方法的结果

### 使用官方原生方法

使用协议 [UIAdaptivePresentationControllerDelegate](https://developer.apple.com/documentation/uikit/uiadaptivepresentationcontrollerdelegate).

1. 使需要更新数据与视图的父控制器遵守此协议
2. 父控制器实现协议中的方法, 比如 [`presentationControllerDidDismiss(_:)`](https://developer.apple.com/documentation/uikit/uiadaptivepresentationcontrollerdelegate/3229889-presentationcontrollerdiddismiss)
3. 父控制器中设置父控制器为 `presentedController` 的代理(也可以在 `presentedVC` 中设置父控制器为`presentedVC` 的代理, 原理相同)

具体实现代码如下:

```swift
class Parent: UIViewController, UIAdaptivePresentationControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mySegue" {
          segue.destination.presentationController?.delegate = self;
        }
    }

    // MARK: - UIAdaptivePresentationControllerDelegate
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    // 需要自定义实现的内容
    // ps: 只有在向下拖拽 VC 的时候触发 dismiss 的时候此方法才会被调用, 如果是自定义动作 dismiss 的话需要手动呼叫 presentationController.delegate?.presentationControllerDidDismiss
    // 或者重写 dismiss 方法, 在 dismiss 方法中调用 presentationController.delegate?.presentationControllerDidDismiss
    }
}
```

### 使用自定义协议传递方法

此方法原理是将父 VC 作为 presentedVC, 然后在需要需要关闭页面的地方呼叫代理的相应方法, 具体代码实现过程如下:

```swift
// 1. 自定义协议
protocol HLDelegate {
    /// 在弹出的子视图 dismiss 后更新父视图
    func updateListVC()
}

// 2. 设置父 VC 遵守协议, 实现协议的相应方法, 并将父 VC 设置为childVC 的代理
class superVC: HLDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        childVC.delegate = self
    }

    func updateListVC() {
        // 自定义想要实现的代码
    }
}


// 3. childVC 中需要退出的地方调用代理的相应方法
class childVC {

    var delegate: HLDelegate?

    func exitAndUpdateSuperVC() {
        delegate?.updateListVC()
    }
}

```

## present 与 dismiss 的关系

假设有3个UIViewController, 分别是A, B, C

- 如果 A 已经弹了B, 这个时候你想想弹一个C, 此时应该使用 B 弹 C(多层级弹窗应该由父控制器弹出子控制器)
- 此时
    - A.presentingViewController (null)
    - A.presentedViewController B
    - B.presentingViewController A
    - B.presentedViewController C
    - C.presentingViewController B
    - C.presentedViewController (null)
- dismiss时, 遵守如下规则
    - 父节点负责调用dismiss来关闭他弹出来的子节点, 也可以直接在子节点中调用dismiss方法, UIKit会通知父节点去处理.
    - 如果你连续弹出多个节点, 应当由最底层的父节点调用dismiss来一次性关闭所有子节点.
    - 关闭多个子节点时, 只有最顶层的子节点会有动画效果, 下层的子节点会直接被移除, 不会有动画效果.
