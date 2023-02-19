---
title: Mac 上的包管理工具 Homebrew 使用
date: 2019-12-02
comments: true
path: usage-of-homebrew
categories: Terminal
tags: ⦿mac, ⦿homebrew, ⦿tool
updated:
---

Homebrew 是使用 ruby 语言写的 Mac 系统的包管理工具 (也有 Linux 版本), 在系统默认没有提供相关包的情况下发挥作用. 大多是工程类没有图形界面的包.

Homebrew 的优点是能够判断系统中已经有的组件而不会重复下载, 其他的包管理工具如 `MacPorts`, `Fink`, `pkgsrc`, `Gentoo Prefix`等都会重复下载系统已有的组件.

![himg](https://a.hanleylee.com/HKMS/2020-01-19-100244.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 安装

```bash
/usr/bin/ruby -e "$(curl -fsSL [https://raw.githubusercontent.com/Homebrew/install/master/install](https://raw.githubusercontent.com/Homebrew/install/master/install))"
```

## 镜像设置 (可选)

```bash
# brew
git -C "$(brew --repo)" remote set-url origin https://mirrors.ustc.edu.cn/brew.git

# core
git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

# cask
git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

# bottles for zsh 和下面 2 选 1
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zprofile
source ~/.zprofile

# bottles for bash 和上面 2 选 1
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
source ~/.bash_profile
```

## 基础命令

- `brew install vim`: 安装 vim
- `brew install cask`: 安装 cask(也是一种软件管理工具, 但是涵盖软件范围广, 基本都是图形界面软件, 比如 QQ 微信等)
- `brew help`: 查看简单帮助
- `brew install <package name>`: 安装软件包
- `brew uninstall <package name>`: 卸载软件包
- `brew list [--versions]`: 列出已安装的软件包 (包括版本)
- `brew search <package name>`: 查找软件包
- `brew info <package name>`: 查看软件包信息
- `brew update`: 更新 brew
- `brew cleanup`: 清理所有包的旧版本
- `brew outdated`: 列出过时的软件包 (已安装但不是最新版本)
- `brew upgrade [<package name>]`: 更新过时的软件包 (不指定软件包表示更新全部)
- `brew doctor`: 检查 brew 运行状态
- `man brew`: 显示使用手册
- `brew pin $FORMULA`: 锁定某个包 (以后不会再更新)
- `brew unpin $FORMULA`: 取消锁定
- `brew tap buo/cask-upgrade`: 安装一个第三方的仓库
    - 第三方仓库需要在`GitHub`上, 且仓库名必须以 `homebrew-`开头
    - 此命令的仓库名可以简写, 省略了`homebrew-`
    - 在`brew install`时, 默认的检查顺序如下
        1. pinned taps
        2. core formulae
        3. other taps
- `brew tap-pin user/repo`: 固定某个第三方仓库
- `brew tap-info --installed`: 列出所有已安装的 `taps`
- `brew untap buo/cask-upgrade`: 删除
- `brew deps --installed --tree`: 查看已安装的包的依赖, 树形显示
- `brew install mas`: 安装更新官方商店软件的插件
- `mas upgrade`: 更新 mas 内需要更新的软件

## 如何安装旧版本包

### 使用 brew tap

以安装 1.2.22 版本的 `pyenv` 为例

```bash
# 1. create a new local tap(ignore this if created)
brew tap-new $USER/local
# 2. extract into our local tap
brew extract --version=1.2.22 pyenv hanley/local
# 3. run brew install@version as usual
brew install pyenv@1.2.22
brew pin pyenv@1.2.22
```

> 从 <https://github.com/Homebrew/homebrew-core/find/master> 找到所需包的历史版本
>
> 或者直接使用 `<https://github.com/Homebrew/homebrew-core/commits/master/Formula/<yourpackage>.rb` 定位到版本 commits 列表

### 使用 brew install url

在 github 上找到所需包的历史版本的 rb 文件, 定位该文件的 url, 然后直接使用 `brew install <url>` 即可

## 官方全部包列表

[Homebrew Formulae](https://formulae.brew.sh/formula/)

## 个人 Homebrew 包清单 (仅供参考)

```bash
autoconf                        libidn2                         python
brew-rmtree                     libmpc                          python@3.8
cask                            libsodium                       readline
cmake                           libtasn1                        reattach-to-user-namespace
cscope                          libunistring                    ruby
ctags                           libyaml                         ruby-build
emacs                           lsd                             sourcekitten
gcc                             lua                             sphinx-doc
gdbm                            mpfr                            sqlite
gettext                         mysql                           swiftlint
git                             ncurses                         tmux
gitup                           nettle                          trash
gmp                             node                            tree
gnutls                          openssl@1.1                     unbound
highlight                       p11-kit                         utf8proc
icu4c                           pcre2                           xz
isl                             perl                            yarn
libevent                        pkg-config                      yasm
libffi                          protobuf
```

## 小知识

`Gem`是封装起来的`Ruby`应用程序或代码库. 在终端使用的`gem`命令, 是指通过`RubyGems`管理`Gem`包.

`rvm` 用于帮你安装`Ruby`环境, 帮你管理多个`Ruby`环境, 帮你管理你开发的每个`Ruby`应用使用机器上哪个`Ruby`环境. `Ruby`环境不仅仅是`Ruby`本身, 还包括依赖的第三方`Ruby`插件. 都由`RVM`管理.

`curl` 全称是 `commandline url`, 是在命令行模式下工作, 利用 `URL` 的语法进行数据的传输或者文件的传输

### `[Cask](https://github.com/Homebrew/homebrew-cask)`

#### 介绍

`brew` 中的一个 gui 软件管理命令

#### 基础命令

- `brew install --cask <software name>`: 安装软件
- `brew install --cask <software name> --force`: 强制安装 (可用在已有 dmg 安装的情况下)
- `brew uninstall --cask <software name>` : 卸载软件
- `brew zap --cask <software name>`: 将与此包相关的所有文件全部删除 (可能会删除与其他包共享的一些文件)
- `brew search --cask <software name>`: 根据名称搜索相关软件
- `brew info --cask <software name>`: 查看软件相关信息
- `brew list --cask`: 列出通过 `Homebrew-Cask` 安装的包
- `brew fetch --cask <software name>`: 下载远程软件包到本地文件夹 (不安装)
- `brew outdated --cask` : 列出过期的软件包
- `brew upgrade --cask`: 升级所有包
- `brew tap buo/cask-upgrade`: 安装第三方仓库, 此仓库可以帮助用户检查更新并更新所有 `cask`
- `brew cu -a`: 通过执行上一个命令后, 可用此命令更新所有 cask 下载的软件. 如果使用默认的 `brew cask upgrade`会导致部分自动更新的软件不被列出进而不能更新.

#### 个人 cask 软件包清单 (仅供参考)

```bash
1password            eudic                iterm2               omnifocus            qlvideo              suspicious-package
alfred               firefox              itsycal              omnigraffle          qq                   transmit
aliwangwang          fliqlo               kap                  omnioutliner         quicklook-json       tuxera-ntfs
baidunetdisk         folx                 karabiner-elements   omniplan             quicklookase         typora
bartender            fork                 keycastr             paw                  sf-symbols           visual-studio-code
betterzip            gemini               loopback             pdf-expert           shadowsocksx-ng-r    webpquicklook
beyond-compare       get-backup-pro       macvim               permute              slack                wechat
chromedriver         github               monitorcontrol       picgo                snipaste             xscope
dash                 google-chrome        moom                 qlcolorcode          sogouinput
default-folder-x     google-earth-pro     neteasemusic         qlimagesize          spotify
downie               iina                 nextcloud            qlmarkdown           sublime-text
dropbox              imazing              obs                  qlstephen            surge
```

### `[rmtree](https://github.com/beeftornado/homebrew-rmtree)`

这个包很简单, 功能就是将一个已安装包, 且将只用于该包的所有依赖全部删除, 非常实用!

#### 安装

`brew tap beeftornado/rmtree && brew install brew-rmtree`: 安装第三方 tap 并将该 tap 下的包 `brew-rmtree` 安装到本机

#### 使用

`brew rmtree <package name>`: 删除该包并将其所有依赖删除

### `[bundle](https://github.com/Homebrew/homebrew-bundle)`

这个功能可以让我们备份恢复软件

- `brew bundle dump --describe --force --file="~/Desktop/Brewfile"`: 生成备份文件
    - `--describe`: 为列表中的命令行工具加上说明性文字.
    - `--force`: 直接覆盖之前生成的 `Brewfile` 文件. 如果没有该参数, 则询问你是否覆盖.
    - `--file="~/Desktop/Brewfile"`: 在指定位置生成文件. 如果没有该参数, 则在当前目录生成 `Brewfile` 文件.
- `brew bundle install --file="~/Desktop/Brewfile"`: 根据 `Brewfile` 批量安装软件
- `brew bundle check`: 检查是否 `Brewfile` 中的所有依赖已经安装
- `brew bundle list`: 列出 `Brewfile` 中的所有依赖
- `brew bundle cleanup`: 将 `Brewfile` 中所有未列出的依赖全部删除

## Ref

- [How to Install an Older Brew Package](https://itnext.io/how-to-install-an-older-brew-package-add141e58d32)
