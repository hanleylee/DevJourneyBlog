---
title: 使用 launchd 管理 Mac 启动任务与定时任务
date: 2022-09-25
comments: true
path: manage-process-and-timed-task-by-launchd
categories: tools
tags: ⦿timer,⦿tools
updated: 2022-09-25
---

![himg](https://a.hanleylee.com/HKMS/2021-12-19143027.jpg?x-oss-process=style/WaMa)

本文介绍使用 `launchd` 方式配置启动任务及定时任务

<!-- more -->

## 什么是 launchd

[launchd](https://en.wikipedia.org/wiki/Launchd) 是 MacOS 用来管理系统和用户级别的守护进程的工具. 该工具由两部分组成:

- `launchd`, 该工具主要有两个功能:
    - 启动系统
    - 加载和维护服务
- `launchctl`: 是 `launchd` 提供的用于对用户交互的工具

对于 `launchd` 来说, 每一个 `plist` 文件即为一个任务. 系统启动时, `launchd` 会加载 `/System/Library/LaunchDaemons` 和 `/Library/LaunchDaemons` 中的所有 plist 文件, 用户登录后, 会扫描 `/System/Library/LaunchAgents`, `/Library/LaunchAgents`, `~/Library/LaunchAgents` 这三个目录的文件并加载它们

## plist 放在不同位置时的区别

对于 launchd 来说, 有如下五个路径的 plist 文件会被读取加载, 他们被触发的时机并不相同, 总结如下:

| 位置                            | 类型           | 以什么用户权限运行 | 运行时机       | Provided      |
|---------------------------------|----------------|--------------------|----------------|---------------|
| `/System/Library/LaunchDaemons` | System Daemons | root / 指定用户    | 开机时         | Apple         |
| `/System/Library/LaunchAgents`  | System Agents  | 当前登录用户       | 任意用户登录   | Apple         |
| `/Library/LaunchDaemons`        | Global Daemons | root / 指定用户    | 开机时         | Administrator |
| `/Library/LaunchAgents`         | Global Agents  | 当前登录用户       | 任意用户登录   | Administrator |
| `~/Library/LaunchAgents`        | User Agents    | 当前登录用户       | 指定用户登录时 | User          |

总的来说, `LaunchDaemons` 和 `LaunchAgents` 主要有以下两个区别:

1. 运行时机
    - `LaunchDaemons` 在按下开机按钮后, 用户还未输入密码时, 就已经运行了.
    - `LaunchAgents` 在用户输入密码后, 才开始运行.
2. 运行用户
    - `LaunchDaemons` 是以 root / 其他指定用户运行
    - `LaunchAgents` 是以当前登录用户的权限运行

## 案例: 通过 Launchctl 为 Mac 设置定时任务

下面通过实现定时开关 Mac 的 Wi-Fi 来演示具体流程

### 创建待执行的 shell

- *closeWiFi.sh*

    ```bash
    #!/bin/sh
    # 关闭 Wi-Fi
    networksetup -setairportpower en0 off
    ```

- *openWiFi.sh*

    ```sh
    #!/bin/sh
    # 打开 Wi-Fi
    networksetup -setairportpower en0 on
    ```

### 创建 plist 并放入所需目录

- *closewifi.plist* (每天晚上 23 点 00 分, 执行 *closeWiFi.sh*)

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <!-- 任务名称, 这个一定不能重复, 否则无法被成功创建, 系统会告诉你已经有同名的任务了! -->
        <key>Label</key>
        <string>com.hanley.closewifi</string>
        <key>ProgramArguments</key>
        <!-- 任务加载时就默认启动一次 -->
        <key>RunAtLoad</key>
        <true/>
        <array>
            <string>/Users/hanley/script/closeWiFi</string>
        </array>
        <!-- 任务执行间隔, 单位为 s, 如果计算机进入休眠, 在唤醒前有多个任务被执行, 则这些时间会合并成一个事件再执行 -->
        <!-- <key>StartInterval</key> -->
        <!-- <integer>60</integer> -->

        <!--
            日历的形式执行任务
            Minute <integer>    分钟
            Hour <integer>      小时
            Day <integer>       哪天
            Weekday <integer>   周几 (0 和 7 都表示周日)
            Month <integer>     几月
        -->
        <key>StartCalendarInterval</key>
        <dict>
            <key>Minute</key>
            <integer>00</integer>
            <key>Hour</key>
            <integer>23</integer>
        </dict>
        <key>KeepAlive</key>
        <false/>
        <!-- 输出日志路径 -->
        <key>StandardOutPath</key>
        <string>/Users/hanley/.cache/log/closeWiFi.log</string>
        <!-- 异常日志路径 -->
        <key>StandardErrorPath</key>
        <string>/Users/hanley/.cache/log/closeWiFi-err.err</string>
    </dict>
    </plist>
    ```

- *openwifi.plist*(每天早上 09 点 00 分, 执行 *openWiFi.sh*)

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.hanley.openwifi</string>
        <key>ProgramArguments</key>
        <array>
            <string>/Users/hanley/script/openWiFi</string>
        </array>
        <key>StartCalendarInterval</key>
        <dict>
            <key>Minute</key>
            <integer>00</integer>
            <key>Hour</key>
            <integer>09</integer>
        </dict>
        <key>KeepAlive</key>
        <false/>
        <key>StandardOutPath</key>
        <string>/Users/hanley/.cache/log/openWiFi.log</string>
        <key>StandardErrorPath</key>
        <string>/Users/hanley/.cache/log/openWiFi-err.err</string>
    </dict>
    </plist>
    ```

## KEYS

上述实例中, 我们使用到了 `LABEL`, `ProgramArguments` 之类的 *KEYS*, 常用的 *KEYS* 如下:

- `Label`: 标签的值, 不能与其他 plist 文件中的 `Label` 标签中的值完全重复
- `ProgramArguments`: 标签中放入 shell 所在的路径, 用于控制在指定的时间执行 shell
- `RunAtLoad`: 表示加载定时任务即开始执行脚本
- `KeepAlive`: 是否设置程序是一直存活着, 如果退出就重启
- `Disabled`: 指定默认情况下该服务是否应该被加载, 如果用户使用 `launchctl disable` / `launchctl enable` 设置了服务状态, 那么此值会被忽略
- `StartInterval`: 定时任务的周期, 单位为秒
- `StartCalendarInterval`: 指定命令在多少分钟, 小时, 天, 星期几, 月时间上执行
- `StandardOutPath` 填写脚本运行日志输出的路径
- `StandardErrorPath` 填写脚本运行错误日志输出的路径
- `WorkingDirectory`: 设置工作目录
- `UserName`: 只有指定用户下才会执行(只在 Daemons 可用)
- `GroupName`:  只有指定用户组下才会执行(只在 Daemons 可用)

全部 *KEYS* 可使用 `man 5 launchd.plist` 查看; 使用 `plutil -lint xxx.plist` 可以验证 plist 文件的正确性

## 常用 launchctl 命令

`launchctl` 是 `launchd` 提供的用于对用户交互的工具, 我们可以方便的 启动/停止/启用/禁用 相关服务.

使用 `man launchctl` 可以查看到具体用法, 其中使用了大量的 `specifier` 作为命令一部分, 主要可以分为三种:
    - `service-name`: 服务名, 如 `com.apple.example`
    - `domain-target`: 域名, 如 `gui/501`, 其中 501 可以通过 `launchctl manageruid` 获取
    - `service-target`: 指定域名下的服务名, 是服务名与域名的结合, 如 `gui/501/com.apple.example`

我将实际经常会用到的使用命令列出如下:

- 加载 / 卸载: 卸载加载是启动的前提, 只有加载了之后才能执行任务
    - `launchctl bootstrap gui/501 ~/Library/LaunchAgents/com.hanleylee.test_timer.plist`: **加载** 指定服务
    - `launchctl bootout gui/501 ~/Library/LaunchAgents/com.hanleylee.test_timer.plist`: **卸载** 指定服务
    - `launchctl load <path_of_plist>`: **加载** 一个 plist 文件, 只会加载没有被 disable 的任务, 添加 `-w` 会 enable 状态并加载, 这导致下次启动也会加载该任务
    - `launchctl unload <path_of_plist>`: 停止并 **卸载** 一个 plist 任务, 添加 `-w` 会 disable 状态, 这导致下次启动也不会加载该任务
    - `launchctl unload <path_of_plist> && launchctl load <path_of_plist>`: 修改配置后重载配置, 如果任务被修改了, 那么必须先 unload, 再重新 load
    - `launchctl remove <label>`: 通过服务名进行 **卸载**
- 启动 / 停止: 启动与停止只会影响当次执行的任务, 不会影响下次的计时任务执行
    - `launchctl start <label>`: 在不修改 Disabled 状态的前提下根据 `service_name` 值 **启动** 一个已加载的 service(效果为立即执行, 无论时间是否符合条件)
    - `launchctl stop <label>`: 在不修改 Disabled 状态的前提下根据 `service_name` 值 **停止** 一个正在执行中的任务(不会影响其下次的定时启动功能, 只会取消当前执行的当次行为)
- 启用 / 禁用: 表示该服务下次启动后会不会被加载, 不会影响当前已加载的服务
    - `launchctl enable gui/501/com.hanleylee.test_timer`: 启用服务, 启用之后再次启动系统会加载该服务
    - `launchctl disable gui/501/com.hanleylee.test_timer`: 禁用服务, 禁用之后再次启动系统也不会加载该服务了
- 杀掉服务
    - `launchctl kill gui/501/com.hanleylee.xuexiqiangguo`
    - `launchctl kickstart -k <path_of_plist>`: 杀死进程并重启服务, 对一些停止响应的服务有效
- Other
    - `launchctl print gui/501`
    - `launchctl print-disabled gui/501`
    - `launchctl list`: 列出已加载的所有服务
    - `launchctl list | grep 'com.hello'`: 筛选任务列表

相关注意事项:

- 一个服务, 必须在被加载后才能使用 start 进行启动, 如果使用了 `RunAtLoad` 或 `KeepAlive` 则在加载时就启动.
- 在执行 start 和 unload 前, 任务必须先 load 过, 否则报错

## Ref

- [Mac 执行定时任务](http://www.mrliuxia.com/blog/mac-timer-task/)
- [MAC 本如何优雅的创建定时任务](https://www.cnblogs.com/hanlingzhi/p/6505967.html)
- [Mac 中的定时任务利器: launchctl__WanG- 程序员宝宝](https://cxybb.com/article/qq_34208844/103252998)
- `man 5 launchd.plist`
- `man launchd`
