---
title: LLVM 学习
date: 2020-01-05
comments: true
path: llvm-learn
categories: Basic
tags: ⦿blog, ⦿llvm
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-02-29-LLVM.png?x-oss-process=style/WaMa)

LLVM 是一个著名的编译器, 由大神 `Chris Lattner` 开发, 可用于常规编译器, JIT 编译器, 汇编器, 调试器, 静态分析工具等一系列跟编程语言相关的工作.

通常我们所说的 LLVM 并不仅仅是 LLVM, 还包括了实现前端的 Clang/swiftc.

<!-- more -->

> 由于 LLVM 有很多学习的知识点, 本篇文章作为 LLVM 的基础文, 后续的其他 LLVM 相关文章会以本篇文章为基础(模块化思想, 😂)

## LLVM 架构的优点

- 不同的前端后端使用统一的中间代码 `LLVM Intermediate Representation` (LLVM IR)
- 如果需要支持一种新的编程语言, 那么只需要实现一个新的前端 (Swift 就是新增了一个针对于 Swift 的前端)
- 如果需要支持一种新的硬件设备, 那么只需要实现一个新的后端
- 优化阶段是一个通用的阶段, 它针对的是统一的 LLVM IR, 不论是支持新的编程语言, 还是支持新的硬件设备, 都不需要对优化阶段做修改
- LLVM 现在被作为实现各种静态和运行时编译语言的通用基础结构 (GCC 家族, Java,.NET, Python, Ruby, Scheme, Haskell, D 等)

LLVM 架构的目标是可以编译任何代码, 虽然目前还没有达到, 但是这样的架构是极为优秀的,

- 内存占用查询
    - `MemoryLayout<Password>.stride` // 分配占用的内存大小, 40(因为实际用了 33, 最小对齐参数是 8, 因此最接近的数就是 40 了)
    - `MemoryLayout<Password>.size`  //  实际用到的内存大小, 33
    - `MemoryLayout<Password>.alignment`  // 对齐参数, 一般为 1, 2, 4, 8

## LLVM 编译阶段

LLVM 的编译架构分为三个阶段

### 前端

进行语法分析, 语义分析, 生成中间代码.

实际上在 Xcode 中写代码的时候会实时提示错误就是因为持续在调用 LLVM 的前端部分

#### ① Preprocessing

预处理步骤的目的是将你的程序做一些处理然后可提供给编译器. 它会处理宏定义, 发现依赖关系, 解决预处理器指令.

Xcode 解决依赖关系通过底层 llbuild 构建系统. 它是开源的, 你可以在 Github swift-llbuild 页面了解更多信息.

#### ② Lexical Analysis 词法分析

- 词法分析, 也作 Lex 或者 Tokenization
- 将预处理理过的代码⽂文本转化成 Token 流
- 不校验语义

#### ③ Semantic Analysis - 语法分析

- 语法分析, 在 Clang 中由 Parser 和 Sema 两个模块配合完成
- 验证语法是否正确
- 根据当前语⾔言的语法, ⽣生成语意节点, 并将所有节点组合成 抽象语法树 (AST)

#### ④ Static Analysis - 静态分析

- 通过语法树进行代码静态分析, 找出非语法性错误
- 模拟代码执行路径, 分析出 control-flow graph (CFG)【MRC 下会分析出引用计数的错误】
- 预置了常用 Checker(检查器)

#### ⑤ 中间代码生成

- CodeGen 负责将语法树从顶至下遍历, 翻译成 LLVM IR
- LLVM IR 是 Frontend 的输出, 也是 LLVM Backend 的输入, 是前后端的桥接语言
- 与 Objective-C Runtime 桥接

到这一步, *LLVM* 前段编译器 *clang* 的工作已经基本做完了.

### 公用优化器

将生成的中间文件进行优化, 去除冗余代码, 进行结构优化.

#### IR 格式

IR 是 LLVM 前后端的桥接语言, 其主要有三种格式:

- 可读的格式, 以`.ll` 结尾
- Bitcode 格式, 以`.bc` 结尾
- 运行时在内存中的格式

这三种格式完全等价.

### 后端

将优化后的中间代码再次转换, 变为汇编语言, 再次进行优化. 最后将各个文件代码转换为二进制代码 (机器语言) 并链接以生成一个可执行文件.

#### ⑥ Assemble

Assembler 将中间代码转为汇编代码, 然后将汇编代码转为可重定位的机器码, 最终生成包含数据和代码的 *Mach-O 文件*.

机器代码是一种数字语言, 表示一组指令, 可以直接由 CPU 执行. 它被是可重定位的, 因为无论目标文件的地址空间在哪, 它将执行的指令相对地址.

*Mach-O 文件* 是一种特殊的 iOS 和 MacOS 文件格式, 操作系统用它来描述对象文件, 可执行文件和库. 它是一串字节组合形成的有意义的程序块, 将运行在 ARM 处理器上或英特尔处理器.

#### ⑦ Link 生成 Executable 可执行文件

链接器将各种对象文件和库链接合并为一个可以在 iOS 或 macOS 系统上运行的 Mach-O 可执行文件

链接器的作用, 就是完成变量, 函数符号和其地址绑定这样的任务. 例如, 如果在代码中使用 printf, 链接器链接这个符号和 libc 库 printf 函数实现的地方. 通常在编译阶段通过创建符号表来解决不同对象文件和库的引用.

