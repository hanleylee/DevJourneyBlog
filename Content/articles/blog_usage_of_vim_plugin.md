---
title: 神级编辑器 Vim 使用 - 插件篇
date: 2021-01-15
comments: true
path: usage-of-vim-editor-plugin
categories: Terminal
tags: ⦿vim, ⦿tool
updated:
---

在这篇中, 会列举各种实用的插件, 包括他们的安装, 配置及使用方法

注意: 不是本部分的所有插件都是你需要装的, 如果盲目安装插件只会导致你 vim 功能混乱, 速度底下, 所以适时整理真正需要的插件, 禁用或清除掉不常用的插件才是正确使用方法.

![himg](https://a.hanleylee.com/HKMS/2020-01-09-vim8.png?x-oss-process=style/WaMa)

<!-- more -->

本系列教程共分为以下五个部分:

1. [神级编辑器 Vim 使用-基础篇](https://www.hanleylee.com/usage-of-vim-editor-basic.html) <!-- ./blog_usage_of_vim_basic.md -->
2. [神级编辑器 Vim 使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html) <!-- ./blog_usage_of_vim_operation.md -->
3. [神级编辑器 Vim 使用-插件篇](https://www.hanleylee.com/usage-of-vim-editor-plugin.html) <!-- ./blog_usage_of_vim_plugin.md -->
4. [神级编辑器 Vim 使用-正则操作篇](https://www.hanleylee.com/usage-of-vim-editor-regex.html) <!-- ./blog_usage_of_vim_regex.md -->
5. [神级编辑器 Vim 使用-最后](https://www.hanleylee.com/usage-of-vim-editor-last.html) <!-- ./blog_usage_of_vim_final.md -->

## [vim-plug](https://github.com/junegunn/vim-plug)

`vim-plug` 是 vim 下的插件管理器, 可以帮我们统一管理后续的所有插件, 后续的安装插件全部由此工具完成

类似的插件管理工具还有 [Vundle](https://github.com/VundleVim/Vundle.vim), 相较而言 `vim-plug` 支持异步且效率非常高, 具体选择交由读者自己

### 安装

终端中输入如下命令

```vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### 基础命令

- `PlugInstall`:  安装插件
- `PlugUpdate`:  更新所有插件
- `PlugUpgrade`:  更新插件本身
- `PlugClean`:  删除插件, 把安装插件对应行删除, 然后执行这个命令即可

### 安装插件流程

安装完 `vim-plug` 之后, 我们就可以使用其为我们服务安装插件了, 我们只需要在 `call plug#begin(~/.vim/plugged)` 与 `call plug#end()` 中指明我们需要的第三方插件即可, 如下:

```vim
call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }   " 模糊搜索
Plug 'junegunn/fzf.vim'                               " 模糊搜索
Plug 'embear/vim-localvimrc'
Plug 'ycm-core/YouCompleteMe'     " 补全插件

call plug#end()
```

后续的所有插件除非特别说明, 否则都按照 `Plug 'PlugName'` 的方式进行安装

## [AutoFormat](https://github.com/Chiel92/vim-autoformat)

自动格式化管理插件, 可根据不同文件类型使用不同的格式化工具

### 安装

```vim
Plug 'Chiel92/vim-autoformat'
```

### 配置

```vim
"*****************   vim-autoformat   **********************
let g:autoformat_verbosemode=0 "详细模式
let g:autoformat_autoindent = 0
let g:autoformat_retab = 1
let g:autoformat_remove_trailing_spaces = 1
let g:formatdef_hl_js='"js-beautify"'
let g:formatdef_hl_c='"clang-format -style=\"{BasedOnStyle: LLVM, UseTab: Never, IndentWidth: 4, PointerAlignment: Right, ColumnLimit: 150, SpacesBeforeTrailingComments: 1}\""' "指定格式化的方式, 使用配置参数
let g:formatters_c = ['hl_c']
let g:formatters_cpp = ['hl_c']
let g:formatters_json = ['hl_js']
let g:formatters_js = ['hl_js']
let g:formatdef_sqlformat = '"sqlformat --keywords upper -"'
let g:formatters_sql = ['sqlformat']

"保存时自动格式化指定文件类型代码
"au BufWrite *:Autoformat
"autocmd BufWrite *.sql,*.c,*.py,*.java,*.js:Autoformat "设置发生保存事件时执行格式化
```

## [ALE](https://github.com/dense-analysis/ale)

与 `AutoFormat` 插件类似, 本插件也相当于一个错误统计处理平台, 通过为不同语言配置不同 linter 来达到错误统计的效果

如果你安装了 lightline 或者其他的类似工具, 那么也可以集成到你的底部工具栏中

![himg](https://a.hanleylee.com/HKMS/2021-01-11-073717.png?x-oss-process=style/WaMa)

### 安装

```vim
Plug 'dense-analysis/ale'
```

### 配置

```vim
"*********************   dense-analysis/ale   ************************
let b:ale_fixers = ['prettier', 'eslint']
let g:ale_fixers = {
            \   '*': ['remove_trailing_lines','trim_whitespace' ],
            \   'python': ['autopep8']
            \}
let g:ale_set_highlights = 0
"let g:ale_fix_on_save = 1 "auto Sava
let g:ale_echo_msg_format = '[#%linter%#] %s [%severity%]'
let g:ale_sign_column_always = 1 "始终开启标志列
let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
let g:ale_echo_msg_error_str = ''
let g:ale_echo_msg_warning_str = ''
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_linters_explicit = 1
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
let g:ale_c_cppcheck_options = ''
let g:ale_cpp_cppcheck_options = ''
let g:ale_linters = {
            \   'c': ['clangd'],
            \   'swift': ['swiftlint'],
            \   'markdown': ['markdownlint'],
            \   'sh': ['shellcheck'],
            \   'json': ['jsonlint'],
            \   'zsh': ['shellcheck']
            \}
let g:ale_list_window_size = 5
let g:ale_statusline_format = ['E•%d', 'W•%d', 'OK']
```

```vim
" 快速跳转至错误的快捷键
nnoremap <Leader>en <Plug>(ale_next)
nnoremap <Leader>ep <Plug>(ale_previous)
```

## netrw

很多人使用 vim 编辑文件, 完成后退出 vim 进行目录切换, 殊不知 vim 其实自带路径管理功能的, 从 vim 7 以后我们可以使用 vim 自带的 `netrw` 进入路径管理窗口

![himg](https://a.hanleylee.com/HKMS/2021-01-19223003.jpg?x-oss-process=style/WaMa)

`netrw` 是 vim 自带的插件, 不需要额外安装, 其提供的功能非常强大, 相比与 `NERDTREE` 这些第三方插件来说速度更快, 体量更轻, 设计更简洁

### 操作命令

- `:Ex`:  全屏进入 `netrw`, 全称是 `:Explorer`
- `:Sex>`:  水平分割进入 `netrw`
- `:Vex>`:  垂直分割进入 `netrw`
- `<F1>`:  在 netrw 界面弹出帮助信息
- `<CR>`:  打开光标下文件 / 夹
- `-`:  进入上一级目录
- `p`:  预览文件 (光标保持不动)
- `P`:  打开文件, 会在上一个使用的窗口一侧的第一个窗口打开文件
- `<C-w>z`:  关闭预览窗口
- `gn`:  使光标下的目录作为目录树最顶部, 在 tree style 下与 `<CR>` 是不同的
- `d`:  创建文件夹
- `D`:  移除文件 / 夹
- `cd`:  change 工作目录到当前路径
- `I`:  显示 / 隐藏顶部 `banner`
- `o`:  以水平分割窗口方式打开光标下文件
- `v`:  以垂直分割窗口方式打开光标下文件
- `%`:  在当前目录下新建一个文件并编辑
- `r`:  翻转排序方式
- `qb`:  列出所有的目录以及历史路径
- `qf`:  显示文件详细信息
- `R`:  重命名文件 / 文件夹
- `s`:  在 `name`, `time` 和 `file size` 之间切换排序
- `t`:  新 tab 中打开文件
- `<c-h>`:  编辑隐藏列表
- `<c-l>`:  更新 netrw 列表内容
- `a`:  隐藏 / 显示由 `g: netrw_list_hide` 所控制的文件
- `C`:  设置编辑窗口
- `gb`:  跳转到上次标记的书签
- `gd`:  强制作为目录
- `gf`:  强制作为文件
- `gh`:  快速隐藏 `.` 开头的文件
- `i`:  在 `thin`, `long`, `wide`, `tree listings` 状态之间切换
- `mb`:  将当前目录存为书签
- `mc`:  Copy marked files to marked-file target directory
- `mm`:  Move marked files to marked-file target directory
- `md`:  对标记的文件做 `diff` 操作
- `me`:  将标记的文件放入参数列表中并进行编辑
- `mf`:  标记一个文件
- `mF`:  取消标记一个文件
- `mg`:  对标记的文件使用 `vimgrep` 命令
- `mp`:  打印标记的文件
- `mr`:  使用 `shell-style` 标记文件
- `mt`:  使当前目录成为标记文件目标
- `mT`:  对标记文件应用 `ctags`
- `mu`:  对所有标记文件取消标记
- `mz`:  压缩 / 反压缩标记文件
- `O`:  Obtain a file specified by cursor
- `qF`:  Mark files using a quickfix list
- `S`:  确认在 name 排序状态下的扩展名优先级
- `u`:  跳转到上一次浏览的目录
- `x`:  使用系统中与之关联的程序打开光标下文件
- `X`:  执行光标下的文件

### 配置

```vim
let g:netrw_hide = 1 "设置默认隐藏
let g:netrw_liststyle = 3 " tree 模式显示风格
let g:netrw_banner = 0 " 显示帮助信息
let g:netrw_browse_split = 0 "控制 <CR> 直接在当前窗口打开光标下文件
let g:netrw_winsize = 30 " 占用宽度
let g:netrw_list_hide= '\(^\|\s\s\)\zs\.\S\+' " 需要隐藏的文件
let g:netrw_localrmdir = 'trash' "默认的删除工具使用 trash
let g:netrw_altv = 1 " 控制 v 分裂的窗口位于右边
let g:netrw_preview = 1 " 默认是水平分割, 此项设置使之垂直分割
let g:netrw_alto = 0 " 控制预览窗口位于左侧或右侧, 与 netrw_preview 共同作用
" let g:netrw_chgwin = 2 " 控制按下 <CR> 的新文件在位于屏幕右侧的 2 号窗口打开, Lex 默认会设为 2
```

### netrw copy 文件的方式

netw 复制文件的方式比较费解, 其原理是先标记好一个源文件, 然后标记好一个要被拷贝到的路径, 最后使用拷贝命令进行拷贝, 具体如下:

1. `mf` 标记源文件
2. 将光标移动至 `./` 上, 然后使用 `mt` 标记此目标路径
3. `mc` 拷贝文件至此 (也可以 `mv` 移动文件至此)

## [NerdTree](https://github.com/preservim/nerdtree)

不管出于任何原因不想使用 `netrw`, 我们都有很多第三方插件可以选择, `NerdTree` 就是其中的佼佼者

### 安装

1. 先在.vimrc 文件中添加 Plug 名称及设定:

    ```vim
    Plug 'preservim/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin' "目录树 git 状态显示
    "F1 开启和关闭 NerdTree
    map <F1>:NERDTreeToggle<CR>
    let NERDTreeChDirMode=1

    let NERDTreeShowBookmarks=1 "显示书签
    let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$'] "设置忽略文件类型
    let NERDTreeWinSize=25 "窗口大小
    ```

2. 运行 vim, 输入命令 `:PlugInstall`

### 操作命令

1. 文件操作

    - `e`: 进入文件夹内部浏览, 会在右侧开启小窗口进入文件夹列表
    - `o`: 在预览窗口中打开文件, 左侧 NerdTree 仍然被保留 (事实上除非打开新 tab 或手动退出, 否在会一直存在)
    - `O`: 递归地打开其内所有文件夹
    - `go`: 在预览窗口中打开文件, 光标将仍然保留在小窗口中, 非常好用, 用于预览多个文件特别有用.
    - `i`: 以分割视图打开文件
    - `gi`: 以分割视图打开, 但是光标仍然保留在小窗口
    - `s`: 以分割视图打开文件
    - `gs`: 以分割视图打开文件, 但是光标仍然保留在小窗口
    - `t`: 在新标签页打开选择的文件, 全屏
    - `T`: 在新标签页静默打开选择的文件, 全屏, 因为是静默, 所以不会跳转到新窗口
    - `C`: 将当前所选文件夹改为根目录, 即进入到所选择的文件夹, 与 o 不同, o 是在当前视图下将文件夹展开, C 则是直接进入到文件夹.
    - `cd`: 将当前文件夹改为 cwd(当前工作目录)
    - `CD`: 将文件夹目录跳转到 CWD(当前工作目录) 中
    - `m`: 对所选择的文件或文件夹弹出编辑菜单. 包括修改文件名, 复制, 移动, 删除等操作
    - `B`: 隐藏 / 显示书签, 如果显示书签, 还会将光标自动跳转至书签
    - `I`: 显示系统隐藏文件

2. 关闭移动系列

    - `q`:  直接退出 NerdTree
    - `D`:  删除书签
    - `F`:  隐藏文件, 只保留文件夹在视图中
    - `⌃ j`:  当同一个 NerdTree 有多个目录级别时, 只在同一级别下向下移动
    - `⌃ k`:  当同一个 NerdTree 有多个目录级别时, 只在同一级别下向上移动
    - `J`:  移动到同一级别的最下方
    - `K`:  移动到同一级别的最上方

3. 其他

    - `A`: 全屏进入 NerdTree 窗口
    - `r`: 刷新当前文件夹的缓存, 使界面刷新
    - `R`: 刷新整个文件夹树的缓存, 使整个界面更新
    - `?`: 快速显示帮助, 非常有用, 忘记功能时使用!

> 每次 `NERDTree` 从左侧显示出来的时候其所在目录即工作目录, 可以通过 `cd` 命令进行设置, 或者在 `.vimrc` 中设置 `set autochair` 进行自动切换, 这个概念对于文件批量操作很重要, 因为文件批量操作时添加待操作文件是依靠当前工作目录来进行筛选的.

## unimpaired

一个映射了大量实用命令的插件, 主要前缀键是 `[` 与 `]`,

### 安装

```vim
Plug 'tpope/vim-unimpaired'
```

### 使用

- `[b`:bprevious
- `]b`:bnext
- `[B`:bfirst
- `]B`:blast
- `[Space`: 当前行上增加空行
- `]Space`: 当前行下增加空行
- `[e`: 当前行上移
- `]e`: 当前行下移
- `[f`:previous file in current directory
- `]f`:next file in current directory
- `<p`: 复制到当前行下, 减少缩进
- `<P`: 复制到当前行上, 减少缩进
- `=P`: 复制到当前上, 自动缩进
- `>p`: 复制到当前行下, 增加缩进
- `>P`: 复制到当前行上, 增加缩进
- `[p`: 复制到当前行上
- `]p`: 复制到当前行下
- `[q`:cprevious, quickfix previous
- `]q`:cnext
- `[Q`:cfirst
- `]Q`:clast
- `[a`:previous
- `]a`:next
- `[A`:first
- `]A`:last
- `[l`:lprevious
- `]l`:lnext
- `[L`:lfirst
- `]L`:llast
- `[<C-L>`:lpfile
- `]<C-L>`:lnfile
- `[<C-Q>`:cpfile
- `]<C-Q>`:cnfile
- `[<C-T>`:ptprevious
- `]<C-T>`:ptnext
- `[n`:previous scm conflict
- `]n`:next scm conflict
- `[t`:tprevious, tag previous
- `]t`:tnext
- `[T`:tfirst
- `]T`:tlast

## [xkbswitch](https://github.com/lyokha/vim-xkbswitch)

vim 下的输入法自动切换工具, 在进入命令模式时自动切换至英文输入法, 回到插入模式时返回到上一次选择的输入法 (在需要中英文切换的环境中非常有用)

### 安装

1. 下载基础工具 [xkbswitch-macosx](https://github.com/myshov/xkbswitch-macosx)(每个系统有不同的实现工具, 这里以 macOS 为例)

   ```bash
   git clone https://github.com/myshov/xkbswitch-macosx
   # 把 git 下来的 xkbswitch 弄到 /usr/local/bin 下, 其实环境变量能搜到就行
   cp xkbswitch-macosx/bin/xkbswitch /usr/local/bin
   git clone https://github.com/myshov/libxkbswitch-macosx
   cp libxkbswitch-macosx/bin/libxkbswitch.dylib /usr/local/lib/
   ```

2. 在 vim 中安装插件

   在 `vimrc` 中加入下面的内容:

   ```bash
   Plug 'lyokha/vim-xkbswitch', {'as': 'xkbswitch'}

   let g:XkbSwitchEnabled     = 1
   let g:XkbSwitchIMappings   = ['cn']
   let g:XkbSwitchIMappingsTr = {'cn': {'<': '', '>': ''}}
   ```

   最后 `PlugInstall` 即可.

3. 先在.vimrc 文件中添加 Plug 名称及设定:

    ```vim
    Plug 'lyokha/vim-xkbswitch', {'as': 'xkbswitch'}
    let g:XkbSwitchEnabled     = 1
    ```

4. 运行 vim, 输入命令:PlugInstall

### 使用方式

在 `normal` 模式下手动切换至英文输入法模式, 然后进入 `insert` 模式后手动切换到中文输入法模式, 此时插件已经记忆了输入法的状态了, 在 `ESC` 回到 `normal`
模式后会自动切换到英文输入法模式, 再次进入 `insert` 模式时会自动切换到中文输入法模式

## [auto-pairs](https://github.com/jiangmiao/auto-pairs)

自动补全匹配符号

### 安装

```vim
Plug 'jiangmiao/auto-pairs'
```

### 配置

```vim
let g:AutoPairsMapCR = 0
```

### 映射

- `<M-p>`: Toggle Autopairs (g:AutoPairsShortcutToggle)
- `<M-e>`: Fast Wrap (g:AutoPairsShortcutFastWrap)
- `<M-n>`: Jump to next closed pair (g:AutoPairsShortcutJump)
- `<M-b>`: BackInsert (g:AutoPairsShortcutBackInsert)
- `<M-(>` / `<M-)>` / `<M-[>` / `<M-]>` / `<M-{>` / `<M-}>` / `<M-">` / `<M-'>`: Move character under the cursor to the pair

## [tabular](https://github.com/godlygeek/tabular)

一款对齐插件, 快速按照给定的分隔符号完成指定范围内的对齐操作

### 安装

```vim
Plug 'godlygeek/tabular'
```

### 操作

- `:Tabularize /,/`: 将整个缓冲区的所有行按照 `,` 符号进行对齐
- `:'<,'>Tabularize /,/`: 对高亮选中范围内的行进行对齐
- `:Tabularize /,/l1c1r0`: 按照 `,` 进行对齐, 并且为每个分割的文本区域内的文本指定对齐方式, `l`, `c`, `r` 分别为左中右对齐, 1
    代表每个分隔区域对齐补全后添加一个空格

    ```vim
    abc,def,ghi
    a,b
    a,b,c

    :Tabularize /,/r1c1l0

    abc, def, ghi
      a, b
      a, b, c
    ```

> 1. 对于分隔符所处的区域, `l` / `r` / `c` 的作用是相同的, 因为其只有一个宽度
> 2. 如果分隔的区块足够多, 那么将会循环使用 `r1c1l0`

```txt
:Tabularize /,/r1c1l0

        Some short phrase, some other phrase
A much longer phrase here, and another long phrase

That command would be read as

1. Align the matching text, splitting fields on commas.
2. Print everything before the first comma right aligned, then 1 space,
3. then the comma center aligned, then 1 space,
4. then everything after the comma left aligned."

Notice that the alignment of the field the comma is in is
irrelevant - since it's only 1 cell wide, it looks the same whether it's right,
left, or center aligned.  Also notice that the 0 padding spaces specified for
the 3rd field are unused - but they would be used if there were enough fields
to require looping through the fields again.  For instance:

abc,def,ghi
a,b
a,b,c

:Tabularize /,/r1c1l0

abc, def, ghi
  a, b
  a, b,  c
```

## [emmet-vim](https://github.com/mattn/emmet-vim)

### 安装

```vim
Plug 'boydos/emmet-vim'
```

### 配置

```vim
let g:user_emmet_mode='a'    "enable all function in all mode.
let g:user_emmet_leader_key='<C-y>'
let g:user_emmet_install_global = 0
```

### 操作

- `div>ul>li` + `<C-y>,`: `>` 生成子节点

    ```html
    <div>
        <ul>
            <li></li>
        </ul>
    </div>
    ```

- `div+p+bq` + `<C-y>,`: `+` 生成兄弟节点

    ```html
    <div></div>
    <p></p>
    <blockquote></blockquote>
    ```

- `div+div>p>span+em^bq` + `<C-y>,`: `^` 与 `>` 相反, 在父节点生成新节点

    ```html
    <div></div>
    <div>
        <p><span></span><em></em></p>
        <blockquote></blockquote>
    </div>
    ```

- `div+div>p>span+em^^^bq` + `<C-y>,`: 使用 n 个 `^`, 就可以在第 n 父级生成新的节点

    ```html
    <div></div>
    <div>
        <p><span></span><em></em></p>
    </div>
    <blockquote></blockquote>
    ```

- `ul>li*5` + `<C-y>,`: 使用 `*` 生成多个相同元素

    ```html
    <ul>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
    </ul>
    ```

- `div>(header>ul>li*2>a)+footer>p` + `<C-y>,`: 圆括号 `()` 是 Emmet 的高级用法, 用来实现比较复杂的 DOM 结构

    ```html
    <div>
        <header>
            <ul>
                <li><a href=""></a></li>
                <li><a href=""></a></li>
            </ul>
        </header>
        <footer>
            <p></p>
        </footer>
    </div>
    ```

- `(div>dl>(dt+dd)*3)+footer>p` + `<C-y>,`: 还可以嵌套使用圆括号 `()`

    ```html
    <div>
        <dl>
            <dt></dt>
            <dd></dd>
            <dt></dt>
            <dd></dd>
            <dt></dt>
            <dd></dd>
        </dl>
    </div>
    <footer>
        <p></p>
    </footer>
    ```

- `div#header+div.page+div#footer.class1.class2.class3` + `<C-y>,`: Emmet 给元素添加 ID 和 CLASS 的方法和 CSS 的语法类似

    ```html
    <div id="header"></div>
    <div class="page"></div>
    <div id="footer" class="class1 class2 class3"></div>
    ```

- `td[title="Hello world!" colspan=3]` + `<C-y>,`: 使用 `[attr]` 标记来添加自定义属性

    ```html
    <td title="Hello world!" colspan="3"></td>
    ```

- `ul>li.item$*5` + `<C-y>,`: 使用 `$` 操作符可以对重复元素进行有序编号

    ```html
     <ul>
         <li class="item1"></li>
         <li class="item2"></li>
         <li class="item3"></li>
         <li class="item4"></li>
         <li class="item5"></li>
     </ul>
    ```

- `ul>li.item$$$*5` + `<C-y>,`: 还可以用多个 `$` 定义编号的格式

    ```html
    <ul>
        <li class="item001"></li>
        <li class="item002"></li>
        <li class="item003"></li>
        <li class="item004"></li>
        <li class="item005"></li>
    </ul>
    <ul>
        <li class="item001"></li>
        <li class="item002"></li>
        <li class="item003"></li>
        <li class="item004"></li>
        <li class="item005"></li>
    </ul>
    ```

- `ul>li.item$@-*5` + `<C-y>,`: 使用 `@` 修饰符可以改变编号的格式, 在 `$` 后面添加 `@-` 可以改变编号顺序

    ```html
     <ul>
         <li class="item4"></li>
         <li class="item3"></li>
         <li class="item2"></li>
         <li class="item1"></li>
         <li class="item0"></li>
     </ul>
    ```

- `ul>li.item$@3*5` + `<C-y>,`: 在 `$` 后面添加 `@N` 可以改变编号基数

    ```html
    <ul>
        <li class="item3"></li>
        <li class="item4"></li>
        <li class="item5"></li>
        <li class="item6"></li>
        <li class="item7"></li>
    </ul>
    ```

- `ul>li.item$@-3*5` + `<C-y>,`: 还可以组合使用上面的修饰符

    ```html
    <ul>
        <li class="item7"></li>
        <li class="item6"></li>
        <li class="item5"></li>
        <li class="item4"></li>
        <li class="item3"></li>
    </ul>
    ```

- `a{click}+b{here}` + `<C-y>,`: Emmet 使用 `Text:{}` 给元素添加文本内容

    ```html
    <a href="">click</a>
    <b>here</b>
    ```

- `a>{click}+b{here}` + `<C-y>,`:

    ```html
    <a href="">click<b>here</b></a>
    ```

- `p>{Click }+a{here}+{ to continue}` + `<C-y>,`:

    ```html
    <p>
        Click
        <a href="">here</a>
         to continue
    </p>
    ```

- `#page>div.logo+ul#navigation>li*5>a{Item $}` + `<C-y>,`:

    ```html
     <div id="page">
         <div class="logo"></div>
         <ul id="navigation">
             <li><a href="">Item 1</a></li>
             <li><a href="">Item 2</a></li>
             <li><a href="">Item 3</a></li>
             <li><a href="">Item 4</a></li>
             <li><a href="">Item 5</a></li>
         </ul>
     </div>
    ```

### 快捷键

- `<Ctrl-y>,`: 展开简写式
- `<Ctrl-y>d`: Balance a Tag Inward(选中包围的标签?)
- `<Ctrl-y>D`: Balance a Tag Outward
- `<Ctrl-y>n`: 进入下个编辑点
- `<Ctrl-y>N`: 进入上个编辑点
- `<Ctrl-y>i`: 更新 `<img>` 图像尺寸
- `<Ctrl-y>m`: 合并文本行
- `<Ctrl-y>k`: 删除标签
- `<Ctrl-y>j`: 分解 / 展开空标签
- `<Ctrl-y>/`: 注释开关
- `<Ctrl-y>a`: 从 URL 生成 anchor 标签
- `<Ctrl-y>A`: 从 URL 生成引用文本

## [Markdown-preview](https://github.com/iamcco/markdown-preview.nvim)

一款在浏览器中预览 markdown 文件的插件

![himg](https://a.hanleylee.com/HKMS/2021-01-19-125822.jpg?x-oss-process=style/WaMa)

### 安装

```vim
Plug 'iamcco/markdown-preview.nvim', {'do': 'cd app & yarn install'}
```

运行 vim, 输入命令:PlugInstall

### 配置

```vim
map <F3>:MarkdownPreview<CR> "设置 F3 开启 Markdown 文件预览
let g:mkdp_auto_start = 0 "打开文件后自动弹出, 0 为否
let g:mkdp_auto_close = 1 "关闭文件后自动关闭预览窗口, 1 为是
let g:mkdp_refresh_slow = 1 "慢速预览, 修改后退出 insert 模式后方会刷新视图, 1 为是
let g:mkdp_open_to_the_world = 0 "开启公网链接, 0 为否
let g:mkdp_browser = '' "指定浏览器, 默认会跟随系统浏览器
let g:mkdp_port = '' " 指定端口, 默认随机端口
let g:mkdp_page_title = ' **${name}** ' "指定浏览器窗口标题, 默认为 Markdown 文件名
```

### 操作命令

- `:MarkdownPreview`: 开启预览
- `:MarkdownPreviewStop`: 停止预览
- `:MarkdownPreviewTroggle`: 开关预览

## [markdown2ctags](https://github.com/jszakmeister/markdown2ctags)

在窗口右侧显示 markdown 目录结构的一个插件, 此插件基于 ctags 和 tagbar(Tagbar 是一个著名的文档目录显示插件, 但是不支持 markdown, 此插件在 Tagbar 的基础上添加了对 markdown 的支持). 因此此插件必须同时安装以上两种插件方可正常工作

### 安装

1. 通过 `brew` 安装 `ctgs`

    ```vim
    brew install ctags
    ```

2. 在 `.vimrc` 文件中添加 `Plug` 名称

    ```vim
    Plug 'jszakmeister/markdown2ctags'
    Plug 'majutsushi/tagbar'
    ```

### 配置

```vim
"*****************   Tagbar   *************************************
"F4 开启和关闭
map <F4>:TagbarToggle<CR>
let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin': '~/.vim/plugged/markdown2ctags/markdown2ctags.py',
    \ 'ctagsargs': '-f - --sort=yes ',
    \ 'kinds': [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro': '|',
    \ 'kind2scope': {
        \ 's': 'section',
    \ },
    \ 'sort': 0,
\ }
```

### 使用

只要在 vim 界面中使用 `:TagbarToggle` 即可调出 Tagbar 界面, 即可显示 markdown 的目录结构.

## [markdownlint](https://github.com/DavidAnson/markdownlint)

一款 markdown 语法检查工具, 可以根据预设的规则进行 markdown 语法错误警告或提示, 可根据需要进行规则自定义

### 安装

```shell
brew install markdownlint-cli
```

### 使用

配合 ALE 插件一起使用

```vim
let g:ale_linters = {
            \   'c': ['clangd'],
            \   'swift': ['swiftlint'],
            \   'markdown': ['markdownlint'],
            \   'sh': ['shellcheck'],
            \   'zsh': ['shellcheck']
            \}
```

### 配置规则

在项目根目录下建立 `.markdownlint.json` 配置文件, 在其中对默认的规则进行配置, ale markdownlint 工具在被调用的时候会自动去查找该名称配置文件

```json
{
  "default": true,
  "MD013": false,
  "MD014": false,
  "MD024": false,
  "MD029": false,
  "MD033": false,
  "MD040": false,
  "no-hard-tabs": false,
  "no-inline-html": {
    "allowed_elements": [
      "a"
    ]
  }
}
```

## [fzf](https://github.com/junegunn/fzf.vim)

`fuzzy find`, 快速模糊搜索查找工具

> fzf.vim 与 终端工具 fzf 配合使用, 在 vim 中的 `:FZF` 与 `Files` 命令都会调用 `export FZF_DEFAULT_COMMAND='...'` 这个参数, 需要在 `.zshrc` 中配置好

### 安装

1. 在终端中安装 fzf 工具

    ```bash
    brew install fzf
    ```

2. `~/.vimrc` 中安装 vim 的 `fzf` 插件

```bash
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
```

### 配置使用

首先在 `.zshrc` 中配置终端中的 fzf 选项, 如下:

```bash
export FZF_DEFAULT_COMMAND="fd --hidden --follow -I --exclude={Pods,.git,.idea,.sass-cache,node_modules,build} --type f"
export FZF_DEFAULT_OPTS="
--color=dark
--color=fg:#707a8c,bg:-1,hl:#3e9831,fg+:#cbccc6,bg+:#434c5e,hl+:#5fff87
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
--height 60%
--layout reverse
--preview-window 'hidden:right:60%'
--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -N -C {}) 2> /dev/null | head -500'
--bind ',:toggle-preview'
--border
--cycle
"
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_CTRL_T_OPTS=$FZF_DEFAULT_OPTS
export FZF_CTRL_R_OPTS="
--layout=reverse
--sort
--exact
--preview 'echo {}'
--preview-window down:3:hidden:wrap
--bind ',:toggle-preview'
--cycle
"

export FZF_ALT_C_OPTS="--preview 'tree -N -C {} | head -500'"
export FZF_TMUX_OPTS="-d 60%"
export FZF_COMPLETION_TRIGGER='**'
```

(fzf 可扩展性很高, 如果进行适当配置, 它可以在你进行路径跳转, 历史命令搜索, 文件搜索等方面给你极大的帮助!)

然后在 vim 中配置 fzf 插件的相关设置

```vim
nnoremap <Leader>fh:History<CR>
nnoremap <Leader>fl:Lines<CR>
nnoremap <Leader>fb:Buffers<CR>
nnoremap <Leader>ff:Files<CR>
nnoremap <Leader>fg:GFiles<CR>
nnoremap <Leader>f?:GFiles?<CR>
nnoremap <Leader>ft:Tags<CR>
nnoremap <Leader>fa:Ag<CR>
nnoremap <Leader>fc:Commits<CR>

let g:fzf_preview_window = 'right:60%' " Always enable preview window on the right with 60% width
let g:fzf_buffers_jump = 1 " [Buffers] Jump to the existing window if possible
" [[B]Commits] Customize the options used by 'git log'
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
let g:fzf_tags_command = 'ctags -R' " [Tags] Command to generate tags file
let g:fzf_commands_expect = 'alt-enter,ctrl-x' " [Commands] --expect expression for directly executing the command
let g:fzf_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit'
            \}
let g:fzf_layout = { 'down': '~60%' }
```

### 命令

`:Files [path]`: 列出 path 路径下的所有文件 (功能等价于 `:FZF` 命令)
`:Buffers`: 文件缓冲区切换
`:Colors`: 选择 Vim 配色方案
`:Tags [QUERY]`: 当前项目中的 Tag (等价于: ctags -R)
`:BTags`: [QUERY]  当前活动缓冲区的标记
`:Marks`: 所有 Vim 标记
`:Windows`: 窗口
`:Lines [QUERY]`: 在所有加载的文件缓冲区里包含目标词的所有行
`:BLines [QUERY]`: 在当前文件缓冲区里包含目标词的行
`:Locate PATTERN`: locate command output
`:History`: v:oldfiles and open buffers
`:History:`: 命令行命令历史
`:History/`: 搜索历史
`:Commands`: Vim 命令列表
`:Maps`: 普通模式下的按键映射
`:Snippets`: Snippets ([UltiSnips][us])
`:Commits`: Git commits (requires [fugitive.vim][f])
`:BCommits`: 查看与当前缓冲区有关的 commit
`:GFiles [OPTS]`: Git files (git ls-files)
`:GFiles?`: Git files (git status)
`:Ag [PATTERN]`: ag search result (ALT-A to select all, ALT-D to deselect all)
`:Rg [PATTERN]`: rg search result (ALT-A to select all, ALT-D to deselect all)
`:Filetypes`: File types

## [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe)

补全插件, 支持 `c`, `c++`, `java`, `python`, `PHP` 等多语言

### 安装

1. 先在 `.vimrc` 文件中添加 Plug 名称

    ```vim
    Plug 'ycm-core/YouCompleteMe'`
    ```

2. 运行 vim, 输入命令 `:PlugInstall`

经历过上述 2 个步骤后, YouCompleteMe 插件还没法使用, 此时打开 Vim 时会看到如下的报错:

```txt
The ycmd server SHUT DOWN (restart with ‘:YcmRestartServer’). YCM core library not detected; you need to compile YCM before using it. Follow the
instructions in the documentation.
```

这是因为, YouCompleteMe 需要手工编译出库文件 ycm_core.so (以及依赖的 libclang.so) 才可使用.  假设使用 vim-plug 下载的 YouCompleteMe 源码保存在目录 ~/.vim/plugged/YouCompleteMe, 在该目录下执行

```bash
# 编译全部语言
./install.py --all  # 或者 /usr/bin/python install.py

# 或仅编译 C 族语言
./install.py --clang-completer
```

## [coc.nvim](https://github.com/neoclide/coc.nvim)

基于 lsp 的补全插件, 基本上支持 lsp 的语言都可以使用此插件进行补全. 此插件利用了 vsc 的插件生态, 方案比较成熟, 推荐使用 (作者是国人)

### 命令

- `CocInstall <plugin>`: 安装插件
- `CocUninstall`: 卸载插件
- `CocConfig`: 打开配置文件 (vim: `~/.vim/coc-settings.json` )
- `CocLocalConfig`: 打开本地配置文件
- `CocEnable`: 开启 coc
- `CocDisable`: 关闭
- `CocUpdate`: 升级插件
- `CocList <flag>`: 列出相关内容
    - `diagnostic`: 诊断信息
    - `extension`: 所有插件
    - `commands`: 所有可用命令
    - `outline`: 大纲
    - `symbols`: symbols

### 常用插件

```vim
coc-clangd
coc-cmake
coc-css
coc-diagnostic
coc-dictionary
coc-emoji
coc-flutter
coc-gitignore
coc-go
coc-highlight
coc-html
coc-java
coc-json
coc-julia
coc-markdownlint
coc-omni
coc-pyright
coc-r-lsp
coc-rome
coc-rust-analyzer
coc-sh
coc-snippets
coc-solargraph
coc-sourcekit
coc-syntax
coc-tabnine
coc-tag
coc-tsserver
coc-vetur
coc-vimlsp
coc-word
coc-yaml
coc-yank
```

## [ludovicchabant/vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)

管理 tag 文件, tag 文件关乎着项目的引用与跳转, 因此是一个比较大的话题, 详细可以参考 [韦大的文章](https://zhuanlan.zhihu.com/p/36279445)

### 安装

1. 安装 `universal-ctags` 命令行程序

    ```bash
    brew tap universal-ctags/universal-ctags
    brew install --HEAD universal-ctags
    ```

2. 安装 vim 插件 vim-gutentags

    ```vim
    Plug 'ludovicchabant/vim-gutentags'
    ```

### 配置

```vim
"*****************   gutentags   *************************************
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project'] " gutentags 搜索工程目录的标志, 当前文件路径向上递归直到碰到这些文件 / 目录名
let g:gutentags_ctags_tagfile = '.tags' " 所生成的数据文件的名称
let g:gutentags_modules = [] " 同时开启 ctags 和 gtags 支持:
if executable('ctags')
    let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
    let g:gutentags_modules += ['gtags_cscope']
endif

let g:gutentags_cache_dir = expand('~/.cache/tags') " 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中
" 配置 ctags 的参数, 老的 Exuberant-ctags 不能有 --extra=+q, 注意
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags'] " 如果使用 universal ctags 需要增加下面一行, 老的 Exuberant-ctags 不能加下一行
let g:gutentags_auto_add_gtags_cscope = 0 " 禁用 gutentags 自动加载 gtags 数据库的行为
```

### 为系统头文件生成 tags

默认情况下, 我们不能跳转到 `printf` 这类标准库中的方法中, 如果需要的话, 我们可以为系统标准库生成 tags, 然后将在 `.vimrc` 文件中为其进行指定, 这样即可跳转到系统的标准库头文件定义中了.

首先将系统中的头文件目录找出来, 然后使用 ctags 对目录中所有文件进行生成

```bash
ctags --fields=+niazS --extras=+q --c++-kinds=+px --c-kinds=+px --output-format=e-ctags -R -f ~/.vim/systags /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include  ~/header
```

然后在 `vim` 中指定 tags 文件的路径即可

```vim
set tags+=~/.vim/systags
```

## [vim-fugitive](https://github.com/tpope/vim-fugitive)

vim 下最好的 git 插件, 同时也是 git 下最好的 vim 插件

### fugitive object

fugitive 插件操作的对象名为 `fugitive object`, 可以是文件也可以是 commit, 下面列举了一些 `fugitive object` 的表示方式

- `@`: The commit referenced by @ aka HEAD
- `master`: The commit referenced by master
- `master^`: The parent of the commit referenced by master
- `master...other`: The merge base of master and other
- `master:`: The tree referenced by master
- `./master`: The file named master in the working directory
- `:(top)master`: The file named master in the work tree
- `Makefile`: The file named Makefile in the work tree
- `@^:Makefile`: The file named Makefile in the parent of HEAD
- `:Makefile`: The file named Makefile in the index (writable)
- `@~2:%`: The current file in the grandparent of HEAD
- `:%`: The current file in the index
- `:1:%`: The current file's common ancestor during a conflict
- `:2:#`: The alternate file in the target branch during a conflict
- `:3:#5`: The file from buffer #5 in the merged branch during a conflict
- `!`: The commit owning the current file
- `!:Makefile`: The file named Makefile in the commit owning the current file
- `!3^2`: The second parent of the commit owning buffer #3
- `.git/config`: The repo config file
- `:`: The |fugitive-summary| buffer
- `-`: A temp file containing the last |:Git| invocation's output
- `<cfile>`: The file or commit under the cursor

### commnads

- `:Git`: 进入 summary 界面
- `:Git <arbitrary subcommand>`: 所有 command line 中 `git...` 后面可以使用的 subcommand 都可以使用, 比如 `:Git push`, `:Git push`, 甚至是在 `~/.gitconfig` 中的 `git alias`.
- `:Git <arbitrary subcommand> -p`: 与上命令相同, 不过会将命令结果单独开一个页面进行显示
- `:Git blame`: 对当前文件执行 `git blame` 命令
- `:Gclog[!]`: 将本 repo 的所有 log 输出至 quickfix, 并跳转至第一个 commit 的信息页面 (添加 `!` 可以防止跳转)
- `:Gllog[!]`: 与 `Gclog` 相同, 但是将结果输出至 `location list`
- `:[range]Gclog[!]`: 给定范围 (比如选中多行), 然后使用 `Gclog` 的话会将与范围相关的所有 commit 列出, 可以使用 `:0Gclog!` 来将与本文件相关的所有 commit 列出
- `:Gread [object]`: 如果不传 `fugitive object`, 则等同于 `git checkout -- file`, 如果传了, 则先将本 buffer 清空, 然后读取指定的 `fugitive-object` 内容到本 buffer 中
- `:Gwrite`: 类似于 `git add`
- `:Gcd [directory]`: cd 到本 root 的根目录下
- `:Gedit [object]`: edit 一个 `fugitive object`
- `:Gdiffsplit [object]`: 使用 `vimdiff` 查看给定的 `object` 与当前 `file` 的差异, 如果给定的是一个 `commit`, 那么会将该 commit 中的本文件与当前本文件进行差异对比
- `:Gvdiffsplit [object]`: 与 `:Gdiffsplit` 相同, 但是永远 split vertically.
- `:Ghdiffsplit [object]`: 与 `:Gdiffsplit` 相同, 但是永远 split horizontally.
- `:GMove {destination}` Wrapper around git-mv that renames the buffer afterward.  Add a! to pass -f.
- `:GRename {destination}` Like |:GMove| but operates relative to the parent directory of the current file.
- `:GDelete`: 与 `git rm --cached **` 相同, Add a! to pass -f and forcefully discard the buffer.
- `:GRemove`: 与 `GDelete` 相同, 但是保持空 buffer 存在
- `:GBrowse`: 在 GitHub 中查看当前 file / commit

### 键位映射

- blame
    - `A`:  resize to end of author column
    - `C`:  resize to end of commit column
    - `D`:  resize to end of date/time column
    - `gq`:  close blame, then `:Gedit` to return to work tree version
    - `<CR>`:  close blame, and jump to patch that added line (or directly to blob for boundary commit)
    - `o`:  jump to patch or blob in horizontal split
    - `O`:  jump to patch or blob in new tab
    - `p`:  jump to patch or blob in preview window
    - `-`:  reblame at commit
    - `~`:  reblame at [count]th first grandparent
    - `P`:  reblame at [count]th parent (like HEAD^[count])
- stage/unstaging
    - `s`: Stage (add) the file or hunk under the cursor.
    - `u`: Unstage (reset) the file or hunk under the cursor.
    - `-`: Stage or unstage the file or hunk under the cursor.
    - `U`: Unstage everything.
    - `X`: Discard the change under the cursor.
    - `=`: Toggle an inline diff of the file under the cursor.
    - `>`: Insert an inline diff of the file under the cursor.
    - `<`: Remove the inline diff of the file under the cursor.
    - `gI`: Open.git/info/exclude in a split and add the file under the cursor.  Use a count to open.gitignore.
    - `I`: Invoke |:Git| add --patch or reset --patch on the file
    - `P`: under the cursor. On untracked files, this instead
    - `gq`: Close the status buffer.
- diff
    - `dd`: Perform a |:Gdiffsplit| on the file under the cursor.
    - `dv`: Perform a |:Gvdiffsplit| on the file under the cursor.
    - `ds`: Perform a |:Ghdiffsplit| on the file under the cursor.
- navigation
    - `<CR>`: Open the file or |fugitive-object| under the cursor. In a blob, this and similar maps jump to the patch from the diff where this was
        added, or where it was removed if a count was given. If the line is still in the work tree version, passing a count takes you to it.
    - `o`: Open the file or `fugitive-object` under the cursor in a new split.
    - `gO`: Open the file or `fugitive-object` under the cursor in a new vertical split.
    - `O`: Open the file or `fugitive-object` under the cursor in a new tab.
    - `p`: Open the file or `fugitive-object` under the cursor in a preview window. In the status buffer, 1p is required to bypass the legacy usage instructions.
    - `~`: Open the current file in the [count]th first ancestor.
    - `P`: Open the current file in the [count]th parent.
    - `C`: Open the commit containing the current file.

### 常用流程

- 查看当前 head 的 diff

`:Gdiffsplit HEAD`

- 查看当前 file 的所有相关 commit

`:0Gclog!`

- 查看当前 file 之前某个版本与现在版本的差异

    1. `:0Gclog!` 列出所有本 file 相关的 commit
    2. `enter` 进入需要对比的 commit
    3. `Gdiffsplit HEAD` 与当前 `HEAD` 对比差异

    > 我们也可以直接找出需要对比的 commit hash, 让后直接使用 `Gdiffsplit commit_hash` 来进行对比.
    > 当进行 diff 对比时, 永远是旧的 commit 信息列在屏幕左侧, 新的 commit 信息列在右侧

## [gv.vim](https://github.com/junegunn/gv.vim)

一款基于 `fugitive` 的查看 vim commit 树形图的工具

### command

- `:GV`: to open commit browser
- `:GV!`: will only list commits that affected the current file
- `:GV?`: fills the location list with the revisions of the current file

### map

- `o` / `<cr>` on a commit to display the content of it
- `o` / `<cr>` on commits to display the diff in the range
- `O`: opens a new tab instead
- `gb`: for:Gbrowse
- `]]`: and [[ to move between commits
- `.`: to start command-line with:Git [CURSOR] SHA à la fugitive
- `q`: or gq to close

## [vim-surround](https://github.com/tpope/vim-surround)

一款超级强大的快速添加 / 删除 / 改变包围符号的神器

### 安装

```vim
Plug 'tpope/vim-surround'
```

### 命令

- `ds`: 删除包围符号
- `cs`: 改变包围符号
- `ysw`: 当前至下一个词尾添加一个包围符号
- `ysW`: 当前至至下一个空格添加一个包围符号
- `ySw`: 当前至下一个词尾添加一个包围符号并将焦点移至下一行
- `ySW`: 当前至下一个空格添加一个包围符号并将焦点移至下一行
- `yss)`: 整行添加包围符号 `()`
- `ysiw)`: 为当前光标下单词添加包围符号 `()`
- `S"`: Visual 模式下对选中区域添加包围符号 `"`
- `gS"`: Visual 模式下对选中区域进行换行并添加包围符号
- `⌃-s`: Insert 模式下插入包围符号
- `⌃-s, ⌃-s`: Insert 模式下在插入包围符号并将焦点移至下一行
- `dst`: 删除 html/xml 的标签内部的所有字符
- `cst`: 删除 html/xml 的标签内部的所有字符并进入插入模式
- `ysa<'`: 在 `<>` 包裹的范围上加符号 `'`

### 范例

```txt
| Old text              | Command  | New text                    |
| :-------------------: | :-----:  | :-----------------------:   |
| "Hello *world!"       | ds"      | Hello world!                |
| [123+4*56]/2          | cs])     | (123+456)/2                 |
| "Look ma, I'm *HTML!" | `cs"<a>` | `<a>Look ma, I'm HTML!</a>` |
| if *x>3 {             | ysW(     | if ( x>3 ) {                |
| my $str = *whee!;     | vlllls'  | my $str = 'whee!';          |
| <div>Yo!*</div>       | dst      | Yo!                         |
| <div>Yo!*</div>       | `cst<p>` | `<p>Yo!</p>`                |
```

## [nerdcommenter](https://github.com/preservim/nerdcommenter)

快速注释插件

### 安装

```bash
Plug 'preservim/nerdcommenter'
```

### 命令

- `<leader>cc`: NERDCommenterComment, 注释当前行或所选择行 (文本)
- `<leader>cu`: NERDCommenterUncomment, 取消当前所处位置的注释状态 Uncomments the selected line(s).
- `<leader>ci`: NERDCommenterInvert, 反转所选择行的注释状态 (逐个地反转) `仅支持行`
- `<leader>c<space>`: NERDCommenterToggle (反) 激活所选择行的注释状态, 依据最顶部行的注释状态进行判断, 执行命令后, 所选择行的注释状态均为最顶部行注释状态的相反状态. `仅支持行`
- `<leader>cn`: NERDCommenterNested, 与 cc 相同, 不过嵌套地进行注释
- `<leader>cs`: NERDCommenterSexy, 将当前选择文本以块的方式进行注释 (即在选择文本的上方与下方加上单行注释) `仅支持行`
- `<leader>cy`: NERDCommenterYank, 与 cc 完全相同, 不过会先进行复制操作
- `<leader>c$`: NERDCommenterToEOL Comments the current line from the cursor to the end of line.
- `<leader>cA`: NERDCommenterAppend, Adds comment delimiters to the end of line and goes into insert mode between them.
- `<leader>ca`: NERDCommenterAltDelims Switches to the alternative set of delimiters.
- `<leader>cm`: NERDCommenterMinimal, Comments the given lines using only one set of multipart delimiters.

## [tpope/vim-commentary](https://github.com/tpope/vim-commentary)

快速注释插件, 相比于 `nerdcommenter` 更加简洁实用

### 安装

```bash
Plug 'tpope/vim-commentary'
```

### 命令

- `gcc`: 注释或反注释
- `gcap`: 注释一段
- `gc`: visual 模式下直接注释所有已选择的行

## [terryma/vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors)(已废弃, 推荐使用 [vim-visual-multi](#vim-visual-multi))

实现真正的多光标的一个插件, vim 的 visual block 模式并不是多光标, 如果想将 visual block 模式下被选中的多行的当前单词推进到每个单词的末尾, 那么就需要使用到多光标的概念.

> 我理解的此多光标插件的使用分为两种状态
>
> - 从 normal 模式直接使用 `<C-n>` 进入多光标状态并选中当前光标下的单词, 然后再次使用 `<C-n>` 选择下一个, `<C-x>` 跳过当前符合的单词, 最后进行插入修改等操作
> - 从 visual 或 visual block 模式下使用 `<C-n>` 进入直接添加光标到当前所有行的选中单词处, 然后移动光标, 在合适位置进行进行插入修改等操作, 最后 esc 两次退出

### 安装

```bash
Plug 'terryma/vim-multiple-cursors'
```

### 命令

- `<C-n>`: 进入多光标状态 / 或选择下一个符合当前选择的单词
- `<C-x>`: 跳过当前候选
- `<C-p>`: 移除当前单词处的光标及选择状态跳转到上一个光标处

```vim
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'
```

## [vim-visual-multi](https://github.com/mg979/vim-visual-multi)

### 安装

```vim
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
```

### Maps

- `<C-n>`: 选择当前光标所在的单词, 进入 `V-M` (visual multi) 模式
- `<C-Down>` / `<C-Up>`: 创建垂直光标选区
- `<S-Arrows>`: 一次创建一个字符选区
- `n` / `N`: 选择下一个出现的相同字符
- `[/` / `]`: 跳转到上一个 / 下一个选区处
- `q`: 跳过当前并选择下一个出现的地方
- `Q`: 移除当前的选取
- `i` / `a` / `I` / `A`: 进入插入模式
- `<Tab>`: 在 `cursor mode` 与 `extend mode` 之间切换

> 在 `V-M` 模式中, 绝大多数 vim 命令都是可以使用的, 比如 `r`, `~`

## [ctrlsf.vim](https://github.com/dyng/ctrlsf.vim)

一个异步批量搜索替换工具

### 安装

```vim
Plug 'dyng/ctrlsf.vim'
```

### Commands

- `CtrlSF [pattern]`: 搜索匹配字符串

### Maps

- 在 `CtrlSF window` 中:
    - `<CR>` / `o`: 在相应的文件中打开相应的行
    - `<C-O>`: 在 `horizontal split window` 中打开
    - `t`: 在新 tab 中打开
    - `p`: 在 preview 中打开
    - `P`: 在 preview 中打开并将焦点移动到 preview 上
    - `O`: 与 `o` 相同, 但是保持 `CtrlSF` 开启
    - `T`: 与 `t` 相同, 但是保持 focus 在 CtrlSF 上
    - `M`: 在 `normal view` (sublime) 与 `compact view` (quick-fix) 切换
    - `q`: 退出 CtrlSF
    - `<C-j>`: 移动光标到下一个匹配处
    - `<C-k>`: 移动光标到上一个匹配处
    - `<C-c>`: 停止搜索
- 在 `preview window` 中
    - `q`: 关闭 `preview`

## [seoul256.vim](https://github.com/junegunn/seoul256.vim)

一套配色 vim 配色方案, 韩国人出品. 与之匹配的还有一个 iTerm 配色方案, 两者结合的比较好看

### 安装

在.vimrc 文件中添加 Plug 名称及设定:

```vim
Plug 'junegunn/seoul256.vim'
colo seoul256
let g:seoul256_background = 236 "设置背景颜色深度
set background=dark "设置背景颜色为黑色, 必须设置, 否则上面的数值设置没有意义
" seoul256 (dark):
"   Range:   233 (darkest) ~ 239 (lightest)
"   Default: 237
```

## [Goyo.vim](https://github.com/junegunn/goyo.vim)

一款专注写作的 vim 插件, 开启后四周空白, 更利于专注. 不适用于写代码和看代码

### 安装

1. 在.vimrc 文件中添加 Plug 名称及设定:

    ```vim
    Plug 'junegunn/goyo.vim'
    ```

## 命令

- `:Goyo`: 进入专注模式
- `:Goyo!`: 退出专注模式, 或使用:q
- `:Goyo 90%`: 调整高度为窗口的 90%
- `:Goyo x30%`: 调整宽度为窗口的 30%
- `:Goyo 70%-10x90%+10%`: 调整区域宽为窗口 70%, 左边距向左移 10 单位, 高度为窗口 90%, 向下移动窗口的 10%

## [Limelight](https://github.com/junegunn/limelight.vim)

与 `Goyo`, `seoul256` 为同一开发者, 联合使用效果最佳. 不适用于写代码和看代码.

[官网](https://github.com/junegunn/limelight.vim)

### 安装

在 `.vimrc` 文件中添加 `Plug` 名称及设定:

```vim
Plug 'junegunn/limelight.vim'
let g:limelight_default_coefficient = 0.5 // 设置隐藏区域的黑暗度, 值越大越暗
let g:limelight_paragraph_span = 2 // 设置暗光的跨度, 暗光所能照亮的范围
let g:limelight_priority = -1 // 暗光优先级, 防止搜索的高亮效果被覆盖
autocmd! User GoyoEnter Limelight // 进入 Goyo 专注插件时, 同时开启暗光效果
autocmd! User GoyoLeave Limelight! // 离开 Goyo 专注插件时, 同时退出暗光效果
```

### 命令

- `:Limelight` // 进入 Limelight 状态
- `:Limelight!` // 退出 Limelight 状态
- `:Limelight0.3` //

## [XVim](https://github.com/XVimProject/XVim2)

如果你同时是一名 iOS 开发者, 那么 `XVim` 可以帮助你在 `Xcode` 中找回缺失的 `Vim` 操作, XVim 可以让 Xcode 像 vim 一样编辑.

> 由于 XVim 没有上架到 Mac App Store, 因此我们需要进入官网下载源码编译按照, 编译前需要对 Xcode 进行自签名, 否则我们自己编译出来的结果文件是不能安装到 Xcode 上的

[官网](https://github.com/XVimProject/XVim2)

### 安装

1. 对系统的代码证书重新生成

    [XVimProject/XVim2](https://github.com/XVimProject/XVim2/blob/master/SIGNING_Xcode.md)

2. 克隆源码仓库

    ```vim
    git clone https://github.com/XVimProject/XVim2.git
    ```

3. 确认 xcode 内容点

    ```vim
    xcode-select -p
    /Applications/Xcode.app/Contents/Developer
    ```

    如果有多个版本 Xcode, 此项会让你清楚你将安装 XVim 到哪一个版本上, 如果结果不是你想要的版本, 那么使用 `xcode-select -s <path-of-xcode>` 进行手动指定

4. make

    ```vim
    cd XVim2
    make
    ```

5. 按照需要可生成 `.xvimrc` 文件 ( `.xvimrc` 文件必须放在用户主目录, 即 `.vimrc` 同级目录)
6. 重启 Xcode
7. 完成安装

### 使用

- `:run`: xcode 代码运行
- `:make`: 构建 xcode 代码
- `:xhelp`: 光标位置快速帮助
- `:xccmd`: 执行 xcode 菜单
- `⌃ g`: 打印当前行的位置

## Vimum

`Vimum` 是一款 `Chrome` 插件, 使用 vim 的模式概念让我们可以脱离鼠标访问浏览网页

- `gg`: 跳转到页面顶部
- `G`: 跳转到页面底部
- `gi`: 激活搜索框
- `j`: 页面向下滚动
- `k`: 页面向上滚动
- `u`: 页面向上翻页
- `d`: 页面向下翻页
- `r`: 刷新当前页面
- `H`: 页面回退到上一次历史
- `L`: 页面从历史记录中返回来
- `x`: 关闭页面
- `X`: 恢复被关闭的页面 (可多次重复)
- `f`: 显示页面上各个点击点的链接, 可以在当前页打开
- `F`: 显示页面上各个点击点的链接, 在新页面打开
- `gt`: 向右侧浏览下一个 tab
- `gT`:  向左侧浏览 tab
- `yf`:  拷贝页面上显示的链接
- `yy`: 拷贝当前网页的链接
- `yt`: 复制当前 tab
- `v`:  进入选择模式, 可选择文本, 第一次按下时会进入 `creat mode`, 选中起点后再次按下 `v` 将启用选择模式, 然后按下 `y` 来进行复制. 如果需要再次进入
`creat mode`, 可使用 `c` 按键. 如果在复制中要改变复制区域的起点, 可以使用 `o` 按键, 或者在使用 `/` 进行搜索确定焦点后进行 `v` 选择操作.
    在选择模式中可使用 `w`, `b`, `h`, `j`, `k`, `l`, `e`, `$` 来进行移动
- `V`: 进入行选择模式, 可批量选择多行文本
- `o`: 键入搜索内容, 可在当前页面显示历史记录或打开网页链接或搜索新内容
- `O`: 兼容搜索内容, 在新页面给出与 o 键相同的结果
- `b`: 搜索书签, 并在当前页面打开
- `B`: 搜索书签, 并在新页面打开
- `T`: 在已打开的 tab 中进行搜索
- `/`: 搜索当前页面值, 使用 `⌘ F` 进行也页面搜索, `/` 不能搜索中文
- `n`: 选中下一个搜索结果
- `N`: 选中上一个搜索结果

## Vimari

如果你正在使用 `Safari`, 但是也想在浏览器中使用 vim 的操作, 那么 `Vimari` 就很适合你了, 因为 `Vimum` 不支持 `Safari`, 因此 `Vimari` 就诞生出来了,
虽然没有 `Vimum` 功能那么强大, 但是基本的浏览操作倒是都覆盖了

- `f`: 触发跳转
- `F`: 触发跳转 (新 tab 中打开链接)
- `h/j/k/l`: 移动
- `u`: 向上翻页
- `d`: 向下翻页
- `gg`: 跳转到页面顶部
- `G`: 跳转到页面底部
- `gi`: 跳转到第一个输入处
- `H`: 回到前一个历史页面
- `L`: 回到后一个历史页面
- `r`: 重载页面
- `w`: 下一个 tab
- `q`: 上一个 tab
- `x`: 关闭当前 tab
- `t`: 开启新 tab

## 其他插件

vim 丰富的插件生态是其一大特色, 本文只是起到抛砖引玉的功能, 更多实用的插件有待读者的发现. 以下列举了笔者常用的插件.

```vim
"============= File Management =============
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " 模糊搜索
Plug 'junegunn/fzf.vim'                             " 模糊搜索
Plug 'embear/vim-localvimrc'                        " 用于针对工程设置 vimrc

" ============= Edit ===========
Plug 'ycm-core/YouCompleteMe'                       " 补全插件
Plug 'SirVer/ultisnips'                             " 自定义某些片段
Plug 'ludovicchabant/vim-gutentags'                 " 根据 ctags 或 gtags 生成 tags 进行使用, 自动管理
Plug 'skywind3000/gutentags_plus'                   " 提供
Plug 'Shougo/echodoc.vim'
Plug 'lyokha/vim-xkbswitch', {'as': 'xkbswitch'}    " 返回到 normal 模式时快速切换为英文输入法
Plug 'dense-analysis/ale'                           " 提示语法错误
Plug 'easymotion/vim-easymotion'                    " 空格任意跳转
Plug 'bronson/vim-visual-star-search'
Plug 'jiangmiao/auto-pairs'                         " 匹配括号
Plug 'dhruvasagar/vim-table-mode'                   " 自动表格, 使用 `\tm` 就进入了表格模式, 会进行自动对齐
Plug 'godlygeek/tabular'                            " 文本对齐, 使用:Tabularize /= 可以等号对齐多行
Plug 'terryma/vim-multiple-cursors'                 " 多行文本操作
Plug 'tpope/vim-commentary'                         " 快速注释, gcc
Plug 'tpope/vim-repeat'                             " 支持重复
Plug 'tpope/vim-surround'                           " 包围符号
Plug 'tpope/vim-unimpaired'

" ============= Appearance ============
Plug 'joshdick/onedark.vim'
Plug 'ap/vim-css-color'              " 显示 css 颜色
Plug 'machakann/vim-highlightedyank' " 使 yank 的文档半透明高亮
Plug 'mhinz/vim-signify'             " 显示当前行的 git 状态
Plug 'Yggdroot/indentLine'           " 显示缩进线
Plug 'itchyny/lightline.vim'         " 显示底部导航栏

"============== Function ==============
Plug 'majutsushi/tagbar'        " 显示文档的层级
Plug 'qpkorr/vim-renamer'       " 批量修改文件的神器, 使用:Ren 进行编辑与保存, 完成后退出即可
Plug 'Chiel92/vim-autoformat'   " 自动格式化文档
Plug 'skywind3000/asyncrun.vim' " 异步执行
Plug 'tpope/vim-fugitive'       " git 插件
Plug 'jiazhoulvke/jianfan'      " 简繁转换 Tcn, Scn
Plug 'simnalamburt/vim-mundo'   " 显示修改历史

"============== Language ==============
Plug 'plasticboy/vim-markdown'       " markdown 增强插件
Plug 'jszakmeister/markdown2ctags'   " markdown 层级显示
Plug 'iamcco/markdown-preview.nvim', {'do': 'cd app & yarn install'} " Markdown 实时预览
```

实际上以上所列出的插件很多仅由百余行的文件构成, 所以如果一些插件不能满足需求的话完全可以按照自己的想法写出一个适合自己的插件. 想法最重要, 做一件事只要有了想法就成功了 80%.

## 最后

我的 vim 配置仓库: [hanleylee/dotvim](https://github.com/hanleylee/dotvim)

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow
