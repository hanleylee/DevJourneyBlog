---
title: Variable Expansion in Applescript
date: 2021-11-20
comments: true
path: variable-expansion-in-applescript
categories: Language
tags: ⦿applescript, ⦿shell, ⦿tools
updated:
---

AppleScript 是 Apple 平台 用来操控系统及 app 的一种脚本语言, 简单使用时非常便利, 但是在一些灵活场景下便难以胜任, 这篇谈谈我遇到的 `variable expansion` 问题

![himg](https://a.hanleylee.com/HKMS/2021-11-20182127.png?x-oss-process=style/WaMa)

<!-- more -->

事件背景: EuDic 提供了 AppleScript 脚本控制功能, 我想要写一个 AppleScript 脚本来快速查找单词, 但是 EuDic 有 Pro / Lite 两种版本,

- Pro
    - app name: `Eudic.app`
    - bundle id: `com.eusoft.eudic`
- Lite
    - app name: `Eudb_en_free.app`
    - bundle id: `com.eusoft.freeeudic`

因此我必须在脚本中区分出用户安装的版本, 然后进行相应版本的调用

在脚本编写过程中, 我发现 AppleScript 在某些位置是不支持 `variable expansion` 的

```applescript
-- script1.applescript
set appName to "EuDic"
tell application "System Events"
    tell application appName
        activate
        show dic with word "hello"
    end tell
end tell
```

```applescript
-- script2.applescript
tell application "System Events"
    tell application "EuDic"
        activate
        show dic with word "hello"
    end tell
end tell
```

运行 `script1` 脚本会报错: `script error: Expected end of line, etc. but found identifier. (-2741)`, 运行 `script2.applescript` 则完全没有问题, 这就让我感到很奇怪了, 难道一个 AppleScript 连 `variable expansion` 能力都没有? 经过了大量资料查找后, 我发现它真的没有这个能力...

因为 AppleScript 编译器采用了各种技巧来支持那些花哨的类英语关键字. 这些技巧中最主要的是寻找 `tell application "..."` 行, 这样它就知道在 `tell` 块中编译语句时要查找哪些特定于应用程序的关键字.

大多数情况下, 这对于简单的代码来说已经足够了, 但是一旦你想让你的代码更加灵活, 这种聪明反而会为你带来羁绊.  **因为脚本直到运行时才提供应用程序名称**, 编译器在编译时不知道查找该应用程序的术语, 因此只能使用 AppleScript 中预定义的那些关键字和任何加载的 `osaxen`.

在我们这个例子中, `show dict with word` 术语是由 `EuDic` 定义的, 但是直到运行时, AppleScript 才知道他要找的术语是 `EuDic` 提供的, 这时如果直接运行 `show dic with word` 术语, 那么就会报错(在这种情况下, `activate` 并不会报错, 因为 `activate` 是预定义的术语), 对于这种情况, 我在网上找到的解决办法大致如下:

1. 直接使用原始 `"com.eusoft.eudic"`
2. 将相关代码包含在 `using terms from application ...` 块中. 这明确告知编译器在编译所附代码时从何处获取附加术语.

    ```applescript
    set appName to "EuDic"

    tell application "System Events"
        tell application appName
            activate
            using terms from application "EuDic"
                show dic with word "hello"
            end using terms from
        end tell
    end tell
    ```

很明显, 上面两种方式需要直接把 "EuDic" 写死, 那么到底有没有方法能在 AppleScript 中动态地 `variable expansion` 呢? 我想到了在 Shell 中调用 AppleScript 的方式. 根据 [so](https://stackoverflow.com/questions/30858608/adding-applescript-to-bash-script) 的回答, 我们有三种方式可以在 shell 中调用 AppleScript, 其中 `Here Doc` 方式是支持 `variable expandsion` 的, 因此我的方案就是 Shell + AppleScript + `Here Doc`

Shell 的 `here doc` 默认支持 `variable expansion`(当然, 我们可以使用引号 `<<'EOF'` 使该功能关闭), 具体实现如下:

```bash
#!/usr/bin/env bash

if [[ -d /Applications/Eudb_en_free.app ]]; then
    eudicID=$(osascript -e 'id of app "Eudb_en_free"')
elif [[ -d /Applications/Eudic.app ]]; then
    eudicID=$(osascript -e 'id of app "Eudic"')
fi

if [[ -z "$eudicID" ]]; then
osascript <<EOF
display dialog "Please install EuDic"
EOF
   exit
fi

osascript <<EOF
tell application "System Events"
    do shell script "open -b $eudicID"
    tell application id "$eudicID"
        activate
        show dic with word "$1"
    end tell
end tell
EOF
```

这样, 我们便可以同时利用 AppleScript 的便利性与 Shell 的灵活性了.

这是目前我自己能想到的比较好的解决办法, 如果你有更好的方法可以留言交流 ✌️

## Project

[hanleylee/alfred-eudic-workflow](https://github.com/hanleylee/alfred-eudic-workflow)

## Ref

- [Passing variables into 'tell application' commands](https://macscripter.net/viewtopic.php?id=11155)
- [Adding AppleScript to Bash Script](https://stackoverflow.com/questions/30858608/adding-applescript-to-bash-script)
- [Using variables inside a bash heredoc](https://stackoverflow.com/questions/4937792/using-variables-inside-a-bash-heredoc)
