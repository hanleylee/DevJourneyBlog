---
title: iPad 文本编辑工具 iVim 使用
date: 2020-02-03
comments: true
path: text-editor-ivim-on-ipad
categories: Tools
updated:
---

Vim 作为一个在主机端历史悠久且享誉无数的文本编辑软件, 很多人都习惯了其操作逻辑. 前段时间使用了一些 iPad 上的文本编辑软件, 发现了一款软件 - iVim, 基本继承了主机端的操作方式, 除了不能安装插件之外基本已经无可挑剔, 与其他 vim 的 iPad 版本移植比较下来算得上是最完美的版本(此软件只有`自动恢复上次编辑`功能收费).

看了下网上对于这个软件的使用方式介绍很少, 由于 iOS 的系统文件管理方式与主机端不同, 因此很多人甚至进去后都不知道怎么使用配置文件`.vimrc`, 因此本文主要介绍下如何简单使用此软件. 如果想看详细的简洁版 vim 使用请移步 [神级编辑器 Vim 使用](https://www.hanleylee.com/usage-of-vim-editor.html)

![himg](https://a.hanleylee.com/HKMS/2020-02-03-main.png?x-oss-process=style/WaMa)

<!-- more -->

## 安装

App Store 搜索 iVim 下载即可

## iOS 文件管理机制

由于 iOS 的文件管理是封闭的, 默认不会显示隐藏文件, iVim 的`.vimrc`文件为隐藏文件, 因此不会被显示

![himg](https://a.hanleylee.com/HKMS/2020-02-03-hidden%20vimrc.gif)

通过管理工具(e.g. iMazing)可以看到文件夹内的隐藏文件

![himg](https://a.hanleylee.com/HKMS/2020-02-03-imazing%20show.png?x-oss-process=style/WaMa)

## 使用

- `:w .vimrc`: 保存当前编辑文档为`.vimrc`

    此命令为初次配置`.vimrc`使用, 之后每次使用配置文件直接打开`.vimrc`文件即可.

    如果想参考 vimrc 配置请移步 [我的 GitHub](https://github.com/HanleyLee/Config)

- `e ~/.vimrc`: 打开配置文件`.vimrc`

- `:help ios`: 显示 iVim 的功能帮助

- `:help`: 显示 vim 的功能帮助

- `:ishare`: 将当前编辑的文件分享到其他应用中

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-ishare.gif)

- `:idocuments import`: 导入文件进行编辑, 导入的文件会存放在 `File` → `On My iPad` → `iVim`中

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-idocuments%20import.gif)

- open in iVim: 使用 iOS 的 share 选项将文件在 iVim 中打开, 保存时直接保存到原路径.

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-open%20in%20iVim.gif)

- copy to iVim: 使用 iOS 的 share 选项将文本的内容作为 buffer 复制到 iVim, 在 iVim 编辑完成后保存时要新建文件

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-copy%20to%20iVim.gif)

[在 iPad 上使用蓝牙键盘可以用到的快捷键](https://www.hanleylee.com/shortcut-of-bluetooth-keyboard-on-ipad.html)
