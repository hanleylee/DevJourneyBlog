---
title: 使用 Swift Package Manager 作为你的算法游乐场
date: 2023-07-28
comments: true
urlname: make-algorithm-playground-with-spm
tags: ⦿algorithm, ⦿spm, ⦿swift, ⦿xcode
updated:
---

给大家分享一个我最近琢磨出来的适合 iOS/Mac 开发工程师的算法刷题方式

github: <https://github.com/hanleylee/algorithm> 🥰

![himg](https://a.hanleylee.com/HKMS/2023-07-28215303.gif)

<!-- more -->

## 我用过的刷题工具

刷算法题是程序员找工作前的一个重要流程了, 我刷算法题的时候不喜欢在 Leetcode 的代码编辑器中直接写答案, 我觉得能本地保存下来题解代码, 可以随时复习才是更好的. 和我一样想法的人不在少数, 在网上搜到了很多本地生成题目的工具, 我尝试过以下这些:

- <https://github.com/skygragon/leetcode-cli>
- <https://github.com/dragfire/leetup>
- <https://github.com/clearloop/leetcode-cli>

这些工具的思想都是通过在终端通过命令将相应题目生成到本地文件, 然后在本地编写题解代码. 用户可以将生成的题目文件放入 git 仓库中进行管理 -- 以前的我就是这样用 Vim 一道一道刷算法题的

## 用熟悉的工具打造适合自己的刷题工具

最近工资不景气, 又要出来准备面试了, 在复习专业知识的同时, 算法也是一个重点复习项目, 我想这次能不能使用我最熟悉的语言 Swift + 我最熟悉的编译器 Xcode 进行刷题呢?

我继续分析我需要的功能:

1. 可以快速本地运行验证题目答案
2. 可以将 `ListNode`, `TreeNode` 这些代码定义在公共位置处, 不需要每个题解文件中再重复定义
3. 能够有良好的代码提示功能 & 警告功能, 本地运行无误后可以直接将代码复制粘贴到 Leetcode 上直接提交

经过这样分析, 我发现使用 `XCTest` 的单元测试功能可以很好地满足我第一点需求, 定义公共库可以满足我第二点需求, 第三点需求 Xcode 默认就能满足. 那么该怎么把代码运行起来呢? 通过传统 Xcode 工程的方式吗? 说实话我挺不喜欢 Xcode 管理工程时使用的 `.xcodeproj` 项目文件的, 而且本地直接创建的文件如果不拖动到工程中, 也不能被自动识别. 相对而言我更加喜欢完全基于文本配置文件的工程.

我想到了 Swift Package Manager(以下均简称 SPM), 这个 Apple 官方出品的包管理器其实不仅仅是一个包管理器, 它还可以直接编译运行一些命令行工程, 甚至也直接支持运行单元测试, 其配置仅为一个 `Package.swift` 文件. 我可以在其中添加一个 `CommonCode Target`, 然后再创建一个 `Test Target`, 这样我们就可以在 `CommomCode Target` 中放置公共代码, 然后将题解代码放到 `Test Target` 中了, 具体的配置如下:

```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "CSAlgorithm",
    platforms: [
        .macOS(.v12),
//        .iOS(.v11)
    ],
    products: [
        .library(name: "CSAlgorithm", targets: ["CSAlgorithm"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CSAlgorithm",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CSAlgorithmTests",
            dependencies: ["CSAlgorithm"],
            path: "Tests"
        ),
    ]
)
```

如上, 我们定义了 `CSAlgorithm` Target, 这个是用来放一些公共代码的; 又定义了 `CSAlgorithmTests` 这个 `testTarget`, 这个是用来放题解代码的

实际上, 只需要上面这个 `Package.swift` 文件, 另外创建出来 `Sources` 与 `Tests` 两个文件夹, 我们的刷题框架就搭建好了, SPM 就是这么简单优雅

## 如何使用

### 创建题解

以我们现在要解 Leetcode [第 1 题](https://leetcode.cn/problems/two-sum/) 为例, 我们在 `Tests` 文件夹中新建 `0001_two_sum.swift` 文件, 然后将题解模板复制到该文件中, 再添加测试用例代码, 完整代码文件如下:

```swift
import XCTest

private class Solution {
    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
        for i in 0 ..< nums.count - 1 {
            for j in (i + 1) ..< nums.count {
                let res = nums[i] + nums[j]
                if res == target {
                    return [i, j]
                }
            }
        }
        return []
    }

    func twoSum2(_ nums: [Int], _ target: Int) -> [Int] {
        var dic: [Int: Int] = [:]

        for i in 0 ..< nums.count {
            let diff = target - nums[i]

            if let j = dic[diff] {
                return [i, j]
            } else {
                dic[nums[i]] = i
            }
        }

        return []
    }
}

class TestSolution0001: XCTestCase {
    func test1() {
        let sol = Solution()
        XCTAssertEqual(sol.twoSum([2, 7, 11, 15], 9), [0, 1])
        XCTAssertEqual(sol.twoSum([3, 2, 4], 6), [1, 2])
        XCTAssertEqual(sol.twoSum([3, 3], 6), [0, 1])
    }

    func test2() {
        let sol = Solution()
        XCTAssertEqual(sol.twoSum2([2, 7, 11, 15], 9).sorted(), [0, 1])
        XCTAssertEqual(sol.twoSum2([3, 2, 4], 6).sorted(), [1, 2])
        XCTAssertEqual(sol.twoSum2([3, 3], 6).sorted(), [0, 1])
    }
}
```

然后我们点击测试用例旁的 `Run` 按钮, 就能立即验证我们的解法是否正确

![himg](https://a.hanleylee.com/HKMS/2023-07-28234949.png?x-oss-process=style/WaMa)

> 需要注意一点是我们在 `class Solution` 的前面加上了 `private` 关键字, 这保证了该 class 仅在当前文件内可访问, 避免多个题解的 `Solution` 产生编译冲突

### 定义公共类型

如果我们想定义一个公共的 `ListNode` 或 `TreeNode`, 该写在哪里呢? 直接在 `CSAlgorithm` Target 指定的 `Sources` 文件夹中写就好了. 以定义 `ListNode` 为例:

![himg](https://a.hanleylee.com/HKMS/2023-07-28225622.png?x-oss-process=style/WaMa)

然后我们在需要的题解处怎样去使用? 步骤如下:

1. 在文件开头 `import CSAlgorithm`
2. 因为我们使用泛型定义了 `ListNode<T>`, 而 `LeetCode` 上面的定义是 `ListNode(_ val: Int)`, 因此我们需要使用 `private typealias ListNode = CSAlgorithm.ListNode<Int>` 进行一次类型重定向

![himg](https://a.hanleylee.com/HKMS/2023-07-28234143.png?x-oss-process=style/WaMa)

### 为基础类型添加工具方法以方便测试

上面我们定义了 `ListNode` 这个基础类型, 在需要该类型的题目中随时可以使用. 我们还可以在公共代码中为该类型扩展一些有用的方法, 比如根据数组创建链表:

```swift
public extension ListNode {
    static func create(with arr: [T]) -> ListNode? {
        guard !arr.isEmpty else { return nil }
        let res = ListNode(arr.first!)
        var head: ListNode? = res

        for element in arr {
            let node = ListNode(element)
            head?.next = node
            head = head?.next
        }

        return res.next
    }
}
```

再扩展一个字符值方法

```swift
extension ListNode: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node: ListNode? = self
        while let nd = node {
            s += "\(nd.val)"
            node = nd.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}
```

这样我们在测试用例中就可以直接使用了

![himg](https://a.hanleylee.com/HKMS/2023-07-28233908.png?x-oss-process=style/WaMa)

## 总结

以前使用 C艹 做算法题, 总是感觉不那么得心应手, 自从换了这一套 Swift + Xcode 工具流做算法题后, 两个星期已经蹭蹭蹭做了几十道了 😄

总结下来, 这套工具流有以下好处:

- 使用 Swift 语言对 iOS 开发人员友好
- 可以本地通过 TestCase 对当前题目进行快速验证, 通过后再上传 leetcode
- 可以提前定义好各种基础数据结构, 写题解时进行代码提示
- SPM 对本地文件的变动(新建 / 删除 / 修改)实时更新
- 使用 `private` 保证了每个类的可见范围仅为本文件, 这样即使重名也不会冲突
- 使用 `typealias` 包装类型名, 保证了名称与 Leetcode 中的定义一致

## 最后

以上就是我对这套工具流的理解, 如果有看不太懂怎么操作的同学, 可以直接访问我的算法刷题仓库: [algorithm](https://github.com/hanleylee/algorithm)
