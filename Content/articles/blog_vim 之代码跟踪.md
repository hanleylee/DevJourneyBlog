---
title: Vim 之代码跟踪
date: 2021-05-19
comments: true
path: tracing-code-in-vim
categories: Terminal
tags: ⦿blog, ⦿vim, ⦿track, ⦿code
updated:
---

这一篇聊聊我们如何通过 `vim` 浏览代码

代码浏览最重要的就是跟踪代码, 跟踪定义, 跟踪声明, 跟踪调用, 跟踪引用...

![himg](https://a.hanleylee.com/HKMS/2021-05-19235557.png?x-oss-process=style/WaMa)

<!-- more -->

vim 的跟踪通常可以通过两种方式实现:

- tags: 通过 `ctags` 工具生成 tags 文件
- cscope 数据库: 通过 `cscope` 或 `gtags-cscope` 生成 cscope 数据库

两种方法各有优缺点, 而且可以搭配使用, 并不冲突. 下面逐个介绍.

## ctags

`ctags` 定义: 产生标记文件以帮助在源文件中定位对象. 包含以下对象:

- `class names`(类名)
- `macro definitions`(宏定义)
- `enumeration names`(枚举名)
- `enumerators`(枚举变量)
- `function definitions`(函数定义)
- `function prototypes`/`declarations`(函数定义 / 声明)
- `class`, `interface`, `struct`, and `union data members`(类, 接口, 结构体, 联合体)
- `structure names`(结构体名)
- `typedefs`(别名)
- `union names`(联合体名)
- `variables` (`definitions` and `external declarations`) 变量

### 安装 ctags

我们一般所说的 ctags 分为两种

- [Exuberant Ctags](http://ctags.sourceforge.net): 这个是正统的 `Ctags`, 但是年久失修, 上一次更新还是 2009 年
- [Universal Ctags](https://github.com/universal-ctags/ctags): 是老 `Exuberant Ctags` 的一个 `fork` 版本, 继承了其所有优点, 并且直到现在还在活跃更新

综上所述, 建议安装 `Universal Ctags`, 使用如下方式安装即可

```bash
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
```

### 生成 tags

使用 `ctags -R –c++-kinds=+px –fields=+iaS –extra=+q .` 可以将当前目录下的所有文件内容进行处理生成 `./tags` 文件, 这些选项的作用如下:

- `-R`: ctags 循环生成子目录的 tags
- `--c++-kinds=+pxl`: `ctags` 记录 `c++` 文件中的函数声明和各种外部和前向声明 (`l` 表示记录局部变量, 可以认为是 `local` 的缩写)
- `--fields=+iaS`: `ctags` 要求描述的信息, 其中 i 表示如果有继承, 则标识出父类; a 表示如果元素是类成员的话, 要标明其调用权限 (即是 public 还是 private); S 表示如果是函数, 则标识函数的 signature.
- `extra=+q`: 强制要求 `ctags` 做如下操作: 如果某个语法元素是类的一个成员, `ctags` 默认会给其记录一行, 可以要求 `ctags` 对同一个语法元素再记一行, 这样可以保证在 VIM 中多个同名函数可以通过路径不同来区分.

### 配置 tags 路径

生成了 `tags` 文件后, 我们要让 vim 找的到当前浏览的文件所对应的是哪个 `tags` 文件, 我们在 `~/.vimrc` 中应该加上这样的配置

```vim
set tags=./tags;,tags
```

前半部分 `./.tags;` 代表在文件的所在目录下查找名字为 `.tags` 的符号文件, 后面一个分号代表查找不到的话向上递归到父目录, 直到找到 `tags` 文件或者递归到了根目录还没找到; 逗号分隔的后半部分 `tags` 是指同时在 `vim` 的当前目录 (`:pwd` 命令返回的目录, 可以用 `:cd ..` 命令改变) 下面查找 `tags` 文件.

### 使用 tags

`tags` 的使用非常简单, **把光标移动到某个元素上, `CTRL+]` 就会跳转到对应的定义, `CTRL+o` 可以回退到原来的地方**.

另外也有一些其他的 `tags` 相关命令可以使用:

- `:tag func`: 跳转到 `func` 函数实现的地方
- `:tnext`: 下一个标签匹配处
- `:tprev`: 上一个标签匹配处
- `:tfirst`: 第一个标签匹配处
- `:tlast`: 最后一个标签匹配处
- `:tags`: 所有匹配的标签
- `:tselect`: 显示所有匹配的标签并让你选择指定的

## `cscope`

`cscope` 是类似于 `ctags` 一样的工具, 但可以认为是 `ctags` 的增强版, 因为她比 `ctags` 能够做更多的事:

- 符号在哪里使用的?
- 符号在哪里定义的?
- 变量从哪里得到它的值的?
- 全局变量的定义?
- 这个函数在源代码中的什么文件中?
- 什么函数调用了这个函数?
- 这个函数调用了什么函数?
- 消息 `out of space` 来自哪里?
- 这个源文件在目录中的结构?
- 哪些文件包含了这个头文件?

### cscope 如何使用

在终端中的项目路径中使用 `cscope -Rbkq`:

- `R`: 表示把所有子目录里的文件也建立索引
- `b`: 表示 `cscope` 不启动自带的用户界面, 而仅仅建立符号数据库
- `q`: 生成 `cscope.in.out` 和 `cscope.po.out` 文件, 加快 cscope 的索引速度
- `k`: 在生成索引文件时, 不搜索 `/usr/include` 目录

通常我们使用 `cscope -Rb` 可以在当前路径下得到 `cscope.out`

> cs 是 cscope 的简写命令, 后面也是如此.

然后在 `vim` 中使用 `:cs add cscope.out`: 添加一个新的 cscope 数据库链接.  之后便可以在 `vim` 中使用 `:cs ...` 的一系列命令了

- `:cs show`: 查看当前已经链接的 cscope 数据库链接
- `:cs find a ...`: Find assignments to this symbol
- `:cs find c ...`: Find functions calling this function
- `:cs find d ...`: Find functions called by this function
- `:cs find e ...`: Find this egrep pattern
- `:cs find f ...`: Find this file
- `:cs find g ...`: Find this definition
- `:cs find i ...`: Find files #including this file
- `:cs find s ...`: Find this C symbol
- `:cs find t ...`: Find this text string

## [gtags](https://www.gnu.org/software/global/)

`gtags`, 全名为 `gnu global`, 是一个类似 `cscope` 的工具(不是 `ctags` 的替代品!), 也能提供源文件之间的交叉索引. 其独到之处在于, 当生成索引文件以后, 再修改整个项目里的一个文件, 然后增量索引的过程非常快.

### 安装

```bash
brew install global
```

安装好以后, 有 `global`, `gtags`, `gtags-cscope` 三个命令. `global` 是查询, `gtags` 是生成索引文件, `gtags-cscope` 是与 `cscope` 一样的界面.

### `gtags` 环境配置

`gtags` 是支持使用 `ctags/universal-ctags` 或者 `pygments` 来作为分析前端支持 50+ 种语言. 使用 `ctags/universal-ctags` 作为前端只能生成定义索引不能生成引用索引, 因此我们要安装 `pygments` , 保证你的 `$PATH` 里面有 `python`, 接着:

```bash
pip install pygments
```

保证在环境里里要设置过如下两个环境变量:

```bash
export $GTAGSLABEL = 'native-pygments'
export $GTAGSCONF = '/path/to/share/gtags/gtags.conf'
```

第一个 `GTAGSLABEL` 告诉 `gtags` 默认 `C/C++/Java` 等六种原生支持的代码直接使用 `gtags` 本地分析器, 而其他语言使用 `pygments` 模块.  第二个环境变量必须设置, 否则会找不到 `native-pygments` 和 `language map` 的定义,  Mac 下的路径为 `/usr/local/share/gtags`, 可以把它拷贝成 `~/.globalrc`

实际使用 `pygments` 时, `gtags` 会启动 `python` 运行名为 `pygments_parser.py` 的脚本, 通过管道和它通信, 完成源代码分析, 故需保证 `gtags` 能在 `$PATH` 里调用 `python`, 且这个 `python` 安装了 `pygments` 模块.

### `gtags` 使用

```bash
$ cd project/
$ gtags
```

`gtags` 遍历子目录, 从源码文件中提取符号, 这样就生成了整个目录的索引文件, 包括 `GTAGS`, `GRTAGS`, `GPATH` 三个数据库文件.

- `GTAGS`: 定义数据库
- `GRTAGS`: 引用数据库
- `GPATH`: 路径名数据库

也可以先用 `find` 命令生成一个文件列表, 叫 `gtags.files`, 然后再执行 `gtags`, 就会只索引 `gtags.files` 里的文件.

```bash
$ cd project/
$ find . -name "*.[ch]" > gtags.files
$ gtags
```

### `gtags-cscope` 在 `vim` 中的使用

查询使用的命令是 `global` 和 `gtags-cscope`. 前者是命令行界面, 后者是与 `cscope` 兼容的 `ncurses` 界面. 这里就不多介绍了, 重点是如何在 `vim` 里查询:

首先进入 vim, 然后:

```vim
:set cscopeprg=gtags-cscope
:cs add GTAGS
```

然后就可以像 `cscope` 一样, 用 `cs find g` 等命令进行查询了.

`gtags-cscope` 还有一个优点就是我后台更新了 `gtags` 数据库, 不需要像 `cscope` 一样调用 `cs reset` 重启 `cscope` 子进程, `gtags-cscope` 一旦连上永远不用重启, 不管你啥时候更新数据库, `gtags-cscope` 进程都能随时查找最新的符号.

当我们更改了某个文件以后, 比如 `project/subdir1/subdir2/file1.c`, 想更新索引文件 (索引文件是 `project/GTAGS`), 只需这样:

```bash
$ cd project/subdir1/subdir2/
$ vim file1.c
$ global -u
```

`global -u` 这个命令会自动向上找到 `project/GTAGS`, 并更新其内容. 而 `gtags` 相对于 `cscope` 的优势就在这里: 增量更新单个文件的速度极快, 几乎是瞬间完成. 有了这个优势, 我们就可以增加一个 `autocmd`, 每次 :w 的时候自动更新索引文件.

## `gutentags` - 一个将 `ctags`, `cscope`, `gtags` 串起来的一个自动化工具

[`gutentags`](https://github.com/ludovicchabant/vim-gutentags) 可以为我们生成数据库并自动 `cs add` 添加 `gtags` 数据库到 `vim`, 在你配置好它之后, 一切皆在后台线程默默完成, 什么都不需要再操心. 可以参考 [我的 `gutentags` 配置](https://github.com/HanleyLee/dotvim/blob/main/after/plugin/gutentags.vim)

编辑一个项目还好, 如果同时编辑两个以上的项目, `gutentags` 会把两个数据库都连接到 `vim` 里, 于是你搜索一个符号, 两个项目的结果都会同时出现, 基本没法用了.

这时, 我们可以搭配 [skywind3000/gutentags_plus](https://github.com/skywind3000/gutentags_plus) 一起使用, 这个脚本让已经加载过的数据库不会重复加载, 非本项目的数据库会得到即时清理, 所以你根本感觉不到 `gtags` 的存在, 只管始用 `GscopeFind g` 命令查找定义, `GscopeFind s` 命令查找引用, 既不用 `care gtags` 数据库加载问题更不用关心何时更新, 你只管写你的代码, 打开你要阅读的项目, 随时都能通过 `GscopeFind` 查询最新结果, 并放入 `quickfix` 窗口中:

这个小脚本末尾还还定义了一系列快捷键:

- `<leader>cg`: 查看光标下符号的定义
- `<leader>cs`: 查看光标下符号的引用
- `<leader>cc`: 查看有哪些函数调用了该函数
- `<leader>cf`: 查找光标下的文件
- `<leader>ci`: 查找哪些文件 include 了本文件
- `<leader>cd`: Functions called by this function
- `<leader>ct`: Find text string under cursor
- `<leader>ce`: Find egrep pattern under cursor
- `<leader>ca`: Find places where current symbol is assigned
- `<leader>cz`: Find current word in ctags database

### 设置排除文件类型

`ctags` 排除与 `gtags` 排除不一致, 需要手动在 `$GTAGSCONF` 中设置 skip

![himg](https://a.hanleylee.com/HKMS/2021-05-19235020.jpg?x-oss-process=style/WaMa)

## 最后

我的 vim 配置仓库: [HanleyLee/dotvim](https://github.com/HanleyLee/dotvim)

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow
