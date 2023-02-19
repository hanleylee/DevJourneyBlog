---
title: Launch Vim as vanilla
date: 2021-09-02
comments: true
path: lauchn-vim-as-vanilla
categories: Terminal
tags: ⦿vim, ⦿vanilla
updated:
---

![himg](https://a.hanleylee.com/HKMS/2021-10-07032957.png?x-oss-process=style/WaMa)

有时我们可能会需要 vim 加载任何插件进行启动, vim 在这方面也提供了充分的自定义选项, 根据不同需要, 可以通过不同的方式达到目的

<!-- more -->

为了尽可能清楚详尽的剖析它们的区别, 我做了如下表格

> `vim_rtp` = */usr/share/vim/vimfiles*, */usr/share/vim/vim82*, */usr/share/vim/vimfiles/after*
>
> `user_rtp` = *~/.vim,~/.vim/after*
>
> `vim_defaults_load` = */usr/share/vim/vim82/defaults.vim*, */usr/share/vim/vim82/filetype.vim*, */usr/share/vim/vim82/ftplugin.vim*, */usr/share/vim/vim82/indent.vim*, `/usr/share/vim/vim82/syntax/**/*.vim`
>
> `vim_user_load` = `~/.vim/ftdetect/**/*.vim`

| method                                | &rtp                   | load vim plugin(such as `netrw`) | load user plugin             |
|---------------------------------------|------------------------|----------------------------------|------------------------------|
| `vim -u NONE`                         | `vim_rtp` + `user_rtp` | NONE                             | NONE                         |
| `vim -u DEFAULTS`                     | `vim_rtp` + `user_rtp` | `vim_defaults_load`              | `vim_user_load`              |
| `vim -u NORC`                         | `vim_rtp` + `user_rtp` | all                              | all(no *~/.vimrc*)           |
| `vim --clean`                         | `vim_rtp`              | `vim_defaults_load`              | NONE                         |
| `vim --clean --cmd "set loadplugins"` | `vim_rtp`              | all                              | NONE                         |
| `HOME=/tmp/vim_tmp vim`               | `vim_rtp` + `user_rtp` | all                              | allfile under */tmp/vim_tmp* |

> 以上结果可以使用 `echo &rtp` 与 `:scriptnames` 进行输出验证

## 单独测试某一插件

如果我们要测试一个插件的 bug, 那么最好就是使用一个干净的 vim 环境, 然后只加载此插件, 这时就可以使用 `HOME=~/vim_test_home vim` 这种方式了.

在这种方式下, 我们可以在 `~/vim_test_home` 文件夹中只添加某一插件的相关配置, 不设任何自定义功能, 这样可以快速准确判断出该 bug 是否属于该插件

## 快速验证 vim 的一个默认功能

这时我们可以使用 `vim --clean --cmd "set loadplugins"`. 为什么? 因为这样不仅可以不加载任何用户自定义的配置, 还能加载 vim 的默认插件 (比如 `netrw`)

## 一些其他启动选项

- `vim [option] [files]`
    - `-N`: nocompatible mode
    - `-i NONE`: without reading your `viminfo` file

## 在 shell 环境中设置 alias

另外为了方便, 可以在 `~/.zshrc` 中设置如下 `alias`

- `alias vn='vim -u NONE -U NONE -N -i NONE'`
- `alias vc='vim --clean --cmd "set loadplugins"'`
- `alias vt='HOME=~/vim_test_home vim'`

## load plugin at anytime

我们可以使用 `runtime! plugin/**/*.vim` 来加载`runtimepath` 下所有子文件夹`plugin` 下的 vim 文件

## Ref

- [--clean](https://vimhelp.org/starting.txt.html#--clean)
- [-u](https://vimhelp.org/starting.txt.html#-u)
- [-U](https://vimhelp.org/starting.txt.html#-U)
- [-i](https://vimhelp.org/starting.txt.html#-i)
- [Load plugins in vim started with --noplugin](https://vi.stackexchange.com/questions/28034/load-plugins-in-vim-started-with-noplugin)
- [How can I get Vim to ignore all user configuration, as if it were freshly installed?](https://vi.stackexchange.com/questions/6112/how-can-i-get-vim-to-ignore-all-user-configuration-as-if-it-were-freshly-instal)
