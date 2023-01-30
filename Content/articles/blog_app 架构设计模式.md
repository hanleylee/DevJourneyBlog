---
title: App 架构设计模式
date: 2020-03-09
comments: true
path: framework-design-of-app
categories: iOS
tags: ⦿ios, ⦿framework, ⦿design
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-03-20-133633.jpg?x-oss-process=style/WaMa)

<!-- more -->

## MVC

![himg](https://a.hanleylee.com/HKMS/2020-03-09-144244.jpg?x-oss-process=style/WaMa)

### 各部分职责

- `Model`: 负责处理资料相关事务 (计算, 修改, 存取等等), 并通知 `Controller` 资料的变化, 所以这里的 `model` 不是单纯的 `data model` 而是所谓的 `fat
  model`.
- `View`: 负责显示各种画面元件, 并在使用者执行动作 (滑动, 点击, 按压等等) 时通知 `Controller`.
- `Controller`: 负责在使用者有动作的时候去执行特定工作, 要求 `Model` 更新状态, 在 `Model` 有变化时更新 `View` 的内容来显示这些变化. 但是 `MVC` 的致命缺点就在于 Controller 的定义太模糊, 感觉可能很清晰, 但是大部分人会在 `Controller` 中放置如下功能:
    - 如果不是用 `storyboard` / `xib`, 那就需要建立与摆放各个 `views`; 就算是用 `storyboard` / `xib`, 也可能需要透过程式码调整一些设定.
    - 执行各种动画.
    - 转换资料以便让各个 `views` 显示.
    - 管理整个页面的 `state` 变化.
    - 作为其他元件的 `data sources` 与 `delegates`.
    - 执行 API call 或 `database access`.
    - `present` / `dismiss` 或 `push` / `pop` 其他的 `view controllers`
    - 其他有的没的...

| Model             | View | Controller             |
| ----------------- | ---- | ---------------------- |
| Data structure    |      |                        |
| Data manipulation |      |                        |
|                   | UI   |                        |
|                   |      | Life cycle             |
|                   |      | Setup view & animation |
|                   |      | UI Navigation          |
|                   |      | API call               |
|                   |      | Biz logic              |
|                   |      | Data conversion        |
|                   |      | Data source            |
|                   |      | Delegate               |
|                   |      | etc                    |

## MVVM | MVP

![himg](https://a.hanleylee.com/HKMS/2020-03-09-145255.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-03-09-145237.jpg?x-oss-process=style/WaMa)

上面分别是 MVVM 与 MVP 的框架, 他们的结构基本一样. 其目的都是是为了将 MVC 中无处安放的 API call, data source 等代码放到 ViewModel/Presenter 中.

| Model             | View                   | VM/Presenter    |
| ----------------- | ---------------------- | --------------- |
| Data structure    |                        |                 |
| Data manipulation |                        |                 |
|                   | UI                     |                 |
|                   | Life cycle             |                 |
|                   | Setup view & animation |                 |
|                   | UI Navigation          |                 |
|                   |                        | API call        |
|                   |                        | Biz logic       |
|                   |                        | Data conversion |
|                   |                        | Data source     |
|                   | Delegate               |                 |
|                   | etc                    |                 |

### MVVM 与 MVP 的不同

- MVVM

    强调 **binding**, 常见的 binding framework 有 *ReactiveCocoa*, *RxSwift*, 或是 Apple 在 iOS 13 推出的 *Combine*.

    将使用者动作绑定到 *View Model* 的某个 `method`. 将 *View Model* 的 `property` 变化绑定到 *View* 的画面更新.

    你会发现它们做的事情是一模一样的, 所谓的 `binding` 说穿了就是帮这些基本操作 (`delegate`, `target-action`, `KVO`) 裹上一层糖衣, 让程式码变得更加容易维护

- MVP

    在使用者动作发生时, View 要求 Presenter 做事. Presenter 做完事之后, 通知 View 更新画面, 透过 delegate 是最常见的做法.

## 先对 Coordinator 与 Common Codes 有个共识

### Coordinator

身为 iOS 开发者, 我们早就习惯在 *View Controller* 里头去建立并透过 `present` / `push` 的方式呈现另一个 *View Controller*, 也很习惯在 *View Controller* 按了一个按钮之后就把自己 `dismiss` / `pop`, 更别说我们会在 *View Controller* 里头建立与设定 `UINavigationItem`. 这样的 *View Controller* 会有以下的问题:

- **难以重复使用**: 因为把呈现方式写死了, 所以很难在不同场景使用.
- **流程缺乏弹性**: 因为把下一个画面写死了, 所以很难调整画面流程.
- **知道太多**: *View Controller* 应该专注于自身的画面, 不应该插手别的画面.
- **不合理**: *View Controller* 不应该知道自己会被包在 *Navigation* 或 *Tabbar Controller* 里头, 更别说知道自己会被 `present` 或 `push` 到屏幕上.

所以一个理想的 *View Controller* 会专心负责一个画面, 甚至只负责画面的某个区域, 有另一个综观全局的管理者负责组合, 调度这些 *View Controllers*. 这个角色就是 *Coordinator*, 它的功能如下:

- 负责建立与切换 *View Controllers*.
- 负责组合出一个画面 (Scene) 或一套流程 (Scenario).
- 负责组合多个 *child coordinators*.

### Common Codes

到目前为止我们把画面转换的逻辑搬到 Coordinator, 把业务逻辑搬到 View Model, View Controller 精简到只剩下单一画面的管理, 再也不是动辄破千行的怪物 (根据经验此时的 *View Controller* 大概不到五百行, 就算不用 `storyboard` / `xib` 建立画面, 程式码也不到八百行).

尴尬的是, 由于业务逻辑通常程式码都不少, 所以在 View Controller 瘦身的同时, View Model 却开始变得臃肿; 更糟糕的是, 可能有很多重复的业务逻辑散落在多个 View Model 里头. 身为一个工程师, 我们自然而然会想要把这些重复的部分抽出来.

这些被抽出来的部分, 我们通常会命名为 *Manager* / *Service* / *Helper* / *Utility*, 它们会直接或间接存取 data model. 如此一来, 业务逻辑可被多人共用, View Model 也不再那么庞大, 只需要专注在调用业务逻辑与转换资料格式即可.

## VIPER

VIPER 就是在 MVVM/MVP 的基础上进一步将 Coordinator 与 Common Codes 加入进来

![himg](https://a.hanleylee.com/HKMS/2020-03-09-151121.jpg?x-oss-process=style/WaMa)

| Model(Entity)  | View                   | VM/Presenter    | Coordinator(Router) | Manager/Service(Interactor) |
| -------------- | ---------------------- | --------------- | ------------------- | --------------------------- |
| Data structure |                        |                 |                     |                             |
|                |                        |                 |                     | Data manipulation           |
|                | UI                     |                 |                     |                             |
|                | Life cycle             |                 |                     |                             |
|                | Setup view & animation |                 |                     |                             |
|                |                        |                 | UI Navigation       |                             |
|                |                        |                 |                     | API call                    |
|                |                        |                 |                     | Biz logic                   |
|                |                        | Data conversion |                     |                             |
|                |                        | Data source     |                     |                             |
|                | Delegate               |                 |                     |                             |
|                | etc                    |                 |                     |                             |

|Swift Version|Tag|
| --- | --- |
| Swift 5.1 | >= 0.9.0 |
| Swift 5.0 | >= 0.8.1 |
| Swift 4 | >= 0.4.x |
| Swift 3 | 0.3.x |

### 各部分职责

- `View`: 就是 `MVVM` / `MVP` 的 `View`
- `Presenter`: 就是 `MVP` 的 `Presenter`, 也是 `MVVM` 的 `View Model`
- `Router`(也有人称为 `Wireframe`): 就是 `Coordinator`
- `Interactor`: 就是那些可共用或不可共用的 `Manager` / `Service` / `Helper` / `Utility`
- `Entity`: 就是单纯的 `data model`

## 参考

[漫谈 iOS 架构: 从 MVC 到 VIPER, 以及 Redux](https://chiahsien.github.io/post/common-ios-architecture-from-mvc-to-viper-with-redux/)
