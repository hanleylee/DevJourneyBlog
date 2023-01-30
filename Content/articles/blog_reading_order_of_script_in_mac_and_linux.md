---
title: Shell 在 MacOS 及 Linux 中的文件读取顺序
date: 2021-06-08
comments: true
path: reading-order-of-script-in-mac-and-linux
categories: Terminal
tags: ⦿blog, ⦿PATH, ⦿order, ⦿shell
updated:
---

Shell 在 MacOS 及 Linux 中的文件读取顺序

![himg](https://a.hanleylee.com/HKMS/2021-05-31-18-32-43.jpg?x-oss-process=style/WaMa)

<!-- more -->

## MacOS 与 Linux 中 zsh 的加载顺序

|                 | Interactive login | Interactive non-login | Script |
|-----------------|-------------------|-----------------------|--------|
| `/etc/zshenv`   | A                 | A                     | A      |
| `~/.zshenv`     | B                 | B                     | B      |
| `/etc/zprofile` | C                 |                       |        |
| `~/.zprofile`   | D                 |                       |        |
| `/etc/zshrc`    | E                 | C                     |        |
| `~/.zshrc`      | F                 | D                     |        |
| `/etc/zlogin`   | G                 |                       |        |
| `~/.zlogin`     | H                 |                       |        |
| `~/.zlogout`    | I                 |                       |        |
| `/etc/zlogout`  | J                 |                       |        |

如文章首图与上表所示, `zsh` / `bash` / `sh` 都有针对于 `login` / `nologin` 及 `interactive`, `non-interactive` 的不同读取顺序. 主要分为以下四种情形

- `interactive - login`: 登录远程主机 (e.g `ssh`)
- `interactive - non-login`: 打开一个新 terminal 或一个新建 terminal 窗口
- `non-interactive - non-login`: 执行一个脚本所在的 `sub-shell` 就处于这种状态 (这种状态下不能进行交互, 这种状态也只存在于脚本执行的 d 短暂时间内)
- `non-interactive - login`: 这种情况很少见, 比如这种情况 `echo 'echo $-; shopt login_shell' | ssh localhost`

> 特别值得强调的是, 在 MacOS 中, 如果我们打开一个 terminal 或新开一个 tab 时, zsh 会将其作为 `login` 对待. 当然, 在运行脚本所创建的 `sub-shell` 中, 其状态都是 `non-interactive`

## Mac 下的 `/etc/zprofile` 对 PATH 做的奇怪事情

在 Mac 下有 `/etc/zprofile` 文件, 在这个文件中有这样一段命令

```zsh
if [-x /usr/libexec/path_helper]; then
    eval `/usr/libexec/path_helper -s`
fi
```

由首图及上表可知, zsh 会在 `~/.zshenv` 之后加载 `/etc/zprofile`, 进而执行 `/usr/libexec/path_helper` 这个脚本, 根据这个 [blog](https://www.softec.lu/site/DevelopersCorner/MasteringThePathHelper) 的描述, 这个脚本工具会将变量 `$PATH` 的顺序重排, 同时读取 `/etc/paths` 与 `/etc/manpaths` 中的 `path`. 顺着这个思路, 如果我们在 `zshenv` 中定义了 `$PATH`, 那么精心配好的顺序无疑会被打乱.

由此我们可以得出一个结论: **变量 `$PATH` 的定义必须必须放在 `/etc/zprofile` 之后**

## MacVim 中读取到的 `$PATH`

由于 `MacOS` 的特殊性 (如果我们打开一个 `terminal` 或新开一个 `tab` 时, zsh 会将其作为 `login` 对待), 在开启 MacVim 时, MacVim 读取到的文件顺序与 `login - non-interactive` 是相同的

也就是说, MacVim 不会读取 `~/.zshrc`, 会读取 `~/.zprofile`, 那么如果我们需要在 MacVim 中获得正确的 `$PATH`, 就必须将 `$PATH` 及一些其他基本变量的设置放在 `~/.zprofile` 中

## 打造一个兼容各个系统的 `zsh` 配置

我使用的是 `zsh`, 我觉得非常顺手, 各种功能强大, 兼容主流平台, 因此我的所有工作环境都会使用 `zsh`. 由于平时会使用 `MacOS` 与 `Linux`, 而且想要将自己的一些个性化配置在不同环境下通用, 那么就需要考虑下如何在 `MacOS`, `MacVim`, `ssh remote`, `Linux Desktop` 下有统一的加载行为.

经过考虑, 我目前的方案是:

1. 创建一个 `init.zsh` 脚本, 在其中有各种变量的定义, 包括 `$PATH`. 在脚本开始进行加载的判断 (防止同一次启动中重复加载次脚本)

    ```sh
    if [-z "$_INIT_ZSH_LOADED"]; then
        _INIT_ZSH_LOADED=1
    else
        return
    fi
    ```

2. 在 `.zprofile` 的开头 `source init.zsh`
3. 在 `.zshrc` 的开头 `source init.zsh`
4. 在 `.zlogin` 中使用想要显示的交互信息 (比如 `neofetch` 信息)

这里附上我的 shell 配置仓库, 供各位参考

<https://github.com/hanleylee/dotsh>

## 参考

- [Shell Startup Files Loading Order on Linux and MacOS](https://www.erikstockmeier.com/blog/12-5-2019-shell-startup-scripts)
- [Mastering the path_helper utility of MacOSX](https://www.softec.lu/site/DevelopersCorner/MasteringThePathHelper)
- [MacVim troubleshooting](https://www.softec.lu/site/DevelopersCorner/MasteringThePathHelper)
- [Differentiate Interactive login and non-interactive non-login shell](https://askubuntu.com/questions/879364/differentiate-interactive-login-and-non-interactive-non-login-shell)
