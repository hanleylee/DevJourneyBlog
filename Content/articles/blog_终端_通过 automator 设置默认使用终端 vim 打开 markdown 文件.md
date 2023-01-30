---
title: 使用 Automator 将终端 vim 作为默认文本编辑器
date: 2020-01-01
comments: true
path: set-terminal-vim-as-default-text-editor
categories: Mac
updated:
---

如果在 Mac 上经常使用 vim, 并且不希望使用 MacVim 打破 vim 与终端的一体性的话, 可以通过 Automator 设置终端的 vim 作为默认文本编辑器.  这样就不用只能通过在终端里输入 `vim <filename>` 来打开文件了

![himg](https://a.hanleylee.com/HKMS/2020-01-19-124423.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 操作流程

1. 启动 `Automator`, 选择 `Application` 打开
    ![himg](https://a.hanleylee.com/HKMS/2019-12-29-005044.png?x-oss-process=style/WaMa)

2. 从左侧找到 `Run AppleScript` 选项

    ![himg](https://a.hanleylee.com/HKMS/2019-12-29-035607.png?x-oss-process=style/WaMa)

3. 双击 `Run AppleScript` 按钮将其添加进入文件, 将如下代码复制进入框内

    ```bash
    on run {input, parameters}
        tell application "iTerm"
            create window with default profile
            tell front window
                tell current session
                    write text ("vim " & quote & POSIX path of input & quote & "; exit")
                end tell
            end tell
        end tell
    end run
    // 者利用的是 iTerm, 可根据需要改成 Terminal 或其他终端
    ```

    结果如下:

    <p align="center">
    <a href="https://www.hanleylee.com">
    <img src="http://hanleylee.oss-cn-shanghai.aliyuncs.com/HKMS/2019-12-29-040450.png"
    style="width: 888px;"
    alt="Hanley Lee">
    </a>
    <br/>
    使用 iTerm 作为终端机器用内置 Vim 打开文件
    <br/>
    </p>

4. 使用⌘ S 保存文件, 文件名格式为*.app, 你可以取名为 iVim 或任意你喜欢的.
5. 最后, 找出一个任意你希望用 iTerm 的 Vim 打开的文件类型, 右键 `Get Info`, 在打开类型中选择刚刚创建的 iVim.app(如果寻找比较困难的话可以用图示办法, 显示全部再搜索进行选取)

    ![himg](https://a.hanleylee.com/HKMS/2019-12-29-041345.png?x-oss-process=style/WaMa)

    ![himg](https://a.hanleylee.com/HKMS/2019-12-29-041712.png?x-oss-process=style/WaMa)

6. 最后, 在文件信息界面选择 `Change All`, 之后在你双击此类型的任意文件后就会自动打开 iTerm 进入 Vim 编辑模式了. 赶快去试试吧

    ![himg](https://a.hanleylee.com/HKMS/2019-12-29-042222.png?x-oss-process=style/WaMa)

## 参考: [GitHub](https://gist.github.com/charlietran/43639b0f4e0a01c7c20df8f1929b76f2)
