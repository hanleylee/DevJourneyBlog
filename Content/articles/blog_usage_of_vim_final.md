---
title: 神级编辑器 Vim 使用-最后
date: 2021-01-15
comments: true
path: usage-of-vim-editor-last
categories: Terminal
tags: ⦿vim, ⦿tool
updated:
---

本文是系列笔记的最后一篇, 在这里讨论下与 vim 操作无关的事情 `^_^`

![himg](https://a.hanleylee.com/HKMS/2020-01-09-vim8.png?x-oss-process=style/WaMa)

<!-- more -->

本系列教程共分为以下五个部分:

1. [神级编辑器 Vim 使用-基础篇](https://www.hanleylee.com/usage-of-vim-editor-basic.html) <!-- ./blog_usage_of_vim_basic.md -->
2. [神级编辑器 Vim 使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html) <!-- ./blog_usage_of_vim_operation.md -->
3. [神级编辑器 Vim 使用-插件篇](https://www.hanleylee.com/usage-of-vim-editor-plugin.html) <!-- ./blog_usage_of_vim_plugin.md -->
4. [神级编辑器 Vim 使用-正则操作篇](https://www.hanleylee.com/usage-of-vim-editor-regex.html) <!-- ./blog_usage_of_vim_regex.md -->
5. [神级编辑器 Vim 使用-最后](https://www.hanleylee.com/usage-of-vim-editor-last.html) <!-- ./blog_usage_of_vim_final.md -->

## Vim 会不会过时

`Vi(m)` 在上世纪 80 年代左右就已经诞生了, 时至今日, 市面上流行的文本编辑器没有任意一个比 vim 更长寿(Emacs 除外). 而且, 我认为 vim 在可预见的未来内也不会过时, 原因有以下几点:

- vim 基于终端, 可与终端中的工具无缝切换使用, 而终端中的工具有一个特点: 那就是生命力顽强, 经久不衰
- vim 在创始人 `Bram Moolenaar` 的带领下始终保持着不断地迭代更新, 从 [这里](https://github.com/vim/vim) 可以看到
- vim 一开始的定位就是文本编辑器, 而不是开发环境 `IDE`, 其只专注于文本操作, 这使得其在文本操作这个细分领域几乎无可匹敌
- 目前有大量的 `C/C++` 程序员都在使用 vim 作为其文本编辑工具, 用户量庞大

## 如何更高效地学习 Vim

以下是几点个人对于 vim 操作技能提升的建议

- 如果你经常使用 `hjkl` 键进行连续移动, 请重新思考你使用 vim 的意义何在
- 如果一处编辑花费了你较多的操作, 那么请停止一下, 绝对有其他操作方式让你更高效的完成编辑
- 如果有简单的重复性的操作, 请充分考虑 `.` 命令
- 如果有复杂的重复性的操作, 请考虑宏
- 如果一种操作需要多文件使用, 以后也有可能会用到, 请考虑使用脚本文件

最后, 请将 vim 作为你的唯一编辑器用于所有文字编辑(本系列文章以及我所有笔记整理都是由 vim 来完成的), 这会让你在实践中快速进步

## 后续如何继续提高学习?

无论如何, 我都认为 vim 官方的帮助文档时最好的学习资料, 使用方法非常简单: normal 模式下输入 `:h [command]` 即可, 这可以很快速的定位到你想要了解的知识上, 而且叙述简单明了. e.g. `:h netrw`

在官方文档这么详细的背景下, 很多第三方插件也在插件的帮助文档中对其插件功能及可配置项进行了详细的说明, 使用方式也是 `:h [command]`.

另外, 也有一系列的书对 vim 的一些特性进行了深入挖掘, 这里推荐:

- *Vim 使用技巧(第2版)* - Drew Neil
- *Vim 8 文本处理实战* - 鲁兰斯.奥西波夫

## Vim 常见问题

### 光标移动速度慢

主要原因有两点

1. vim 中的插件拖慢了速度

    vim 的第三方状态栏插件 `air-line` 插件开启后光标移动会被卡住, 改为 `powerline` 或 `lightline`, 效果好多了

2. 在系统设置中将重复时间调至最短, 速度仍然不够快, 在终端中使用如下设置

    ```bash
    defaults write NSGlobalDomain KeyRepeat -int 1
    ```

    在系统设置中调至最快所对应的值是 2, 这里设置成 1 会变得更快. 最快的值是 0, 不过已经超出可控范围了, 因此不建议设置.

### 中文输入法下在 MacVim 中输入中文会导致大量重复拼音

- 原因

    输入法没有完全截获按键

- 解决办法

    终端下输入 `defaults write org.vim.MacVim MMUseInlineIm 0`

- 原理

    将输入法针对于 `MacVim` 设置为单行模式

## 最后

我的 vim 配置仓库: [HanleyLee/dotvim](https://github.com/hanleylee/dotvim)

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow
