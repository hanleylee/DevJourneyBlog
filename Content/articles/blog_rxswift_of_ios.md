---
title: iOS 之 RxSwift
date: 2020-03-13
comments: true
path: rxswift-of-ios
categories: iOS
tags: ⦿ios, ⦿rxswift
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-03-20-133718.jpg?x-oss-process=style/WaMa)

<!-- more -->

## RxSwift 优点

- 复合, Rx 就是复合的代名词
- 复用, 易于复合
- 清晰, 因为声明都是不可变更的
- 易用, 抽象了异步编程, 统一了代码风格
- 稳定, Rx 完全通过了单元测试

## RxSwift 的核心概念

在 Rx 中, 可监听序列即一连串的元素, 这些元素处于监听状态, 设置一个观察者对可监听序列进行监听, 监听序列每发出一个元素就会被观察者知道, 然后观察者调用相关方法进行响应

![himg](https://a.hanleylee.com/HKMS/2020-03-12-164722.png?x-oss-process=style/WaMa)

在 RxSwift 的监听与响应过程中, 主要由以下几部分组成

- *监听序列*: 含序列元素转换, 序列合并的一系列产生序列的过程; 使用 subscribeOn 方法可让这个过程实现在不同线程
- *响应事件*: 接受监听序列传递来的元素进而通过元素执行事件; 使用 observeOn 方法可让这个过程实现在不同线程
- *disposable*: 清理包, 在订阅的事件 (即可监听序列) 发出 `complete` 或 `error` 事件后订阅事件就会被清除
- *操作符*: 操作符可以控制监听序列的元素, 可以做到发哪些元素, 怎么发, 组合多个序列发出元素等等一系列功能

### 函数响应式编程

所谓响应式编程, 就是使用异步数据流 (Asynchronous data streams) 进行编程. 在传统的指令式编程语言里, 代码不仅要告诉程序做什么, 还要告诉程序什么时候做. 而在响应式编程里, 我们只需要处理各个事件, 程序会自动响应状态的更新. 而且, 这些事件可以单独封装, 能有效提高代码复用性并简化错误处理的逻辑.

典型的例子有 `map`, `filter`, `reduce`, 其优点如下:

- 灵活
- 简洁
- 高复用
- 易维护
- 适应各种需求变化

### Observable(可被监听的序列) - 产生事件

- `Observable`
- `Single`
- `Completable`
- `Maybe`
- `Driver`
- `Signal`
- `ControlEvent`

默认情况下, RxSwift 已经创建了足够多的常用序列, e.g. `button` 的点击, `textField` 的当前文本, `switch` 开关, `slider` 的当前数值等等.  如果需要自定义序列也非常简单:

```swift
// 创建序列最直接的方法就是调用 Observable.create, 然后在构建函数里面描述元素的产生过程. observer.onNext(0) 就代表产生了一个元素, 他的值是 0.
// 后面又产生了 9 个元素分别是 1, 2, ... 8, 9 . 最后, 用 observer.onCompleted() 表示元素已经全部产生, 没有更多元素了.
let numbers: Observable<Int> = Observable.create { observer -> Disposable in

    observer.onNext(0)
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onNext(4)
    observer.onNext(5)
    observer.onNext(6)
    observer.onNext(7)
    observer.onNext(8)
    observer.onNext(9)
    observer.onCompleted()

    return Disposables.create()
}

// 调用自定义创建的序列
numbers.subscribe(onNext: { print($0) })
```

复杂一点, 也通过这种方式封装一个闭包回调:

```swift
typealias JSON = Any

let json: Observable<JSON> = Observable.create { (observer) -> Disposable in

    let task = URLSession.shared.dataTask(with: ...) { data, _, error in

        guard error == nil else {
            observer.onError(error!) // 如果任务失败, 就调用 observer.onError(error!), 并返回
            return
        }

        guard let data = data,
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            else {
                observer.onError(DataError.cantParseJSON)
                return
        }

        observer.onNext(jsonObject) // 如果获取到目标元素, 就调用 observer.onNext(jsonObject).
        observer.onCompleted() //  由于我们的这个序列只有一个元素, 所以在成功获取到元素后, 就直接调用 observer.onCompleted() 来表示任务结束.
    }

    task.resume()

    return Disposables.create { task.cancel() } // 表示如果数据绑定 (订阅) 被清除, 就取消网络请求
}

// 这样一来我们就将传统的闭包回调转换成序列了. 然后可以用 subscribe 方法来响应这个请求的结果:

json
    .subscribe(onNext: { json in
        print("取得 json 成功: \(json)")
    }, onError: { error in
        print("取得 json 失败 Error: \(error.localizedDescription)")
    }, onCompleted: {
        print("取得 json 任务成功完成")
    })
    .disposed(by: disposeBag)
// 这里 subscribe 后面的 onNext,onError, onCompleted 分别响应我们创建 json 时, 构建函数里面的 onNext,onError, onCompleted 事件. 我们称这些事件为 Event
```

通过枚举自定义处理类型, 然后将生成一个枚举类型的 `Observable`:

```swift
enum ValidateFailReason {
    case emptyInput
    case other(String)
}

enum ValidateResult {
    case validating
    case ok
    case failed(ValidateFailReason)
    var isOk: Bool {
        if case ValidateResult.ok = self {
            return true
        } else {
            return false
        }
    }
}

let username = "lihonglei"

let result = Observable<ValidateResult>.create { (anyObserver) -> Disposable in
    if username.isEmpty {
        anyObserver.onNext(.failed(.emptyInput))
        anyObserver.onCompleted()
        return Disposables.create()
    }

    anyObserver.onNext(.validating)

    print("发起用户名验证请求 ...")

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
        if username.count < 6 && username.count > 0 {
            anyObserver.onNext(.failed(.other("用户名不能少于 6 个字符")))
        } else if username.trim().contains(characters: CharacterSet(charactersIn: "!@#$%^&*()")) {
            anyObserver.onNext(.failed(.other("用户名有其他字符")))
        } else {
            anyObserver.onNext(.ok)
        }
        anyObserver.onCompleted()
    }
    return Disposables.create()
}

result.subscribe { [weak self] (event) in

    switch event {
        case .completed:
            return
        case .error(_):
            print("验证服务出错")
        case .next(let result):
            switch result {
                case .ok:
                    print("ok")
                case .validating:
                    print("验证中")
                case .failed(let reason):
                    switch reason {
                        case .emptyInput:
                            print("未输入")
                        case .other(let msg):
                            print("错误: \(msg)")
                }
        }

    }
}.disposed(by: disposeBag)
```

注意: `subscribe` 大体有两种, 这两种使用哪个都可以, 最终效果相同

- `numbers.subscribe(onNext: ((Int) -> Void)?, onError: ((Error) -> Void)?, onCompleted: (() -> Void)?, onDisposed: (() -> Void)?)`: 订阅一个 element handler, 一个 error handler, 一个 completion handler, 以及一个 disposed handler
- `numbers.subscribe(on: (Event<Int>) -> Void)`: 订阅一个 event handler

    ```swift
    let numbers: Observable<Int> = Observable.create { observer -> Disposable in

        observer.onNext(0)
        observer.onNext(1)
        observer.onNext(2)
        observer.onNext(3)
        observer.onNext(4)
        observer.onNext(5)
        observer.onNext(6)
        observer.onNext(7)
        observer.onNext(8)
        observer.onNext(9)
        observer.onCompleted()

        return Disposables.create {
            print("hhh")
        }
    }

    // 调用自定义创建的序列
    // 第一种方式, 只订阅 element handler 到监听序列
    numbers.subscribe(onNext: { print($0) })
    // 第二种方式, 订阅 element, error, complete, dispose handler 到监听序列
    numbers.subscribe(onNext: { (int) in
        print(int)
    }, onError: { (error) in
        print("error: \(error)")
    }, onCompleted: {
        print("complete")
    }) {
        print("disposed")
    }

    // 第三种方式, 订阅一个 event handler 到监听序列
    numbers.subscribe { (event) in
        switch event {
            case .completed:
                print("completed")
            case .error(let error):
                print("error: \(error)")
            case .next(let int):
                print(int)
        }
    }
    ```

#### Event - 事件

可以在 `Event` 中添加自定义事件 (将尖括号中的 `Element` 实现自定义即可), 默认事件如下:

```swift
public enum Event<Element> {
    case next(Element) // 序列产生了一个新元素
    case error(Swift.Error) // 创建序列时产生了一个错误, 导致序列终止
    case completed // 序列的所有元素都已经成功产生, 整个序列已经完成
}
```

可以通过如下方式添加自定义事件

```swift
enum ValidateFailReason{
    case emptyInput
    case other(String)
}

enum ValidateResult {
    case validating
    case ok
    case failed(ValidateFailReason)
    var isOk: Bool {
        if case ValidateResult.ok = self {
            return true
        } else {
            return false
        }
    }
}
```

通过如下方式使用

```swift
vm.output.usernameValidateResult.subscribe { [weak self] (event: Event<ValidateResult>) in
    switch event {
        case .completed:
            return
        case .error(_):
            self?._usernameValidationLb.text = "验证服务出错";
        case .next(let result):
            switch result{
                case .ok:
                    self?._usernameValidationLb.text = ""
                case .validating:
                    self?._usernameValidationLb.text = "验证中..."
                case .failed(let reason):
                    switch reason{
                        case .emptyInput:
                            self?._usernameValidationLb.text = ""
                        case .other(let msg):
                            self?._usernameValidationLb.text = msg
                }
        }
    }
}.disposed(by: disposeBag)
```

#### 特征序列

RxSwift 中的 `Observable` 存在一些特征序列, 这些特征序列与 `Observable` 是同级的, 特征序列可以帮助我们更准确的描述序列, 并且给我们提供语法糖, 让我们能够更优雅地书写代码, 已有的特征序列如下:

- Single

    `Single` 只能发出一个元素, 或产生一个 `error` 事件

    ```swift
    // **************   创建自定义 Single   ******************
    func getRepo(_ repo: String) -> Single<[String: Any]> {

        return Single<[String: Any]>.create { single in
            let url = URL(string: "https://api.github.com/repos/\(repo)")!
            let task = URLSession.shared.dataTask(with: url) {
                data, _, error in

                if let error = error {
                    single(.error(error))
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
                      let result = json as? [String: Any] else {
                    single(.error(DataError.cantParseJSON))
                    return
                }

                single(.success(result))
            }

            task.resume()

            return Disposables.create { task.cancel() }
        }
    }

    // **************   使用自定义 Single   ******************
    getRepo("ReactiveX/RxSwift")
        .subscribe(onSuccess: { json in
            print("JSON: ", json)
        }, onError: { error in
            print("Error: ", error)
        })
        .disposed(by: disposeBag)

    // **************   订阅提供一个 SingleEvent 的枚举   ***************
    public enum SingleEvent<Element> {
        case success(Element) // 产生一个单独的元素
        case error(Swift.Error) // 产生一个错误
    }
    ```

    > 你同样可以对 Observable 调用 .asSingle() 方法, 将它转换为 Single.

- `Completable`

    与 `Single` 类似, `Complete` 要么只能产生一个 `completed` 事件, 要么产生一个 `error` 事件.

    ```swift
    // **************   创建自定义 Completable   ******************
    func cacheLocally() -> Completable {
        return Completable.create { completable in
           // Store some data locally
           ...
           ...

           guard success else {
               completable(.error(CacheError.failedCaching))
               return Disposables.create {}
           }

           completable(.completed)
           return Disposables.create {}
        }
    }

    // **************   使用自定义 Completable   ******************
    cacheLocally()
        .subscribe(onCompleted: {
            print("Completed with no error")
        }, onError: { error in
            print("Completed with an error: \(error.localizedDescription)")
         })
        .disposed(by: disposeBag)

    // **************   订阅提供一个 CompletableEvent 的枚举   ***************
    public enum CompletableEvent {
        case error(Swift.Error) // 产生完成事件
        case completed // 产生一个错误
    }
    ```

- `Maybe`

    `Maybe` 介于 `Single` 与 `Completable` 之间, 要么只能发出一个元素, 要么产生一个 `completed` 事件, 要么产生一个 `error` 事件

    ```swift
    // **************   创建自定义 Maybe ******************
    func generateString() -> Maybe<String> {
        return Maybe<String>.create { maybe in
            maybe(.success("RxSwift"))

            // OR

            maybe(.completed)

            // OR

            maybe(.error(error))

            return Disposables.create {}
        }
    }

    // **************   使用自定义 Maybe   ******************
    generateString()
        .subscribe(onSuccess: { element in
            print("Completed with element \(element)")
        }, onError: { error in
            print("Completed with an error \(error.localizedDescription)")
        }, onCompleted: {
            print("Completed with no element")
        })
        .disposed(by: disposeBag)

    ```

    > 你同样可以对 Observable 调用 .asMaybe() 方法, 将它转换为 Maybe.

- Driver

    Driver(司机) 主要是为了简化 UI 层的代码. 在如下情况中也可以使用它 (即意味着 Driver 拥有如下属性):

    - 不会产生 error 事件
    - 一定在 MainScheduler 监听 (主线程监听)
    - 共享附加作用

    ```swift
    let results = query.rx.text.asDriver()        // 将普通序列转换为 Driver
        .throttle(0.3, scheduler: MainScheduler.instance)
        .flatMapLatest { query in
            fetchAutoCompleteItems(query)
                .asDriver(onErrorJustReturn: [])  // 仅仅提供发生错误时的备选返回值
        }

    results
        .map { "\($0.count)" }
        .drive(resultCount.rx.text)               // 这里改用 `drive` 而不是 `bindTo`
        .disposed(by: disposeBag)                 // 这样可以确保必备条件都已经满足了

    results
        .drive(resultsTableView.rx.items(cellIdentifier: "Cell")) {
          (_, result, cell) in
            cell.textLabel?.text = "\(result)"
        }
        .disposed(by: disposeBag)
    ```

    drive 方法只能被 Driver 调用. 这意味着, 如果你发现代码所存在 drive, 那么这个序列不会产生错误事件并且一定在主线程监听. 这样你可以安全的绑定 UI 元素.

- Signal

    Signal 与 Driver 相似, 唯一的区别是 Driver 会对新观察者回放 (重新发送) 上一个元素, 而 Signal 不会对新观察者回放上一个元素. Signal 拥有如下属性:

    - 不会产生 error 事件
    - 一定在 MainScheduler 监听 (主线程监听)
    - 共享附加作用

    ```swift
    // **************   Driver(用于状态改变, 合理)   ****************
    let textField: UITextField = ...
    let nameLabel: UILabel = ...
    let nameSizeLabel: UILabel = ...

    let state: Driver<String?> = textField.rx.text.asDriver()

    let observer = nameLabel.rx.text
    state.drive(observer)

    // ... 假设以下代码是在用户输入姓名后运行

    let newObserver = nameSizeLabel.rx.text
    state.map { $0?.count.description }.drive(newObserver)
    /*
    这个例子只是将用户输入的姓名绑定到对应的标签上. 当用户输入姓名后, 我们创建了一个新的观察者, 用于订阅姓名的字数.
    那么问题来了, 订阅时, 展示字数的标签会立即更新吗?

    嗯, 因为 Driver 会对新观察者回放上一个元素 (当前姓名), 所以这里是会更新的. 在对他进行订阅时, 标签的默认文本会被刷新. 这是合理的.
    */

    // **************   Driver(用于描述点击事件, 不合理)   ***********

    let button: UIButton = ...
    let showAlert: (String) -> Void = ...

    let event: Driver<Void> = button.rx.tap.asDriver()

    let observer: () -> Void = { showAlert("弹出提示框 1") }
    event.drive(onNext: observer)

    // ... 假设以下代码是在用户点击 button 后运行

    let newObserver: () -> Void = { showAlert("弹出提示框 2") }
    event.drive(onNext: newObserver)
    /*
    当用户点击一个按钮后, 我们创建一个新的观察者, 来响应点击事件. 此时会发生什么? Driver 会把上一次的点击事件回放给新观察者.
    所以, 这里的 newObserver 在订阅时, 就会接受到上次的点击事件, 然后弹出提示框. 这似乎不太合理.

    因此像这类型的事件序列, 用 Driver 建模就不合适. 于是我们就引入了 Signal:
    */

    // **************   Signal(用于描述点击事件, 合理)   **************
    let event: Signal<Void> = button.rx.tap.asSignal()

    let observer: () -> Void = { showAlert("弹出提示框 1") }
    event.emit(onNext: observer)

    // ... 假设以下代码是在用户点击 button 后运行

    let newObserver: () -> Void = { showAlert("弹出提示框 2") }
    event.emit(onNext: newObserver)
    /*
    在同样的场景中, Signal 不会把上一次的点击事件回放给新观察者, 而只会将订阅后产生的点击事件, 发布给新观察者. 这正是我们所需要的.
    */
    ```

> 一般情况下状态序列我们会选用 Driver 这个类型, 事件序列我们会选用 Signal 这个类型.

- ControlEvent

    专门用于描述 UI 控件所产生的事件, 具有如下特征:

    - 不会产生 error 事件
    - 一定在 MainScheduler 订阅 (主线程订阅)
    - 一定在 MainScheduler 监听 (主线程监听)
    - 共享附加作用

### Observer(观察者) - 响应事件

观察者用来监听事件, 然后响应事件. e.g.:

- 弹出提示框就是观察者, 它是对点击按钮这个监听序列作出响应.
- 当温度高于 33° 时打开空调降温, 温度 `[..., 31, 32, 33, ...]` 是一个监听序列, 打开空调降温就是一个观察者
- 海贼王新增一集时, 观看这一集, `海贼王的集数` 就是监听序列, `观看这一集` 就是观察者

```swift
    // *************   例 1   ************
    let userNameValid = usernameOutlet.rx.text.orEmpty
        .map { $0.count >= minimalUsernameLength} // 通过 map 方法将其转化为用户名是否有效

    userNameValid.bind(to: passwordOutlet.rx.isEnabled) // 将监听序列 userNameValid 绑定到观察者 passwordOutlet.rx.isEnabled 上
        .disposed(by: disposeBag)

    // *************   例 2   ************
    // subscribe 后面的全部是观察者
    tap.subscribe(onNext: { [weak self] in
        self?.showAlert()
    }, onError: { error in
        print("发生错误:  \(error.localizedDescription)")
    }, onCompleted: {
        print("任务完成")
    })
```

#### 创建观察者

默认下, RxSwift 已经创建好了许多的观察者, 如 view 是否隐藏, button 是否可点击, label 的当前文本, imageView 的当前图片

创建观察者最直接的办法就是在 Observable 的 subscribe 后面描述. 描述事件发生时观察者要做如何响应, subscribe 中的 onNext, onError, onCompleted 这些闭包就构建出了一个完整的观察者.

当然, 也可以通过特征观察者来创建我们要使用的观察者

#### 特征观察者

- AnyObserver

    AnyObserver 用于描述任意一种观察者, 即任何 Observer 都可以转化为 AnyObserver, 以下为示例:

    ```swift
    URLSession.shared.rx.data(request: URLRequest(url: url))
        .subscribe(onNext: { data in
            print("Data Task Success with count: \(data.count)")
        }, onError: { error in
            print("Data Task Error: \(error)")
        })
        .disposed(by: disposeBag)

    // 上面的代码可转化为如下使用 AnyObserver 表示:
    let observer: AnyObserver<Data> = AnyObserver { (event) in
        switch event {
        case .next(let data):
            print("Data Task Success with count: \(data.count)")
        case .error(let error):
            print("Data Task Error: \(error)")
        default:
            break
        }
    }

    URLSession.shared.rx.data(request: URLRequest(url: url))
        .subscribe(observer)
        .disposed(by: disposeBag)
    ```

    ```swift
    usernameValid
        .bind(to: usernameValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)

    // 上面的代码可转化为如下使用 AnyObserver 表示:
    let observer: AnyObserver<Bool> = AnyObserver { [weak self] (event) in
        switch event {
        case .next(let isHidden):
            self?.usernameValidOutlet.isHidden = isHidden
        default:
            break
        }
    }

    usernameValid
        .bind(to: observer)
        .disposed(by: disposeBag)
    ```

- Binder

    Binder 与普通的 Observer 相比有以下两个特征:

    - 不会处理错误事件
    - 确保绑定都是在给定的 Scheduler 上执行 (默认是 MainScheduler)

    根据以上特性, Binder 特别适合作为 UI 观察者, 因为 UI 的操作都需要在主线程上执行, 我们可以将以下代码进行优化:

    ```swift
    // ***********   优化前   ***********
    let observer: AnyObserver<Bool> = AnyObserver { [weak self] (event) in
        switch event {
        case .next(let isHidden):
            self?.usernameValidOutlet.isHidden = isHidden
        default:
            break
        }
    }

    usernameValid
        .bind(to: observer)
        .disposed(by: disposeBag)

    // ***********   优化后   ***********
    let observer: Binder<Bool> = Binder(usernameValidOutlet) { (view, isHidden) in
        view.isHidden = isHidden
    }

    usernameValid
        .bind(to: observer)
        .disposed(by: disposeBag)
    ```

#### 观察者的复用

`view 是否隐藏`, `按钮是否可点击`, `label 当前文本`, 这些观察者都是常用的, RxSwift 使用了如下的方法进行复用:

- view 是否隐藏

    ```swift
    extension Reactive where Base: UIView {
      public var isHidden: Binder<Bool> {
          return Binder(self.base) { view, hidden in
              view.isHidden = hidden
          }
      }
    }

    // 实际调用
    usernameValid
        .bind(to: usernameValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)
    ```

- label 当前文本

    ```swift
    extension Reactive where Base: UILabel {
        public var text: Binder<String?> {
            return Binder(self.base) { label, text in
                label.text = text
            }
        }
    }
    ```

- 按钮是否可以点击

    ```swift
    extension Reactive where Base: UIControl {
        public var isEnabled: Binder<Bool> {
            return Binder(self.base) { control, value in
                control.isEnabled = value
            }
        }
    }
    ```

> 我们也可以使用这种方式根据我们的需要为常用的观察者进行自定义创建

### Observable & Observer

有些事物既能作为可监听序列, 也可作为观察者, 比如 textfiled 的当前文本, 即可以作为由用户输入而产生的一个文本序列, 也可作为当前显示内容的观察者:

```swift
// 作为可监听序列
let observable = textField.rx.text
observable.subscribe(onNext: { text in show(text: text) })

// 作为观察者
let observer = textField.rx.text
let text: Observable<String?> = ...
text.bind(to: observer)
```

> 很多 UI 控件存在这种性质, e.g. switch 开关状态, segmentControl 选中索引, dataPicker 的选中日期, view 的隐藏属性, 按钮的可点击属性...

#### 辅助观察者 / 可监听序列

另外, RxSwift 中定义了一些辅助类型, 这些辅助类型既是可监听序列, 也是观察者:

##### AsyncSubject

将在源 Observable 产生完成事件后, 队随后的观察者发出最后一个元素. 如果源没有发出任何元素, 只有一个完成事件, 那么 AsyncSubject 也只有一个完成事件; 如果源 Observable 因为产生了一个 error 而终止, 那么 AsyncSubject 不会发出任何元素, 而是将 error 发送出来

```swift
let disposeBag = DisposeBag()
let subject = AsyncSubject<String>()

subject
    .subscribe { print("Subscription: 1 Event:", $0) }
    .disposed(by: disposeBag)

subject.onNext("🐶")
subject.onNext("🐱")
subject.onNext("🐹")
subject.onCompleted()

// ********  输出结果   *********
Subscription: 1 Event: next(🐹)
Subscription: 1 Event: completed
```

##### PublishSubject

对观察者发送订阅后产生的元素, 而在订阅前发出的元素将不会发送给观察者. 如果源 Observable 因为产生了一个 error 事件而中止,  PublishSubject 就不会发出任何元素, 而是将这个 error 事件发送出来.

```swift
let disposeBag = DisposeBag()
let subject = PublishSubject<String>()

subject
    .subscribe { print("Subscription: 1 Event:", $0) }
    .disposed(by: disposeBag)

subject.onNext("🐶")
subject.onNext("🐱")

subject
    .subscribe { print("Subscription: 2 Event:", $0) }
    .disposed(by: disposeBag)

subject.onNext("🅰️")
subject.onNext("🅱️")

// ********   输出结果   *********
// 因为 subject 订阅了两次事件, 因此在最后发送 A, B 时, 第一次订阅的事件会响应, 第二次订阅的事件也会响应
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
```

- ReplaySubject: 将对观察者发送全部的元素, 无论观察者是何时进行订阅的.

    ```swift
    let disposeBag = DisposeBag()
    let subject = ReplaySubject<String>.create(bufferSize: 1)

    subject
        .subscribe { print("Subscription: 1 Event:", $0) }
        .disposed(by: disposeBag)

    subject.onNext("🐶")
    subject.onNext("🐱")

    subject
        .subscribe { print("Subscription: 2 Event:", $0) }
        .disposed(by: disposeBag)

    subject.onNext("🅰️")
    subject.onNext("🅱️")

    // ********   输出结果   *********
    Subscription: 1 Event: next(🐶)
    Subscription: 1 Event: next(🐱)
    Subscription: 2 Event: next(🐱)
    Subscription: 1 Event: next(🅰️)
    Subscription: 2 Event: next(🅰️)
    Subscription: 1 Event: next(🅱️)
    Subscription: 2 Event: next(🅱️)
    ```

##### BehaviorSubject

当观察者对 BehaviorSubject 进行订阅时, 它会将源 Observable 中最新的元素发送出来 (如果不存在最新的元素, 就发出默认元素). 然后将随后产生的元素发送出来.

```swift
let disposeBag = DisposeBag()
let subject = BehaviorSubject(value: "🔴")

subject
    .subscribe { print("Subscription: 1 Event:", $0) }
    .disposed(by: disposeBag)

subject.onNext("🐶")
subject.onNext("🐱")

subject
    .subscribe { print("Subscription: 2 Event:", $0) }
    .disposed(by: disposeBag)

subject.onNext("🅰️")
subject.onNext("🅱️")

subject
    .subscribe { print("Subscription: 3 Event:", $0) }
    .disposed(by: disposeBag)

subject.onNext("🍐")
subject.onNext("🍊")

// *******   输出结果   **********
Subscription: 1 Event: next(🔴)
Subscription: 1 Event: next(🐶)
Subscription: 1 Event: next(🐱)
Subscription: 2 Event: next(🐱)
Subscription: 1 Event: next(🅰️)
Subscription: 2 Event: next(🅰️)
Subscription: 1 Event: next(🅱️)
Subscription: 2 Event: next(🅱️)
Subscription: 3 Event: next(🅱️)
Subscription: 1 Event: next(🍐)
Subscription: 2 Event: next(🍐)
Subscription: 3 Event: next(🍐)
Subscription: 1 Event: next(🍊)
Subscription: 2 Event: next(🍊)
Subscription: 3 Event: next(🍊)
```

##### ControlProperty

ControlProperty 专门用于描述 UI 控件属性的, 它具有以下特征:

- 不会产生 error 事件
- 一定在 MainScheduler 订阅 (主线程订阅)
- 一定在 MainScheduler 监听 (主线程监听)
- 共享附加作用

### Operator(操作符) - 创建变化组合事件

> RxSwift 中的部分操作符带有 latest 关键字, 意思是最新, 最后, 最近; 以数组为例: `[a, b, c]`, `a` 是第一个元素, 也是第一个被监听的元素, `c` 是最后一个元素, 也是最新的元素, 也是最后一个被监听的元素

#### 创建监听序列

##### create

构建一个完整的 Observable

```swift
let id = Observable<Int>.create { observer in
    observer.onNext(0)
    observer.onNext(1)
    observer.onCompleted()
    return Disposables.create()
}
```

##### from

将 (单个) 数组类型 (或已有可监听序列) 转换为一个 Observable

```swift
let numbers = Observable.from([0, 1, 2])

// equal to
// let numbers = Observable<Int>.create { observer in
//     observer.onNext(0)
//     observer.onNext(1)
//     observer.onNext(2)
//     observer.onCompleted()
//     return Disposables.create()
// }
```

##### of

将其他类型的多个元素 (**可以是监听序列或其他数据类型如 Int, array 等**) 转换为一个 Observable

of 中如果是多个多个序列, 那么转换出来的序列虽然是一个序列, 但是这个序列是包含子序列的序列, 并不是纯元素序列, 可以使用 `merge` 操作符将含子序列的序列 **压扁** 为一个只包含纯元素的序列

```swift
let disposeBag = DisposeBag()

Observable.of(10, 100, 1000)
    .scan(1) { aggregateValue, newValue in
        aggregateValue + newValue
    }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

// result:
// 11
// 111
// 1111
```

##### just

创建一个只能发出一个元素的 Observable

```swift
let id = Observable.just(0)
```

##### empty

创建一个空的只含有 complete 事件的 Observable

```swift
let id = Observable<Int>.empty()

// equal to
// let id = Observable<Int>.create { observer in
//     observer.onCompleted()
//     return Disposables.create()
// }
```

##### error

创建一个只含有 error 事件的 Observable

```swift
let error: Error = ...
let id = Observable<Int>.error(error)

// equal to
// let error: Error = ...
// let id = Observable<Int>.create { observer in
//     observer.onError(error)
//     return Disposables.create()
// }
```

##### nerver

创建一个永远不会发出任何事件的 Observable, 甚至 error 事件都不会发出

```swift
let id = Observable<Int>.nerver()

// equal to
// let id = Observable<Int>.create { observer in
//     return Disposables.create()
// }
```

##### repeatElement

创建一个重复发出某个元素的 Observable, 不会停止, 直至 disposable 被清除

```swift
let id = Observable.repeatElement(0)

// equal to
// let id = Observable<Int>.create { observer in
// observer.onNext(0)
// observer.onNext(0)
// observer.onNext(0)
// observer.onNext(0)
// ...  无数次
// return Disposables.create()
// }
```

##### interval

创建一个 Observable, 每个一段时间就发出一个索引, 其将发出无数个元素, 不会停止, 直至 disposable 被清除

##### timer

创建一个 Observable, 在经过设定的一段时间后, 产生一个唯一的元素

#### 组合多个监听序列形成一个新的监听序列

##### amb

多个 Observables 中, 谁最先发出元素就只发出那个 Observable 的所有元素, 其他的 Observable 则抛弃

![himg](https://a.hanleylee.com/HKMS/2020-03-22-082757.jpg?x-oss-process=style/WaMa)

##### merge

最容易理解的组合多个 Observables, 按照每个 Observable 发出元素的时机发出元素

![himg](https://a.hanleylee.com/HKMS/2020-03-22-082954.jpg?x-oss-process=style/WaMa)

##### zip

配对, 将两个 (或多个) 独立的序列合并为一个新的混合序列, 并让每个 Observable 都发出一个新的元素 (组合其他的 Observable 来创建一个新的 Observable)

![himg](https://a.hanleylee.com/HKMS/2020-03-22-083119.jpg?x-oss-process=style/WaMa)

```swift
// 汉堡
let rxHamburg: Observable<Hamburg> = ...
// 薯条
let rxFrenchFries: Observable<FrenchFries> = ...

// zip 操作符
Observable.zip(rxHamburg, rxFrenchFries)
    .subscribe(onNext: { (hamburg, frenchFries) in
        print("取得汉堡: \(hamburg) 和薯条: \(frenchFries)")
    })
    .disposed(by: disposeBag)
```

##### combineLatest

在多个 Observables 中的任何一个 Observable 发出最新 (最后) 一个元素时, 就发出一个由这个元素与另外几个 Observables 的最新元素通过指定方法得出的元素

![himg](https://a.hanleylee.com/HKMS/2020-03-22-091808.jpg?x-oss-process=style/WaMa)

```swift
let disposeBag = DisposeBag()

let first = PublishSubject<String>()
let second = PublishSubject<String>()

Observable.combineLatest(first, second) { $0 + $1 }
          .subscribe(onNext: { print($0) })
          .disposed(by: disposeBag)

first.onNext("1")
second.onNext("A")
first.onNext("2")
second.onNext("B")
second.onNext("C")
second.onNext("D")
first.onNext("3")
first.onNext("4")

// result:
// 1A
// 2A
// 2B
// 2C
// 2D
// 3D
// 4D
```

##### withLatestFrom

当主 Observable 的最新元素要发出的时候, 就结合次 Observable 的最新元素通过指定方法处理, 然后发出

默认情况下如果只写 `first.withLatestFrom(second)` 的话则将按照 `first.withLatestFrom(second) { $1 }` 的方式只返回 `次 Observable`(即 `second`) 的元素

只能接序列

~~如果 `主 Observable` 与 `次 Observable` 的类型不同, 那么只能返回一种类型的 Observable, 或是 `主 Observable`, 或是 `次 Observable`~~

![himg](https://a.hanleylee.com/HKMS/2020-03-22-092238.jpg?x-oss-process=style/WaMa)

```swift
let disposeBag = DisposeBag()
let firstSubject = PublishSubject<String>()
let secondSubject = PublishSubject<String>()

firstSubject
     .withLatestFrom(secondSubject) {
          (first, second) in
          return first + second
     }
     .subscribe(onNext: { print($0) })
     .disposed(by: disposeBag)

firstSubject.onNext("A")
firstSubject.onNext("B")
secondSubject.onNext("1")
secondSubject.onNext("2")
firstSubject.onNext("AB")

// result: AB2
```

> withLatestFrom 与 combinLatest 的区别是: withLatestFrom 只在主 Observable 发出最新元素时取出次 Observable 的最新元素进行自定义方法的拼接, 而
> combineLatest 则是在任意一个 Observable 发出最新元素时都对另一个 (一些) Observable 的最新元素进行自定义方法的组合

##### concat

按顺序地"拼接"数个监听序列. 当前一个 Observable 元素发送完毕产生 complete 事件后才开始发送另一个 Observable 的元素

只能拼接序列

拼接顺序取决于添加监听队列的先后顺序

![himg](https://a.hanleylee.com/HKMS/2020-03-22-093110.jpg?x-oss-process=style/WaMa)

##### concatMap

在 concat 的基础上按给定方法并按顺序地"拼接" Observable 中的元素

##### sample

取样; 在第二个 Observable 发出元素时, 发出在此时刻第一个 Observable 发出的最新 (最近, 最后) 的元素

#### 对单个监听序列进行转换

> 可被连接的 Observable: 在被订阅后不会立刻发出元素, 直到 connect 操作符被应用为止 (这样一来你可以等所有观察者全部订阅完成后, 才发出元素.)

##### publish

将 Observable 转换为可被连接的 Observable.

##### replay

将 Observable 转换为可被连接的 Observable, 并且这个可被连接的 Observable 将缓存最新的 n 个元素. 当有新的观察者对它进行订阅时, 它就把这些被缓存的元素发送给观察者.

##### shareReplay

使得观察者共享源 Observable, 并且缓存最新的 n 个元素, 将这些元素直接发送给新的观察者.

share 的默认 replay 值为 0, 但是添加 share 与不添加 share 是完全不一样的.

```swift
func shareTest(){
    // 随便创建一个对象, 目的是为了方便观察对象的内存地址
    class UserModel{
        var age:Int
        init(age:Int) {
            self.age = age
        }
    }

    // 这里创建数组的作用是为了引用不让对象在 ARC 机制下提前释放
    var array:[UserModel] = Array()
    // 创建一个普通的 Subject
    let seq = PublishSubject<Int>()
    let a = seq.map { (i) -> UserModel in
        print("映射 ---\(i)")
        return UserModel(age: i)
    }
        .share(replay: 2, scope: .forever)

    a.subscribe(onNext: { (num) in
        print("第一次订阅 --",Unmanaged.passUnretained(num).toOpaque())
        array.append(num)
    }).disposed(by: disposeBag)

    seq.onNext(1)
    seq.onNext(2)

    a.subscribe(onNext: { (num) in
        print("第二次订阅 --",Unmanaged.passUnretained(num).toOpaque())
        array.append(num)
    }).disposed(by: disposeBag)

    seq.onNext(3)
    seq.onNext(4)

    a.subscribe(onNext: { (num) in
        print("第三次订阅 --",Unmanaged.passUnretained(num).toOpaque())
        array.append(num)
    }).disposed(by: disposeBag)
    print(array)
    seq.onCompleted()
}
```

![himg](https://a.hanleylee.com/HKMS/2020-04-27-2020-04-28_RxSwift%20%E7%9A%84%20share%20%E4%BD%9C%E7%94%A8.png?x-oss-process=style/WaMa)

注: BehaviorSubject 的默认值在 replay 为 0 的时候只会触发第一个订阅, 不会触发第二个订阅, 手动 onNext 的值不受此影响

##### connect

通知可被连接的 Observable, 可以发出元素了

##### refCount

将可被连接的 Observable 转换为普通的 Observable, 与 publish 相反

##### `as...`

将某类型 Observable 转换为指定类型的 Observable

##### groupBy

将源 Observable 分解为多个子 Observable, 然后将这些子 Observable 发送出来. 它会将元素通过某个键进行分组, 然后将分组后的元素序列以 Observable 的形态发送出来.

![himg](https://a.hanleylee.com/HKMS/2020-03-22-112342.jpg?x-oss-process=style/WaMa)

#### 单个监听序列中的元素进行转换

##### map

返回原序列, 处理层面就位于源 Observable 的元素或子 Observable(如果有) 上, 处理完后将结果元素放到其原位置上, 最后返回原序列

##### flatMap

返回的是 (可) 自定义类型的新序列, 将源 Observable 的每个元素应用指定方法转换为 Observables(一个元素就对应一个 Observable, 如果源 Observable 的元素就是 Observable, 则不转换), 然后将这些 Observables 全部进行降维直至转换为内部的基本元素, 然后将这些元素合并成一个新 Observable 并返回

![himg](https://a.hanleylee.com/HKMS/2020-03-22-083556.jpg?x-oss-process=style/WaMa)

##### flatMapLatest

返回的是 (可) 自定义类型的新序列, 将源 Observable 的每个元素应用指定方法转换为 Observables(一个元素就对应一个 Observable, 如果源 Observable 的元素就是 Observable, 则不转换), 然后在这些 Observables 中找出最新的一个, 进行降维直至转换为内部的基本元素, 然后将这些元素合并成一个新 Observable 并返回

```swift
let first = BehaviorSubject(value: "first-0")
let second = BehaviorSubject(value: "second-0")

Observable.of(first, second)
    .flatMapLatest({ (bhv) -> Observable<String> in
        return bhv.asObservable()
    })
    .subscribe(onNext: { str in
        print(str)
    })
    .disposed(by: disposeBag)

first.onNext("first-1")
first.onNext("first-2")
second.onNext("second-1")
second.onNext("second-2")

// result:
// first-0
// second-0
// second-1
// second-2
```

##### flatMapFirst

将 observable 中的每个元素逐个应用方法转换为多个 observables, 然后取第一个

##### scan

**持续地** 将 Observable 的每一个元素应用方法, 然后发出每一次的函数返回结果, 与 reduce 很相似, 不过 reduce 只能返回一个结果, 而此操作符则会对 Observable 中的每一个序列都返回一个结果

```swift
let disposeBag = DisposeBag()

Observable.of(10, 100, 1000)
    .scan(1) { aggregateValue, newValue in
        aggregateValue + newValue
    }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

// result:
// 11
// 111
// 1111
```

##### materialize

将序列产生的事件, 转换成元素

![himg](https://a.hanleylee.com/HKMS/2020-03-22-101117.jpg?x-oss-process=style/WaMa)

##### dematerialize

与 materialize 相反

##### retry

如果产生错误, 就重试

##### catchError

如果产生错误, 就切换到备选 Observable

##### catchErrorJustReturn

如果产生错误, 就返回一个预设的元素 (可以是空数组或别的)

##### timeout

如果源 Observable 在规定时间内没有发出任何元素, 就产生一个超时的 error 事件

#### 对单个监听序列中的元素进行筛选

##### filter

容易理解, 当 Observable 中的元素满足限制条件后方可被正常发出

##### elementAt

只发出 Observable 的第 n 个元素

##### ignoreElements

忽略掉所有的 next 事件, 只接收 completed 和 error 事件

##### debounce

如果一段时间内产生的多个值, 则只发出最后一个值 (在键盘输入的绑定中很常见)

![himg](https://a.hanleylee.com/HKMS/2020-03-22-095051.jpg?x-oss-process=style/WaMa)

在 RxSwift 的点语法中, 位于 debounce 之后的所有命令都会受此操作符影响, 在此之前的操作符则不受影响, 比如 debug 位于此操作符之后就会被此操作符影响

##### throttle

返回一个新序列, 这个序列只包含在指定的时间内由原序列发出的第一个和最后一个元素. 适用于: 输入框搜索限制发送请求.

同时, 可在 `latest` 选项中设置为 `true` 或 `false`, `false` 表示默认只选择返回多个元素中最早的那个元素, `true` 表示将最早的和最后的元素都发出来

```swift
let pb1 = PublishSubject<Int>()
pb1.throttle(2, latest: true, scheduler: MainScheduler.instance)
    .subscribe(onNext: { int in
        print("element:", int)
    })
    .disposed(by: bag)
pb1.onNext(1)
pb1.onNext(2)
pb1.onNext(3)
pb1.onNext(4)
pb1.onNext(5)

// result:
// element: 1
// element: 5
```

##### distinctUntilChanged

对比最新发出的元素与上一个发出的元素, 如果有不同就发出, 否则不发出 (在键盘输入的绑定中很常见)

e.g. 密码输入框末尾添加了 1, 然后又快速删除了这个 1, 那么相当于整个密码串值没有发生改变, 那么就不会向监听者发送元素

在 RxSwift 的点语法中, 位于 distinctUntilChanged 之后的所有命令都会受此操作符影响, 在此之前的操作符则不受影响, 比如 debug 位于此操作符之后就会被此操作符影响

##### skip

跳过 Observable 的前 n 个元素, 与 take 相反

![himg](https://a.hanleylee.com/HKMS/2020-03-22-095324.jpg?x-oss-process=style/WaMa)

##### skipUntil

跳过一个序列中的前 n 个元素, 直到另一个 Observable 发出一个元素才开始可以发出元素, 与 takeUntil 相反

![himg](https://a.hanleylee.com/HKMS/2020-03-22-095524.jpg?x-oss-process=style/WaMa)

##### skipWhile

设定一个判定条件, 直到 Observable 中的元素满足此条件后, 此 Observable 才可发出之后的元素, 与 takeWhile 相反

![himg](https://a.hanleylee.com/HKMS/2020-03-22-095545.jpg?x-oss-process=style/WaMa)

##### startWith

在已有 Observable 的原有元素前插入一个 (些) 自定义元素并发出

只能插入元素

##### take

仅取出 Observable 的前 n 个元素, 与 skip 相反

##### takeLast

仅取出 Observable 的最后 n 个元素

##### takeUntil

取出一个序列中的前 n 个元素, 直到另一个 Observable 发出一个元素才被沉默, 与 skipUntil 相反

##### takeWhile

设定一个判定条件, 直到 Observable 中的元素满足此条件后, 此 Observable 被沉默不发出元素, 与 skipWhile 相反

#### 将监听序列所有元素合并为一个结果

##### reduce

容易理解, 持续的将 Observable 的每一个元素应用一个函数, 然后发出最终结果

#### 其他

##### debug

打印所有的订阅, 事件以及销毁信息 (观察订阅事件等处理过程时非常有用)

##### subscribeOn

指定序列产生, 组合, 变换等一系列处理所使用的线程

##### observeOn

指定监听者响应事件, 执行方法时所使用的线程

##### defered

直到订阅发生, 才创建 Observable.

##### buffer

缓存元素, 当元素达到某个数量, 或者经过了特定的时间, 会将这个元素发送出来

##### window

window 操作符和 buffer 十分相似, buffer 周期性的将缓存的元素集合发送出来, 而 window 周期性的将元素集合以 Observable 的形态发送出来.

##### `delay`

将产生的每一个元素, 延迟一段时间后再发出

##### `delaySubscription`

在开始发出元素时, 延时后进行订阅 (重新从 Observable 中发出某些元素)

##### do

Observable 发生某个事件时, 采取某个行动

##### using

创建一个 Disposable 资源, 使它与 Observable 具有相同的寿命

#### 自定义操作符

```swift
extension ObserverType {
    func myMap<R>(transform: E -> R) -> Observable<R> {
        return Observable.create{ observer in
            let subscription = self.subscribe {e in
                switch e{
                case .next(let value):
                    let result = transform(value)
                    observer.on(.next(result))
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
            return subscription
        }
    }
}
```

#### 易混淆操作符的一些区别

- flatMap 与 map

    - map + merge = flatMap 函数

    ![himg](https://a.hanleylee.com/HKMS/2020-03-28-154827.jpg?x-oss-process=style/WaMa)

    ```swift
    // ************   例 1   *************
    let test = Observable.of("1", "2", "3")
        .map { Observable.just($0) } // map 对源 Observable 的三个元素进行了重生成内部序列, 使之变为了有子监听序列的监听序列
                                      // 就是 map 进行了升维操作, 这是 map 的缺点

    test.subscribe(onNext: {
            print($0) // 在传入到监听者这边后, 监听序列会被褪去一层, 但仍然不是基本元素, 现在还是监听序列
        })
        .disposed(disposeBag)
    // 结果:
    // RxSwift.(Just in _BD9B9D4356C4038796FB16D0D54A9F8E)<Swift.String>
    // RxSwift.(Just in _BD9B9D4356C4038796FB16D0D54A9F8E)<Swift.String>
    // RxSwift.(Just in _BD9B9D4356C4038796FB16D0D54A9F8E)<Swift.String>

    // ************   例 2   *************
    let test = Observable.of("1", "2", "3")
        .map { Observable.just($0) }.merge() // merge 将多个监听序列或嵌套型监听序列转为一个且不嵌套的纯监听序列

    test.subscribe(onNext: {
            print($0)
        })
        .disposed(disposeBag)
    // 结果:
    1
    2
    3

    // ************   例 3   *************
    let test = Observable.of("1", "2", "3")
        .flatMap { Observable.just($0) } // flatMap 会自动对内部元素逐个生成 Observable, 然后降维为基本元素并合并成一个序列再返回
                                          // 等于 map + merge
    test.subscribe(onNext: {
            print($0)
        })
        .disposed(disposeBag)
    // 结果
    1
    2
    3
    ```

- flatMap 与 flatMapLatest

    flatMapLatest 会将监听序列上的元素 (可能带有子序列) 逐个转换为多个单条序列, 与每个元素一一对应, 在后一个元素被加进来后, 只发送最后加入进来的元素序列所发出的元素, 形容的话有些抽象, 直接看图更直观:

    ![himg](https://a.hanleylee.com/HKMS/2020-03-28-155356.jpg?x-oss-process=style/WaMa)

- combinestLatestFrom 与 withLatestFrom 与 flatMapLatest 的混合使用

    ```swift
    let disposeBag = DisposeBag()

    let test1 = PublishSubject<String>()
    let test2 = PublishSubject<String>()

    let testA = PublishSubject<String>()

    // 在后面声明闭包方便在 flatMapLatest 中调用
    // 也可以不声明, 那么在 flatMapLatest 中就只能通过 pair.0 与 pair.1 来进行调用了
    let params = Observable.combineLatest(test1, test2) { (param1: $0, param2: $1) }

    let res = testA
        // 后面不加闭包的话默认只返回 params 这个序列的元素, 与 testA 的关系就只是 testA 发出一个元素后, 取出 params 的最新元素直接发出
        // 只能返回一种类型, 如果两序列类型不同的话则只能返回一个序列
        // 等效于 withLatestFrom(param) { $1 }
        // 等效于 withLatestFrom(param) { return $1 }
        // 等效于 withLatestFrom(param) { da1, da2 in return da2 }
        .withLatestFrom(params)
        // 此时, flatMapLatest 操作的序列只有 withLatestFrom 返回的 params, 并没有 testA
        .flatMapLatest { (pair) -> Observable<String> in
            return Observable.of(pair.param1, pair.param2)
    }

    res.subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)

    test1.onNext("1")
    test2.onNext("2")
    testA.onNext("A")

    // result:
    // 1
    // 2
    ```

- throttle 与 debounce

    - `.throttle(.milliseconds(500), latest: true, scheduler: MainScheduler.instance)`
    - `debounce(.milliseconds(500), scheduler: MainScheduler.instance)`

    throttle 默认的 latest 是 true, 此时会发出序列第一个元素 a 触发后 500ms 范围内的第一个元素 a 及最后一个元素 b; 如果 latest 属性设置为 false 的话, 将只会发出第一个元素 a.

    debounce 则只会发出第一个元素 a 触发序列后 500ms 范围内的最后一个元素 b, 不包含元素 a

    所以, 综合下来, throttle 不是 debounce 的强化版, 两者是截然不同的效果, 但都是为了过滤高频元素.

### Disposable(可被清除的资源) - 管理绑定 (订阅) 的生命周期

一个被监听的序列如果发出了 error 或者 completed 时间, 那么所有的内部资源都会被释放. 如果要提前释放这些资源或者取消订阅的话, 可以对返回的可被清除的资源调用 dispose 方法:

```swift
var disposable: Disposable?

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.disposable = textField.rx.text.orEmpty
        .subscribe(onNext: { text in print(text) })
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.disposable?.dispose()
}
```

> 通常情况下是不需要我们手动调用 dispose 方法的, 上面的只是演示如何使用而已. 推荐使用 DisposeBag 或者 takeUntil 来自动管理生命周期

#### DisposeBag

当清除包被释放的时候, 清除包内部所有可被清除的资源 (Disposable) 都将被清除.

```swift
var disposeBag = DisposeBag()

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    textField.rx.text.orEmpty
        .subscribe(onNext: { text in print(text) })
        .disposed(by: self.disposeBag)
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.disposeBag = DisposeBag()
}
```

根据 ViewController 的生命周期来使 disposeBag 自动被释放, 从而取消所有的绑定

```swift
var disposeBag = DisposeBag() // 来自父类 ViewController

override func viewDidLoad() {
    super.viewDidLoad()

    ...

    usernameValid
        .bind(to: passwordOutlet.rx.isEnabled)
        .disposed(by: disposeBag)

    usernameValid
        .bind(to: usernameValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)

    passwordValid
        .bind(to: passwordValidOutlet.rx.isHidden)
        .disposed(by: disposeBag)

    everythingValid
        .bind(to: doSomethingOutlet.rx.isEnabled)
        .disposed(by: disposeBag)

    doSomethingOutlet.rx.tap
        .subscribe(onNext: { [weak self] in self?.showAlert() })
        .disposed(by: disposeBag)
}

```

在上面这个例子中, disposeBag 与 ViewController 具有相同的生命周期. 当退出页面时, ViewController 被释放, disposeBag 也跟着被释放, 那么这里的 5 次绑定 (订阅) 同时自动取消.

#### takeUntil

takeUntil 是另一种自动取消订阅的方法, 将上述例子换用 takeUntil 来实现的话, 代码如下所示:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    ...
    _ = usernameValid
        .takeUntil(self.rx.deallocated)
        .bind(to: passwordOutlet.rx.isEnabled)

    _ = usernameValid
        .takeUntil(self.rx.deallocated)
        .bind(to: usernameValidOutlet.rx.isHidden)

    _ = passwordValid
        .takeUntil(self.rx.deallocated)
        .bind(to: passwordValidOutlet.rx.isHidden)

    _ = everythingValid
        .takeUntil(self.rx.deallocated)
        .bind(to: doSomethingOutlet.rx.isEnabled)

    _ = doSomethingOutlet.rx.tap
        .takeUntil(self.rx.deallocated)
        .subscribe(onNext: { [weak self] in self?.showAlert() })
}
```

### Schedulers(调度器) - 线程队列调配

Scheduler 是帮助 RxSwift 实现多线程. 他可以控制任务 (监听任务 & 执行任务) 在哪个线程执行

```swift
// 后台取得数据, 主线程处理结果
// *********   GCD 实现   **********
DispatchQueue.global(qos: .userInitiated).async {
    let data = try? Data(contentsOf: url)
    DispatchQueue.main.async {
        self.data = data
    }
}

// *********   RxSwift 实现   **********
let rxData: Observable<Data> = ...

rxData
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { [weak self] data in
        self?.data = data
    })
    .disposed(by: disposeBag)
```

#### subscribeOn & observeOn

- `subscribeOn`: 决定在哪个线程进行数据序列的构建
- `observeOn`: 决定在哪个线程进行监听

##### 1. 在 Observable.create 的方式使用时

![himg](https://a.hanleylee.com/HKMS/2021-03-16-17-59-28.jpg?x-oss-process=style/WaMa)

`subscribeOn` 是向上和向下作用的, 只使用 `subscribeOn` 指定执行的队列之后,  **产生事件**,  **操作事件**,  **响应事件** 都将在指定的队列中执行.

`observarOn` 是向下作用的, `observarOn` 可以指定其后面的 **操作事件** 和 **响应事件** 执行的队列, 可以使用多个 `observarOn` 来改变不同的 **操作事件** 执行的队列

同时使用 `subscribeOn` 和 `observerOn` 时. **产生事件** 和 `observeOn` 之前的  **操作事件** 将会在 `subscribeOn` 指定的队列中执行. `observeOn` 之后的 **操作事件** 和  **响应事件** 将会在 `observeOn` 指定的队列中执行.

```swift
func subscribeOnAndObserveOn() {
    Observable<Int>.create { observer in
        print("产生事件 -> \(Thread.current)")
        observer.onNext(1)
        return Disposables.create()
    }
    .map {  element -> Int in
        print("操作事件 1 -> \(Thread.current)")
        return element + 1
    }
    .observeOn(MainScheduler.instance)
    .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
    .map { element -> Int in
        print("操作事件 2 -> \(Thread.current)")
        return element + 1
    }
    .subscribe(onNext: { element in
        print("响应事件 -> \(Thread.current), element -> \(element)\n")
    }).disposed(by: self.disposeBag)
}
```

##### 2. 在 `PublishSubject` / `PublishRelay` / `BehaviorSubject` / `BehaviorSubject` 的方式使用时

当使用这些可为监听序列, 同时可为观察者时, subscribeOn 什么都影响不了, observeOn 功能保持不变, 即仍然只能影响之后的逻辑

#### 一些调度器

- MainScheduler: 抽象了的主线程, 与 GCD 概念相同
- SerialDispatchQueueScheduler: 抽象了的串行队列, 与 GCD 概念相同
- ConcurrentDispatchQueueScheduler: 抽象了的并发队列, 与 GCD 概念相同
- OperationQueueScheduler: 抽象了的 NSOperationQueue

```swift
// Observable<String>
let text = usernameOutlet.rx.text.orEmpty.asObservable()

// Observable<Bool>
let passwordValid = text
    // Operator
    .map { $0.characters.count >= minimalUsernameLength }

// Observer<Bool>
let observer = passwordValidOutlet.rx.isHidden

// Disposable
let disposable = passwordValid
    // Scheduler 用于控制任务在那个线程队列运行
    .subscribeOn(MainScheduler.instance)
    .observeOn(MainScheduler.instance)
    .bind(to: observer)

// 取消绑定, 你可以在退出页面时取消绑定
disposable.dispose()
```

### Error Handing(错误处理)

在序列中一旦发生了一个 error 事件, 整个序列将被终止. 总的来说, RxSwift 有两种错误处理机制, retry 与 catch

- retry: 让序列在发生错误后重试

    ```swift
    // 请求 JSON 失败时, 立即重试,
    // 重试 3 次后仍然失败, 就将错误抛出

    let rxJson: Observable<JSON> = ...

    rxJson
        .retry(3)
        .subscribe(onNext: { json in
            print("取得 JSON 成功: \(json)")
        }, onError: { error in
            print("取得 JSON 失败: \(error)")
        })
        .disposed(by: disposeBag)
    ```

- retryWhen: 让序列在发生错误后延时一段时间再重试

    ```swift
    // 请求 JSON 失败时, 等待 5 秒后重试,

    let retryDelay: Double = 5  // 重试延时 5 秒

    rxJson
        .retryWhen { (rxError: Observable<Error>) -> Observable<Int> in
            return Observable.timer(retryDelay, scheduler: MainScheduler.instance)
        } // retryWhen 操作符, 这个操作符主要描述应该在何时重试, 并且通过闭包里面返回的 Observable 来控制重试的时机
        .subscribe(...)
        .disposed(by: disposeBag)
    ```

    ```swift
    // 请求 JSON 失败时, 等待 5 秒后重试,
    // 重试 4 次后仍然失败, 就将错误抛出

    let maxRetryCount = 4       // 最多重试 4 次
    let retryDelay: Double = 5  // 重试延时 5 秒

    rxJson
        .retryWhen { (rxError: Observable<Error>) -> Observable<Int> in
        //  flatMapWithIndex 这个操作符可以给我们提供错误的索引数 index. 然后用这个索引数判断是否超过最大重试数, 如果超过了, 就将错误抛出.
        // 如果没有超过, 就等待 5 秒后重试
            return rxError.flatMapWithIndex { (error, index) -> Observable<Int> in
                guard index < maxRetryCount else {
                    return Observable.error(error)
                }
                return Observable<Int>.timer(retryDelay, scheduler: MainScheduler.instance)
            }
        }
        .subscribe(...)
        .disposed(by: disposeBag)
    ```

- catchErrorJustReturn: 序列发生错误时, 返回一个自定义结果

    ```swift
    // 当错误发生时, 返回一个空数组
    searchBar.rx.text.orEmpty
        ...
        .flatMapLatest { query -> Observable<[Repository]> in
            ...
            return searchGitHub(query)
                .catchErrorJustReturn([])
        }
        ...
        .bind(to: ...)
        .disposed(by: disposeBag)
    ```

- catchError: 让序列在发生错误后用一个 (组) 备用元素将错误替换掉

    ```swift
    // 先从网络获取数据, 如果获取失败了, 就从本地缓存获取数据

    let rxData: Observable<Data> = ...      // 网络请求的数据
    let cahcedData: Observable<Data> = ...  // 之前本地缓存的数据

    rxData
        .catchError { _ in cahcedData }
        .subscribe(onNext: { date in
            print("获取数据成功: \(date.count)")
        })
        .disposed(by: disposeBag)
    ```

- Result: 仅给用户错误提示

    最简单的错误提示方案:

    ```swift
    // 当用户点击更新按钮时, 就立即取出修改后的用户信息. 然后发起网络请求, 进行更新操作
    // 一旦操作失败就提示用户失败原因

    updateUserInfoButton.rx.tap
        .withLatestFrom(rxUserInfo)
        .flatMapLatest { userInfo -> Observable<Void> in
            return update(userInfo)
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {
            print("用户信息更新成功")
        }, onError: { error in
            print("用户信息更新失败:  \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)

    // 这样实现是非常直接的. 但是一旦网络请求操作失败了, 序列就会终止. 整个订阅将被取消
    // 如果用户再次点击更新按钮, 就无法再次发起网络请求进行更新操作了.
    ```

    改进版错误提示方案:

    ```swift
    updateUserInfoButton.rx.tap
        .withLatestFrom(rxUserInfo)
        .flatMapLatest { userInfo -> Observable<Result<Void, Error>> in
            return update(userInfo)
                .map(Result.success)  // 转换成 Result
                .catchError { error in Observable.just(Result.failure(error)) }
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { result in
            switch result {           // 处理 Result
            case .success:
                print("用户信息更新成功")
            case .failure(let error):
                print("用户信息更新失败:  \(error.localizedDescription)")
            }
        })
        .disposed(by: disposeBag)
    // 这样我们的错误事件被包装成了 Result.failure(Error) 元素, 就不会终止整个序列.
    // 即便网络请求失败了, 整个订阅依然存在. 如果用户再次点击更新按钮, 也是能够发起网络请求进行更新操作的.
    ```

### RxRelay

PublishSubject 与 BehaviorSubject 既是可监听序列, 也是观察者, 但是他们在接收到 error 或 complete 时就会终止, 这有时不符合我们的使用习惯, 因此有了 PublishRelay 与 BehaviorRelay, 这两个就是 PublishSubject 与 BehaviorSubject 去掉 onError 与 onCompleted 后的产物, 其余特性基本一模一样

```swift
let disposeBag = DisposeBag()
let relay = PublishRelay<String>()

relay
    .subscribe { print("Event:", $0) }
    .disposed(by: disposeBag)

relay.accept("🐶")
relay.accept("🐱")

// 输出
// Event: next(🐶)
// Event: next(🐱)
```

## RxSwift 能做到的

1. Target Action

    ```swift
    //=============   传统   =============
    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

    func buttonTapped() {
        print("button Tapped")
    }

    //=============   RxSwift   =============
    button.rx.tap
        .subscribe(onNext: {
            print("button Tapped")
        })
        .disposed(by: disposeBag)
    ```

2. 代理

    ```swift
    //=============   传统   =============
    class ViewController: UIViewController {

        override func viewDidLoad() {
            super.viewDidLoad()
            scrollView.delegate = self
        }
    }

    extension ViewController: UIScrollViewDelegate {
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            print("contentOffset: \(scrollView.contentOffset)")
        }
    }
    //=============   RxSwift   =============
    class ViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()

            scrollView.rx.contentOffset
                .subscribe(onNext: { contentOffset in
                    print("contentOffset: \(contentOffset)")
                })
                .disposed(by: disposeBag)
        }
    }
    ```

3. 闭包回调

    ```swift
    //=============   传统   =============
    URLSession.shared.dataTask(with: URLRequest(url: url)) {
    (data, response, error) in
        guard error == nil else {
            print("Data Task Error: \(error!)")
            return
    }

    guard let data = data else {
        print("Data Task Error: unknown")
        return
    }

    print("Data Task Success with count: \(data.count)")
    }.resume()

    //=============   RxSwift   =============
    URLSession.shared.rx.data(request: URLRequest(url: url))
        .subscribe(onNext: { data in
            print("Data Task Success with count: \(data.count)")
        }, onError: { error in
            print("Data Task Error: \(error)")
        })
        .disposed(by: disposeBag)
    ```

4. 通知

    ```swift
    //=============   传统   =============
    var ntfObserver: NSObjectProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        ntfObserver = NotificationCenter.default.addObserver(
            forName: .UIApplicationWillEnterForeground,
            object: nil, queue: nil) { (notification) in
            print("Application Will Enter Foreground")
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(ntfObserver)
    }

    //=============   RxSwift   =============
    override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.rx
        .notification(.UIApplicationWillEnterForeground)
        .subscribe(onNext: { (notification) in
            print("Application Will Enter Foreground")
        })
        .disposed(by: disposeBag)
    }
    ```

5. 多个任务间依赖关系

    ```swift
    //=============   传统   =============
    /// 用回调的方式封装接口
    enum API {

        /// 通过用户名密码取得一个 token
        static func token(username: String, password: String,
            success: (String) -> Void,
            failure: (Error) -> Void) { ... }

        /// 通过 token 取得用户信息
        static func userinfo(token: String,
            success: (UserInfo) -> Void,
            failure: (Error) -> Void) { ... }
    }

    //=============   RxSwift   =============
    API.token(username: "beeth0ven", password: "987654321",
        success: { token in
            API.userInfo(token: token,
                success: { userInfo in
                    print("获取用户信息成功: \(userInfo)")
                },
                failure: { error in
                    print("获取用户信息失败: \(error)")
            })
        },
        failure: { error in
            print("获取用户信息失败: \(error)")
    })
    ```

6. 等待多个并发任务完成后处理结果

    ```swift
    enum API {

        /// 通过用户名密码取得一个 token
        static func token(username: String, password: String) -> Observable<String> { ... }

        /// 通过 token 取得用户信息
        static func userInfo(token: String) -> Observable<UserInfo> { ... }
    }

    //=============   RxSwift   =============
    API.token(username: "beeth0ven", password: "987654321")
        .flatMapLatest(API.userInfo)
        .subscribe(onNext: { userInfo in
            print("获取用户信息成功: \(userInfo)")
        }, onError: { error in
            print("获取用户信息失败: \(error)")
        })
        .disposed(by: disposeBag)
    ```

## RxSwift 范例

1. 绑定可监听序列 (image) 到观察者 (imageView.rx.image) 上

    ```swift
    let image: UIImage = UIImage(named: ...)
    imageView.image = image

    let image: Observable<UIImage> = ...
    image.bind(to: imageView.rx.image)"
    ```

    在这个范例中, 第一个是我们最熟悉的, 含义就是将一个单独的图片设置到 `imageView` 上; 第二个则是一个典型的 `RxSwift` 范例, 它的含义是将一个序列
    (`image`)"同步"到观察者 (`imageView.rx.image`) 上

## 参考

- [RxSwift 中文文档](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/)
- [RxSwift 操作符可视化](https://rxmarbles.com/)
- [RxSwift 官方英文文档](http://reactivex.io/documentation/operators.html)
