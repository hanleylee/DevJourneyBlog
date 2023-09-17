---
title: Xcode git "invalid data in index" workaround
date: 2023-04-01
comments: true
path: xcode-git-crash-workaround
tags: ⦿xcode,⦿git
updated:
---

最近一段时间, 我的 Xcode 不能正常显示文件的 git 状态, 在 Xcode 中直接对工程中的文件重命名时会出现以下错误

![himg](https://a.hanleylee.com/HKMS/2023-04-01164754.png?x-oss-process=style/WaMa)

<!-- more -->

invalid data in index - calculated checksum does not match expected (-1)

具体的报错文本信息如下:

```txt
Details

An unknown error occurred.
Domain: com.apple.dt.SourceControlErrorDomain
Code: -1
Recovery Suggestion: invalid data in index - calculated checksum does not match expected (-1)
User Info: {
    DVTErrorCreationDateKey = "2023-04-01 08:48:26 +0000";
    "com.apple.dt.sourcecontrol.UnderlyingErrorString" = "invalid data in index - calculated checksum does not match expected (-1)";
}
--


System Information

macOS Version 13.2 (Build 22D49)
Xcode 14.3 (21812) (Build 14E222b)
Timestamp: 2023-04-01T16:48:26+08:00
```

网上搜了很多信息, 没有通过报错关键字找到任何有价值的线索, 通过一步步摸索进而确定了问题. 在这里记录下解决方法, 方便后来人查找

## 问题排查

经过 **清缓存**, **删除 `$HOME/.gitconfig`**, **重装 Xcode** 等尝试, 终于最后确定了(应该)是 Xcode 使用的 git 库是旧版的, 不兼容新版 `git 2.40.0` 生成的 `.git/index` 进而造成的问题

## 解决方案

在有问题的工程下通过使用 `/usr/bin/git reset --mixed HEAD` 即可解决该报错问题

原理: `/usr/bin/git reset --mixed HEAD` 这个命令使用系统自带 git 版本对当前工程的 `.git/index` 文件进行生成

## 后记

因为我是使用 homebrew 安装了新版 git, 且其在 $PATH 的顺序比 `/usr/bin/git` 靠前, 如果在终端中执行 `git reset` 相关动作的话, 那么 `.git/index` 文件又会被生成为最新的, 进而 Xcode 又会报错. 因此如果想彻底解决这个问题, 可以有以下方案:

- 等到 Xcode 升级相关 git 解析库
- 等后续的新版 git 兼容旧版本
- 使用版本号低于 `2.40.0` 的 git

