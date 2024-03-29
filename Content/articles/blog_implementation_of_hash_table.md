---
title: 哈希函数及哈希表的实现原理
date: 2020-03-04
comments: true
path: implementation-of-a-hash-function
categories: 算法
tags: ⦿hash-map, ⦿hash-function
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-03-05-053457.jpg?x-oss-process=style/WaMa)

<!-- more -->

> 现在, 你有一万部不重复的电影 (重复指的是底层二进制存储完全一致), 现在给你一部新的电影, 如何判断这部电影是否已经包含在已有的一万部电影里面了? 答案就是对每一部电影提取出哈希值, 使用哈希值进行比对以判断是否重复.

## 哈希函数特点

- 易压缩: 对于任意大小的输入, 哈希值长度均是固定且很短的
- 易计算: 计算哈希值速度快, 容易
- 对于哈希值的结果 `R` 来说, 不能反推出原始值 `O`, 这是安全性的基础
- 抗碰撞性: 理想的哈希函数是无碰撞的, 不过实际设计中很难做到这一点 (碰撞性就是对于结果 `456` 来说只能有原始值 `123`, 不能再有任意其他的原始值可得出结果 `456` )

## 哈希运算的应用

- Swift 的 `==` 运算符即对哈希值进行比对, 只要哈希值相同则相同 (objc 不太一样, objc 是对内存进行比对, 哪怕 `a` 与 `b` 都是 1, 但是 `a == b` 返回值也是 `false` )
- 向 `sets` 中添加新元素时, `sets` 通过哈希运算确定是否已经包含新元素, 如果包含的话则不执行 `append` 动作
- 对哈希表中的 `key` 进行哈希运算, 得出哈希值然后将 `value` 放到哈希值指定的地方 (考虑到哈希值可能为负以及过大, 因此要先取绝对值然后使用数组元素数取余)
- 大文件哈希运算出哈希值, 方便比对或校验

## 哈希表的具体实现

哈希表其实就是两个数组, 一个是存 `key`, 一个是存 `value`, 在其实现过程中的主要技术就是哈希函数与链表, 因此成为哈希表.

比如有一组 `key` 与 `value`: `["a": "b"]`, 我们要存进哈希表中, 步骤如下:

1. 我们首先输入 `a`, 哈希表将 `a` 进行哈希运算, 得到哈希值, 将此值进行绝对值, 以数组元素数进行取余 (这样可以保证 `value` 数组是连续的, 否则会产生越界现象) 得到结果 `r`
2. 在 value 数组中定位到第 `r` 个元素, 将 `["a": "b"]` 存储到第 r 个数组元素下方的那一条链表尾部 (在向链表尾部前进的过程中, 检查所有链表节点的值, 如果有节点的 `key` 为 `a`, 则直接更新此节点的 `value` 为 `b` )
3. 结束

当我们要查询 `key` 为 `FIRSTNAME` 的对应 `value` 时:

1. 对 `FIRSTNAME` 进行哈希运算, 得到哈希值,  将此值进行绝对值, 以数组元素数进行取余, 得到结果 2
2. 找到 `value` 数组第 2 个元素, 在其链表中逐个遍历 `key` 为 `FIRSTNAME` 的元素, 直至遍历成功或结束

    ![himg](https://a.hanleylee.com/HKMS/2020-03-05-053702.jpg?x-oss-process=style/WaMa)

3. 返回遍历结果, 结束

## 哈希函数的实现原理

哈希函数的实现原理是不可逆加密, 即在运算的过程中主动丢失了一些信息, 这样的话是很难再通过结果反算回来的. 一个简单的例子如下 (原始值为 `A`, 结果为 `E`):

1. `A + 123 = B`
2. `B^2 = C`
3. 取 `C` 中第 2~4 位数, 组成一个 3 位数 `D`
4. `D/12` 的结果求余数, 得到 `E`

> 自 Xcode 9 之后, 每次运行均会生成一个新的哈希 seed, 这导致了每次运行 1.hashValue 都不相同 (同一次内的 1.hashValue 运算结果还是相同的), 这样是为了避免碰撞.
