---
title: 我的 Swift 代码书写规范
date: 2020-01-05
comments: true
path: personal-swift-code-writing-standard
categories: iOS
tags: ⦿swift, ⦿code-guideline
updated:
---

目前使用 swift 开发 iOS App 也有一段时间了, 为了让自己的代码更统一, 更美观, 我在参考他人代码的基础上制定了一套适合我自己的 Swift 代码书写规范.

![himg](https://a.hanleylee.com/HKMS/2020-01-19-112432.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 代码书写原则

- `Swift`语言应符合美式英语习惯
- 类, 函数等, 左大括号不另一起行, 并且跟前面留有空格
- 函数, 类中间要空一行
- 代码逻辑不同块之间, 要空一行
- 注释符号, 与注释内容之间加空格
- 类继承, 参数名和类型之间等, 冒号前面不加空格, 但后面跟空格
- 自定义操作符, 声明及实现, 两边都要有空格隔开
- if 后面的 else, 跟着上一个 if 的右括号
- `switch`中, `case`跟`switch`左对齐
- 函数体长度不超过 200 行
- 单行不能超过 200 个字符
- 单类体长度不超过 300 行
- 实现每个协议时, 在单独的 extension 里来实现
- 闭包中的单表达式, 省略 return
- 简单闭包, 写在同一行
- 尾随闭包, 在单闭包参数时才使用
- 过滤, 转换等, 优先使用 filter, map 等高阶函数简化代码
- 使用 `[weak self]` 修饰的闭包, 闭包开始判断 self 的有效性
- 能推断出来的类型, 不需要加类型限定
- 单行注释, 优先使用 //
- 异常的分支, 提前用 guard 结束.
- 多个嵌套条件, 能合并的, 就合并到一个 if 中
- 尽可能使用 private, fileprivate 来限制作用域
- 尽可能使用 private, fileprivate 来限制作用域
- 不使用强制解包
- 不使用强制类型转换
- 不使用 try!
- 不使用隐式解包
- 无用的代码(包括官方的模板注释)都需要删除, 对代码的注释除外
- 等号两端有空格;
- 代码尽可能自注释;
- 尽量使用语法糖
- 每个文件都以一个新的空行结束, 即回车
- 任何地方都不能以空格结尾
- 方法间有空的一行
- 花括号的左括号与方法体在同一行, 右括号在新的一行
- 冒号前面无空格, 后面有一个空格, 三目运算符? : 除外和空字典 `[:]` 除外
- 逗号前面无空格, 后面有一个空格
- 二元三元运算符的前后都有一个空格
- (的右面和)的左面不能有空格
- 类型名字使用 Pascal 命名法(大驼峰命名法), 比如 protocols, struct, enum, class, typedef, associatedtype 等
- 函数, 方法, 属性, 常量, 变量, 参数, 枚举值等使用 camel 命名法(小驼峰命名法)
- 尽量避免简称或缩略词, 通用缩略词应整体大写
- 初始化方法中必须要使用 self, 或属性名相同时使用 self, 仅此两种情况
- 注释全部使用 // 方法,  // 后必须跟着一个空格, 且注释要单独放在一个行中
- 尽一切可能使用类型推断以减少冗余类型信息
- 声明一个变量可以为 nil 时使用? , 当确定一个变量不是 nil 时在后面加！
- 用 //MARK: - 的方法将同类放到一起, 比如动作方法放在一起, 便于理解, 增加代码可读性.

## Swift 代码命名规范

### 变量, 常量

- 小驼峰命名
- `名词` + `名词` + `名词` + `...`
- 不能有动词
- `Rx` 中的监听序列使用 `动词` + `名词` + `Subject` 的形式命名
- `UI` 控件使用 `Lb`, `Btn`, `View` 等结尾

案例:

- `let maximumWidgetCount = 100`
- `let urlString: URLString`
- `let userID: UserID`
- `var deleteStockSubject = PublishSubject<StockModel>()`

### 方法

- 小驼峰命名
- `动词` + `名词` + [`介词`]
- 使用全称, 避免使用缩写

案例:

- `printError(myError)`
- `removeObject(object, atIndex: index)`
- `setBackgroundImage(myImage)`
- `func getDateFromString(dateString: String) -> NSDate`
- `func convertPointAt(column column: Int, row: Int) -> CGPoint`

### 类, 结构体

- 大驼峰命名
- `名词`

### 枚举

```swift
enum Shape {
    case rectangle
    case square
    case rightTriangle
    case equilateralTriangle
}
```

## 相关常用的方法命名实例

### 返回真伪值的方法

| 位置   | 单词   | 意义                                                                            | 例            |
| ------ | ------ | ------------------------------------------------------------------------------- | ------------- |
| Prefix | is     | 对象是否符合期待的状态                                                          | isValid       |
| Prefix | can    | 对象**能否执行**所期待的动作                                                    | canRemove     |
| Prefix | should | 调用方执行某个命令或方法是**好还是不好**,**应不应该**, 或者说**推荐还是不推荐** | shouldMigrate |
| Prefix | has    | 对象**是否持有**所期待的数据和属性                                              | hasObservers  |
| Prefix | needs  | 调用方**是否需要**执行某个命令或方法                                            | needsMigrate  |

### 用来检查的方法

| 单词     | 意义                                                 | 例             |
| -------- | ---------------------------------------------------- | -------------- |
| ensure   | 检查是否为期待的状态, 不是则抛出异常或返回error code | ensureCapacity |
| validate | 检查是否为正确的状态, 不是则抛出异常或返回error code | validateInputs |

### 按需求才执行的方法

| 位置   | 单词      | 意义                                      | 例                     |
| ------ | --------- | ----------------------------------------- | ---------------------- |
| Suffix | IfNeeded  | 需要的时候执行, 不需要的时候什么都不做    | drawIfNeeded           |
| Prefix | might     | 同上                                      | mightCreate            |
| Prefix | try       | 尝试执行, 失败时抛出异常或是返回errorcode | tryCreate              |
| Suffix | OrDefault | 尝试执行, 失败时返回默认值                | getOrDefault           |
| Suffix | OrElse    | 尝试执行, 失败时返回实际参数中指定的值    | getOrElse              |
| Prefix | force     | 强制尝试执行. error抛出异常或是返回值     | forceCreate, forceStop |

### 异步相关方法

| 位置            | 单词         | 意义                                       | 例                    |
| --------------- | ------------ | ------------------------------------------ | --------------------- |
| Prefix          | blocking     | 线程阻塞方法                               | blockingGetUser       |
| Suffix          | InBackground | 执行在后台的线程                           | doInBackground        |
| Suffix          | Async        | 异步方法                                   | sendAsync             |
| Suffix          | Sync         | 对应已有异步方法的同步方法                 | sendSync              |
| Prefix or Alone | schedule     | Job和Task放入队列                          | schedule, scheduleJob |
| Prefix or Alone | post         | 同上                                       | postJob               |
| Prefix or Alone | execute      | 执行异步方法(注: 我一般拿这个做同步方法名) | execute, executeTask  |
| Prefix or Alone | start        | 同上                                       | start, startJob       |
| Prefix or Alone | cancel       | 停止异步方法                               | cancel, cancelJob     |
| Prefix or Alone | stop         | 同上                                       | stop, stopJob         |

### 回调方法

| 位置   | 单词   | 意义                       | 例           |
| ------ | ------ | -------------------------- | ------------ |
| Prefix | on     | 事件发生时执行             | onCompleted  |
| Prefix | before | 事件发生前执行             | beforeUpdate |
| Prefix | pre    | 同上                       | preUpdate    |
| Prefix | will   | 同上                       | willUpdate   |
| Prefix | after  | 事件发生后执行             | afterUpdate  |
| Prefix | post   | 同上                       | postUpdate   |
| Prefix | did    | 同上                       | didUpdate    |
| Prefix | should | 确认事件是否可以发生时执行 | shouldUpdate |

### 操作对象生命周期的方法

| 单词       | 意义                           | 例              |
| ---------- | ------------------------------ | --------------- |
| initialize | 初始化. 也可作为延迟初始化使用 | initialize      |
| pause      | 暂停                           | onPause , pause |
| stop       | 停止                           | onStop, stop    |
| abandon    | 销毁的替代                     | abandon         |
| destroy    | 同上                           | destroy         |
| dispose    | 同上                           | dispose         |

### 与集合操作相关的方法

| 单词     | 意义                         | 例         |
| -------- | ---------------------------- | ---------- |
| contains | 是否持有与指定对象相同的对象 | contains   |
| add      | 添加                         | addJob     |
| append   | 添加                         | appendJob  |
| insert   | 插入到下标n                  | insertJob  |
| put      | 添加与key对应的元素          | putJob     |
| remove   | 移除元素                     | removeJob  |
| enqueue  | 添加到队列的最末位           | enqueueJob |
| dequeue  | 从队列中头部取出并移除       | dequeueJob |
| push     | 添加到栈头                   | pushJob    |
| pop      | 从栈头取出并移除             | popJob     |
| peek     | 从栈头取出但不移除           | peekJob    |
| find     | 寻找符合条件的某物           | findById   |

### 与数据相关的方法

| 单词   | 意义                                   | 例            |
| ------ | -------------------------------------- | ------------- |
| create | 新创建                                 | createAccount |
| new    | 新创建                                 | newAccount    |
| from   | 从既有的某物新建, 或是从其他的数据新建 | fromConfig    |
| to     | 转换                                   | toString      |
| update | 更新既有某物                           | updateAccount |
| load   | 读取                                   | loadAccount   |
| fetch  | 远程读取                               | fetchAccount  |
| delete | 删除                                   | deleteAccount |
| remove | 删除                                   | removeAccount |
| save   | 保存                                   | saveAccount   |
| store  | 保存                                   | storeAccount  |
| commit | 保存                                   | commitChange  |
| apply  | 保存或应用                             | applyChange   |
| clear  | 清除数据或是恢复到初始状态             | clearAll      |
| reset  | 清除数据或是恢复到初始状态             | resetAll      |

## 命名中常用的单词

| 单词        | 意义   |
| ----------- | ------ |
| get         | 获取   |
| set         | 设置   |
| add         | 增加   |
| remove      | 删除   |
| create      | 创建   |
| destory     | 移除   |
| start       | 启动   |
| stop        | 停止   |
| open        | 打开   |
| close       | 关闭   |
| read        | 读取   |
| write       | 写入   |
| load        | 载入   |
| save        | 保存   |
| create      | 创建   |
| destroy     | 销毁   |
| begin       | 开始   |
| end         | 结束   |
| backup      | 备份   |
| restore     | 恢复   |
| import      | 导入   |
| export      | 导出   |
| split       | 分割   |
| merge       | 合并   |
| inject      | 注入   |
| extract     | 提取   |
| attach      | 附着   |
| detach      | 脱离   |
| bind        | 绑定   |
| separate    | 分离   |
| view        | 查看   |
| browse      | 浏览   |
| edit        | 编辑   |
| modify      | 修改   |
| select      | 选取   |
| mark        | 标记   |
| copy        | 复制   |
| paste       | 粘贴   |
| undo        | 撤销   |
| redo        | 重做   |
| insert      | 插入   |
| delete      | 移除   |
| add         | 加入   |
| append      | 添加   |
| clean       | 清理   |
| clear       | 清除   |
| index       | 索引   |
| sort        | 排序   |
| find        | 查找   |
| search      | 搜索   |
| increase    | 增加   |
| decrease    | 减少   |
| play        | 播放   |
| pause       | 暂停   |
| launch      | 启动   |
| run         | 运行   |
| compile     | 编译   |
| execute     | 执行   |
| debug       | 调试   |
| trace       | 跟踪   |
| observe     | 观察   |
| listen      | 监听   |
| build       | 构建   |
| publish     | 发布   |
| input       | 输入   |
| output      | 输出   |
| encode      | 编码   |
| decode      | 解码   |
| encrypt     | 加密   |
| decrypt     | 解密   |
| compress    | 压缩   |
| decompress  | 解压缩 |
| pack        | 打包   |
| unpack      | 解包   |
| parse       | 解析   |
| emit        | 生成   |
| connect     | 连接   |
| disconnect  | 断开   |
| send        | 发送   |
| receive     | 接收   |
| download    | 下载   |
| upload      | 上传   |
| refresh     | 刷新   |
| synchronize | 同步   |
| update      | 更新   |
| revert      | 复原   |
| lock        | 锁定   |
| unlock      | 解锁   |
| checkout    | 签出   |
| checkin     | 签入   |
| submit      | 提交   |
| commit      | 交付   |
| push        | 推     |
| pull        | 拉     |
| expand      | 展开   |
| collapse    | 折叠   |
| begin       | 起始   |
| end         | 结束   |
| start       | 开始   |
| finish      | 完成   |
| enter       | 进入   |
| exit        | 退出   |
| abort       | 放弃   |
| quit        | 离开   |
| obsolete    | 废弃   |
| depreciate  | 废旧   |
| collect     | 收集   |
| aggregate   | 聚集   |

## Swift 代码分区书写规范

- `// MARK: - 123` 此为标记(特殊的注释), 前面的一个 - 可以在 JumpBar 中显示加粗分割线. 与此相类似的还有 `// TODO:` 和 `// FIXME:` ,`TODO`表示代码还需完善, `FIXME`表示将相关代码标记, 以便重新或修复 bug.
- 大驼峰, 每一个单词的首字母都大写, 例如: `AnamialZoo`, `JavaScript`中构造函数用的是大驼峰式写法; 小驼峰, 第一个单词的首字母小写, 后面的单词的首字母全部大写, 例如: `fontSize`, `backgroundColor`.
- class 中书写顺序:

    ```swift
    // MARK: - IBOutlet
    @IBOutlet var ...

    // MARK: - Variable
    var ...

    // MARK: - Life Cycle
    func viewDidLoad()
    func viewWillAppear(_ animated: Bool)
    func viewDidAppear(_ animated: Bool)
    func viewWillDisappear(_ animated: Bool)
    func viewDidDisappear(_ animated: Bool)

    // MARK: - Customize Method
    func ...

    // MARK: - IBAction
    @IBAction func ...
    ```

## Swift 文档注释规范

### 单行注释

光标放在需要注释的变量上按下组合键 `⌥ ⌘ /` 即可自动生成

```swift
/// 为变量进行单行注释
let str = "hanleylee.com"
```

### 多行注释

#### 一般注释

光标放在需要注释的变量上按下组合键 `⌥ ⌘ /` 即可自动生成

```swift
/// 对菜单进行排序, swift 中默认是常量, 因为需要使用变量要使用 inout 关键字
/// - Parameters:
///   - foo: 传入的 FoodMO 类型数组
///   - property: 按照哪种属性进行排序

/// 可添加详细说明(必须隔一行)
func sortFoodsArray(from foo: inout [FoodMO], by property: String) {
    if property == "foodName" {
        foo.sort { (food1, food2) -> Bool in
            food1.foodName! < food2.foodName!
        }
    } else if property == "selectedTime" {
        foo.sort { (food1, food2) -> Bool in
            food1.selectedTime! > food2.selectedTime!
        }
    }
}
```

#### 使用 Markdown 格式进行多行注释

总的来说, markdown 格式的文档注释结构如下

1. 第一部分(必要!)
    - Summary
2. 第二部分(必要! 系统自动生成)
    - Declaration
3. 第三部分(不必要)
    - Disscussion(默认不需使用关键字声明的)
    - Remark
    - Precondition
    - Requires
    - Todo
    - Warning
    - Version
    - Author
    - Note
    - Important
    - `# Customize Title`(与上面的关键字低一级别, 需放在最后声明)
4. 第四部分(不必要)
    - Parameter
        - Parameter 1:
        - Parameter 2:
    - Return

示例如下:

```swift
/**
 这里是 Summary, 与下方空一行

 现在是 discussion 正文, 下面是 Discussion 部分关键字部分
 - Remark: There's a counterpart function .
    text 内容
    分割线↓
    ---
    分割线↑
 - Precondition: `fullname` should not be nil.
 - Requires: Both first and last name should be parts of the full name.
 - Todo: Support middle name in the next version.
 - Warning: A wonderful **crash** will be the result of a `nil` argument.
 - Version: 1.1
 - Author: Myself Only
 - Note: Too much documentation for such a small function.
 - Important: important
 # Customize Title(与上面的关键字同一级别)

 - Parameter fullname: The fullname that will be broken into its parts.
 - Returns: A *tuple* with the first and last name.
 */

func breakFullName(fullname: String) -> (firstname: String, lastname: String) {
    let fullnameInPieces = fullname.componentsSeparatedByString(" ")
    return (fullnameInPieces[0], fullnameInPieces[1])
}
```

## 使用 Jazzy 导出文档注释

Jazzy 让你可以通过命令行将工程中的所有文档注释导出为一个可离线浏览的网页.

### 安装

```bash
[sudo] gem install jazzy
```

### 使用

1. cd 至工程所在目录
2. 使用命令`jazzy`导出文档注释, 默认只会导出使用 public 及以上级别修饰的方法和属性的文档注释. 如果需要导出全部则使用 `jazzy --min-acl internal`

### 常用命令

- `jazzy`: 导出 public 及以上权限级别的文档注释
- `jazzy --min-acl internal`: 导出最小权限级别为 `internal` 的文档注释
- `jazzy -help`: 查看 jazzy 所有可用命令

## Swift 文档批注规范

### 非渲染型文档批注

### 多行批注

```swift
/*

*/
```

### 单行批注

```swift
//
```

### 渲染型文档批注(Playground 中使用)

#### 多行可渲染文档批注

playground 中可以进行多行批注(并不是文档注释), 使用方法与 markdown 文档书写方式相同, 具体如下

```swift
/*:
# Summary

## Example

- Example:

    第一行

    第二行

```

也可用代码格式实现多行 Example
第一行
第二行

## Official Link

 <https://leetcode-cn.com/problems/reverse-integer>

## Other

- Experiment:
- callout(Checkpoint):
- Note:
- Important:

### 单行可渲染文档批注

```swift
//: # 一级标题
//: 一般文本
//: - Note:
//: - Example:
//: callout(Checkpoint)
//: - Important:
```

## 参考

- [告别编码5分钟，命名2小时！史上最全的Java命名规范参考！](https://www.cnblogs.com/liqiangchn/p/12000361.html)
