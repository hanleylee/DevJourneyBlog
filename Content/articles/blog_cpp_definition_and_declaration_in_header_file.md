---
title: C++ 之头文件声明定义
date: 2021-05-17
comments: true
path: header-file-and-declaration-definition-of-c++
categories: Language
tags: ⦿c/cpp, ⦿header, ⦿declaration, ⦿definition
updated:
---

![himg](https://a.hanleylee.com/HKMS/2021-05-17233909.jpg?x-oss-process=style/WaMa)

最近在学习 `c++`, 在编译与链接过程中遇到了一些定义与声明的问题, 经过多处查阅资料, 基本解惑. 现记录与此, 希望让后面人少走些弯路.

<!-- more -->

## `C++` 的头文件应该用什么扩展名?

目前业界的常用格式如下:

- `implementation file`
    - `*.cpp`
    - `*.cc`
    - `*.cc`
    - `*.c`
- `header file`
    - `*.hpp`
    - `*.h++`
    - `*.hh`
    - `*.hxx`
    - `*.h`

一句话: 建议 **源文件使用 `.cpp`, 头文件使用 `.hpp`**

关于 `implementation file` 并没有什么说的, 使用 `.cpp`/`.cc` 都是可以的. 但是 `header file` 需要注意.

c 的头文件格式是 `.h`, 认为 `h` 代表 `header`, 于是有很多人也喜欢在 c++ 用 `.h` 作为头文件扩展名. 其实扩展名并不影响编译结果, 对于编译器来说扩展名是不重要的 (甚至使用 `.txt` 也可以). 但是如果在一个 `c` 与 `c++` 混合使用的大型项目中, 你很难立刻分辨出这是一个 `cpp` 的 `header file` 或者是一个 `c` 的`header file`; 此外, 在 `vim` 或者 `vscode` 的语法提示插件看来, `.h` 就是 c 语言的, 那么当你在 c 文件写了 cpp 的某些语法当然会提示不正确 (当然肯定还是可以编译通过的)

因此, 我认为最好的处理结果就是如果 `header file` 中涉及到了任何 `c++` 的语法, 那么这个头文件就应该以 `.hpp` 为后缀, 否则都已 `.h` 为后缀

## `implementation file` 与 `header file` 写什么内容

理论上来说 `implementation file` 与 `header file` 里的内容, 只要是 c++ 语言所支持的, 无论写什么都可以的, 比如你在 `header file` 中写函数体, 只要在任何一个 `implementation file` 包含此 `header file` 就可以将这个函数编译成 `object` 文件的一部分 (编译是以 `implementation file` 为单位的, 如果不在任何 `implementation file` 中包含此 `header file` 的话, 这段代码就形同虚设), 你可以在 `implementation file` 中进行函数声明, 变量声明, 结构体声明, 这也不成问题!!!

那为何一定要分成 `header file` 与 `implementation file` 呢? 为何一般都在 `header file` 中进行函数, 变量声明, 宏声明, 结构体声明呢? 而在 `implementation file` 中去进行变量定义, 函数实现呢?

原因如下:  

1. 如果在 `header file` 中实现一个函数体, 那么如果在多个 `implementation file` 中引用它, 而且又同时编译多个 `implementation file`, 将其生成的 `object file` 连接成一个可执行文件, 在每个引用此 `header file` 的 `implementation file` 所生成的 `object file` 中, 都有一份这个函数的代码, 如果这段函数又没有定义成局部函数, 那么在连接时, 就会发现多个相同的函数, 就会报错.
2. 如果在 `header file` 中定义全局变量, 并且将此全局变量赋初值, 那么在多个引用此 `header file` 的 `implementation file` 中同样存在相同变量名的拷贝, 关键是此变量被赋了初值, 所以编译器就会将此变量放入 `DATA 段`, 最终在连接阶段, 会在 `DATA 段` 中存在多个相同的变量, 它无法将这些变量统一成一个变量, 也就是仅为此变量分配一个空间, 而不是多份空间, 假定这个变量在 `header file` 中没有赋初值, 编译器就会将之放入 `BSS 段`, 连接器会对 `BSS 段` 的多个同名变量仅分配一个存储空间.
3. 如果在 `implementation file` 中声明宏, 结构体, 函数等, 那么如果要在另一个 `implementation file` 中引用相应的宏, 结构体, 就必须再做一次重复的工作, 如果我改了一个 `implementation file` 中的一个声明, 那么又忘了改其它 `implementation file` 中的声明, 这不就出了大问题了, 如果把这些公共的东西放在一个头文件中, 想用它的 `implementation file` 就只需要引用一个就 OK 了!
4. 在 `header file` 中声明结构体, 函数等, 当你需要将你的代码封装成一个库, 让别人来用你的代码, 你又不想公布源码, 那么人家如何利用你的库中的各个函数呢?  ? 一种方法是公布源码, 别人想怎么用就怎么用, 另一种是提供 `header file`, 别人从 `header file` 中看你的函数原型, 这样人家才知道如何调用你写的函数, 就如同你调用 `printf` 函数一样, 里面的参数是怎样的? 你是怎么知道的? 还不是看人家的头文件中的相关声明!

## 头文件如何来关联源文件

已知 `header file` `a.h` 声明了一系列函数 (仅有函数原型, 没有函数实现), `b.cpp` 中实现了这些函数, 那么如果我想在 `c.cpp` 中使用 `a.h` 中声明的这些在 `b.cpp` 中实现的函数, 通常都是在 `c.cpp` 中使用 `#include "a.h"`, 那么 `c.cpp` 是怎样找到 `b.cpp` 中的实现呢?  

编译器预处理时, 要对 `#include` 命令进行 **文件包含处理**: 将 `a.h` 的全部内容复制到`#include "a.h"` 处. 这也正说明了, 为什么很多编译器并不 care 到底这个文件的后缀名是什么 - 因为 `#include` 预处理就是完成了一个 **复制并插入代码** 的工作.  

程序编译的时候, 并不会去找 `b.cpp` 文件中的函数实现, 只有在 `link` 的时候才进行这个工作. 我们在 `b.cpp` 或 `c.cpp` 中用 `#include "a.h"` 实际上是引入相关声明, 使得编译可以通过, 程序并不关心实现是在哪里, 是怎么实现的. 源文件编译后成生成 `obj file`, 在此文件中, 这些函数和变量就视作一个个符号. 在 `link` 的时候, 需要在 `makefile` 里面说明需要连接哪个 `obj` 文件 (在这里是 `b.cpp` 生成的 `.obj` 文件), 此时, 连接器会去 `.obj` 文件中找在 `b.cpp` 中实现的函数, 再把他们 `build` 到 `makefile` 中指定的那个可以执行文件中.  

在 `Clion` 中, 一般情况下不需要自己写 `makefile`, 只需要将需要的文件都包括在 project 中, `Clion` 会自动帮你把 makefile 写好.  

通常, 编译器会在每个 `.o` 或 `.obj` 文件中都去找一下所需要的符号, 而不是只在某个文件中找或者说找到一个就不找了. 因此, 如果在几个不同文件中实现了同一个函数, 或者定义了同一个全局变量, 链接的时候就会提示`redefined`.

## 什么是声明? 什么是定义?

- 根据 cpp 标准的规定, 一个变量声明必须满足两个条件, 否则就是定义:
    1. 必须使用 `extern`;
    2. 不能为变量赋予初始值;
- 一个变量 / 函数可以被多处声明, 但是只能定义在一处;

> 是定义还是声明与其位于 `header file` 还是 `implementation file` 无关.

根据以上规定, 我们可以有如下的结论:

```cpp
extern int a; // 声明
int a; // 定义
int a = 0; // 定义
extern int a = 0; // 定义
```

> 许多程序员对定义变量和声明变量混淆不清, 定义变量和声明变量的区别在于定义会产生内存分配的操作, 是汇编阶段的概念; 而声明则只是告诉包含该声明的模块在连接阶段从其它模块寻找外部函数和变量.

## 如何跨文件使用全局变量 / 全局函数?

我们在编译模块中的任意一个文件中书写的变量/函数在此模块中其他文件中都可以被访问到, 但是其他编译模块的文件是没有访问此变量的权限的.  那么如何跨模块共享变量 / 函数呢?

答案就是使用 `extern`. 在这里请在做的各位牢牢记住它的定义: **标示所修饰的变量或函数的可能位于其他模块**.

> 一定要牢牢记住上面的定义, 带着定义我们就可以想明白以下问题
>
> - 为什么在一个 `implementation file` 中使用一个外部变量要先 `extern` 声明该变量 (或者导入该变量所在的 `header file`)?
> - 为什么 `header file` 中要使用 extern 声明一个变量?

### 全局变量

这样当我们编译某个单元时, 编译器发现了使用 `extern` 修饰的变量, 如果正好本模块中有其相关定义, 那么就直接使用; 如果没有相关定义, 那么就挂起, 在编译后续其他模块的时候进行查找, 如果到最后还没有找到, 那么在链接阶段就会报错 `ld: symbol(s) not found for architecture x86_64`;

#### 正确方式

1. 在 `test1.hpp` 中声明 `extern int a;`
2. 在 `test1.cpp` 中定义 `int a = 10;` (或者使用 `int a;` 定义, 这样的话值是默认值 0)
3. 在 `test2.cpp` 中 `#include "test1.hpp"`, 这样便可以在 `test2.cpp` 中直接使用 a 变量了.

#### 错误方式 1

在头文件 `test1.hpp` 中直接 `extern int a = 10;`

这样属于在头文件中直接定义, 我们已经说了 `一个变量可以被多处声明, 但只能定义在一处`, 在这种情况下如果有多个 `implementation file` 都 `#include "test1.hpp"`, 那么会造成在 `obj` 文件的 `链接` 阶段发现多处存在同一个变量的定义, 这时会报错 `ld: 1 duplicate symbol for architecture x86_64`

> 同时, 在头文件中定义一个变量属于非常业余的做法, 请不要争相模仿

#### 错误方式 2

在头文件 `test1.hpp` 中 直接 `extern int a = 10;`, 在 `test2.cpp` 中直接使用 `extern int a;`(没有 `#include test1.hpp`)

这样做可以避免多处重复定义的问题, 但是这样的话 `test1.hpp` 定义的其他变量与方法都不可以使用了, 必须全部使用 `extern ***` 的形式进行声明然后使用, 这样会及其得不偿失.

#### 总结

所以我们可以得出结论:

- 只在头文件中做声明

真理总是这么简单!

### 全局函数

函数与变量类似, 也分为定义与声明. 但是与变量在声明时必须要包含 `extern` 不同, 由于函数的定义和声明是有区别的, 定义函数要有函数体, 声明函数没有函数体, 所以函数定义和声明时都可以将 `extern` 省略掉, 反正其他文件也是知道这个函数是在其他地方定义的, 所以不加 `extern` 也行.

> 所以在 cpp 中, 如果在一个函数前添加了 extern, 那么仅表示此函数可能在别的模块中定义; 或者也可以让我们在只使用了某个头文件的这个方法时不用 `#include
> <***.hpp>`

## `static` 使用

### 当 `static` 用于修饰类中的变量/函数

是一个静态成员变量/函数

- 类加载的时候会分配内存 可以通过类名直接访问

### 当 `static` 用于修饰类之外的变量/函数

是一个普通的全局静态成员变量/函数

- 用于修饰变量时表示其存储在全局(静态)区, 不存储在栈上面; 只对本编译模块有效(即使在外部使用 `extern` 声明也不可以),
- 不是真正意义的全局(普通的函数默认是 `extern` 的) 声明与定义时同时发生的 当局部变量不想在函数结束时被释放的时候可以使用 `static`,
- 比如函数中要返回一个数组, 不想让这个数组函数结束时被释放, 那么可以使用 static 修饰此局部变量

`static` 使变量只在本编译模块内部可见, 这样的话如果两个编译模块各自都有一个 `value` 变量的话, 那么千万不要将两个编译模块内 static 修饰的变量认为是同一份内存, 他们实际上是两份内存, 修改其中一个不会影响另外一个

#### static 针对的作用域是编译模块, 如何理解?

如果一个 `implementation file` 及其所有的 `#include ...` 文件内所组成的一个编译模块中有多个 `static int a = 0`, 那么会报错 `error: redefinition of 'a'` 如果`test.hpp` 有 `static int a = 0`, `test1.cpp` 与 `test2.cpp` 分别都有 `#include "test.hpp"`, 那么这就是两个编译模块各有一个 `static int a`, 这时是 cpp 允许的, 可以顺利通过编译并运行的

## const

当 `const` 单独使用时它就与 `static` 相同, 而当与 `extern` 一起合作的时候, 它的特性就跟 `extern` 的一样了

## ifndef 的使用与意义

`#ifndef` 能保证你的头文件在本编译模块只被编译一次(但是多个模块都编译此段代码的话则还是会有重复代码)

## 总结一些 `头文件` & `声明` & `定义` 的规则

1. `header file` 中是对于该模块接口的声明, 接口包括该模块提供给其它模块调用的外部函数及外部全局变量, 对这些变量和函数都需在 `header file` 中冠以 `extern` 关键字声明
2. 模块内的函数和全局变量需在 `implementation file` 开头冠以 `static` 关键字声明
3. 永远不要在 `header file` 中定义变量
4. 如果要用其它模块定义的变量和函数, 直接 `#include` 其 `header file` 即可.

> 如果工程很大, 头文件很多, 而有几个头文件又是经常要用的, 那么
>
> 1. 把这些头文件全部写到一个 `header file` 里面去, 比如写到 preh.h
> 2. 写一个 `preh.cpp`, 里面只一句话: `#include "preh.h"`
> 3. 对于 `preh.c`, 在 project setting 里面设置 `create precompiled headers`, 对于其他 c++ 文件, 设置 `use precompiled header file`

## 参考

- [extern 与头文件 (*.h) 的区别和联系](https://www.runoob.com/w3cnote/extern-head-h-different.html)
- [理解 C++ 中的头文件和源文件的作用](https://www.runoob.com/w3cnote/cpp-header.html)
- [c++ 多个文件中如何共用一个全局变量](https://www.cnblogs.com/invisible2/p/6905892.html)
