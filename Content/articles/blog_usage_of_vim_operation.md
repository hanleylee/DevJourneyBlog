---
title: 神级编辑器 Vim 使用 - 操作篇
date: 2021-01-15
comments: true
path: usage-of-vim-editor
categories: Terminal
tags: ⦿vim, ⦿tool
updated:
---

本部分笔记可作为速查 `CheatSheet` 使用

![himg](https://a.hanleylee.com/HKMS/2020-01-09-vim8.png?x-oss-process=style/WaMa)

<!-- more -->

本系列教程共分为以下五个部分:

1. [神级编辑器 Vim 使用-基础篇](https://www.hanleylee.com/usage-of-vim-editor-basic.html) <!-- ./blog_usage_of_vim_basic.md -->
2. [神级编辑器 Vim 使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html) <!-- ./blog_usage_of_vim_operation.md -->
3. [神级编辑器 Vim 使用-插件篇](https://www.hanleylee.com/usage-of-vim-editor-plugin.html) <!-- ./blog_usage_of_vim_plugin.md -->
4. [神级编辑器 Vim 使用-正则操作篇](https://www.hanleylee.com/usage-of-vim-editor-regex.html) <!-- ./blog_usage_of_vim_regex.md -->
5. [神级编辑器 Vim 使用-最后](https://www.hanleylee.com/usage-of-vim-editor-last.html) <!-- ./blog_usage_of_vim_final.md -->

## 基础命令

- `vim code.c`: 在终端中打开 `code.c` 文件 (终端命令)
- `vim ~/.vimrc`: 打开根目录下的 `.vimrc` 文件 (终端命令)
- `vim -u NONE -N`: 以不加载任何插件的方式启动 vim(终端命令)
- `gvim -o file1 file2`: open into a horizontal split (file1 on top, file2 on bottom) [C]
- `gvim -O file1 file2`: open into a vertical split (side by side,for comparing code) [N]
- `gvim.exe -c "/main" joe.c`: Open joe.c then jump to "main"
- `vim -c "%s/ABC/DEF/ge | update" file1.c`: execute multiple command on a single file
- `vim -c "argdo %s/ABC/DEF/ge | update" *.c`: execute multiple command on a group of files
- `mvim --servername VIM3 --remote-tab foobar.txt`: 在 MacVim 中已打开的窗口中打开文件
- `mvim -f file.txt`: 使用 `MacVim` 编辑, 编辑完后返回结果给 terminal(如果不加 f 的话就是立刻返回结果给终端)
- `vim -c "argdo /begin/+1,/end/-1g/^/d | update" *.c`: remove blocks of text from a series of files
- `vim -s "convert.vim" file.c`: Automate editing of a file (Ex commands in convert.vim)
- `gvim -u NONE -U NONE -N hugefile.txt`: "load VIM without.vimrc and plugins (clean VIM) e.g. for HUGE files
- `gvim -c 'normal ggdG"*p' c:/aaa/xp`: Access paste buffer contents (put in a script/batch file)
- `gvim -c 's/^/\=@*/|hardcopy!|q!'`: print paste contents to default printer
- `:h [option]`: 显示对命令的帮助
- `:help :sort`: 同上, 显示对 `:sort` 的解释
- `:help guimac` / `:help macvim`: 显示 macvim 的帮助
- `:gui`: 在 MacVim 中打开 vim 中当前的所有 buffer(great!)
- `:source ~/.vimrc`: 重载配置文件 (可以在不重启 vim 的情况下重载配置文件)
- `:runtime syntax/c.vim`: 将文件加载入 `runtimpath`, 不使用冒号只会加载第一个符合的
- `:runtime! **/maps.vim`: 将文件夹下所有符合的文件添加到 `runtimpath` 中, 使用冒号会加载全部符合的
- `:syntax on`: 开启语法
- `:set number`: 设置行号
- `:set ft=json`: 设置的文件格式为 `json 格式`
- `:set ft?`: 查看当前文件的 ft 值
- `.`: 修改完之后移动至下一个单词出按 `.` 可重复相同操作 (厉害!)
- `5.`: 重复 5 次相同动作
- `*`: 向下查找光标下的单词
- `#`: 向上查找光标下的单词
- `ga`: show unicode information of the character under cursor
- `g<C-g>`: counts words, 可以在 normal mode 与 visual mode 下使用
- `:e.`: `.` 代表 `pwd` 的结果, 即当前工作路径, 这个命令会进入 `netrw` 的文件管理界面
- `gq`: 重新布局 (如果设置了 `textwidth` 的话会根据 `textwidth` 进行断行)
- `gq}` format a paragraph
- `gqap`: format a paragraph
- `ggVGgq`: refromat entire file
- `Vgq`: current line
- `gw`: same as gq, but puts the cursor back at the same position in the text. However, `formatprg` and `formatexpr` are not used.
- `:verbose vmap`: show all map under visual model
- `==`: indent current line
    - `=G`: indent the all the lines below the current line
    - `n==`: indent `n` lines below the current line
    - `=%`: indent a block of code
- `%!xxd`: show file in hex mode
- `%!xxd -r`: show content of file

## 保存退出

- `:q`: 退出文件
- `q:`: command line history window(puts you in full edit mode)
- `q/`: search history window(puts you in full edit mode)
- `n1,n2 w [file]`: 将 `n1` 行到 `n2` 行的内容保存到另一个文件
- `:wq`: 保存退出
- `:wa`: 保存所有缓冲区
- `:wn`: 保存当前缓冲区并进入下一个参数列表
- `:qa`: 退出所有缓冲区
- `:cq {N}`: quit vim with error code, useful when vim is called from another program, such as git call vim as mergetool
- `ZZ`: 保存退出当前 window(same as `:x` but not `:wq` which write the file even if it hasn't been modified)
- `ZQ`: 不保存直接退出当前 window(equal to `:q!`)
- `:x`: 与 `ZZ` 及 `:zq` 功能类似, 但是不会写入没有被修改过的文件
- `:xa`: 保存并退出所有缓冲区 (不会保存没有修改过的)
- `:sav path/to.txt`: 将本缓冲区保存为文件 (相当于另存为, 命令全名是 `saveas`)
- `:sav php.html`: Save current file as php.html and "move" to php.html
- `:sav! %<.bak`: Save Current file to alternative extension (old way)
- `:sav! %:r.cfm`: Save Current file to alternative extension
- `:sav %:s/fred/joe/`: do a substitute on file name
- `:sav %:s/fred/joe/:r.bak2`: do a substitute on file name & ext.
- `:!mv % %:r.bak`: rename current file (DOS use Rename or DEL)
- `:w path/to.txt`: 保存到某路径
- `:e!`: 重载本文件, 即使有未保存的内容也会被丢弃 (edit 缩写)
- `:e path/to.txt`: 打开指定文件
- `:e.`: 进入 `netrw` 浏览目录

## 移动

- `hjkl`: 左下上右键
- `10 + hjkl`: 向左下上右跳 10 个格
- `gj`: 在一段被折为多行时, 将光标向下移动一行 (向下移动一个屏幕行)
- `gk`: 在一段被折为多行时, 将光标向上移动一行 (向上移动一个屏幕行)
- `>>`: 整行向右缩进
- `<<`: 整行向左缩进
- `%`: 在 `()`, `[]`, `{}` 之内跳转到包围符号上
- `]}`: 跳转到下一个 `}` 上
- `[{`: 跳转到下一个 `{` 上
- `[m`: jump to beginning of next method
- `[M`: jump to end of next
- `]m`: jump to beginning of previous
- `]M`: jump to end of previous

- `>%`: 将 `{}`, `()`, `[]` 包裹的代码右移 (必须先将光标放到符号上)
- `<%`: 将 `{}`, `()`, `[]` 包裹的代码左移 (必须先将光标放到符号上)
- `:le`: 当前行居左对齐
- `:ce`: 当前行居中对齐
- `:ri`: 当前行居右对齐
- `0`: 移动到行首 (非字符)
- `^`: 光标移至行首 (字符)
- `$`: 光标移至行尾 (换行符)
- `g^`: 移动到屏幕行的行首
- `g$`: 移动到屏幕行的行尾
- `g_`: 光标移至最后一个可见字符上
- `g;`: 跳转到上次修改的位置, 可以通过 `changes` 查看所有更改
- `g,`: 跳转到下次修改的位置
- `gi`: 跳转到上次退出插入模式的位置并直接进入 `Insert Mode`
- `gn` / `gN`: 跳转冰选中上个 / 下个 `highlight`
- `''`, 反撇号, 跳转 mark, 详见 [Mark](#mark)
- `w`: 跳至下一个 **word** 首
- `W`: 跳至下一个 **WORD** 首
- `b`: 跳至上一个 **word** 首
- `B`: 跳至上一个 **WORD** 开始处
- `e`: 跳至下一个 **word** 末端
- `E`: 跳至下一个 **WORD** 末端
- `ge`: backward to the end of **word**
- `gE`: backward to the end of **WORD**
- `f`: 移动到行内下一个字符, 如 `fx` 将查找行内出现的下一个 `x` 字符
- `F`: 移动到行内上一个字符, 用法同 `f`
- `t`: 移动到行内下一个字符的前一字符上
- `T`: 移动到行内上一个字符的下一字符上
- `;`: 重复查找, 即重复 `f` 或 `t`, 非常有用, 可以与 `.` 想媲美
- `,`: `;` 的反面, 当按 `;` 过头了可以用 `,` 退回来
- `<C-b>`: 向前滚一页
- `<C-f>`: 向后滚一页
- `<C-e>`: 向上滚一行
- `<C-y>`: 向下滚一行
- `<C-u>`: 向上滚半页
- `<C-d>`: 向下滚半页
- `gg`: 跳至文件顶部
- `G`: 跳至文件底部
- `M`: 光标移至页中部
- `L`: 光标移至页底部
- `H`: 光标移至页顶部
- `88gg`: 跳至第 88 行
- `88G`: 跳至第 88 行
- `10|`: 移动到当前行的第 10 列
- `zz`: 将当前行置于视图中央
- `zt`: 将当前行置于视图顶部
- `zb`: 将当前行置于视图底部
- `gd`: 跳转到局部变量定义处
- `gD`: 跳转到文件内全局声明 (从文件开头开始查找)
- `[<C-d>`: 跳转到定义处
- `[<C-i>`: 跳转到函数, 变量和定义处
- `gf`: Edit existing file under cursor in **same window**
- `<C-w>gf`: Edit existing file under cursor in **new tabpage**
- `<C-w> f`: Edit existing file under cursor in **split window**
- `<C-w> <C-f>`: Edit existing file under cursor in **split window**
- `<C-o>`: Normal 模式下返回上一个操作的位置; Insert 模式下切换到 Normal 模式, 输入完命令后再次进入 Insert 模式: `c-o zz`
- `<C-t>`: Normal 模式下返回上一个操作的位置; Search 模式下跳转到上一个匹配位置
- `<C-g>`: Search 模式下跳转到下一个匹配位置
- `<C-i>`: Normal 模式下返回下一个操作的位置
- `<C-^>` / `<C-6>`: Normal 模式下在本文件与上一个操作文件中跳转
- `'m`: 反撇号, 跳转到设置的标记 `m` 处
- `'M`: 跳转到全局标记
- `<C-]>`: 跳转到当前光标的定义处 (基于 `.tags` 文件)
- `<C-w>]`: 用新窗口 (如果在本 buffer 内则直接跳转) 打开并查看光标下符号的定义 (光标会跳转)(基于 `.tags` 文件)
- `<C-w>}`: 使用 preview 窗口预览光标下符号的定义 (光标不会跳转)(基于 `.tags` 文件)

### `word` 与 `WORD` 的区别

> `:h 03.1`

- A `word` is delimited by **non-word character**, such as a `.`, `-` or `)`. To change what Vim considers to be a word, see the `iskeyword` option. The `iskeyword` of markdown is `@,48-57,_,192-255,$`, `@` means `a-z,A-Z`.
- A `WORD` is delimited by **white-space**

## 复制 / 粘贴 / 删除

- `c`: 删除并进入 `插入模式` (理解: `cert`, 会插入)
- `cw`:  删除一个单词并进入 `插入模式`
- `C`: 删除自游标处到当前行尾, 并进入 `插入模式`
- `c2c`: 删除两行并进入 `插入模式`
- `cc`: 删除一行并进入 `插入模式`
- `d^`: 删除至行首 (理解: `delete`, 不会插入, 直接删除, 不会复制)
- `D`: 从当前光标处删除至行尾
- `dw`: 向右删除一个单词
- `d2d`: 删除两行
- `dd`: 删除一行
- `d121gg`: 从当前行删除到 121 行
- `d121j`: 从当前行向下删除 121 行
- `dtj`: 向前删除到 j(不包含 j)
- `dfj`: 向前删除到 j(包含j)
- `dTj`: 向后删除到 j(不包含j)
- `dFj`: 向后删除到 j(包含j)
- `d/ans`: 向前删除到 ans(不包含 ans)
- `d?ans`: 向后删除到 ans(不包含 ans)
- `d/\d`: 向前删除到第一个数字
- `x`: 删除本字符 (等于 delete)
- `X`: 向前删除一个字符 (等于 backspace)
- `s`: 删除右侧并进入插入模式
- `S`: 删除整行并进入插入模式
- `yy`: 复制一行
- `y$`: 从光标当前处复制到结尾, 不会复制到换行符, 但是如果 `v$y` 则会复制到换行符
- `y`: 复制所选 (可视模式)
- `'a,'by*`: yank range into paste
- `%y*`: yank range into paste
- `.y*`: yank current line to paste
- `set paste`: prevent vim from formatting pasted in text
- `y5j`: 向下复制 5 行
- `v/d/c/y` + `[文本对象]`
    - 操作分隔符的文本对象: 用于确定范围
        - `i(/[/{/"/'<`: 由 `(/[/{/"/'<` 包围起来的字符, 不包含 `(/[/{/"/'<`
        - `a(/[/{/"/'<`: 由 `(/[/{/"/'<` 包围起来的字符及包围符号本身
        - `[/?]motion<cr>`: `d/ans` / `d?ans` / `c/ans` / `c?ans`
    - 操作文本块的文本对象
        - `it`: 由 tag 包围起来的字符
        - `at`: 由 tag 包围起来的字符及 tag 本身
        - `iw`: 当前单词
        - `aw`: 当前单词及一个空格
        - `iW`: 当前字串
        - `aW`: 当前字串及一个空格
        - `is`: 当前句子
        - `as`: 当前句子及一个空格
        - `iB`: 当前 bracket(在定位 fold marker 时很有用)
        - `aB`: 当前 bracket 及一个空格
        - `ip`: 当前段落
        - `ap`: 当前段落记一个空行
    - 一般来说, `d{motion}` 命令和 `aw`, `as` 和 `ap` 配合起来使用比较好, 而 `c{motion}` 命令和 `iw` 及类似的文本对象一起用效果会更好.
- `p`: 如果整行复制, 粘贴在下方一行. 如果选中复制, 粘贴到当前光标后方
- `P`: 与 `p` 方向相反
- `gp`: 与 `p` 类似, 不过会把光标移动至文本的结尾
- `gP`: 与 `P` 类似, 不过会把光标移动到文本的结尾, 在粘贴多行的时候尤其有用

## 模式切换

- `i`: 当前字符之前插入
- `I`: 行首插入
- `a`: 当前字符之后插入
- `A`: 当前字符行尾插入
- `o`: 在下方插入一行并进入 `Insert Mode`
- `O`: 在上方插入一行并进入 `Insert Mode`
- `<C-v>`: 进入列选择模式, 可沿垂直方向选中多行, 然后使用大写的 I 和 A 分别可以实现在前侧和后侧批量添加字符, 使用 `>` 可以向右缩进, 使用 `r` 可以替换, 特别好用!
- `v`: 进入 visual 模式, 移动光标可进行批量选择删除
- `gv`: 重复选择上次选择并操作的区域
- `O`: 在 Visual 模式下切换高亮选取的活动端使之可调整

## 大小写 / 加减

- `~`: 将当前光标处的大小写翻转
- `g~5j`: 将当前行向下 5 行大小写反转
- `gu5j`: 将当前行向下 5 行改为小写
- `gU5j`: 将当前行向下 5 行改为大写
- `gUit`: 将 tag 包围的内容改为大写
- `guu`: 将当前行改为小写
- `gUU`: 将当前行改为大写
- `g~~`: flip case line
- `Vu`: 将当前行改为小写
- `VU`: 将当前行改为大写
- `veu`: 当前光标至尾端的字符改为小写
- `vG~`: 将当前光标至文本结尾的字符翻转大小写
- `ggguG`: lowercase entire file
- `<C-a>`: 对数字进行增加操作, 在列选择模式下批量增加数字, 对 Markdown 的列表排序特别好用
    - `<C-v>` + `select` + `C-a`: 将选择区域数字统一增加 1
    - `<C-v>` + `select` + `2` + `C-a`: 将选择区域数字统一增加 2
    - `<C-v>` + `select` + `g` + `C-a`: 将选择区域的数字 + 以 1 为梯度的一个数列(`1, 3, 5, 7 ...`)相加, 得到的结果覆盖原选择区域
    - `<C-v>` + `select` + `2` + `g` + `C-a`: 将选择区域的数字 + 以 2 为梯度的一个数列(`2, 4, 6, 8 ...`)相加, 得到的结果覆盖原选择区域
- `<C-x>`: 对数字进行缩小操作 (用法同 `C-a`)

## 撤销

- `u`: 撤销 undo(命令模式, 可多次撤销)
- `U`: 无论当前行修改了多少次, 全部撤销操作
- `<C-r>`: Normal 模式下反撤销
- `:undolist`: 撤销历史 (命令模式)
- `:undo 5`: 撤销 5 个改变 (命令模式)

## Folding

- `zf`: 创建折叠
- `zc`: close, 关闭当前光标下可折叠区域
- `zo`: open, 打开当前光标下可折叠区域
- `za`: toggle, 打开 / 关闭当前光标下可折叠区域
- `zC/zO/zA`: 与小写不同的是操作对象为全局, 与光标位置无关
- `zr`: reduce, 整体减少折叠等级 (与光标位置无关)
- `zR`: 将所有折叠级别减值最小 (直观看来就是缓冲区完全展开了)
- `zm`: more, 整体增加折叠级别 (与光标位置无关)
- `zM`: 增加折叠级别至最高 (直观看来就是缓冲区完全折叠了)
- `zi`: 全部折叠与全部展开之间进行切换
- `[z`: 当前打开折叠的开始处
- `z]`: 当前打开折叠的末尾处
- `zd`: 删除当前折叠 marker
- `zE`: 删除所有折叠 marker
- `zj`: 移动至下一个折叠
- `zk`: 移动至上一个折叠
- `zn`: 禁用折叠
- `zN`: 启用折叠

## window/tab

- `:tabnew [filename]`: 新建一个 tab 页, 例: `tabnew %` 以当前文件新建一个 tab 页, `%` 表示当前文件
- `:tabclose`: 关闭当前 tab
- `:tabonly`: 关闭所有其他的 tab
- `:tabn`: 移动至下一个 tab, 直接使用 gt 也可
- `:tabp`: 移动至上一个 tab, 直接使用 gT 也可
- `:tabs`: 查看所有打开的 tab
- `:tabdo %s/foo/bar/g`: 在所有打开的 tab 上执行替换
- `:tab ball`: 将所有的缓冲区在 tab 中打开
- `:tab sball`: 将所有的缓冲区在 tab 中再次打开
- `gt`: 跳转到下一个 tab
- `gT`:  跳转到上一个 tab
- `5gt`: 跳转到第 5 个 tab 上
- `:sp`: 上下切割当前文件, 同 `<C-w> s`
- `:vs`: 左右切割当前文件, 同 `<C-w> v`
- `:sp [filename]`: 上下分割并打开一个新文件, 如果不输入 filename 会切割打开本文件 (光标在文件开头位置)
- `:vs [filename]`: 左右分割并打开一个新文件, 如果不输入 filename 会切割打开本文件 (光标在文件开头位置)
- `<C-w> T`: 如果当前 tab 存在多个不同的 window, 那么将当前 window 移动到新 tab 上, 必须是大写
- `<C-w> s`: 水平切割当前窗口
- `<C-w> v`: 垂直切割当前窗口
- `<C-w> h/j/k/l`: 光标向某个方向分屏移动
- `<C-w> H/J/K/L`: 当前分屏向某个方向移动
- `<C-w> w`: 在所有窗口间进行切换
- `<C-w> _`: 使窗口高度最大化
- `<C-w> |`: 使窗口宽度最大化
- `<C-w> =`: 使所有窗口等宽等高
- `<C-w> r`: 翻转窗口顺序
- `<C-w> q`: quit, 关闭当前分屏, 如果是最后一个, 则退出 vim
- `<C-w> c`: close, 关闭当前分屏, 如果是最后一个, 则退出 vim
- `<C-w> o`: only, 关闭所有除当前屏幕外的所有分屏
- `<C-w> z`: 关闭当前打开的 preview 窗口
- `[N]<C-w> +`: 分屏增加 N 列高度 (可选)
- `[N]<C-w> <`: 分屏减少 N 列宽度 (可选)
- `:wincmd l`: 将光标移动至右窗口, 与 `<C-w>l` 功能等价
- `:3wincmd l`: 将光标移动至右窗口, 重复三次此动作
- `:$wincmd w`: 将光标移动至最右窗口
- `:close`: 关闭活动窗口
- `:only`: 只留下当前活动窗口
- `:new abc.txt`: 在新窗口中编辑文件

## Buffer

- `:ls` / `:buffers`: 显示当前所有 buffer(缓冲区列表)
    - `a`: active buffer
    - `h`: hidden buffer
    - `%`: the buffer is the current window
    - `#`: alternate buffer, 可以使用 `:e #` 直接编辑
- `:ls!`: 列出非缓冲区列表文件
- `:bn`: buffer next, 下一个 buffer
- `:bp`: buffer previous, 上一个 buffer
- `:bf`: 打开第一个 buffer
- `:bl`: 打开最后一个 buffer
- `:b1`: 切换到 buffer1(同理可按照数字切换到不同的 buffer)
- `:bd`: 删除 buffer(并没有删除文件本身, 只是 buffer 而已)
- `:bd 1 3`: 删除 buffer 编号为 `1`, `3` 的两个 buffer
- `:bw 3`: 将非缓冲区文件全部删除
- `:bufdo [command]`: 对所有缓冲区执行操作
    - `:bufdo /searchstr/`: use `:rewind` to recommence search
    - `:bufdo %s/searchstr/&/gic`: say n and then a to stop
    - `:bufdo execute "normal! @a" | w`: execute macro a over all buffers
    - `:bufdo exe ":normal Gp" | update`: paste to the end of each buffer
- `:1,3 bd`: 删除 buffer 编号在 `1~3` 之间的所有 buffer

## Tag

- `<C-]>`: 跳转到当前光标的定义处
- `g<C-]>`: 查看当前光标处有多少个定义 (可输入数字然后跳转)
- `g]`: 查看当前光标处有多少个定义 (可输入数字然后跳转)
- `:tag {keyword}`: 根据 `keyworkd` 查找有多少个匹配的 tag
- `:tag`: 正向遍历 tag 历史
- `:tnext`: 跳转到下一处匹配的 tag
- `:tprev`: 跳转到上一处匹配的 tag
- `:tfist`: 跳转到第一处匹配的 tag
- `:tlast`: 跳转到最后一处匹配的 tag
- `:tselect`: 提示用户从 tag 匹配的列表中选择一项进行跳转
- `:cs`: 显示 `cscope` 的所有可用命令

## Mark

vim 中 mark 分为三种:

- `Local mark` (a-z):  每一个 buffer 里皆有自己的 local mark, 也就是说档案 A 可以有 `mark a`, 档案 B 里也可以有自己的 `mark a`
- `Global mark` (A-Z):  此种 *mark* 是全域的, 也就是说在档案 A 里所看到的 `mark A` 和 B 档案 B 里的 `mark A` 是一样的
- `Special mark`: 其他神奇的 mark, 不在此文章討论范围

- `:marks`: 显示所有的 `marks`
- `mm`: 为当前位置在当前缓冲区内设置本地标记 `m`
- `dmm`: 删除本地标记 `m`
- `'m`: 反撇号, 跳转到设置的本地标记 `m` 处
- `mM`: 为当前位置设置全局标记 `M` (必须是大写, 可以跨文件使用)
- `'M`: 跳转到全局标记
- `'[`: 上一次修改或复制的第一行或第一个字符
- `']`: 上一次修改或复制的最后一行或最后一个字符
- `'<`: 上一次在可视模式下选取的第一行或第一个字符
- `'>`: 上一次在可视模式下选取的最后一行或最后一个字符
- `''`: 上一次跳转 (不包含 `hjkl` 的那种跳转) 之前的光标位置
- `'"`: 上一次关闭当前缓冲区时的光标位置
- `'^`: 上一次插入字符后的光标位置, `gi` 便是使用了此 mark
- `'.`: 上一次修改文本后的光标位置, 如果想跳转到更旧的 mark, 可以使用 `g;`
- `'(`: 当前句子的开头, 与 command `(` 相同
- `')`: 当前句子的结尾, 与 command `)` 相同
- `'{`: 当前段落的开头, 与 command `{` 相同
- `'}`: 当前段落的结尾, 与 command `}` 相同

> 跳转时我们可以使用 *单引号*, 也可以使用 *反撇号*, *单引号* 只会让我们跳转到该行的第一个非空白字符, *反撇号* 会让我们跳转到改行的该列, 更加精确

## Completion

- `<C-n>`: 触发补全, 向下
- `<C-p>`: 触发补全, 向上
- `<C-x>`: 进入补全模式
    - `<C-x> <C-l>`: 整行补全
    - `<C-x> <C-n>`: 根据当前文件里关键字补全
    - `<C-x> <C-k>`: 根据字典补全
    - `<C-x> <C-t>`: 根据同义词字典补全
    - `<C-x> <C-i>`: 根据头文件内关键字补全
    - `<C-x> <C-]>`: 根据 tag 补全
    - `<C-x> <C-f>`: 补全文件名
    - `<C-x> <C-d>`: 补全宏定义
    - `<C-x> <C-v>`: 补全 `vim` 命令
    - `<C-x> <C-u>`: 用户自定义补全方式
    - `<C-x> <C-s>`: 例如: 一个英文单词 拼写建议

## Quick List

- `:cnext`: 显示当前页下一个结果
- `:cpre`: 显示当前页上一个结果
- `:copen`: 打开 Quickfix 窗口
- `:cfirst`: 跳转到第一项
- `:clast`: 跳转到最后一项
- `:cnfile`: 跳转到下一个文件中的第一项
- `:cpfile`: 跳转到上一个文件中的最后一项
- `:cc N`: 跳转到第 n 项
- `:cclose`: 关闭 Quickfix 窗口
- `:cdo {cmd}`: 在 quickfix 列表中的每一行上执行 {cmd}
- `:cfdo {cmd}`: 在 quickfix 列表上的每个文件上执行一次 {cmd}
- `:cl[ist]`: 打开 location list 窗口, 目前看来不需要使用此选项

## Location List

与 Quick-List 相似, 最大的不同是: Quick-List 是针对多个窗口共享一个结果, 而 `Location List` 则是各个窗口的结果互相独立

- `lopen`: 用于打开位置列表窗口
- `lclose`: 用于关闭位置列表窗口
- `lnext`: 用于切换到位置列表中的下一项
- `lprevious`: 用于切换到位置列表中的上一项
- `lwindow`: 用于在错误出现时才触发位置列表窗口

## 宏

- `q + 小写字母`: 进入宏记录模式, 记录到 `小写字母` 寄存器中, 记录完成后再次按下 `q` 即可.
- `q + 大写字母`: 进入宏记录模式, 在 `小写字母` 寄存器尾部接着添加命令, 记录完成后再次按下 `q` 即可.
- `@ + 小写字母`: 执行对应寄存器内的宏. 可使用前缀添加数字的方式重复多次命令
- `@:`: repeat last `:` command, `:` 寄存器总是保存着最后执行的命令行命令
- `@@`: 直接重复上一次的 `@` 命令, 此命令必须建立在 **上一次使用了以 `@` 开头的寄存器宏** 或者 **刚刚建立了一个寄存器宏的** 基础上, 因此经常配合 `@:` 使用.
- `10@a`: 执行寄存器 `a` 中所存储宏 10 次 (串行处理, 如果有错误, 则立刻停止, 后续命令不再执行)

## 参数列表

参数列表与缓冲区的概念很类似, 参数列表的原始含义是我们在终端中使用 `vim a.txt b.txt` 时后面的一系列文件或参数名, 但是我们也可以在进入 vim 后使用 `args` 手动添加参数文件. 其与缓冲区的区别是:

1. 位于参数列表的文件必然位于缓冲区列表中
2. 缓冲区列表永远是乱糟糟的, 但是参数列表永远是秩序井然

- `:args *.*`: 将当前目录下的所有类型的文件加入到参数列表中 (不包括文件夹中的文件)
- `:args **/*.*`: 将当前目录下的所有文件及子文件夹的所有文件都匹配加入到参数列表中
- `:args *.md aa/**/*.md` 表示添加子文件夹下的 md 文件及 aa 文件夹下的和其子文件夹下的 md 文件到参数列表中
- `:args 'cat list.txt'`: 用反撇号将命令包围起来, 然后将命令被执行后的结果作为参数加入参数列表中
- `:argdo %s/oldword/newword/egc | update`: 对所有存在参数列表中的文件执行命令, s 代表替换, % 指对所有行进行匹配, g 代表整行替换 (必用), e 指使用正则表达式, c 代表每次替换前都会进行确认, update 表示对文件进行读写
- `:argdo exe '%!sort' | w`
- `:argdo write`: 将所有参数列表中的内容进行缓冲区保存
- `:argdo normal @a`: 将当前参数列表的所有缓冲区执行寄存器 a 中所存储的宏
- `:argd *`: 清空参数列表
- `:argdo bw`: 将参数列表中的所有文件清除出缓冲区
- `:args`: 显示当前的所有参数列表
- `:next`: 跳转到下一个参数列表的文件
- `:prev`: 跳转到上一个参数列表的文件
- `:first`: 跳转到第一个参数列表的文件
- `:last`: 跳转到最后一个参数列表的文件
- `:args **/*.md`: 将当前文件夹下所有.md 文件加入到参数列表中 (包括子文件夹中的文件)
- `:argdo %s/!\[.*\]/!\[img\]/gc`: 将所有参数列表中的以 `![` 开头, 以 `]` 结尾的所有字段改为 `[img]`
- `:argdo source FormatCN.vim`: 对参数列表中的所有文件执行脚本 `FormatCN.vim`

## 命令行模式

- `:shell`: 调用系统的 `shell` 来在 vim 进程中执行命令, 执行完使用 `exit` 退出
- `:term bash`: 在底部分割出一个独立窗口并调用 `bash`, 也可以使用 `term zsh` 来调用 `zsh`, 或 `:terminal zsh`
- `:history`: all commands(equal to `:his c`)
- `:his c`: commandline history
- `:his s`: search history
- `<C-w> N`: 在进入 `:term` 的终端模式后, 使用本命令可以获得 `Normal 模式` 的效果, 使用 `i` 返回正常的终端模式
- `<C-\><C-n>`: 同 `<C-w> N`
- `:col<C-d>`: 在 Ex 命令模式中使用补全查看可能的选项, 然后使用 `Tab` / `S-Tab` 进行选择 / 反向选择
- `<C-r><C-w>`: 将当前的光标下的单词 `<cword>` 插入到命令行中
- `<C-r><C-a>`: 将当前的光标下的单词 `<CWORD>` 插入到命令行中
- `<C-f>`: 将正在命令行中输入的内容放入到命令行窗口开始编辑
- `<C-c>`: 与 `<C-f>` 相反, 此命令可以使命令行窗口的当前行内容从命令行窗口放回到命令行中
- `<C-z>`: 在终端中将 `vim` 最小化, 然后如果再需要调用的话使用 `fg` 进行操作, 使用 `jobs` 查看所有处于后台的工作
- `<C-b>`: beginning, 在命令行模式中跳转到行首
- `<C-e>`: end, 在命令行模式中跳转到结尾
- `<C-p>`: 在命令行模式中显示上次的命令
- `<C-n>`: 在命令行模式中显示下次的命令
- `:!!`: last `:!` command
- `:~`: last substitute
- `:!<command>`: 在 shell 中执行命令
- `:!sh %`: 将当前文件所有行作为输入使用外部程序 sh 执行, `%` 代表本文件所有行
- `!!<command>`: 运行命令并将结果作为当前行的内容, 同 `:read!<command>`, `:.!<command>`
- `:read!<command>`: 将命令的结果输入 (重定向) 到当前缓冲区
    - `r !printf '\%s' {a..z}`: 获得 `a-z`
- `:put=execute('echo expand(\"%:p\")')`: 将当前文件名输出到 buffer
- `:put=execute('scriptnames')`: 将输出 put 到当前 `buffer` 上
- `:put=range(1,5)`: 生成 `1,2,3,4,5`, 并粘贴到当前光标之后(每行一个元素)
- `:put=range(10,0,-1)`: 生成 `10,9,8,7,6,5,4,3,2,1,0`, 并粘贴到当前光标之后(每行一个元素)
- `:put=range(0,10,2)`: 生成 `0,2,4,6,8,10`, 并粘贴到当前光标之后(每行一个元素)
- `:put=range(5)`: 生成 `0,1,2,3,4`, 并粘贴到当前光标之后(每行一个元素)
- `:enew|put=execute('scriptnames')`: 新开一个 `buffer`, 将输出 `put` 到该 `buffer` 上
- `:tabnew|put=execute('scriptnames')`: 新开一个 `tab`, 将输出 `put` 到该 `buffer` 上
- `:redir @">|silent scriptnames|redir END|enew|put`: 使用重定向到 `"` 寄存器, 然后在新 `buffer` 上 `put`
- `:!ls`: 显示当前工作目录下的所有文件 (此操作属于调用系统进程, 使用! 来调用系统操作是 Vim 的一大特点)
- `:[range]write!sh`: 将当前缓冲区的内容, 在 shell 中逐行执行, 与 `read!<command>` 作用正好相反, `!` 表示外部程序
- `:[range]write! sh`: 将当前缓冲区的内容, 在 shell 中逐行执行, `!` 表示外部程序
- `:[range]write! sh`: 将当前缓存区内容写入到一个名为 sh 的文件, `!` 表示强制覆盖式写入
- `:[range]write! filename`: 将当前缓冲区内容另存为到 filename 文件中
- `:.,$ sort [option] [pattern]`: 从当前行到末尾进行排序
    - `!`: 翻转顺序, 默认小在前, 翻转后大在前
    - `i`: 忽略大小写
    - `n`: numeric, 综合数字进行排序, 100 会排在 20 的后面
    - `f`: 浮点型
    - `b`: 二进制排序
    - `o`: 八进制排序
    - `x`: 十六进制排序
    - `u`: 移除重复行, `:sort! u` 会倒序去重排序 (`!` 控制正反序, 默认是正序)
    - `pattern`: When `pattern` is specified and there is no `r` flag the text matched with `pattern` is skipped, so that you sort on what comes after the match.
- `:sort /.*\%2v/`: sort all lines on second column
- `:2,$!sort -t',' -k2`: 使用外部 `sort` 程序进行排序, 以 `,` 为分隔符, 以第二项进行排序
- `:%!tac`: 将整个文档翻转
- `:%!sort -R`: 随机排序
- `:%!shuf`: 随机排序
- `:w!sudo tee % > /dev/null`: 在当前用户没有权限对当前文件做操作时使用超级管理员身份进行操作
- `:ls`: 列出当前所有的缓冲区文件列表, 执行的是 vim 的 ls 命令
- `:f`: 显示当前文件路径, (使用了 `<C-g>` 代替, 此项基本不会用了)
- `:command`: 显示当前所文件的所有可使用命令
- `:retab`: 重新生成所有的 tab(主要用于在.vimrc 中重新设置了 tab 格式, 然后在已存在旧格式 tab 的文档进行重生成)
- `:map g`: 查看所有以 `g` 开头的映射
- `echo $VIMRUNTIME`: 输出 vim 的 `runtime` path
- `echom $VIMRUNTIM`: echo 的信息只能显示一次, 之后不能查看, 使用 `echom` 可以通过 `messages` 调用查看.
- `echom &rtp`: 输出 `runtimepath`

> Vim 的先祖是 vi, 正是 vi 开创了区分模式编辑的范例. 相应的, vi 奉 一个名为 ex 的行编辑器为先祖, 这就是为什么会有 Ex 命令.

Ex 命令在命令行模式中执行, 而命令行模式的进入方式为 `:` 键, 因此我们可以看到所有的 `Ex` 命令都是以 `:` 开始的, 输入完命令后按下确定键 `<CR>` 即可执行, 虽然 `Ex` 命令年代久远, 但是不可否认其语法的简洁明了以及高效, 很多复杂的操作往往都是通过 `Ex` 命令来进行处理.

- `:[range] <command> [target]`: 执行命令并将结果放入目标位置
    - `:3,5 w!bash`: 将 3~5 行写入 bash
    - `:. w!bash`: 将当前行写入 bash
    - `:.!bash`: 将当前行执行结果写入当前 buffer
    - `:3,5 delete x`: 将当前行执行结果删除到 x 寄存器
    - `:.,$delete x`: 将当前行到文件结尾的所有内容删除
    - `:3,5 yank x`: 将当前行执行结果复制到 x 寄存器
    - `:. put x`: 在当前行后粘贴寄存器 x 的内容
    - `:3,5 copy .`: 将 3~5 行复制到当前行下
    - `:3,5 copy $`: 将 3~5 行复制到缓冲区的尾部
    - `:3,5 move.`: 将 3~5 行移动到当前行下
    - `:3,5 join`: 将 3~5 行进行合并
    - `[range] normal [cmd]`: normal 用来指定在 normal 模式下对文本的操作命令
        - `:3,5 normal .`: 对 3~5 行执行 `.` 重复命令
        - `:3,5 normal @q`: 对 3~5 行执行寄存器 `q` 内存储的命令
        - `'<,'> normal @a`: 在所选高亮区域上执行宏 (如果有错误也不停止, 因为是针对每一行执行的, 出错了只需要不处理那一行就行了)
    - `:[range] global/{pattern}/[cmd]`: 对指定范围内匹配的所有行执行 Ex 命令 (具体实例参见正则替换篇)
    - `:3,5 s/{pattern}/{string}/[flags]`: 将 `3~5` 行进行相应替换
    - `:3,5 join`: 将 `3~5` 行进行合并
    - `:3 p`: 打印第 3 行
    - `:3,5 p`: 打印 3~5 行
    - `:.,.+3 p`: 打印本行以下的三行内容, `+3` 代表偏移
    - `:% p`: 打印本 buffer 的所有行, `%` 代表所有行, 是 `1:$` 的简写
    - `:0,$ p`: 打印本 buffer 所有行, `$` 代表最后一行
    - `:.,$ p`: 打印本 buffer 内从本行到结尾的所有内容, `.` 代表当前行
    - `/<html>/+1,/<\/html>/-1 p`: 使用 patten 指定范围, `+1` 表示偏移
    - `:6t.`: 把第 6 行复制到当前行下方, tail 代表尾巴, 遵守 `from...to...` 的含义
    - `:t6`: 把当前行复制到第 6 行下方, 当 `.` 位于首位时可以省略 `.`, 因此全称是 `:.t6`
    - `:t.`: 粘贴当前行到下方, 与 `yyp` 不同的是本方式不会将内容放到寄存器中, 而 `yyp` 会将内容复制到 `unname` 寄存器与 `0` 寄存器
    - `:t$`: 粘贴当前行到文本结尾
    - `:'<,'>t0`: 把高亮选中的行复制到文件开头, `'<` 代表高亮选取的第一行, `'>` 代表高亮选取的最后一行
    - `:'<,'>m$`: 把高亮选中的行移动到文件结尾
    - `:'<,'>A;`: 把当前文件的所有行的尾部加上 `;`

## Insert 模式

- `<C-p>`: 选择上方补全
- `<C-n>`: 选择下方补全
- `⎋`: 退出插入模式 (推荐)
- `<C-c>`: 退出插入模式
- `<C-[>`: 退出插入模式
- `<C-u>`: 向左删除到行首
- `<C-w>`: 向左删除一个单词
- `<C-h>`: 向左删除一个字符
- `<C-t>`: 整行向右偏移
- `<C-d>`: 整行向左偏移
- `<C-r>= <function>`: 进行计算并将结果输出到当前缓冲区中
- `<C-x><C-e>`: scroll up wile staying put in insert
- `<C-x><C-y>`: scroll down wile staying put in insert
- `<C-Left>`: jump one word backwards
- `<C-Right>`: jump one word forward
- `<C-v><Tab>`: 无论 `expandtab` 选项是否开启都会插入制表符
- `<C-v><C-c>`: 输入文本结束字符(其他控制字符也可以按照这种方式插入)
- `<C-v><Tab>`: 输入水平制表符
- `<C-v>065`: 按照十进制输入大写字母 A
- `<C-v>o033`: 按照八进制输入转义符 `^[`
- `<C-v>x2a`: 按照十六进制输入转义符 `*`
- `<C-v>X2a`: 按照十六进制输入转义符 `*`
- `<C-v>u1234`: 按照 unicode 码以 16 进制来输入
- `<C-v>U00001234`: 按照 unicode 码以 16 进制来输入
- `<C-k>xx`: 通过两个字符输入常规键盘不方便输入的一些字符, 具体可通过 `:digraphs` / `:h digraph` 查看相关字符定义, 例如 `<C-k>*2` 可插入 `★`

## 路径

vim 的工作路径是使用中要格外注意的地方, 简单来说, 终端中的 vim 默认会把终端当前的路径作为其工作路径, 当然我们可以使用 `cd` 使其工作路径变更

- `:cd [path]`: 设置此次 vim 的工作目录为 path
- `:cd %:h`: cd 到当前缓冲区所属目录中
- `:cd ../`: cd 到上一级
- `:pwd`: 显示当前工作路径
- `:lcd [path]`: 设置当前窗口的工作目录为 path(与 cd 不同的是只会改变当前 window 的工作路径, 其他 window 的不受此影响)

vim 为我们提供了一些可以使用的宏用来表示相关路径或文件名称:

- `%`: 当前文件相对于工作路径的文件名及扩展
- `%:h`: 表示当前文件所在目录的相对工作目录路径 (不含文件名及扩展)
- `%:p`: 表示当前文件所在目录的绝对路径 (含文件名及扩展)
- `%:r`: 移除扩展之后的相对工作目录路径所有内容
- `%:e`: 扩展名
- `%:t`: 当前文件名 (含扩展), 无任何目录信息
- `%<`: 当前文件相对工作路径的文件名, 无扩展

在使用以上这几种宏时, 我们可以使用 `<Tab>` 使其自动展开, 有些命令不支持自动展开的话需要使用 `expand()` 命令

- `echo expand('%:e')`: 打印当前文档扩展名, markdown 是 `md`
- `cd %:h<Tab>`: cd 到当前缓冲区所属目录中, 在最后可以使用 `<Tab>` 进行自动展开
- `e %<Tab>`: 会自动扩展为当前文件含相对工作目录的路径全名

## 寄存器

寄存器是 vim 的一种特有概念, 其他文本编辑器默认都会用系统剪贴板作为复制粘贴的根据地, 然后 vim 另辟蹊径使用多种不同类型寄存器作为临时内容存储位置. 我们可以在复制粘贴时使用指定的寄存器定制化我们的需求, 也可以在录制宏及使用宏时指定寄存器, 大大地提高了我们的工作效率.

很多刚使用 vim 的人会抱怨无法复制内容到 vim 外或 vim 内, 然后各种搜索如何使 vim 的默认复制操作与剪贴板交互, 最后定义了一大堆按键, 譬如 `"*y`, `set clipboard=unnamed`, 其实大可不必, 寄存器是 vim 的高效操作方式之一, 接受了这种方式才能更好地利用 vim 来为我们服务 (虽然刚开始适应的过程必然是痛苦的)

总的来说 Vim 的删除, 复制与粘贴命令以及定义宏时都会用到众多寄存器中的某一个. 可以通过给命令加 `"{register}` 前缀的方式指定要用的寄存器. 若不指明, Vim 将缺省使用无名寄存器

- 无名寄存器

    所有删除复制粘贴操作如果不显示指明寄存器类型的话使用的都是无名寄存器, 其标志符是 `""` / `"@`.

- 编号寄存器

    从 `"0` 到 `"9` 共 10 个, `"0` 保存着拷贝来的字符串, `"1` 保存着上次删除掉的字符串, `"2` 保存着上上次删除掉的字符串, 依次类推, vim 会保存最近的 9 次删除. 删除操作包括 `s`, `c`, `d`, `x`. 只有整行整行的删除才会放入 `"1` 中.

    使用 `y` 复制后内容会被放到 `"0` 寄存器及无名寄存器中, 但是复制寄存器是稳定的, 无名寄存器的内容会时刻被重置替换. 其标志符是 `"0`

- 粘贴板寄存器

    用于与系统的其他应用中进行复制粘贴交互, 等于系统的剪贴板. 其标识符是 `"*` (或 `"+`), 使用 `set clipboard=unnamed` 可以使得 `"*` 与 `""` 始终具有相同的值

- 黑洞寄存器

    所有放入黑洞寄存器的内容全部被丢弃, 相当于完全删除, 不留痕迹, 其标识符是 `"_`

- 有名寄存器

    以单个小写字母命名的寄存器, 可用于自定义存储空间, 一共有 26 个

- 小删除寄存器

    不足一行的小删除会被放到小删除寄存器中, 删除操作包括 `s`, `c`, `d`, `x`.

- 只读寄存器

    - `"%`: 存储着当前文件名, 是当前文件相对于工作目录的路径文件名
    - `".`: 存储着上次插入模式中所输入的所有文本内容
    - `":`: 存储着上次执行的 Ex 命令, 与 `@:` 相对应, `@:` 可执行上次的命令

- 交替文件寄存器

    `"#` 存储着当前 vim 窗口的交替文件. 交替文件指 buffer 中的上一个文件, 可通过 `C-^` 来切换交替文件与本文件

- 表达式寄存器

    表达式寄存器 `"=` 用于计算 vim 脚本的返回值, 并插入到文本中

    - 当我们在 normal 模式下输入 `"=` 后, 再输入 `3+2`, 然后再使用 `p` 即可粘贴 `5`
    - 在 insert 模式下使用 `<C-R>`, 然后输入 `=expand('%:p')` 即可键入当前文件的完整路径名称

- 搜索寄存器

    `"/`, 存储着上次搜索的关键字

### 使用方式

- `""p`: 从无名寄存器中取值进行粘贴
- `"ay`: 将内容复制到有名寄存器 `a`
- `"_y`: 将内容复制到黑洞寄存器, 相当于彻底地删除
- `qa`: 录制操作到寄存器 `a` 中
- `@a`: 执行寄存器 `a` 中的内容
- `u@.`: execute command just type in
- `"ap`: 从自定义寄存器中取出内容进行粘贴
- `"0p`: 从复制寄存器中取出内容进行粘贴, 默认的 p 是从无名寄存器取值
- `"*p`: 从系统粘贴板寄存器中取出内容进行粘贴
- `<C-r>"`: 在插入模式中将无名寄存器的内容粘贴进来
- `<C-r>*`: 在插入模式中将系统粘贴板寄存器的内容粘贴进来
- `<C-r>0`: 在插入模式中将复制寄存器的内容粘贴进来
- `<C-r>%`: 插入当前文件名 (因为 "% 寄存器中存储了当前文件名)
- `:reg a`: 查看有名寄存器 `a` 的内容
- `:reg *`: 查看粘贴板寄存器 `*` 的内容
- `:reg "`: 查看无名寄存器 `"` 的内容
- `:put a`: 将有名寄存器 `a` 的内容粘贴到当前缓冲区中, 与 `"ap` 不同的是 `p` 用于只能在光标之前或光标之后进行粘贴, 但是 `put` 则会始终将内容粘贴到新的一行上
- `:d a`: 将内容删除到有名寄存器 `a` 中
- `:let @q=substitute(@0, 'iphone', 'iPhone', 'g')`: 对寄存器 `0` 的内容进行替换处理然后再赋值到寄存器 `q`
- `:let @*=@0`: 将粘贴寄存器内容赋值到系统剪贴板寄存器
- `:'<,'>normal @q`: 执行
- `let @a=@_`: clear register a
- `let @a=""` clear register a
- `let @a=@"`: save unnamed register
- `let @*=@a`: copy register a to paste buffer
- `let @*=@:`: copy last command to paste buffer
- `let @*=@/`: copy last search to paste buffer
- `let @*=@%`: copy current filename to paste buffer

> 使用 Visual Mode 时, 在选中的文本上使用 `p` 将直接替换该部分文本 (替换后被替换的文本会被放入到无名寄存器中), 可用于解决需要删除然后粘贴但是会影响到无名寄存器的问题

## vimdiff

![himg](https://a.hanleylee.com/HKMS/2021-01-14215042.png?x-oss-process=style/WaMa)

git 与 vim 可以说是非常好的一对搭档了, 平时在终端中提交 commit 我们都少不了与 `vim` 打交道, vimdiff 是 vim 提供的专门用于修正 git 冲突文件的一款工具

若想使用 vimdiff 作为冲突修改工具, 需要设置 `~/.gitconfig` 的以下项

```vim
[diff]
    tool = vimdiff
[merge]
    tool = vimdiff
```

在 vimdiff 中, 一共有四个窗口, 上面依次是 `LOCAL`, `BASE`, `REMOTE`, 底部则是一个最终的文件结果窗口, 整个过程我们只需要将光标在最下方窗口上上下移动, 使用 `diffget` 命令从 `LOCAL`, `BASE`, `REMOTE` 中选择需要使用哪一个作为本行的最终结果 (当然也可以跳到上面的窗口中使用 diffput 放置结果到底部窗口上

- `:diffget LOCAL`: 选择 LCOAL 作为本行最终结果
- `:diffget REMOTE`: 选择 REMOTE 作为本行最终结果
- `:diffget BASE`: 选择 BASE 作为本行最终结果
- `:diffput [num]`: 放置结果到缓冲区上, `num` 为缓冲区编号
- `:diffg L`: 这里 vim 为我们做了简略命令, 同样可用于 `REMTOE` 与 `BASE` 上
- `:diffget //2`: `//2` 将被替换为左侧文件名
- `:diffget //3`: `//3` 将被替换为右侧文件名
- `:%diffget LO`: 将所有变更使用 local 的结果
- `:'<'>diffget LO`: 将当前选中范围的使用 local 的结果
- `dp/do`: 如果只有两个文件则可以使用 `dp/do` 来替代 `:diffput/:diffget`
- `:diffoff`: 关闭 diff mode
- `:diffthis`: 开启 diff mode
- `:ls!`: 显示当前所有缓冲区的号码
- `[c`: conflict, 移动到上一个冲突处
- `]c`: conflict, 移动到下一个冲突处
- `$git merge --continue`: 冲突全部解决完后在外界终端中使用 `git merge --continue` 继续之前的 `merge` 操作
- `:diffsplit filename`: 已经在 vim 中时, 使用此命令与别的文件进行对比
- `:vert diffsplit filename`: 同上
- `vimidff file1 file2`: 对比 `file1` 与 `file2` 的差别
- `vim -d file1 file2`: 同上 🐷
- `:wqa`: 冲突修复完成保存退出, 如果仍然有文件冲突则进入下一个冲突
- `:cq`: 放弃修复, 终止流程(在 merge conflict 时很有用, 否则使用了 `qa` 的话想再次进入 mergetool 就必须使用 `git checkout --conflict=diff3 {file}` 了)

![himg](https://a.hanleylee.com/HKMS/2021-05-26-17-46-26.jpg?x-oss-process=style/WaMa)

```txt
╔═══════╦══════╦════════╗
║       ║      ║        ║
║ LOCAL ║ BASE ║ REMOTE ║
║       ║      ║        ║
╠═══════╩══════╩════════╣
║                       ║
║        MERGED         ║
║                       ║
╚═══════════════════════╝
```

## 远程编辑

可以使用如下方式编辑远程主机上的文件:

- `e scp://user@host//home/hanley/.sh/README.md`: 通过 scp 编辑远程 (使用绝对路径)
- `tabnew scp://user@host//home/hanley/.sh/README.md`: 使用新建 tab 的方式编辑
- `e scp://vm_ubuntu//home/hanley/.sh/README.md`: 也可以通过 `~/.ssh/config` 中的 `alias` 进行 `key` 的使用
- `e scp://vm_ubuntu/.sh/README.md`: 也可以通过 `~/.ssh/config` 中的 `alias` 进行 `key` 的使用 (使用相对路径)

## 最后

我的 vim 配置仓库: [HanleyLee/dotvim](https://github.com/HanleyLee/dotvim)

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow
