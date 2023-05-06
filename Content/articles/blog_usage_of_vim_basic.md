---
title: 神级编辑器 Vim 使用 - 基础篇
date: 2021-01-15
comments: true
path: usage-of-vim-editor-basic
categories: Terminal
tags: ⦿vim, ⦿tool
updated:
---

最近一段时间, 看了两本关于 vim 的书, 重新学了一遍 vim, 在感慨 vim 强大的同时, 也为从前的自满感到汗颜, 我拿起了从前做的关于 vim 的笔记, 重新梳理了一遍, 作为一个系列分享到网上, 主要目的是想让更多 vim 的爱好者能够掌握更多的操作技巧.

本系列 vim 笔记的目的不是从零教会你如何操作 vim, 而是作为一本手册或者扩展你的视野, 让你知道原来 vim 还能这么用.

希望你能从本系列教程中收获到你感兴趣的部分内容!

![himg](https://a.hanleylee.com/HKMS/2020-01-09-vim8.png?x-oss-process=style/WaMa)

<!-- more -->

本系列教程共分为以下五个部分:

1. [神级编辑器 Vim 使用-基础篇](https://www.hanleylee.com/usage-of-vim-editor-basic.html) <!-- ./blog_usage_of_vim_basic.md -->
2. [神级编辑器 Vim 使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html) <!-- ./blog_usage_of_vim_operation.md -->
3. [神级编辑器 Vim 使用-插件篇](https://www.hanleylee.com/usage-of-vim-editor-plugin.html) <!-- ./blog_usage_of_vim_plugin.md -->
4. [神级编辑器 Vim 使用-正则操作篇](https://www.hanleylee.com/usage-of-vim-editor-regex.html) <!-- ./blog_usage_of_vim_regex.md -->
5. [神级编辑器 Vim 使用-最后](https://www.hanleylee.com/usage-of-vim-editor-last.html) <!-- ./blog_usage_of_vim_final.md -->

## vim 是否值得学习

网上有很多形容 vim 的学习曲线是如何陡峭的说法. 人, 最恐惧未知的事情. 如果有人给你说: `你花一天的时间找一个入门教程进行学习就可以学会基础操作`, 你会学习 vim 吗? 绝大部分人都是会的, 其实事实也就是这样, 如果只是基础操作的话 1 天时间绝对是够了. 但是绝大多数人得不到这样的答案, 所以他们关上了这扇窗.

在我看来, vim 的学习投入与产出的性价比是很高的, 学习了 vim 后你会有如下的一系列好处:

- vim 基于终端, 熟练掌握 vim 后你对终端的理解也会变得更为深刻
- vim 可以联合终端中的其他工具共同组成你的工具链 (譬如 `git`)
- 在 `Atom`, `Sublime`, `VSCode`, `NOTEPAD++` 等工具泛滥的如今, 你可以选择一个有着近 40 年历史的经过了时间考验的编辑器
- 操作远程服务器时经常需要在终端中进行文本编辑, vim 可以让你如履平地
- vim 支持所有平台, 你可以使用一份配置文件全平台通用
- 装 13

编辑器的切换是有成本的, 而且成本不小. 任何事情做到一半再去做另外的事情绝对比从一而终的人损失大得多, 因此选择一个适合自己的编辑器作为以后的伙伴是一件应该慎重的事情, 而使用过 vim 的人很少会再换用其他的编辑器, 这应该能说明很多问题.

有些人持有工具无用论的观点, 认为写好代码才是一切, 事实确实是这样. 但是难道有人会拒绝更快速, 更高效的写完一段优雅的代码吗?  这两者并非是鱼和熊掌不可兼得, 我们都可以有.

这方面话题比较容易引战, 点到为止, 具体如何交由读者自行判断.

Let's go!

## 安装

第一步当然是安装, 这里对 `MacOS` 与 `Linux` 进行安装示范

### MacOS

#### 不同版本安装

1. 系统内置

    Mac OS 默认内置 vim, 在没有安装任何其他版本 vim 的情况下在终端中输入 `vim --version` 可看到如下图:

    ![himg](https://a.hanleylee.com/HKMS/2019-12-31-083144.png?x-oss-process=style/WaMa)

    `+` 代表含有的功能, `-` 代表不包含的功能. 可以看到系统内置 `Vim` 的 `clipboard` 选项为 `-`, 代表没有剪贴板功能, 也就是说不会与系统剪贴板有任何互动, 即在 vim 中的内容无法复制到另一个程序中, 无论如何设置都无法改变. 这是最大的区别.

    而且由于是系统内置, 所以如果想要手动升级的话没有可能, 只能等到系统更新的时候 Apple 更新官方内置 `vim`.

2. 官方版 Vim, 通过 Homebrew 安装

    在终端输入 `brew install vim` 可以通过包管理工具 `Homebrew` 来安装官方版本 `Vim`. 安装完后的 vim 位置在 `/usr/local/bin/vim` (通过系统命令 `which vim` 可以知道具体程序的路径), 而系统自带的 vim 位置在 ` /usr/bin/vim `, 如果要使用通过 Homebrew 安装的 ` Vim `, 则必须将系统识别的环境变量 `PATH` 顺序调整为

    ```vim
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    ```

    调整 `PATH` 顺序方法: 打开路径 `/private/etc/paths` (此为隐藏路径, 需要打开显示隐藏文件开关才能看到), 使用任意文本编辑器打开修改并保存. 如下图:

    ![himg](https://a.hanleylee.com/HKMS/2019-12-31-071656.png?x-oss-process=style/WaMa)

    这样设置之后当在终端中输入 vim 时系统会先对 `/usr/local/bin` 路径进行检索, 如果此路径没有的话在对 `/usr/bin` 进行检索, 以此类推. 此时再次验证 `which vim` 命令, 如果返回了 `/usr/local/bin` 就说明设置成功. 以后只要是使用 `vim [filename]` 即可使用通过 `Homebrew` 安装的 `vim` 来打开了.

    此时通过 `vim --version` 可看到如下图

    ![himg](https://a.hanleylee.com/HKMS/2019-12-31-083316.png?x-oss-process=style/WaMa)

    最大的改变是 `clipboard` 选项变为了 `+`, 而且很多功能也变为了 `+`.

    通过 `Homebrew` 安装的 `vim` 一切都很好, 我也用了很长一段时间, 但是有两个问题一直困扰着我:

    1. 使用输入法插件在插入模式与普通模式切换之间有较大延迟, 例如在退出输入模式后会有 2-3 秒的延迟, 在这段延迟中如果我操作了键盘任何键位, 结果将被键入到输入法中. 体验极差.
    2. 速度. 在编辑较长的 `Markdown` 文件时, 如果开启了语法渲染以及底部状态栏插件的话会在快速移动光标过程中有较大延迟. 这种感觉在遇到语法段落结构复杂, 且光标移动较快时最为明显. 极大的影响了使用感受.

    如果 `vim` 一直是这种问题的话也当不得 **编辑器之神** 的称呼了. 我上网搜索后发现有很多人都跟我一样注意到了这一点. Mac 终端上的 `vim` 速度慢, 卡顿, 在 Linux 下就非常流畅没有任何延迟. 通过多方查证, 我测试了 MacVim 在 Mac 系统下的流畅程度. 果然有惊喜.

3. MacVim, 通过 Homebrew 安装

    `MacVim` 是 `vim` 在 Mac 系统的移植, 其内核与官方版本保持一致. 也就是说如果官方版本的 `vim` 在 Mac 上能实现什么功能, 那么 `MacVim` 也能实现相同的功能.

    通过 Homebrew 安装的话只需要用到命令 `brew install macvim`. 安装完成后在终端使用 `mvim` 即可打开 `MacVim` 桌面程序.

    如果想通过终端打开 `MacVim` 的命令行版本, 使用 `mvim -v [filename]` 即可.

    注: 由于通过 `Homebrew` 安装的绝大部分包都没有 GUI, 因此 `Homebrew` 不会将包移入 `/Applications`, 这导致了如果想在桌面上双击一个文件来使用 `MacVim` 打开很难实现, 而且在 Mac 的 `LaunchPad` 里是找不到 `MacVim` 的 (即使它是一个 GUI 软件)

    因此, 有了下一个解决方法.

4. MacVim, 通过 Homebrew Cask 安装

    `Cask` 是 `Homebrew` 的一个软件管理程序. `Homebrew` 本身就已经是包管理工具了, 其下的 `Cask` 又能管理程序, 一层套一层, 真会玩. 不过 `Homebrew` 绝大部分包都是一些环境, 而不是日常用户操作的交互式软件. 而 `Cask` 绝大部分包都是 GUI 软件. 通过 `Cask` 我们能安装绝大部分我们日常需要的软件, 比如 QQ, 音乐, 浏览器, 各种工具...

    通过 `brew install cask` 安装 `Cask` 包. 安装完成后再通过 `brew install macvim --cask` 来安装 `MacVim`.

    ![himg](https://a.hanleylee.com/HKMS/2019-12-31-080239.png?x-oss-process=style/WaMa)

    安装完成后你可以通过终端得知 `MacVim` 自动将 `mvim` 命令与路径 `/usr/local/bin` 里的 `vim`, `gvim`, `view` 等命令进行了绑定. 这表示在 系统变量 `PATH` 为 `/usr/local/bin` 第一的时候, 我们只要是使用 `vim`, `gvim`, `view` 中的任意一个都会打开 `MacVim` 桌面端程序.

    如果此时还是想用 `MacVim` 以命令行模式打开文件的话可以使用 `mvim -v` 或者 `vim -v` 或者其他几个绑定的命令. 当然我为了方便直接在 `~/.zshrc` (我是用的是 zsh) 中设置了 alias.

    ``` vim
    alias vim='mvim -v'
    ```

    设置完记得使用 `source ~/.zshrc` 或者重启终端来重载 `~/.zshrc`

#### 对比与总结

通过 `MacVim` 与 终端 `vim` 的安装体验对比, 总结了 `MacVim` 的如下优缺点 (同样对应 `vim` 的优缺点):

1. 优点

    - 有系统级别的复制粘贴撤销快捷键,
    - 滚动更流畅,
    - 输入法切换速度更快,
    - 右侧的导航滑轨也有了作用

2. 缺点

    - 没有集成在终端中意味着与终端切换的成本更大

3. 总结

    如果必须在 Mac 上使用 vim, 而且对流畅度要求比较高, 那么就是用 MacVim 吧.

    如果绝大多数工作环境都在终端上完成, 那么就使用终端 `vim`.

    如果要求兼具了以上两者, 就等待吧, 等官方解决 Mac 系统上的延迟问题

### CentOS

在 CentOS 中我们可以使用如下方法安装 vim

- 源码编译
- yum 安装
- GUI 版 vim 安装

但是经过多次试验之后发现这三种方法的前两种都是剪贴板缺失的 vim, 也就意味着不能与系统剪贴板进行交互, 因此最好安装 GUI 版 Vim

```bash
sudo yum install vim-X11
```

调用 `vim` 时使用 `vimx` 代替 `vim`

### Debian && Ubuntu

安装 `vim-gtk` or `vim-gnome`.

### Arch Linux

安装 `install gvim`

## Vim 模式区分

模式是 vim 与其他编辑器的最重要区别之一, 简单来说就是同样一个界面的同样操作在不同模式下会产生不同的效果. 最常用的模式有 `Normal Mode`, `Insert Mode`, `Visual Mode`, 与 `Command Line Mode`

### 普通模式 (Normal mode)

Vim 默认模式, 又称为命令模式, 可使用 hjkl 进行移动和简单编辑

### 插入模式 (Insert Mode)

该模式下可以尽情地输入, 普通模式通过 `i`, `a`, `o`, `cc` 等命令可进入插入模式.

### 可视模式 (Visual Mode)

与普通模式类似, 不同的是当移动时会进行扩展当前的选择区域. 普通模式按 `v` (进入字符选择模式) 或 `V` (进入行选择模式) 进入该模式

### 命令行模式 (Command Line Mode)

在该模式下可以在窗口的下方输入一行命令, 然后执行. 当一条命令执行完会自动退出命令模式进入普通模式.

命令模式通过输入 `:` 进行开启

### 替换模式 (Replace Mode)

新输入的文本会替换光标所在处的文本, 并使光标依次向后移动.

普通模式下通过按 `R` 进入该模式

### Ex Mode

与命令模式相似, 不同的是在该模式下可执行多次命令不会自动退出命令模式. 直至输入 `:visual` 退出该模式

在普通模式下通过按 `Q` 可以进入该模式

## vim 键位映射

当我们写了脚本或者不喜欢某些按键的触发方式, 我们当然可以将其改为我们认为最适合我们的键位, vim 对按键映射做了极为精细的区分, 让我们可以更好地掌控全局.

### 键表

- `<k0>-<k9>`: 小键盘数字 0 到 9
- `<ESC>`: ESC 键
- `<BS>`: `backspace` 退格键
- `<CR>`: `ENTER` 回车键
- `<Space>`: 空格键
- `<S-...>`: `shift` 键
- `<C-...>`: `ctrl` 键
- `<M-...>`:  `alt` / `meta` 键 (在 MacOS 上就是 `option` 键)
- `<A-...>`: 同 `<M-...>`
- `<D-...>`: `command` 键
- `<F1>-<F12>`: F1 到 F12 功能键
- `<t_xx>`: key with "xx" entry in termcap

> 使用 `:help key-notation` 查看全部含义

### 前缀

因为 vim 有多种模式, 因此我们可以针对不同的模式设置不同的快捷键映射

- `map`: 用于正常模式, 可视模式, 选择模式, 操作待决模式
- `nmap`: 用于正常模式
- `vmap`: 用于可视模式与选择模式
- `xmap`: 用于可视模式
- `smap`: 用于选择模式
- `omap`: 用于操作待决模式 (按下 `d`, `c`, `y` 等操作符后等到 `movement command` 的过程的模式)
- `map!`: 用于插入模式与命令行模式
- `imap`: 用于插入模式
- `lmap`: 用于插入模式, 命令行模式, 操作符待决模式
- `cmap`: 用于命令行模式
- `tmap`: 终端模式
- `nore`: 不递归, 否则在下面的按键映射下按下 i 就等于按下 k, 就等于按下 j, 最后结果乱套.

    ```vim
    nnoremap  i   k
    nnoremap  k  j
    nnoremap  j   h
    ```

- `<Leader>`: 意思就是在各种快捷键的最前面加上 `<leader>`, 避免了二义性. 如下所示, 在普通模式按下##w 时, 就完成了文件的保存工作
    (如果不进行自定义设置的话, 默认的 leader 键为反斜杠 `\`)

    ```vim
    let mapleader="##"
    nmap `<leader>` w:w<CR>
    ```

| Command    | Nor | Ins | Cmd | Vis | Sel | Opr | Term | Lang |
|:-----------|:---:|:---:|:---:|:---:|:---:|:---:|:----:|:----:|
| [nore]map  | yes |  -  |  -  | yes | yes | yes |   -  |   -  |
| n[nore]map | yes |  -  |  -  |  -  |  -  |  -  |   -  |   -  |
| [nore]map! |  -  | yes | yes |  -  |  -  |  -  |   -  |   -  |
| i[nore]map |  -  | yes |  -  |  -  |  -  |  -  |   -  |   -  |
| c[nore]map |  -  |  -  | yes |  -  |  -  |  -  |   -  |   -  |
| v[nore]map |  -  |  -  |  -  | yes | yes |  -  |   -  |   -  |
| x[nore]map |  -  |  -  |  -  | yes |  -  |  -  |   -  |   -  |
| s[nore]map |  -  |  -  |  -  |  -  | yes |  -  |   -  |   -  |
| o[nore]map |  -  |  -  |  -  |  -  |  -  | yes |   -  |   -  |
| t[nore]map |  -  |  -  |  -  |  -  |  -  |  -  |  yes |   -  |
| l[nore]map |  -  | yes | yes |  -  |  -  |  -  |   -  |  yes |

### 实际修改举例

```vim
 " 单引号补全
inoremap ' ''<esc>i
" 在普通模式, 快速按下 fw, 就相当于输入了: w<CR>, fw 可以理解成 file\_write.
" 文件保存与退出
nmap fw:w `<CR>`
nmap fq:q `<CR>`
nmap fwq:wq `<CR>`
```

### 进阶

- `nmap <buffer> x dd`: `x` 映射为 `dd` (该 map 只对当前 buffer 生效)
- `inoremap <silent><expr> <CR>  pumvisible() &&!empty(v:completed_item)? "\<C-y>": "\<C-g>u\<CR>"`: 使用 `expr` 表示将后面的作为脚本进行解析
- `onoremap in(:<c-u>normal! f(vi(<cr>`: 使用 `cin(` 可以修改下一个括号内的内容
    - `onoremap`: 操作符待决模式
    - `<c-u>`:
    - `normal!`: 模拟在 `normal` 模式下的按键, `dddd` 则为删除两行内容
    - `f(vi(`: 常规 `normal` 模式下的按键
    - `<cr>`: 配合 `normal!`, 表示 `normal!` 的结束

### MacVim 与 iterm 中使用 `Meta` 键

在 Mac 中, Meta 键就是 `option` 键, 如果在 vim 中使用要做一番工作

- MacVim: 在 `$HOME/.gvimrc` 中添加 `set macmeta`
- iTerm: 在 `Preferences` -> `Profiles` -> `Keys` -> `Left option key acts as: Meta`

## viminfo 选项

Vim 使用 `viminfo` 选项, 来定义如何保存会话 (`session`) 信息, 也就是保存 Vim 的操作记录和状态信息, 以用于重启 Vim 后能恢复之前的操作状态. `viminfo` 文件默认存储在以下位置:

- Linux 和 Mac: `$HOME/.viminfo`, 例如: `~/.viminfo`
- Windows: `$HOME\_viminfo`, 例如: `C:\Users\yiqyuan\_viminfo`

viminfo 文件主要保存以下内容:

- `Command Line History` (命令行历史纪录)
- `Search String History` (搜索历史纪录)
- `Expression History` (表达式历史纪录)
- `Input Line History` (输入历史记录)
- `Debug Line History` (调试历史纪录)
- `Registers` (寄存器)
- `File marks` (标记)
- `Jumplist` (跳转)
- `History of marks within files` (文件内标记)

`viminfo` 选项可以指定保存哪些内容, 以及在何处的 `viminfo` 文件中保存这些信息. `viminfo` 选项是一组使用逗号分隔的字符串; 其中每个参数,
是以单个字符开头的数值或字符串值. 其默认值为:

- Windows 下: `set viminfo='100,<50,s10,h,rA:,rB:`
- Linux 和 Mac 下: `set viminfo='100,<50,s10,h`

- `!`: 如果包含, 表示保存和恢复以大写字母开头并且不包含小写字母的全局变量. 例如, 保存 `KEEPTHIS` 和 `K_L_M`, 但不保存 `KeepThis` 和 `_K_L_M`
- `"`: 设置每个寄存器最多保存的行数. 是 `<` 选项的旧称. 需要在 `"` 之前加上转义反斜杠, 否则将会被识别为注释的开始
- `%`: 如果包含, 表示保存和恢复文件缓冲区列表; 如果后跟数值, 该数值指定保存缓冲区的最大数目; 如果不包含数值, 则保存所有缓冲区. 如果 Vim
- 启动时指定文件名参数, 则缓冲区列表不予恢复. 如果 Vim 启动时没有指定文件名参数, 则缓冲区列表从 `viminfo` 文件里恢复.  没有文件名的缓冲区和帮助文件的缓冲区不会写入 `viminfo` 文件. 不保存 `quickfix`, `unlisted`, `unnamed` 和在可移动介质上的缓冲区
- `'`: 保存指定数目文件中的标记. 如果 `viminfo` 选项非空, 则必须包含此参数. 包含本项目意味着 `jumplist` 和 `changelist` 也保存在 `viminfo` 文件里
- `/`: 保存搜索历史的最大数目. 如果此值非零, 那么将保存搜索和替代模式. 如果不包含, 则使用 `history` 选项的值
- `:`: 保存命令行历史的最大数目. 如果不包含, 则使用 `history` 选项的值
- `<`: 每个寄存器保存的最大行数. 如果为零, 表示不保存寄存器. 如果不包含, 则表示保存所有的行. `"` 是本项目的旧称
- `@`: 保存输入行历史的最大数目. 如果不包含, 则使用 `history` 选项的值
- `c`: 如果包含, 则使用 `viminfo-encoding` 选项指定的编码格式写入 `viminfo` 文件
- `f`: 是否保存文件位置标记. 如果为零, 不保存文件位置标记 (0~9, A~Z). 如果不包含或者非零值, 则保存位置标记
- `h`: 载入 `viminfo` 文件时, 关闭高亮效果. 如果不包含, 则取决于在最近搜索命令之后是否使用过 `:nohlsearch` 命令
- `n`: 指定 `viminfo` 文件的名称. 该名称必须紧随在字母 `n` 之后, 并且必须为最后一个选项. 如果启动 Vim 时指定了 -i 参数, 那么此文件名将覆盖 `viminfo` 选项指定的文件名. 文件名中的环境变量, 将在文件打开时被扩展
- `r`: 不保存指定可移动介质或路径内的文件的相关信息. 可以设置多个路径参数. 例如在 Windows 上, 你可以用 `rA:,rB:` 指定软驱或 U 盘. 也可以在 Linux 上, 使用 `r/tmp` 来屏蔽临时文件. 此选项将忽略大小写. 每个参数的最大长度为 50 个字符
- `s`: 如果为零, 将不保存寄存器. 缺省值 `s10`, 将忽略超过 10 Kbyte 文本的寄存器

```txt
set viminfo='1000,f1,<500,:1000,@1000,/1000,h,r$TEMP:,s10,n~/.viminfo
            |     |  |    |     |       |   |  |      |    |
            |     |  |    |     |       |   |  |      |    * declare Vim use ~/.viminfo file to store the related information
            |     |  |    |     |       |   |  |      * keep the size of register less than 10KB
            |     |  |    |     |       |   |  * don't save any information for file inside $TEMP
            |     |  |    |     |       |   * disable hlsearch when open file
            |     |  |    |     |       * save 1000 search history
            |     |  |    |     * save 1000 input line history
            |     |  |    * save 1000 command history
            |     |  * save 500 lines for each register
            |     * remember the position inside file
            * save marks of recent 1000 files
```

请注意:

- 请不要将 `<` 设置过大, 因为此选项将影响保存至 `viminfo` 文件中的信息量. 在 Vim 启动时, 如果读取尺寸过大的 `viminfo` 文件, 将影响 Vim 启动速度;
- 请在 `.vimrc` 文件开头, 首先定义 `:set nocompatible` 选项.

## vim 的加载顺序

vim 提供了一系列加载时间变量, 我们可以根据需要进行调用, 大致顺序如下:

1. `BufWinEnter`: create a default window
2. `BufEnter`: create a defautl buffer
3. `VimEnter`: start the vim session `edit demo.txt`
4. `BufNew`: create a new buffer contain demo.txt
5. `BufAdd`: add that new buffer the session's buffer list
6. `BufLeave`: exit the defautl buffer
7. `BufWinLeave`: exit the default window
8. `BufUnload`: remove the default buffer from the buffer list
9. `BufDelete`: deallocate the default buffer
10. `BufReadCmd`: read the contexts of demo.txt into the new buffer
11. `BufEnter`: activate the new buffer
12. `BufWinEnter`: activate the new buffer's window
13. `InsertEnter`: swap into insert mode

## 显示所有加载的脚本及顺序

`:scriptnames`

可以显示所有已加载的脚本及其顺序

## 显示相关 *变量* / *函数* / *命令* 的信息

- `:function`: list functions
- `:func SearchCompl`: list particular function
- `:command`: list commands
- `:command SearchCompl`: list particular command
- `:verbose set shiftwidth?`: reveals value of shiftwidth and where set
- `:verbose map {lhs}`: show detailed information of map
- `:verbose function xxxx`: show detailed information of function
- `:verbose command xxxx`: show detailed information of command

## `set option`

`set option` 分为两种类型:

- `boolean`: `set number` / `set nonumber`
- `value`: `set numberwidth=10`

```vim
set number " 设置显示行号
set number? " 显示 number 的设置状态
set number! " toggle, 进行开关
set nonumber " 设置不显示行号
set numberwidth=10
set numberwidth?
set number numberwidth=10 " 可在同一行对两种类型同时进行设置
```

### `setlocal`

`setlocal option` 使配置只在当前的 `buffer` 内生效

## 相关变量所代表的含义

- `$VIM`: `/Applications/MacVim.app/Contents/Resources/vim`
- `$VIMRUNTIME`: `/Applications/MacVim.app/Contents/Resources/vim/runtime`
- `$MYVIMRC`: `$HOME/.vimrc`

## vimrc 加载顺序

- `$VIM/vimrc`: system vimrc file:
- `$HOME/.vimrc`: user vimrc file:
- `~/.vim/vimrc`: 2nd user vimrc file:
- `$HOME/.exrc`: user exrc file:
- `$VIM/gvimrc`: system gvimrc file:
- `$HOME/.gvimrc`: user gvimrc file:
- `~/.vim/gvimrc`: 2nd user gvimrc file:
- `$VIMRUNTIME/defaults.vim`: defaults file:
- `$VIMRUNTIME/menu.vim`: system menu file:

## vim 的配置路径

当然, 通常我们可以将所有的配置都放在 `~/.vimrc` 中, 但是随着时间的推移, 我们的 `~/.vimrc` 文件会越来越大, 功能也越来越混乱,
很难一下就在其中找到需要的配置. 为此, vim 为我们预设了多个工作路径, 每个工作路径都不不同的加载时机.

- `~/.vim/colors/`: 加载我们的 colorscheme, 使用 `:color mycolors` 将会调用 `~/.vim/colors/mycolors` 文件
- `~/.vim/plugin/`: plugin 目录, 每次启动 vim 将会将在其中的全部内容
- `~/.vim/ftdetect/`: 每次启动 vim 将会加载其中全部内容, 用于判断打开的文件是什么类型然后 `set filetype ***`
- `~/.vim/ftplugin/`: 当 vim 查找到一个文件的类型后, 为其 `set filetype`, 然后根据具体的类型在本目录下寻找对应的加载文件, 比如一个 `test.md` 文件, vim 在确定其是 `markdown` 类型后, 使用 `setf markdown` 设置其类型, 然后在本目录下寻找 `markdown.vim` 进行加载 (有的话就加载, 没有就不加载)
- `~/.vim/indent/`: 与 `~/.vim/ftplugin` 类似, 也是在确定了文件类型后在本目录下查找对应的文件进行加载, 不过只针对于缩进
- `~/.vim/compliler/`: 与 `~/.vim/ftplugin` 类似, 也是在确定了文件类型后加载对应文件然后确定执行时使用的命令
- `~/.vim/after/`: 每次启动 vim 都会加载其中的文件, 其中可以含 `plugin` 与 `ftplugin` 文件夹, 加载时机位于 `~/.vim/plugin/` 或 `~/.vim/ftplugin` 之后
- `~/.vim/autoload/`: 按需加载, 也是延时加载, 在第一次呼叫相关插件命令后进行加载
- `~/.vim/doc/`: vim 的相关文档说明, 插件加载完成后进行加载

通过 `:scriptnames` 我们可以看到当前 buffer 的所有加载的 `script`

## runtimepath

When Vim looks for files in a specific directory, like syntax/, it doesn’t just look in a single place. Much like PATH on Linux/Unix/BSD systems, Vim has the runtimepath setting which tells it where to find files to load.

`Pathogen`, `vim-plug` 这类包管理工具的存在的主要作用就是将各个 plugin 的 path 添加到 runtimepath 中, 进而统一管理, 可以使用 `echo &rtp` 查看:

```txt
/Users/hanley/.vim
/Users/hanley/.vim/plugged/fzf
/Users/hanley/.vim/plugged/fzf.vim
/Users/hanley/.vim/plugged/vim-rooter
/Users/hanley/.vim/plugged/vim-visual-star-search
/Users/hanley/.vim/plugged/vim-vinegar
/Users/hanley/.vim/plugged/vim-unimpaired
/Users/hanley/.vim/plugged/vim-oscyank
/Users/hanley/.vim/plugged/onedark.vim
/Users/hanley/.vim/plugged/lightline.vim
/Users/hanley/.vim/plugged/vim-cpp-enhanced-highlight
/Users/hanley/.vim/plugged/indentLine
/Users/hanley/.vim/plugged/vim-matchup
/Users/hanley/.vim/plugged/vim-css-color
/Users/hanley/.vim/plugged/vim-fugitive
/Users/hanley/.vim/plugged/vim-rhubarb
/Users/hanley/.vim/plugged/gv.vim
/Users/hanley/.vim/plugged/vim-mundo
/Users/hanley/.vim/plugged/markdown-preview.nvim
/Users/hanley/.vim/plugged/vim-preview
/Users/hanley/.vim/plugged/vim-markdown
/Users/hanley/.vim/plugged/vim-beancount
/Users/hanley/.vim/plugged/jsonc.vim
/Users/hanley/.vim/plugged/vim-maximizer
/Users/hanley/.vim/HanleyLee/vim-alternate
/Users/hanley/.vim/plugged/vim-signature
/Users/hanley/.vim/plugged/auto-pairs
/Users/hanley/.vim/plugged/vim-commentary
/Users/hanley/.vim/plugged/vim-repeat
/Users/hanley/.vim/plugged/vim-surround
/Users/hanley/.vim/plugged/vim-exchange
/Users/hanley/.vim/plugged/vim-easymotion
/Users/hanley/.vim/plugged/tabular
/Users/hanley/.vim/plugged/xkbswitch
/Users/hanley/.vim/plugged/vim-table-mode
/Users/hanley/.vim/plugged/vim-multiple-cursors
/Users/hanley/.vim/plugged/vim-signify
/Users/hanley/.vim/plugged/vim-togglecursor
/Users/hanley/.vim/plugged/vista.vim
/Users/hanley/.vim/plugged/jianfan
/Users/hanley/.vim/plugged/inline_edit.vim
/Users/hanley/.vim/plugged/vim-renamer
/Users/hanley/.vim/plugged/vim-autoformat
/Users/hanley/.vim/plugged/asyncrun.vim
/Users/hanley/.vim/plugged/asynctasks.vim
/Users/hanley/.vim/plugged/vim-quickui
/Users/hanley/.vim/plugged/coc.nvim
/Users/hanley/.vim/plugged/vim-snippets
/Users/hanley/.vim/plugged/vim-gutentags
/Users/hanley/.vim/plugged/gutentags_plus
/Users/hanley/.vim/plugged/vimspector
/Users/hanley/.vim/plugged/vim-scriptease
/Users/hanley/.vim/plugged/vim-repl
/Applications/MacVim.app/Contents/Resources/vim/vimfiles
/Applications/MacVim.app/Contents/Resources/vim/runtime
/Applications/MacVim.app/Contents/Resources/vim/vimfiles/after
/Users/hanley/.vim/plugged/vim-cpp-enhanced-highlight/after
/Users/hanley/.vim/plugged/indentLine/after
/Users/hanley/.vim/plugged/vim-matchup/after
/Users/hanley/.vim/plugged/vim-css-color/after
/Users/hanley/.vim/plugged/vim-markdown/after
/Users/hanley/.vim/plugged/vim-signature/after
/Users/hanley/.vim/plugged/tabular/after
/Users/hanley/.vim/after
/Users/hanley/.config/coc/extensions/node_modules/coc-snippets
```

加载插件文件时根据 `runtimepath` 内部变量的值加载. 所有 `runtimepath` 中的所有目录下名为 `plugin` 的子目录们下面所有以 `.vim` 结尾的文件都会被加载执行.

autoload 加载的文件会在 `runtimepath` 下的所有 `autoload` 文件夹中进行查找, 如果找到一个, 则停止继续查找 (即使后面还有同名的文件!)

## autoload

暂时用不到的文件可以放在 `~/.vim/autoload` 文件夹中, 比如变量或方法, 命名方式为 `file1#func1`, 这样在加载的时候不会立即加载此文件, 而是在显式调用此方法时才会 source `autoload/file1`, 然后再调用 `func1`

```vim
" ~/.vim/autoload/example.vim
echom "Loading..."

function! example#Hello()
    echom "Hello, world!"
endfunction

echom "Done loading."
```

在调用后 `call example#Hello()` 后会显示

```txt
Loading...
Done loading.

Hello, world!
```

## 查找参数初始支持版本号

如果 vim 的某些参数, 只对某个版本以上支持, 那么就需要找到初始支持版本号, 避免在低版本运行配置时报错, 以下是 `set nrformats+=unsigned` 在 vim8.1 上的报错

```txt
Error detected while processing /private/var/root/.vim/main/options.vim:
line  164:
E474: Invalid argument: nrformats+=unsigned
```

可以使用如下方式查找某特性支持版本号:

- `help patches-after-8.2`
- `help patches-8.1`
- `help patches-8`
- `help fixed-<version>`: 最低支持到 5.1, 最高 7.4

## 最后

我的 vim 配置仓库: [HanleyLee/dotvim](https://github.com/HanleyLee/dotvim)

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow
