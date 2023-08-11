---
title: Use keycode in terminal and vim
date: 2021-08-25
comments: true
path: use-keycode-in-terminal-vim
categories: Terminal
tags: ⦿vim, ⦿terminal, ⦿keycode, ⦿tool
updated:
---

![himg](https://a.hanleylee.com/HKMS/2021-08-26144756.jpg?x-oss-process=style/WaMa)

Vim 的按键映射在 GUI 情况下的支持是相当完备的, 例如 `<M-...>`, `<D-...>`, 但是如果 vim 处于 `terminal` 中, 那么就需要做额外一些处理

<!-- more -->

terminal 中的 vim 接受的按键是经过 terminal 处理的, 换句话说, 如果在 terminal 中就不能正确接受到一个按键组合, 那么 运行在 terminal 上的 vim 是不可能获得正确事件并作出相应动作的

## keycode

我们做映射的关键就是理解 `keycode` 在 terminal 到 vim 的传递及转化

- `terminal key code`: `^[[1;2A`, `^[` 表示 `ESC`
- `vim key code`:, `<S-Up>`, Vim 的 keycode 具有字面含义, 因为他要运行在不同的系统上

### 查看方式

- `terminal`: 使用 `cat` 或 `sed -n l` 等支持管道的命令, 然后直接按下按键组合即可显示
- `vim`: 在命令模式下使用 `<C-v>key` 可显示当前按键组合在 vim 中所产生的字符序列

### vim 支持的 keycode

[key code](https://vimhelp.org/intro.txt.html#keycodes)

[termcap](https://vimhelp.org/term.txt.html#termcap)

总的来说, vim 支持

- `<F1>` ~ `<F37>`
- `<S-F1>` ~ `<S-F37>`
- `<C-Home>`, `<C-End>`
- `<S-Home>`, `<S-End>`
- `<S-a>` ~ `<S-z>`
- `<C-a>` ~ `<C-z>`
- `<A-a>` ~ `<A-z>`
-...

默认情况下, 以下的 `keycode` 是没有使用的, 我们可以映射为以下按键

- `<S-F1>` ~ `<S-F12>`
- `<F13>` ~ `<F37>`
- `<S-F13>` ~ `<S-F37>`
- `<xF1>` ~ `<xF4>`
- `<S-xF1>` ~ `<S-xF4>`

### set vim internal keycode

首先我们在终端中将我们需要的按键的 `terminal keycode` 获得, 然后在 vim 中使用 `set` 来绑定 `vim keycode`, 最后使用 map 对该 `vim keycode` 进行映射

- `:set <S-Down>=^[[1;2B`: `^[` 表示 `ESC`, 将终端产生的 `term keycode` 绑定为 vim 的 `<S-Down>`
- `:set <C-S-Down>=^[[1;6B`: 错误! 因为 vim 不支持这样的 `keycode`
- `:map <Esc>[1;6B <C-S-Down>`: 使用这种方式可以避免上个的错误, 这样是将 `term keycode` 转换为了 `vim keystroke`
- `execute "nmap \ed-r <D-r>"`: 使用 `<ESC>d-r` 序列进行映射, 将 `term keycode` 转换为了 `vim keystroke`
- `nmap <lt>D-r> <D-r>`: 直接用 `<D-r>` 字符串进行映射, 将 `term keycode` 转换为了 `vim keystroke`
- `:set <S-Down>={C-v}{Esc}[1;2B`: 使用字面意义进行绑定, `{}` 表示真实的按键所产生的结果
- `:set <S-Down>={C-v}{S-Down}`: 同上

> 当我们在 `term keycode` -> `vim keycode` 这一步不允许时, 可以转变思路为 `term keycode` -> `vim keystroke` 当我们写脚本时, 不能使用 `set <C-S-Down>=^[[1;6B`, 需要使用 `execute "set <C-S-Down>=\e[1;6B"`

## 一些错误写法示范

- `:set <F13>=^[[1;2B`, `:map <F13> <S-Down>`: 多余, `<S-Down>` 默认已经被 `vim keycode` 支持了, 不需要使用 `<F13>`, 直接 `:set <S-Down>=^[[1;2B`
- `:map <C-{C-v}{BS}> <C-BS>`: 不正确, `{C-v}{BS}` 可以使用 `<C-^?>` 代替, 不需要再使用没必要的映射

## ASCII 标准键盘字符码表

![himg](https://a.hanleylee.com/HKMS/2021-08-26141124.png?x-oss-process=style/WaMa)

[link](https://www.csee.umbc.edu/portal/help/theory/ascii.txt)

## 如何从 MacVim 中映射 command 与 option

默认下, MacVim 支持设置 `<D-...>` 的 map 使用 `⌘` 键与其他按键的组合, 设置 `set macmeta` 后可以用 `<M-...>` 来表示 `⌥` 键与其他按键的组合

因为有一些 `⌘` 组合键已经被 MacVim 预定义了, 我们可以使用 `macmenu &File.Print key=<nop>` 的方式移除快捷键, 然后定义自己的动作

## 如何从 iterm 中映射 command 与 option

本文讲的就是如何让 terminal 中发射的字符被 vim 正确利用. 在理解了以上文章的基础上, 我们可以使用任何终端进行自定义, 针对于 `iterm2`, 我们可以这样

![himg](https://a.hanleylee.com/HKMS/2021-08-26144756.jpg?x-oss-process=style/WaMa)

当然, iTerm2 还支持一个选项: `Send Test with "vim" Special Chars`, 这个选项用来法 `<C-...>` 系列的按键还是可以的, 但是对于 `<D-...>` 按键来说则不生效, 如果要使用, 我们还是需要将 `term keycode` 转为 `vim keystroke`

![himg](https://a.hanleylee.com/HKMS/2021-08-26152338.png?x-oss-process=style/WaMa)

这样使用 `<D-b>` 的话就和直接 `Send Text` 没什么区别了

## 未知问题

- `set <D-r>=...` 会报错

## 参考

- [Mapping fast keycodes in terminal Vim](https://vim.fandom.com/wiki/Mapping_fast_keycodes_in_terminal_Vim)
- [Using the ⌘Command Key For Vim Shortcuts](https://www.dfurnes.com/notes/binding-command-in-iterm)
