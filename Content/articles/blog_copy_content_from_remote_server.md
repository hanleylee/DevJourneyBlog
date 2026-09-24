---
title: 从远程服务器上复制内容
date: 2026-09-15
comments: true
path: copy-content-from-remote-server
categories: tool
tags: ⦿server,⦿zmodem,⦿vim
updated:
---

对于经常要登录服务器查看日志的同学来说, 复制内容是一个非常常见的需求. 本文总结几种简单易用的复制方式, 分为两类:

1. **复制文件**: 把远程服务器上的整个文件下载到本地
2. **复制内容**: 把远程终端里选中的文本直接写进本机剪贴板

<!-- more -->

## 复制文件

经典方式是使用 `scp` 将远程服务器上的文件复制到本地:

```sh
scp user@remote_server:/path/to/remote/file /path/to/local/destination
```

但这种方式有很多缺点:

1. 命令比较长, 需要记住远程服务器的用户名, IP 地址, 以及文件路径等信息
2. 如果是通过跳板机登录的远程服务器, `scp` 命令就会变得非常复杂, 需要同时记住跳板机与目标机的用户名, IP, 路径等信息
3. 如果是强交互型跳板机 (例如需要手动选择要登录的目标服务器), `scp` 命令就无法使用了

我更推荐使用 **lrzsz**: 服务端安装 `lrzsz`, 本地使用支持 ZModem 的终端工具 (例如 SecureCRT), 就可以直接在已登录的终端会话里用 `rz` / `sz` 上传下载文件, 不必再单独拼一条 `scp` 命令.

### 服务端安装 lrzsz

以常见 Linux 发行版为例:

```sh
# CentOS / RHEL
yum install -y lrzsz

# Debian / Ubuntu
apt-get install -y lrzsz
```

安装完成后, 远程服务器上就有了 `sz` (send, 下载到本地) 和 `rz` (receive, 从本地上传) 两个命令.

### iTerm2 配置 (macOS)

对于使用 iTerm2 的 macOS 用户, 终端本身不会自动处理 ZModem, 需要配合两个脚本, 在收到对应序列时弹出文件选择框并完成传输.

- `iterm2-recv-zmodem.sh` (远程执行 `sz` 时触发, 将文件保存到本地)

    ```sh
    #!/usr/bin/env bash

    DIR=$(\
        osascript -e 'tell application "iTerm" to activate' \
        -e 'tell application "iTerm" to set thefile to choose folder with prompt "Choose a folder to place received files in"' \
        -e "do shell script (\"echo \"&(quoted form of POSIX path of thefile as Unicode text)&\"\")"\
    )

    if [[ $DIR = "" ]]; then
        echo Cancelled.
        # Send ZModem cancel
        echo -e \\x18\\x18\\x18\\x18\\x18
        sleep 1
        echo
        echo \# Cancelled transfer
    else
        cd "$DIR"
        PATH=$(command -p getconf PATH):/usr/local/bin:/opt/homebrew/bin
        rz --rename --escape --binary --bufsize 4096
        sleep 1
        echo
        echo \# Sent \-\> $DIR
    fi
    ```

- `iterm2-send-zmodem.sh` (远程执行 `rz` 时触发, 选择本地文件上传)

    ```sh
    #!/usr/bin/env bash

    FILE=$(\
        osascript -e 'tell application "iTerm" to activate' \
        -e 'tell application "iTerm" to set thefile to choose file with prompt "Choose a file to send"' \
        -e "do shell script (\"echo \"&(quoted form of POSIX path of thefile as Unicode text)&\"\")"\
    )

    if [[ $FILE = "" ]]; then
        echo Cancelled.
        # Send ZModem cancel
        echo -e \\x18\\x18\\x18\\x18\\x18
        sleep 1
        echo
        echo \# Cancelled transfer
    else
        PATH=$(command -p getconf PATH):/usr/local/bin:/opt/homebrew/bin
        sz "$FILE" --escape --binary --bufsize 4096
        sleep 1
        echo
        echo \# Received "$FILE"
    fi
    ```

将这两个脚本保存在任意目录中 (比如我的是 `~/.local/bin/sh`), 并赋予可执行权限:

```sh
chmod +x ~/.local/bin/sh/iterm2-recv-zmodem.sh
chmod +x ~/.local/bin/sh/iterm2-send-zmodem.sh
```

本地还需要安装 `lrzsz` 工具本身 (脚本里会调用 `rz` / `sz`):

```sh
brew install lrzsz
```

然后在 iTerm2 中打开 `Preferences -> Profiles -> Advanced -> Triggers`, 配置根据序列触发这两个脚本的自动化规则:

```txt
Regular expression: rz waiting to receive.\*\*B0100
Action:             Run Silent Coprocess
Parameters:         /Users/hanley/.local/bin/sh/iterm2-send-zmodem.sh

Regular expression: \*\*B00000000000000
Action:             Run Silent Coprocess
Parameters:         /Users/hanley/.local/bin/sh/iterm2-recv-zmodem.sh
```

