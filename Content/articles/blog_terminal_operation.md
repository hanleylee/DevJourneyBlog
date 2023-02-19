---
title: 终端原理及操作
date: 2019-12-10
comments: true
path: usage-of-terminal
categories: Terminal
tags: ⦿terminal, ⦿tool
updated:
---

本文对 shell 中的概念及命令进行总结, 也涵盖一些终端工具的使用, 涉及到 Linux 及 Mac 系统.

![himg](https://a.hanleylee.com/HKMS/2020-03-20-134408.png?x-oss-process=style/WaMa)

<!-- more -->

## 常见概念理解

- `terminal`: 一个程序, `Mac` 自带 `terminal`, 也有第三方软件比如 `xterm`, `iterm`, `kvt` 等, `terminal` 是 `shell` 的 UI, `shell` 运行在 `terminal` 中
- `shell`: 命令行解释器. 根据字面意义来看就是机器外面的一层壳, 用于在机器与人交互过程中传递信息. 不限于操作系统, 编程语言, 操作方式和表现形式.  具体表现是用户输入一条命令后 shell 就立刻进行执行并返回结果. CLI(`Command Line Interface`) 与 GUI(`Graphic User Interface`) 都是 `shell`, 只不过是不同的表现形式而已.
- `interactive` 与 `non-interactive`: 如果打开 Mac 上的 `iterm`, 输入 `bash` 代码, 按下回车后有返回任何信息就被称为 `interactive`; 如果输入了若干行的 `shell` 脚本, 那么这些 `shell` 代码就运行在 `non-interactive shell` 中
- `login` 与 `non-login`: `login shell` 指登录系统后获得的顶层 `shell`, 比如最常用的 `ssh` 登录, 登陆完后会获得一个 `login shell`; 如果是在 Mac 上直接打开 `iterm` 进入了 `shell` 则是 `non-login shell`
- `shell` 类型
    - `bash`: 全称: `Bourne-Again Shell`, 是最常见的 `shell`. `Mac` 中的 `terminal` 默认就是 `bash`
    - `zsh`: `Mac` 中最常用的 `shell`, 一大半的原因是因为 `on-my-zsh` 这个配置集. `zsh` 兼容 `bash`, 还有自动补全的功能. `zsh` 的配置文件为 `~/.zshrc`
    - `cmd`: `Windows` 下的默认 `shell`, 全称为 `command interpreter`
    - `Jshell`: `Java` 的第三方解释器 (只要一门编程语言有解释器, 就可以作为一个 `shell`, `PHP` 也有 `PHP Shell`)
- `Linux 发行版`: GNU/Linux 是基于 GPL 开源许可协议的操作系统内核, 但仅仅有内核还不是一个完整的操作系统, 要想可以使用还需要集成各种应用软件. Linux 发行版就是指预先集成好的 Linux 操作系统及各种应用软件, 一般情况下用户直接安装就可以使用, 不需要再重新编译. 我们平常所说的安装个 Linux 操作系统指的都是安装一个 Linux 的发行版.
    - `RHEL`: `Red Hat Enterprise Linux`, 是 `Redhat` 公司推出的企业级 `Linux` 发行版, 属于开源操作系统; 但是收费!
    - `Fedora`: 是 `Redhat` 公司推出的实验性 `Linux` 发行版, 新特性都会首先出现在 `Fedora` 上, 稳定后放在 `RHEL` 中.
    - `CentOS`: 直接将 `RHEL` 的源码拿过来, 去掉相关的版权图标信息, 而后发型, 其版本号与 `RHEL` 基本相同. 法律上是完全没问题的, 因为发布出来的 `CentOS` 同样也遵守了 GPL. 除了一些 `Redhat` 的商业应用软件, `CentOS` 追求的是与 `RHEL` 100% 兼容. `CentOS` 作为从 RHEL 源码直接编译的发行版, 其作为服务器的高效率及稳定性等方面都是经过实践验证的, 所以如果自己有丰富的服务器运维经验, 那你可以选择 `CentOS`. 但如果没有专业的运维团队, 又需要大规模部署, 那还是选择 `RHEL` 比较明智, `Redhat` 团队会为你提供专业的, 标准化的解决方案和专业的技术支持.
    - `Arch Linux`: 巨大的定制潜力, `Antergos` 提供了一种更加友好的 `Linux` 体验; 不适合容易放弃的人
    - `Ubuntu`: 界面漂亮, 非常适合新手, `LTS` 版本的安全性和稳定性; 不适合服务器端 (需要较多的内存空间), 对非 `LTS` 版本短暂的支持
    - `Ubuntu Studio`: 昂贵生产软件的绝佳替代品, 允许访问主 `Ubuntu` 中的包, 支持音频插件; 由于功能强大, 所以操作系统不够精简
    - `Debian`: 最适合服务器的操作系统, 稳定得无与伦比, 内存占用小, 常年不需要重启; 由于其发展路线, 帮助文档略少, 技术资料也略少.
    - `Elementary OS`: 设计巧妙, 看起来很棒; 预装的应用程序并不多
    - `Linux Mint`: 非常适合从 `Windows` / `Mac` 切换过来的用户, 良好的媒体支持, 开箱即用, 令人印象深刻的定制选项; 高级玩家可能不会喜欢
    - `Tails`: 强调安全和隐私, 易于使用的操作界面; 功能比较基本
    - `openSUSE`: 非常精美, 安全, 允许你创建自己的操作系统版本; 默认的软件选择略显臃肿
- `GNOME`: Linux 系统就是一个纯命令行的操作系统, `GNOME` 为 `Linux` 提供了桌面操作环境. `GNOME` 是由 `GNU Network Object Model Environment` 的第一个字母所组成, `GNOME` 属于 `GNU` 计划中的一部份.

`Linux` 的图形显示层次是: `Linux 本身` -> `X 服务器` <- [通过 X 协议交谈] -> `窗口管理器 (综合桌面环境)` -> `X 应用程序`.

- `KDE`: 与 `GNOME` 并列的两种最流行的桌面操作环境, 全称是 `K Desktop Environment`. 其他的一些比较流行的桌面操作环境有:
    - `XFCE`
    - `CINNAMON`
    - `UNITY`
    - `MATE`
    - `DEEPIN`
    - `PANTHEON`
    - `BUDGIE`
    - `MANOKWARI`
- `GNU`: `GNU` 计划开始于 1984 年, 专注于发展类似 UNIX 且完全免费的操作系统.

## common environment variables

- `echo $SHELL`: 查看当前使用的 `shell` 类型 (2019.12.10 目前使用 `zsh`)
- `echo $TERM`: 查看当前使用的终端类型
- `echo $PATH`: 查看当前系统的路径顺序
- `exprot PATH="/usr/local/sbin:$PATH"`: 将 `/usr/local/sbin` 加入到系统环境中并使之成为第一顺位
- `echo 'export PATH="/usr/local/sbin:$PATH"'>> ~/.zshrc`: 将字符 `export PATH="/usr/local/sbin:$PATH"` 输出到 `~/.zshrc` 文件的末尾
- `echo $PATH`: 输出当前系统的路径读取顺序
- `echo ${(t)fpath}`: 输出 `fpath` 的类型
- `echo ${(t)FPATH}`:  输出 `FPATH` 的类型
- `PS4='+%x:%I>' zsh -i -x -c '' |& grep ***`: 检查别名的定义位置, 用于查找 `alias` 的详细位置

## 快捷键

- `C-c`: 终止正在执行的命令
- `C-p/n`: 浏览已执行的历史记录
- `C-f`: 向后移动一个字符
- `C-b`: 向前移动一个字符
- `C-a`: 光标移动到行首
- `C-e`: 光标移到行尾
- `C-z`: 将当前进程最小化
- `C-l`: 清除整个屏幕
- `C-u`: 从光标位置删除到行首 (bash); 删除当前行 (zsh)
- `C-k`: 从光标位置删除到行尾
- `C-y`: 粘贴上一次删除的字符串
- `C-h`: 删除光标前一个字符
- `C-d`: 删除光标后一个字符, 在删除完光标后会删除当前 shell 会话
- `C-i`: 与 tab 作用相同
- `C-_`: undo
- `C-x C-u`: undo, same as `c-_`
- `C-t`: 交换光标前的两个字符的位置
- `esc-t`: 交换光标前的两个词的位置
- `alt-t`: 交换光标下的当前单词与前一个单词的位置
- `alt-backspace`: 删除前一个单词
- `alt-.`: 使用上一次的参数
- `alt-u`: 使当前光标至结尾的单词大写
- `C-w`: 移除光标前一个单词
- `C-x-e`: 在编辑器 (vi) 中编辑当前命令行文本
- `C-q`: 将当前命令暂时隐藏, 等待下一个命令执行完毕后再弹出
- `↑/↓`: 浏览已执行的历史记录
- `C-r`: 搜索之前打开过的命令
- `C-s`: 向后搜索历史命令
- `C-xx`: 在行首与当前光标处切换
- `Esc-d` / `alt-d`: 删除光标所在字符
- `Esc-f` / `alt-f`: 光标右移一个单词
- `Esc-b` / `alt-b`: 光标左移一个单词
- `⌘ E`: 向下滚动一行
- `⌘ Y`: 向上滚动一行
- `双击 Tab`: 列出所有的补全列表并直接进入选择模式, 补全项可以使用 ctrl+n/p/f/b 上下左右切换
- `上下键`: 显示历史的命令, 如果在特定前缀命令下只会显示同样的命令, 比如输入 `ls` 情况下只会查找用过的 `ls` 命令

## 纯内置命令 (不包含 gnu coreutils 实现的)

- `set -o noglob` / `set -f`: 关闭扩展
- `set +o noglob` / `set +f`: 打开扩展

---

- `pushd <directory>`: 与 `cd` 类似, 会进入某目录, 但是会将此次的进入目录放入堆栈中, 使用 `popd` 可以进入堆栈的上一目录
- `pushd +3`: 从栈顶算起的 3 号目录 (从 0 开始), 移动到栈顶
- `popd`: 进入堆栈的上一目录
- `popd -3`: 删除从栈底算起的 3 号目录 (从 0 开始)

---

- `pwd`: 列出当前所在的目录

---

- `rmdir [路径]`: 删除一个文件夹 (无法删除含有文件的文件夹)

---

- `zsh_stats`: 查看当前使用频率最高的 20 条命令

---

- `dirs`: 查看堆栈内容
    - `-c`: 清空目录栈.
    - `-l`: 用户主目录不显示波浪号前缀, 而打印完整的目录.
    - `-p`: 每行一个条目打印目录栈, 默认是打印在一行.
    - `-v`: 每行一个条目, 每个条目之前显示位置编号 (从 0 开始).
    - `+N`: N 为整数, 表示显示堆顶算起的第 N 个目录, 从零开始.
    - `-N`: N 为整数, 表示显示堆底算起的第 N 个目录, 从零开始.

    ```bash
    $ pwd # 当前处在主目录, 堆栈为空
    /home/me

    # 进入 /home/me/foo
    $ pushd ~/foo # 当前堆栈为 /home/me/foo /home/me

    # 进入 /etc
    $ pushd /etc # 当前堆栈为 /etc /home/me/foo /home/me

    # 进入 /home/me/foo
    $ popd # 当前堆栈为 /home/me/foo /home/me

    # 进入 /home/me
    $ popd # 当前堆栈为 /home/me

    # 目录不变, 当前堆栈为空
    $ popd
    ```

---

- `./test.sh`: 执行当前目录下的 `test.sh` 文件, 必须使用 `./`, 如果直接使用 `test.sh` 的话系统会在 `PATH` 中查找有没有 `test.sh`, 通常是不在的, 因此会报错, 使用 `./test.sh` 表示就在当前目录找 `test.sh`, 这样就能顺利找到了
- `/bin/sh test.sh`: 与上面的运行方式类似, 不过指定了解释器

---

- `which python`: 输出当前使用的 `python` 路径
- `where python`: 输出当前环境下所有可用的 `python` 路径

---

- `type echo`: 查看 echo 是否是 shell 内置命令, 如果不是内置则显示其路径
- `type -a <command>`: 查找某个命令被定义在的位置
- `type -a echo`: 查看 echo 的所有路径位置 (如果是内置命令也会显示)
- `type -t if`: 显示某个命令的类型, `if` 的类型是 `keyword`

---

- `alias python='/usr/local/bin/python3'`: 设置应用的别名 (如果需要取消设置需使用 `unalias`  `vim`, 如果想要在 `.zshrc` 中设置需将 `'` 改为 `"`)
- `alias`: 列出系统所有已设置的别名

---

- `history`: 显示会话开始后的所有历史命令
- `history -c`: 清理所有历史命令
- `history 10`: 显示最近 10 个历史命令

---

- `compgen -c`: 显示当前终端所有可调用命令

---

- `set` / `env`: 显示所有环境变量

---

- `!!`: run previous command(i.e. `sudo !!`)
- `!vi`: run previous command that begins with vi
- `!vi:p`: print previously run command that begins with vi
- `!n`: execute nth command in history
- `!$`: last argument of last command
- `!^`: first argument of last command
- `^abc^xyz`: replace first occurance of abc with xyz in last command and execute it

## 系统环境路径

在 `/etc/paths` 中规定了系统路径查找顺序

```bash
/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
```

`Homebrew` 安装的软件都会在 `/usr/local/bin` 中有一个快捷方式 (具体的文件在 `/usr/local/Cellars` 中), 因此要将系统环境路径设置为 `/usr/local/bin` 为第一个检查, 这样在键入 `vim` 命令时 `Homebrew` 安装的 `vim` 就会被先检测到, 内置的 `vim` 不会被启动

可在终端使用 `echo $path` 检查当前系统的路径读取顺序.

在 `.zshrc` 中追加路径可加入 `export PATH="/usr/local/sbin:$PATH"`, 这样会将 `/usr/local/sbin` 路径加入到路径列表并成为第一顺位.

## 源码编译安装

尽管已经有些包管理软件, 但是仍然不可避免地要编译安装一些源码, 本例以 CentOS 编译安装 Python3.8.3 为例

1. 编译环境准备

    ```bash
    yum groupinstall 'Development Tools'
    yum install -y ncurses-libs zlib-devel mysql-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel \
    db4-devel libpcap-devel xz-devel
    ```

2. 删除系统中已有的 python3

    在 `/usr/bin` 与 `/usr/local/bin` 中查找 python3 与 `pip3` 的相关文件, 然后删除. 这一步是为了后面我们将编译出的文件链接到此两个文件夹中

3. 下载 Python3.8.3 源码到桌面并解压

    ```bash
    cd /home/hanley/Desktop/https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz
    tar -xvf Python-3.8.3.tgz
    cd Python-3.8.3.tgz
    ```

    <span id= "第四步">

4. 配置编译选项

    ```bash
    ./configure --prefix=/usr/local/python3.8.3 --enable-optimizations
    ```

    解释下这些选项的含义:

    - `--prefix` 选项是配置安装的路径, 如果不配置该选项, 安装后可执行文件默认放在 `/usr/local/bin`, 库文件默认放在 `/usr/local/lib`, 配置文件默认放在 `/usr/local/etc`, 其它的资源文件放在 `/usr/local/share`, 比较凌乱.
    - `--enable-optimizations` 是优化选项 (`LTO`, `PGO` 等) 加上这个 `flag` 编译后, 性能有 `10%` 左右的优化, 但是这会明显的增加编译时间, 老久了.

    > `./configure` 命令执行完毕之后创建一个文件 `Makefile`, 供下面的 `make` 命令使用, 执行 `make install` 之后就会把程序安装到我们指定的文件夹中去.

5. 进行编译, 编译结果会放到 [第 4 步](# 第四步) 配置的文件夹中

    ```bash
    make && make install
    ```

6. 进入编译结果文件夹, 将编译出的结果软链接到 `/usr/bin` 中

    ```bash
    cd /usr/local/Python3.8.3/bin
    ln -s python3.8 /usr/bin/python
    ln -s python3.8 /usr/bin/python3
    ln -s python3.8 /usr/bin/python3.8
    ln -s pip3.8 /usr/bin/pip
    ln -s pip3.8 /usr/bin/pip3
    ln -s pip3.8 /usr/bin/pip3.8
    ```

    因为终端寻找命令是根据我们定义的 `PATH` 的顺序来查找的, 我们的编译结果文件夹 `/usr/local/Python3.8.3` 并不在我们的 `PATH` 中, 因此我们要将其中的结果软链接到已经在 `PATH` 的文件夹中

    同时, 如果不想做软链接, 也可以直接将编译结果文件夹加入到 `PATH` 中

    ```bash
    vim /etc/profile # 编辑 etc/profile 文件
    export PATH=/usr/local/Python3.8.3/bin:$PATH # 在文件末尾直接加入我们的编译结果文件夹
    source etc/profile # 更新配置
    ```

    不过这样的话我们每编译一次软件可能就要编辑一次 `PATH`, 而且也会导致 `PATH` 过多, 因此更方便的方法还是使用软链接的方式

## 标准输入与参数区别

有一些命令不接受标准输入, 这些命令不能用于管道符之后, 比如 `where connect.sh | rm` 是错误的, 这个时候我们只能使用参数传入该命令: `rm "$(where connect.sh)"`

而有些命令既接受标准输入, 又接受命令行参数. 比如 `cat`

如果命令能够让终端阻塞, 说明该命令接收标准输入, 反之就是不接受, 比如你只运行 cat 命令不加任何参数, 终端就会阻塞, 等待你输入字符串并回显相同的字符串.

## 后台运行程序

可以在命令之后加一个 & 符号, 这样命令行不会阻塞, 可以响应你后续输入的命令, 但是如果你退出服务器的登录, 就不能访问该网页了. 如果你想在退出服务器之后仍然能够访问 web 服务, 应该这样写命令 (cmd &)

```bash
$ (python manager.py runserver 0.0.0.0 &)
Listening on 0.0.0.0:8080...

$ logout
```

## 单引号与双引号的区别

不同的 shell 行为会有细微区别, 但有一点是确定的, 对于 `$`, `(`, `)` 这几个符号, 单引号包围的字符串不会做任何转义, 双引号包围的字符串会转义.

shell 的行为可以测试, 使用 `set -x` 命令, 会开启 shell 的命令回显, 你可以通过回显观察 shell 到底在执行什么命令:

![himg](https://a.hanleylee.com/HKMS/2021-07-26173738.png?x-oss-process=style/WaMa)

可见 `echo $(cmd)` 和 `echo "$(cmd)"`, 结果差不多, 但是仍然有区别. 注意观察, 双引号转义完成的结果会自动增加单引号, 而前者不会.

也就是说, 如果 $ 读取出的参数字符串包含空格, 应该用双引号括起来, 否则就会出错.

## 工具使用

### cd

`cd`: 在你知道路径的情况下, 比如 `/usr/local/bin` 你可以输入 `cd /u/l/b` 然后按进行补全快速输入 (路径分为绝对路径与相对路径, 绝对路径总以 `/` 开头, 相对路径直接以文件名开头)

- `cd ~/.oh-my-zsh/themes && ls`: 查看当前 zsh 涵盖主题
- `cd ..`: 返回到上一级目录
- `cd ../.vim`: 返回到上一级目录, 并进入上一级目录下的 `.vim` 目录下
- `cd -`: 返回到上一次访问的目录

### touch

- `touch filename`: 新建一个文件

### env

- `env`: 总是指向 `/usr/bin/env` 文件, 或者说, 这个二进制文件总是在目录 `/usr/bin`
- `/usr/bin/env bash`: 返回 `bash` 可执行文件的位置, 前提是 bash 的路径是在 $PATH 里面.
    - `-i`: --ignore-environment, 不带环境变量启动.
    - `-u`: --unset=NAME, 从环境变量中删除一个变量.
    - `--help`: 显示帮助.
    - `--version`: 输出版本信息.
- `env -i /bin/sh`: 新建一个不带任何环境变量的 Shell

### ln

- `ln -s source/file.txt destination/file.txt`: 将 source 文件夹的 file.txt 文件在 destination 文件夹创建一个符号链接 (软链接)
- `ln source/file.txt destination/file.txt`: 将 source 文件夹的 file.txt 文件在 destination 文件夹创建一个硬链接

### users

- `groups`: 查看当前用户所属组
    - `wheel`: 是系统管理员组, 默认有用户 root, 此组中的用户拥有系统最高权限, 100% 的控制系统, wheel 源于 BSD UNIX, 而 wheel 又有掌舵意思, 意味这掌控着系统方向
    - `admin`: 是用户管理员组, 在此组中的成员可以通过 sudo 命令暂时升级为 root 去执行命令, 和 wheel 同样身为管理员, 但是在平时, 如果不使用 sudo 的话就和普通用户没什么区别, 安全性更好
    - `staff`: 本机的用户都会在此组中, 注意, 并不包括用户 guest
    - `everyone`: 直译过来就是任何人, 包括任何用户, 比如 guest 或者是远程连接过来的用户
- `groups user_name`: 查看指定用户所属组
- `groupadd [option] [groupname]`: 添加某一用户组
    - `-g`: 指定新用户组的组标识号 (GID).
    - `-o`: 一般与 - g 选项同时使用, 表示新用户组的 GID 可以与系统已有用户组的 GID 相同.
- `groupdel [groupname]`: 删除某一用户组
- `groupmode [option] [groupname]`: 修改某一个用户组属性
    - `-g`: GID 为用户组指定新的组标识号.
    - `-o`: 与 - g 选项同时使用, 用户组的新 GID 可以与系统已有用户组的 GID 相同.
    - `-n`: 新用户组 将用户组的名字改为新名字

    > `groupmod –g 10000 -n group3 group2`: 将组 group2 的标识号改为 10000, 组名修改为 group3.

- `newgrp root`: 将用户切换到 root 组中 (前提是 root 组中是有本用户的)

- `cat /etc/passwd`: 查看所有用户
- `cat /etc/group`: 查看所有用户组
- `w`: 查看当前活跃用户
- `whoami`: 当前用户
- `useradd [option] hanley`: 添加用户 hanley
    - `-c`: comment 指定一段注释性描述.
    - `-d`: 目录 指定用户主目录, 如果此目录不存在, 则同时使用 `-m` 选项, 可以创建主目录.
    - `-g`: 指定用户所属的 `primary group` (一个用户只能有一个).
    - `-G`: 指定用户所属的 `secondary group` (一个用户可以有 0 个或多个). `sudo user add -g root -G wheel docker hanleylee`
    - `-s`: 指定用户的登录 Shell. `sudo useradd -s /usr/bin/zsh hanley`
    - `-u`: 用户号 指定用户的用户号, 如果同时有 - o 选项, 则可以重复使用其他用户的标识号.
    - `-D`: 单用显示默认新建用户的配置, 如 `sudo useradd -D`; 后面添加其他参数时用于修改新创建的默认用户的配置, 例如 `sudo useradd -D -s /bin/zsh`
- `userdel [option] hanley`: 删除用户 hanley
    - `-r`: 将用户的主目录一起删除
- `usermod [option] hanley`: 修改用户 hanley 的配置
    - `-c`: comment 指定一段注释性描述.
    - `-d`: 目录 指定用户主目录, 如果此目录不存在, 则同时使用 `-m` 选项, 可以创建主目录.
    - `-g`: 指定用户所属的 `primary group`
    - `-G`: 指定用户所属的 `secondary group`
    - `-s`: Shell 文件 指定用户的登录 Shell.
    - `-u`: 用户号指定用户的用户号, 如果同时有 - o 选项, 则可以重复使用其他用户的标识号.

    > `usermod -s /bin/ksh -d /home/z –g developer hanley`: 此命令将用户 sam 的登录 Shell 修改为 ksh, 主目录改为 / home/z, 用户组改为 developer.
- `id username` 查看当前用户的详情 (用户名, 所属组)

- `passwd [option] hanley`: 修改用户 hanley 的密码
    - `-l`: 锁定口令, 即禁用账号.
    - `-u`: 口令解锁.
    - `-d`: 使账号无口令.
    - `-f`: 强迫用户下次登录时修改口令.

    > 非 root 下不能修改指定用户名的密码, 只能使用 passwd 修改自身密码

- `su - hanley`: 切换到用户 hanley
- `su`: 切换到 root

## 常见问题解决

### mac 设置允许安装任何来源的软件

```bash
sudo spctl --master-disable
defaults write com.apple.LaunchServices LSQuarantine -bool false
```

### 切换 shell

1. `cat /etc/shells`: 常看当前系统支持的 shell 类型
2. `chsh -s /bin/zsh`: 将 `zsh` 设置成默认的 `shell`
3. `source ~/.zshrc`: 重载 `zsh` 的配置文件
    - `. ~/.zshrc`: 同 `source ~/.zshrc`, `.` 是 `source` 的缩写形式
    - `exec $SHELL -l`: 重新启动 SHELL, 与 source 不同的是不会对 PATH 进行重新写入

## 延伸

- [Nodejs 版本管理工具 nvm 及包管理工具 npm 使用](https://hanleylee.com/usage-of-nvm-and-npm.html)
- [Tmux 使用](https://hanleylee.com/usage-of-tmux.html)
- [使用 ssh 协议连接远程主机](https://hanleylee.com/connect-remote-server-by-using-ssh-key.html)
- [神级编辑器 Vim 使用](https://hanleylee.com/usage-of-vim-editor.html)
- [版本管理工具 Git 的使用](https://hanleylee.com/principle-and-usage-of-git.html)
- [Mac 上的包管理工具 Homebrew 使用](https://hanleylee.com/usage-of-homebrew.html)
- [macOS 使用 Parallels Desktop 15 安装 CentOS 8 并安装 Parallels Tools](http://fxxkr.com/2020/03/17/parallels-desktop-15-install-centos8-and-parallels-tools-on-macos/)
