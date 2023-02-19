---
title: 通过 Automator 设置全局快捷键打开应用程序
date: 2019-12-21
comments: true
path: set-global-shortcut-by-automator
categories: Mac
tags: ⦿mac, ⦿automator, ⦿shorcut
updated:
---

为某些常用程序设置快捷键一键打开可以大大节省我们的时间, 但是并不是所有程序都支持设置全局快捷键打开主窗口. 为此有一些第三方软件被创造出来.

实际上Mac 上面自带的 Automator 已经可以完成这个任务.

<!-- more -->

## 操作流程

1. 打开`Automator.app`

   ![img](https://a.hanleylee.com/HKMS/2019-12-28-174726.jpg?x-oss-process=style/WaMa)

2. 新建 选择 `服务`

   ![img](https://a.hanleylee.com/HKMS/2019-12-28-174737.jpg?x-oss-process=style/WaMa)

3. 在左边侧栏中找到实用工具里的 `Run AppleScript`, 然后 双击

   ![img](https://a.hanleylee.com/HKMS/2019-12-28-174727.jpg?x-oss-process=style/WaMa)

4. “服务” `收到` 选择为 `没有输入`

   ![img](https://a.hanleylee.com/HKMS/2019-12-28-174735.jpg?x-oss-process=style/WaMa)

5. 编辑区中输入

   ```bash
   on run {input, parameters}

       (* Your script goes here *)
       tell application "Chrome"
           reopen
           activate
       end tell

   end run
   ```

6. 命名服务

   这样 AppleScript 就写好了, 并将其保存为 Open Terminal. 只需将脚本中的 tell application "Terminal" 中的 "Terminal" 改为其他的程序名, 就可以为其它的程序建立快捷键.

7. 设置快捷键

   在键盘快捷键设置的左侧栏中选中 服务, 可以看到Open Terminal, 然后完成快捷键的设置.

   ![img](https://a.hanleylee.com/HKMS/2019-12-28-174729.jpg?x-oss-process=style/WaMa)

8. 创建的 `Automator` 文件保存在 `/Users/hanley/Library/Services`
