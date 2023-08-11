---
title: Tmux 使用
date: 2020-01-13
comments: true
path: usage-of-tmux
categories: Terminal
tags: ⦿terminal, ⦿tmux, ⦿tool
updated:
---

Tmux 是一款终端复用工具, 相比起 Terminal 或 iTerm, Tmux 可以使用快捷键方便的切换会话窗口, 保存 & 恢复会话, 以及方便地进行远程会话.

![himg](https://a.hanleylee.com/HKMS/2020-02-16-034444.png?x-oss-process=style/WaMa)

<!-- more -->

tmux 最大管理单位为服务器, 服务器下有多个会话, 一个会话之下可以有多个窗口, 一个窗口下可以有多个面板

会话有命名 (`' $`), 窗口有编号有命名 (`' ,` 与 `' .`), 面板只有编号 (`' q`)

## 安装

```bash
brew install tmux
```

## 命令

### 系统级

- `clear`: 清空屏幕
- `tmux list-keys`: 列出 tmux 所有支持的快捷键
- `tmux`: 从终端新建一个 tmux 会话
- `tmux new -s 我的会话`: 从终端新建一个名字为`我的会话`的会话
- `' d`: detach, 断开会话
- `tmux a`: 连接到之前断开的会话
- `tmux a -t 我的会话`: 连接到之前断开的名字为`我的会话`的会话
- `tmux attach -t 我的会话`: 连接到之前断开的名字为`我的会话`的会话
- `tmux kill-session -t 我的会话`: 关闭名字为`我的会话`的会话
- `tmux kill-server`: 关闭整个服务器, 所有会话均被关闭
- `tmux ls`: 查看所有会话
- `' s`: 显示所有的会话
- `' w`: 显示所有的会话以及会话所包含的所有窗口 (因此, 此命令比`'s`更全面)
- `' C-s`: 保存所有会话, 非原生, 由第三方插件 resurrect 实现
- `' C-r`: 恢复所有会话, 非原生, 由第三方插件 resurrect 实现
- `' [`: 进入复制模式, 按 `q` 退出
- `v`: 在进入复制模式后开启选择模式, 已重置, 默认为空格
- `y`: 在进入复制模式且选择完成后进行复制确认, 已重置, 默认为 enter 键

### 面板

- `' |`: 竖直分割面板, 已重置, 默认为`"`
- `' -`: 水平分割面板, 已重置, 默认为`%`
- `' !`: 将当前面板移动到新的窗口打开
- `' x`: 关闭当前面板
- `' z`: 最大(小)化当前面板
- `' 方向键`: 移动光标至某个方向的面板
- `' ⌥- 方向键`: 向某个方向扩张窗口五个单元格, 也可以直接使用鼠标进行拖动
- `' {`: 向前序号置换面板
- `' }`: 向后序号置换面板
- `' C-o`: 顺时针拨动面板
- `' o`: 光标挪至下一面板
- `' q`: 显示当前窗口所有面板序号, 编号显示时输入编号即可切换至面板
- `' t`: 在当前面板显示时钟

### 窗口

- `' c`: 创建新窗口
- `' &`: 关闭窗口
- `' p`: 打开上一个窗口
- `' n`: 打开下一个窗口
- `' ,`: 重命名窗口
- `' .`: 重命名窗口序号
- `' 1~9`: 根据窗口序号切换至对应窗口

## 插件

### [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Tmux 的插件管理器, 需要安装插件时很方便, 目前 tmux 的绝大多数插件都支持使用此管理器进行安装

#### 安装

1. 终端中输入

    ```bash
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```

2. 在 .tmux.conf 中加入:

    ```bash
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'
    ```

3. 重加载 tmux(如果 tmux 在运行的话)

    ```bash
    tmux source ~/.tmux.conf
    ```

#### 使用插件

1. 直接在`.tmux.conf`文件中加入如下:

    ```bash
    set -g @plugin 'tmux-plugins/XXXXXXXXXX'
    ```

2. `prefix I`, 输入命令进行安装

#### 命令

- `prefix I`: 安装插件
- `prefix U`: 更新插件
- `prefix alt u`: 移除插件

### [Tmux Resurrect](https://github.com/tmux-plugins/tmux-resurrect)

Tmux 的所有会话基于一个服务器, 但是如果终端被完全退出或者电脑进行了重启, 那么服务器的数据将会被清空, Tmux 的所有会话也会被清除, 再次打开时所有配置好的窗口都会被重置.

使用此插件可以在需要的时候保存所有窗口布局, 在重启服务器时一键恢复所有布局

#### 安装

```bash
set -g @plugin 'tmux-plugins/tmux-resurrect'
```

#### 使用

- `prefix + Ctrl-s`: save, 保存会话
- `prefix + Ctrol-r`: restore, 恢复会话

### [Tmux-yank](https://github.com/tmux-plugins/tmux-yank)

用于将 tmux 中的内容复制到系统剪贴板中

#### 安装

##### MacOS

1. 通过 tpm 安装本体

    ```bash
    set -g @plugin 'tmux-plugins/tmux-yank'
    ```

2. 使用 Homebrew 安装 `reattach-to-user-namespace`: `brew install reattach-to-user-namespace`
3. 配置 `~/.tmux.conf` 文件

    ```bash
    # ~/.tmux.conf
    set-option -g default-command "reattach-to-user-namespace -l $SHELL"
    ```

##### CentOS

1. 通过 tpm 安装本体

    ```bash
    set -g @plugin 'tmux-plugins/tmux-yank'
    ```

2. 安装 `xsel` 或 `xclip`: `sudo yum install xsel` 或 `sudo yum install xclip` 即可

#### 使用

- `y`: 将当前所选复制到剪贴板
- `Y`: 将当前所选复制到剪贴板并直接输出到当前命令区域