![himg](https://a.hanleylee.com/HKMS/2026-09-15183700.png?x-oss-process=style/WaMa)

配置完成后的日常用法非常简单:

- 需要从远程服务器上下载文件时, 在远程执行 `sz /path/to/file`, iTerm2 会弹出目录选择框, 文件就会被下载到你指定的本地目录
- 需要上传文件时, 在远程执行 `rz`, iTerm2 会弹出文件选择框, 选中本地文件后即可上传到当前远程工作目录

这种方式的核心优势是: **传输发生在已经建立好的 SSH 会话里**. 只要你能登录上去看日志, 就能立刻 `sz` / `rz`, 不用再关心跳板机怎么绕, `scp` 路径怎么拼.

## 复制内容

有时候并不需要整个文件, 只是想把日志里的某一段报错, 某个 token, 某一行配置拷到本机, 去搜索引擎或文档里继续排查. 这时再用 `sz` 就太重了.

终端里直接用鼠标拖选再 `Cmd+C` 当然可以, 但有几个常见痛点:

1. 内容太长, 超过一屏时拖选很麻烦, 还容易选错
2. 在 vim 里看文件时, 终端的鼠标选择和 vim 的 visual 模式容易打架
3. 有些环境禁止鼠标, 或者 tmux / 嵌套会话下选择行为不符合预期

更稳妥的做法是: **在 vim 里选中内容, 再通过 OSC 52 序列把内容写进本机系统剪贴板**.

### 什么是 OSC 52

OSC (Operating System Command) 是一类 ANSI 转义序列, 用来让终端模拟器执行特定操作. 其中 **OSC 52** 的作用就是: 把序列里携带的字符串写入系统剪贴板.

大致流程是:

1. 程序把要复制的文本做 base64 编码
2. 包成 `\e]52;c;<base64>\a` 这样的转义序列
3. 把这个序列写到终端
4. 本地终端模拟器识别后, 把解码结果写入系统剪贴板

这条链路和内容实际产生在哪台机器无关. 哪怕字符串是从远程 SSH 会话里发出来的, 只要本地终端支持 OSC 52 (iTerm2, Alacritty, kitty, Windows Terminal 等都支持), 剪贴板更新的就是你本机的剪贴板. 因此它特别适合「远程 vim -> 本地粘贴」这个场景, 也不依赖 X11 forwarding 之类的额外配置.

### 在 vim 中使用

完整步骤如下:

1. 使用 vim 打开远程文件, 例如 `vim /var/log/app.log`
2. 进入 visual 模式选中内容 (`v` / `V` / `Ctrl-v`), 按 `y` 复制到 vim 的默认寄存器 `@"`
3. 执行下面这条命令, 把寄存器内容通过 OSC 52 写到本机剪贴板:

```vim
:call writefile(["\<Esc>]52;c;" . substitute(system('base64', @"), '\n', '', 'g') . "\x07"], '/dev/tty', 'b')
```

命令拆开看会清晰很多:

| 片段                              | 含义                                                    |
|-----------------------------------|---------------------------------------------------------|
| `@"`                              | 刚才 `y` 进默认寄存器的文本                             |
| `system('base64', @")`            | 对文本做 base64 编码                                    |
| `substitute(..., '\n', '', 'g')`  | 去掉 base64 输出里的换行, 保证序列是一整段              |
| `"\<Esc>]52;c;" ... "\x07"`       | 拼出完整的 OSC 52 序列 (`\x07` 即 BEL, 也可以写成 `\a`) |
| `writefile(..., '/dev/tty', 'b')` | 以二进制方式直接写到当前终端, 避免 vim 改写转义字符     |

执行成功后, 回到本地任意应用 `Cmd+V` / `Ctrl+V`, 就应该能贴出刚才在远程 vim 里选中的内容.

如果这条命令经常用, 可以在 vim 配置里包成函数并绑定快捷键, 例如:

```vim
function! Osc52Yank() abort
    let b64 = substitute(system('base64', @"), '\n', '', 'g')
    call writefile(["\<Esc>]52;c;" . b64 . "\x07"], '/dev/tty', 'b')
    echo 'Copied via OSC 52'
endfunction

" visual 模式下 y 完自动同步到系统剪贴板
vnoremap <silent> <Leader>y y:call Osc52Yank()<CR>
```

之后在 visual 模式下选中内容, 按 `<Leader>y` 即可完成「vim 寄存器 + 本机剪贴板」两步操作.

### 使用注意

- 本地终端需要支持 OSC 52; iTerm2 默认可用
- 若中间套了 tmux, 可能需要允许 escape sequence 透传, 否则序列会被 tmux 吃掉, 到不了本地终端
- OSC 52 对单次内容长度通常有上限 (常见实现大约几十 KB 量级). 超大段文本仍更适合走上一节的 `sz` 下文件

## 小结

| 场景                                  | 推荐方式                              |
|---------------------------------------|---------------------------------------|
| 下载 / 上传整个文件, 尤其是经过跳板机 | 远程 `sz` / `rz` + 本地 ZModem 终端   |
| 只拷一小段日志 / 配置 / 报错信息      | vim visual 选中 + OSC 52 写本机剪贴板 |
| 网络直连且路径简单                    | 传统 `scp` 仍然够用                   |

能登录就能传文件, 能打开 vim 就能拷文本到本机剪贴板 —— 把这两件事搞定, 日常在远程服务器上查问题会轻松很多.
