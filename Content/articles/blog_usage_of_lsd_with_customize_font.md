---
title: ls 利器 - lsd 使用及自定义字体
date: 2020-02-03
comments: true
path: ls-tools-on-terminal
categories: Terminal
updated:
---

在终端中查看当前目录文件结构几乎是我们日常在终端中最频繁的操作了, 默认的 ls 命令功能很丰富, 但是不够**美观**与**直观**, 插件 lsd 可以为 ls 命令中的不同类型文件或文件夹添加不同颜色, 并且使用对应的图标进行标识, 简洁直观.

![himg](https://a.hanleylee.com/HKMS/2020-01-20-223603.png?x-oss-process=style/WaMa)

<!-- more -->

[官网 | GitHub](https://github.com/Peltoche/lsd)

## 安装

这里只简要介绍 macOS 使用 [Homebrew](https://brew.sh/) 安装, 其他系统安装或者其他安装细节问题请参考[官网](https://github.com/Peltoche/lsd).

```bash
brew install lsd
```

## 使用

`lsd`: 最基础命令, 显示当前目录结构

`lsd -l`: 以竖向列表显示当前目录结构

`lsd -la`: 以竖向列表显示当前目录结构(含隐藏文件)

`lsd --tree`: 以目录树格式显示当前目录结构

ps: 使用 zsh 的情况下在`~/.zshrc`文件中添加`alias l='lsd -l'`可以极大地提高幸福指数🤣(如果使用`bash`的话需要在`.bashrc`中进行设置)

## 自定义字体

lsd 要求必须使用 [Iconic 字体](https://github.com/ryanoasis/nerd-fonts) 才可以显示出图标的效果, Iconic 字体的原理就是将 unicode 的一些码点设置为相应的图标, 以达到输入相应文字出现对应图标的效果(与 emoji 的原理类似).

Iconic 字体中默认并没有中文字体, 如果在终端中使用了原生 Iconic 字体, 那么将不能正常显示中文. 考虑到国人在终端中还是有显示中文字体的需求的, 因此我融合了数套字体以完美显示中文, 西文, Iconic 字符. 字体在终端以及 Vim 的显示效果如下:

![himg](https://a.hanleylee.com/HKMS/2020-01-20-223603.png?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-01-20-221736.png?x-oss-process=style/WaMa)

如果你觉得这套字体符合你的审美, 请移步 [我的 GitHub](https://github.com/HanleyLee/Yahei-Consolas-Icon-Hybrid-Font)

### 字体使用

#### 安装(以 macOS 为例)

1. 使用系统自带的`FontBook`软件打开字体文件

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-043210.png?x-oss-process=style/WaMa)

2. 确认安装

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-043844.png?x-oss-process=style/WaMa)

此时, 打开`FontBook`便可以看到安装的字体文件

![himg](https://a.hanleylee.com/HKMS/2020-02-03-044119.png?x-oss-process=style/WaMa)

#### 终端中使用

1. iTerm

    `iTerm` → `Preference` → `Profile` → `Text` → `Font`

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-044341.jpg?x-oss-process=style/WaMa)

    iTerm 的字体设置分为 ASCII 字符的字体与非 ASCII 字符的字体, 建议均设置为本字体, 达到统一效果

    ps: 终端中的 vim 字体为终端使用的字体, 不能针对终端 vim 设置自定义字体.

2. MacVim

    在`~/.vimrc`做如下设定

    ```bash
    set guifont=YaHei\ Consolas\ Icon\ Hybrid:h16 "设置 GUI 下字体及大小, 针对 MacVim 进行设置
    set guifontwide=YaHei\ Consolas\ Icon\ Hybrid:h14 "设置 GUI 下中文字体及大小, 针对 MacVim 进行设置
    ```

### 特性

- ✅ 支持 Vim 中 Powerline 字体显示
- ✅ 支持终端中图形字符显示
- ✅ 同时支持中文与英文优化显示

### 字体组成

中文字符: Microsoft Yahei, PingFang-SC(极少量)

西文字符: Consolas

Iconic 字符: [NerdFont](https://github.com/ryanoasis/nerd-fonts)
