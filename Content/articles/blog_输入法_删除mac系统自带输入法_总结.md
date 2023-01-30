---
title: 删除Mac系统自带输入法
date: 2019-12-21
comments: true
path: delete-default-input-keyboard-of-mac
categories: Mac
updated:
---

某些时候, 使用第三方输入法的我们并不希望在每次输入时还得手动从内置输入法切换到第三方输入法. 尽管现在 Mac 系统自带有切换到文稿输入法, 尽管有一些第三方软件使得我们可以选择进入某些 APP 时自动切换对应输入法, 但是仍然不够完美. 如果系统上只留有一个输入法事情不就完全解决了吗?

<!-- more -->

## 必备条件

1. 任何可以编辑`.plist`文件的编辑器
2. 已开启 SIP 状态的Mac 系统

    开机状态下长按 `⌘ R`, 选择 `Utilities`中的 `Terminal`, 输入如下命令

    ```bash
        csrutil disable
    ```

## 操作步骤

1. 将输入法切换为系统内置输入法
2. 在终端中执行如下命令并根据提示输入管理员密码确认

    ```bash
    sudo open ~/Library/Preferences/com.apple.HIToolbox.plist
    ```

3. 在弹出的窗口中选择 `Root—AppleEnabledInputSources`, 逐个检查名为 0, 1, 2, 3, 4, 5, 6 的文件夹, 待找到出现 ABC 关键字样的文件夹时, 删除整个以数字命名的文件(具体情况要看你选择了系统的哪种输入法, 我选择的是 ABC, 因此删除 ABC 的).

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-154607.png?x-oss-process=style/WaMa)

4. 重启 Mac 即可看到效果
