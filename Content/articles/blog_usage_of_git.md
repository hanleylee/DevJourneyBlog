---
title: 版本管理工具 Git 的使用
date: 2019-12-24
comments: true
path: principle-and-usage-of-git
categories: Terminal
tags: ⦿git, ⦿tool
updated:
---

就软件开发来说, 不管是个人开发还是团队协作, 版本管理工具肯定必不可少. 其中分布式版本管理工具 git 由于其优良的性能, 可靠的安全性最为被接受, 也是最为普及的.

在完整地看了几个教程并且实战了一段时间后, 我将日常使用的命令以及个人理解总结成本文. 本文涉及内容有初级, 有高级, 如果能完全掌握这些命令绝对能在工作中祝你一臂之力. 建议收藏以备以后检索相关命令. 😁

![himg](https://a.hanleylee.com/HKMS/2021-07-26211118.png?x-oss-process=style/WaMa)

<!-- more -->

## 分布式存储与集中式存储的区别

- 都有一个中央仓库
- 团队合作开发中每个人的仓库最终都必须同步到中央仓库
- 中央式存储没有个人仓库的概念, 因此只有做完一个小功能后上传到中央仓库才会有一个记录节点. 这样会导致一个提交里面包含很多代码, 不利于回溯.
- 分布式存储有个人仓库, 每个人做完一个极小的功能后可以先 `commit`, 然后再 push, push 到中央仓库后也会将自己的诸多小 `commit` 传上来.(如果不需要那么多小 `commit` 的话可以使用 `rebase` 依次合并多个小 `commit` 然后再统一 `push`)
- 分布式存储由于在每个机器上都会有完整的存储仓库, 因此本地占用会比较大, 初次 clone 也会稍微费事一些
- 结合以上特点, 由于软件开发主要是文本代码, 而这些资料的占用空间并不大, 而且软件开发对历史回溯要求比较高, 因此一般都是使用分布式存储.  集中式存储主要用于某些占用体积超大的项目开发领域, 比如大型游戏.

## Git 特点概括

- `Git` 的管理是目录级别, 而不是设备级别的, 即两个不同的目录存着同样地址的仓库的话会被认为是两个不同的仓库, 可以用于模拟为两个人.
- `git` 是以 line 为最小单位进行判断的, 即如果序号 `1` 的行被 branch 修改了, 序号 `2` 的行被 `master` 修改了, 那么在 `merge branch` 与 `master` 的时候结果就是序号 `1` 与 `2` 都被修改了. 但是两个 `branch` 都在序号 `1` 的行修改了, 那么就会冲突, 会提示手动解决冲突.  一个仓库中的文件都会被 git 系统监视, 一共有以下 3 种状态
    1. `未被跟踪`: 新建文件都不会被跟踪. 需要手动 `add` 进入暂存区
    2. `已保存`: 已经在系统中保存了此文件, 被放在 `保存区` 未放入暂存区 `(changes not staged for commit)`
    3. `已暂存`: `commit(changes to be commited)`, 被放入 `暂存区`. 等待 `commit` 中

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-144703.jpg?x-oss-process=style/WaMa)

- 其实 `reset` 的三个状态正好对应了文件的几种保存状态
    1. `--hard`: 回退 `commit`, 将两个 `commit` 之间的改动放入暂存区, 再将暂存区所有文件放到保存区, 再将 `保存区` 文件删除. 最硬的
    2. `--mixed`: 回退 `commit`, 将两个 `commit` 之间的改动全部放入 `暂存区`, 再将暂存区所有文件放到 `保存区`
    3. `--soft`: 回退 `commit`, 两个 `commit` 之间的改动全部放入 `暂存区`. 最软的.
- `reset` 的三种模式中, 只有 `hard` 会直接将文件直接转为未提交 `commit` 之前的状态
- 一个已被跟踪的文件被改动了, 只要保存更改就会被放入保存区. 此时可以
    1. 使用 `git checkout -- filename` 来永久撤销文件修改.
    2. 使用 `git add` 命令将更改放入 `暂存区` 等待 `commit`.
- 未放入 `staged area` 的修改不会被 `commit`.
- 如果一个文件未被跟踪 (`untracked file`), 那么 `Git` 系统只会提示你在 `git` 文件夹中有一个未被跟踪的文件, 哪怕对齐进行修改 `git` 也不会关心其修改内容. 只要 `add` 一次就可以永久跟踪.
- `show` 显示的是 `commit` 状态及细节, `diff` 显示的是文件的修改状态和细节
- 在对文件修改时, 只会在当前 `branch` 进行修改, 在 `push` 时, 也只会将此内容 `push` 到远端的此 branch
- `git` 中的 `head` 和 `branch` 都是引用 (`reference`), 其内存储的都是各个 `commit` 的 `sha1` 值. 引用都以文件形式存储在 `.git` 目录中, 当 `git` 工作时, 通过这些文件的内容判断整个仓库的结构.
- 每个仓库只能有一个 head, branch 可以有多个
- `head` 指向的 `branch` 不能被删除, 必须签出到另一个 branch 方可删除
- `git` 中的 `branch` 只是一个对 `commit` 的引用, 删除 `branch` 并不会删除任何 `commit` (不过如果一个 `commit` 不在任何 `branch` 上, 那么这个 `commit` 就是一个野 `commit`, 其在一定时间后会被 `Git` 的回收机制自动删除)
- `checkout` 的本质是移动 `head` 到指定的 `commit`, 即如果后面跟的是 `branch`, 此命令会签出 此 `branch` 所对应的 `commit`. 如果后面跟的是 `commit`, 那么直接签出该 `branch`, 比如 `git checkout 78a4bc`, `git checkout HEAD^`, `git checkout 78a4bc^`. 不过需要注意如果根据 `commit` 值来签出, 那么会导致 `head` 变为 `detached` 状态, 哪怕签出的位置在某个 `branch` 上也不行. 想离开这种 `detached` 状态可以使用 `git checkout <branch name>` 命令

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-144707.jpg?x-oss-process=style/WaMa)

- `merge` 会创建一个新的 `commit` 来使两个 `branch` 的最新 `commit` 进行融合, 但是 `merge` 会出现几种冲突情况:
    1. 两个 `branch` 中的同一个文件的同一行被各自 `branch` 修改了 (只能手动选择保留部分了)
    2. 目标 `commit` (需要被 `merge` 的 `commit`) 与 `head` 所指向的 `commit` 并不存在分叉, 而是 `head` 领先于目标 `commit`: 此时 `merge` 不会创建一个新的 `commit`, 因为没有需要合并的, 什么也不会做
    3. 目标 `commit` 与 `head` 所指向的 `commit` 不存在分叉, 但是 `head` 所指向的 `commit` 落后于目标 `commit`: 此时 `merge` 依然不会创建一个新的 commit(因为没哟需要合并的内容), 此时会将 `head` 指向的 `commit` 快速向前移动 (`fast-forward`). 这其实非常常见: 本地没有提交, 但是同事开发了新内容并合并到了 `master` 上, 本地 `pull` 的时候会先 进行 `fetch`, 然后 `merge`, 此时 `merge` 的目标 `commit` 即领先于 head 指向的 `commit`, 这个时候就会进行 `fast-forward`)

    ![himg](https://a.hanleylee.com/HKMS/2019-12-31-15fddc2b2486758a.gif)

- `merge` 后 `branch` 不会被自动删除
- 没有被 `merge` 的 `branch` 在删除时会失败 (但是如果确认某个 `branch` 完全没有作用了, 一定要删除, 那么可以将 `git branch -d` 改为 `git branch -D` 来强制删除)
- `pull` = `fetch` + `merge`

- `push` 并不会上传 `head` 到远端, 即远程仓库永远只会指向 `master`. 这也是为什么从远端 `clone` 下来后在第一次使用时总是指向 `master` 的.
- 不是最新的几次提交不能用 `git reset`. 不是最新的一次提交不能用 `git commit --amend`
- `rebase` 可以合并 `commit`, 修改之前某次 `commit`, 删除之前某次 `commit`, 属于 git 中的高深用法.
- 在 `git` 中有两个偏移符号 `^` 与 `~`, `^` 表示根据 `head` 向左偏移, `~` 表示根据 `branch` 向左偏移
- `tag` 可以理解为 不可移动的 `branch`, 通常用来为项目节点做标记
- `cherry-pick`: 把选中的 `commit` 一个个合并

## Git 常用命令

- `git help <command>`: 对 git 的某一命令查看帮助, e.g. `git help config`
- `git help --web log`: 在浏览器中查看 `git log` 的用法
- `git help --man log`: 在 man 中查看 `git log` 的用法

- `git -C path/to/repo`: 指定 repo 的路径进行相关 git 操作, 写脚本时非常有用(可以避免 cd)
- `git ls-remote <url> --tags test | cut -f 1`: 获取远程仓库 test 分支最新的 commit 值
- `git --git-dir=/path/to/repo/.git rev-parse origin/<targeted-banch>`: 获得本地仓库分支的最新 commit 值
- `git symbolic-ref --short HEAD`: 获得当前分支名
- `git rev-parse --abbrev-ref HEAD`: 获得当前分支名(同上)
- `git clone`: 克隆仓库
    - `git clone <link> [foldername]`: 从远端链接拉取项目, link 可以为 `https` 连接, 也可以为 `ssh` 连接, 最后的 foldername 表示可以指定文件夹名称
    - `git clone -b master <link>`: 克隆远程仓库到本地, 并 checkout 到 `master` 分支
    - `git clone -b 0.0.5 <link>`: 克隆远程仓库到本地, 并 checkout 到 tag `0.0.5` 上
    - `git clone --recursive <link>`: 递归克隆, 在项目包含子模块时非常有用
    - `git clone --depth=1 <link>`: 克隆深度为 1, 只克隆最后一条, 减少克隆时间
    - `git clone --bare <link>`: 裸克隆, 没有工作区内容, 不能进行提交修改, 一般用于复制仓库
    - `git clone --mirror <link>`: 镜像克隆, 也是裸克隆, 区别于包含上游版本库注册

- `git status`: 状态
    - `git status`: 查看当前 `branch` 的当前状态与最近一次 `commit` 相比, 暂存区 & 保存区 & 以及未跟踪文件的状态, 提交前一定要用
    - `git status -s`: 以短格式输出
    - `git status --ignore-submodules`: 忽略子模块
    - `git status --ignored`: 显示忽略的文件

- `git init`: 初始化
    - `git init`: 将当前目录直接作为 `git` 的工作路径并生成一个 `.git` 文件夹
    - `git init [repo name]`: 将 `repo name` 作为工作路径并在 `repo name` 文件夹下剩下一个 `.git` 文件夹
    - `git init repo.git --bare`: 创建一个 `repo.git` 的文件夹并将其作为 git 库, 其内直接包含 `.git` 文件夹内的所有文件, 相当于去除了工作区
- `git config [range] [command] [option]`: 配置 git 环境
    - `range`: 有三种级别, system, global, local, sytem 针对当前系统所有用户的所有 repo, gloabl 针对当前用户的所有 repo, local 只针对当前 repo,
      他们的关系是如果下一级的 config 没有对某项配置做自定义, 就自动引用上一级的 config 相关配置
        - `--system`: 将 config 配置写入 `/etc/gitconfig`
        - `--global`: 将 config 配置写入 `~/.gitconfig` 文件
        - `--local`: 默认级别, 将 config 配置写入当前 repo 的 `.git/config` 文件中
    - `command`: 命令
        - `--list`: 列出当前 repo 的所有 config 信息 (如果使用了 global 则列出 global 的 config 信息)
        - `--unset`: 取消 config 中某项配置 (后跟 option), 也可以通过编辑 `.gitconfig` 或 `config` 文件来达到同样目的
        - `--unset-all`: 取消 config 中所有配置
        - `--remove-section`: 移除某组配置
        - `--rename-section`: 重命名某组配置
    - `option`: 具体配置
        - `--user.name`: 设置用户名, 安装 git 必设置
        - `--user.email`: 设置用户邮箱, 安装 git 必设置
        - `--core.editor`: 设置 git 的默认编辑器, 默认为 vi 或 vim
        - `--merge.tool`: 设置 git 的合并工具
        - `alias.st status`: 设置 git 的某些快捷别名, e.g. `git config --global alias.st status` 的作用是让 `git st` 指向 `git status`
- `git config --global --unset user.name`: 删除相关配置, 可以是 `--global`, 也可以是 `--local`
- `git config --global -e`: 编辑当前仓库配置文件, 等价于 `vim ~/.gitconfig`
- `git config --global https.proxy http://127.0.0.1:1087`: 配置代理
- `git config --global http.proxy http://127.0.0.1:1087`: 配置代理

- `git push`: 推送本地仓库到远程
    - `git push origin test`: 将当前 branch push 到远程的 `test` 分支上(其本质是提交本地分支 `test` 指针到 `origin`, 相当于拷贝 `refs/heads/test` 到远程引用 `refs/remotes/origin/test` 并提交)

        事实上 `git push` 命令也可以进行 `push`, 不过 `git push` 只能 `push` 从远端 `pull` 或者 `clone` 下来的 `branch`, 对于由本地直接创建的 `branch` 就无能为力了, 或者本地创建的仓库使用 `git push --set-upstream origin branch1` 命令指定了本仓库对应的远程仓库分支, 这样也能直接使用 `git push`

    - `git push origin test -f`: 强制 `push`, 在本地仓库与远程仓库有差别被拒绝的时候但是自己很清楚的时候使用. 但是如果冲突发生在 `master` 的话就不要用了. 很危险.
    - `git push origin <local branch1>:<remote branch2>`: 将本地 `branch1` 推送到远程 `branch2` 上
        - `remote branch2` 不写的话表示将本地分支 `branch1` 推动到远程同名 `branch` 上
        - `local branch2` 不写的话代表将空分支推送到远程 `branch2` 上, 也就是表示删除远程 `branch2`

        以下四种书写方式效果是一样的:

        - `git push origin master`
        - `git push origin master:master`
        - `git push origin master:refs/heads/master`
        - `git push origin refs/heads/master:refs/heads/master`

    - `git push -u origin HEAD`: 将当前分支名推送到远程同名分支(远程没有同名分支的话会自动创建)
    - `git push -u origin branch1`: 将 branch1 分支推送到远程同名分支(远程没有同名分支的话会自动创建)
    - `git push origin --all --force`: 将本地所有分支强制提交到远端
    - `git push --tags`: 推送所有 `tag`, 不推送 `commit`
    - `git push --follow-tags`: 推送 `commit` 的同时会把当前 `branch` 上的所有 `tag` 进行推送
    - `git push --atomic origin <branch name> <tag>`: 将 `git push origin <branch name>` 与 `git push <tag>` 作为一个原子命令, 一旦原子命令中的任何一个失败, 则整个原子命令失败
    - `git push origin 9790eff:master`: 将本地 `9890eff` 以前的所有 `commit` 推送到远端
    - `git push origin --delete master`: 删除分支, 等价于 `git push origin :master`
    - `git push origin :<old name> | git push origin <new name>`: 重命名远程分支 (方法 1), 原理是先删除远程某分支, 然后将本地当前分支推送到新命名的远程分支上
    - `git push b_origin refs/remotes/a_origin/main:main`: 将 `a_origin` 的 `main` 分支推送到 `b_origin` 的 main 分支上
    - `git push b_origin refs/remotes/a_origin/main:refs/heads/main`: 同上, 不过在 `b_origin` 没有 `main` 分支时会自动创建该分支

- `git fetch`: 从远端获取仓库对应分支的最新状态
    - `git fetch -a`: 从远端获取仓库所有分支的更新 (不合并任何分支)
    - `git fetch origin`: 手动指定了要 `fetch` 的 `remote`, 在不指定分支时通常默认为 `master`
    - `git fetch origin dev`: 指定远程 `remote` 和 `FETCH_HEAD`, 并且只拉取该分支的提交
    - `git fetch origin branch1:branch2`: 从服务器拉取远程分支 `branch1` 到本地为 `branch2`, 并使 `branch2` 与 `branch1` 合并
    - `git fetch b_origin main:refs/remotes/a_origin/main`: 将 `b_origin` 的 `main` 分支拉取到本地 `a_origin` 的 `main` 分支上

- `git pull`: 从远端拉取仓库最新状态并与本地仓库合并
    - `git pull -a`: 从服务器远端拉取仓库的所有分支的更新, 并将当前分支对应的远程分支的更新合并到本地当前分支上 (不合并其他分支)
    - `git pull orign test`: 从服务器拉取远端名为 `test` 的 `branch` 并与本地当前的 `branch` 合并 (这个命令适用于在本地 `git branch <name>` 或 `git checkout -b <name>` 刚建立了一个新的本地分支, 然后从服务器的指定分支拉取 `commit` 到本地此新分支上)
    - `git pull origin master --rebase`: 以变基方式拉取远端主分支到本地 `master` 分支, 主要用于第一次拉取远端分支
    - `git pull origin branch1:branch2`: 从服务器远端拉取 `branch1` 分支合并到本地的 `branch2` 分支, 如果本地没有 `branch2` 分支的话则新建.  然后将拉取到的分支合并到当前所处的分支上
    - `git pull origin master:master`: 从服务器拉取远程 `master` 到本地 `master` 上, 然后合并, **然后将 master 分支 merge 到当前所处的分支上**. 这个比 `git fetch` 多了一步 (合并 `master` 到本分支), 因此要慎用, 最好用 `git fetch`, 然后自行判断
    - `git pull origin master:master --rebase`: 与上一种功能类似, 不过是将当前分支 `rebase` 到 `master` 分支上

- `git remote`: 远程仓库
    - `git remote -v`: 查看远程仓库地址
    - `git remote add origin <url>`: 在没有远程仓库的基础上添加远程仓库地址
    - `git remote set-url origin <url>`: 在有 origin 的基础上直接重新设置远程仓库地址
    - `git remote rm origin`: 删除远程仓库地址
    - `git remote show origin`: 查看远程仓库信息 (比如 push 与 pull 地址, 远程仓库当前 head 指向, 远程仓库当前分支)
    - `git remote rename oldname newname`: 重命名远程仓库
    - `git remote remove origin`: 移除远端跟踪

- `git show`: 查看最近一次 `commit` (`head` 所指向的 `commit`) 修改的文件和内容
    - `git show --stat`: 查看最近一次 `commit` 的统计信息 (修改了多少处)
    - `git show 5e68b0d8`: 查看 `sha` 值为 `5e68b0d8` 的 `commit` 修改内容
    - `git show 5e68b0d8 a.txt`: 查看 `sha` 值为 `5e68b0d8` 的 `commit` 中 *a.txt* 文件的具体修改情况

- `git diff`: 显示目前的保存区与最近一次 `commit` 的原工作目录相比有什么差异. 即, 在 `git add` 后会向暂存区提交什么内容
    - `git diff --staged`: 查看暂存区与最近一次 `commit` 的原工作目录相比有什么差异. 即, 这条指令可以让你提前知道你 `commit` 会提交什么内容. 这个命令与 `git diff --cached` 完全等价
    - `git diff master..branch`: 比较 `master` 与 `branch` 之间的不同
    - `git diff 0023cdd..fcd6199`: 比较两个 `commit` 之间的不同
    - `git diff README.md`: 查看当前分支 `README.md` 文件的变动
    - `git diff adt312d`: 查看 `adt312d` 这个 `commit` 与当前最新 `commit` 的异同(从 adt312d 到 HEAD 中间有什么变化)
    - `git diff E..A^ | git apply`: 先获取从 E 到 A 的前一个节点之间的变化, 然后这个改动就是这几个 commit 的逆操作, 使用 `git apply` 将其应用到代码上, 然后再 `add` `commit`
    - `git diff A..B`: 对比 `AB` 两个提交的差异
    - `git diff A...B`: `AB` 两次提交的共同祖先和 `B` 之间的 diff
    - `git diff --theirs`: 在合并冲突时表示当前冲突相对于 theirs 的变化

    ![himg](https://a.hanleylee.com/HKMS/2023-04-02233700.jpg?x-oss-process=style/WaMa)

- `git ls-files`: 列出本分支下所跟踪的文件列表

- `git add`: 添加改动到暂存区 (`staged area`), 虽然 `add` 后添加的是文件名, 但实际上添加的是改动 (如果 `a.txt` 改动后被 `add`, 然后再次被改动 `a.txt` 的另一处, 那么在 `git status` 时会警告 `a.txt` 既在暂存区又不在)
    - `git add./README.md`: 仅暂存当前目录下的 `README.md` 文件
    - `git add <file1> <file2>...`: 一次暂存多个文件
    - `git add.`: 提交本路径下的全部更改 (新文件, 修改文件, 删除文件)(会忽略 `.gitignore` 中列出的新增文件)
    - `git add -A`: 同 `git add.`, 不过添加的是本仓库的所有路径下的更改 (会忽略 `.gitignore` 中列出的新增文件)
    - `git add -u`: 只提交已经跟踪文件的修改 (不理会新文件)
    - `git add --ignore-removal.`: 只提交新文件与修改文件 (不理会删除文件)
    - `git add --all -- ':!path/to/file1' ':!path/to/file2' ':!path/to/folder1/*'`: 排除指定路径下的改动(path 可以使用 `/` 表示 repo 的根目录)
    - `git add -- . ':!path/to/file1' ':!path/to/file2' ':!path/to/folder1/*'`: 排除指定路径下的改动

    ![himg](https://a.hanleylee.com/HKMS/2020-05-01-051414.jpg?x-oss-process=style/WaMa)

- `git merge`: 合并分支
    - `git merge test`: 将名为 `test` 的 `branch` 合并到当前 `head` 所指向的分支
    - `git merge --abort`: 在出现 `merge conflict` 状况时放弃此次 `merge`, 会恢复到 `merge` 之前的状态.
    - `git merge --continue`: 解决冲突后继续 `merge`
    - `git mergetool`: 在合并出现问题时使用此工具进行手动合并
    - `git checkout --conflict=merge file`: 重新标记文件为 `unmerged`(待合并状态)
    <!--- `git merge branch1 branch2`: 将 `branch1` 分支合并到 `branch2` 上 -->
    - `git merge develop -q`: 以安静模式合并, 吧 develop 分支合并到当前分支并不输出任何消息
    - `git merge develop --no-edit`: 合并时使用默认的合并消息
    - `git merge develop --no-commit`: 合并分之后不进行提交

- `git cherry-pick`: 挑选 `commit`
    - `git cherry-pick commit1 commit2 commit3`: 将三个 `commit` 合并入本 `branch`
    - `git cherry-pick commit1 commit2 commit3 --no-commit`: 将三个 `commit` 的内容放入本 `branch` 的暂存区但是先不合并
    - `git cherry-pick -x commit1`: 在合并时将 `commit1` 的原有作者信息进行保留

- `git commit`: 提交通过 `add` 命令放入暂存区的改动
    - `git commit -a`: 提交全部更改 (默认将所有修改文件及删除文件添加进暂存区)
    - `git commit -m "message"`: 使用 `message` 作为 `commit` 的标题直接提交
    - `git commit --amend`: 对最新的 `commit` 进行修改 (此操作不会直接在原 `commit` 上进行修改, 而是将新修改内容与最新 `commit` 内容进行融合, 据此创建一个新的 `commit` 并进行替换)
    - `git commit --amend --no-edit`: 在 `amend` 的基础上, 不进入修改 message 界面
    - `git commit --amend --reset-author`: 默认情况下 `amend` 并不会重置第一次 `author` 的时间, 使用 `--reset-author` 可以重置 `author` 时间为当前时间
    - `git commit --author "HanleyLee <hanley.lei@gmail.com>"`: 指定 author 的方式进行 commit
    - `GIT_COMMITTER_NAME="HanleyLee" GIT_COMMITTER_EMAIL="hanley.lei@gmail.com" git commit --author "HanleyLee <hanley.lei@gmail.com>"`: 同时设置 `author` 与 `committer`
    - `git commit --allow-empty-message`: 允许提交空消息, 通常必须有消息
    - `git commit -v`: 在填写信息的界面显示所有变动 (`diff` 格式的)

- `git stash`: 将保存区与暂存区的文件 (未 `commit` 的) 临时放入一个空间 (注意: 未跟踪的文件不会被 `stash`), equal to `git stash save` / `git stash push`
- `git stash save "test"`: 保存时添加注释(already depreated, use `git stash push`)
- `git stash push`: 将保存区与暂存区的文件
- `git stash push -m "test"`: 将保存区与暂存区的文件, 对 stash 命名
- `git stash list`: 查看当前保存列表
- `git stash show stash@{0}`: 显示更改的相关文件
- `git stash show -p stash@{0}`: 显示所有的更改 (更加详细)
- `git stash pop`: 将 `stash` 空间保存的文件还原到保存区中
- `git stash pop stash@{1}`: 恢复指定 stash, 具体编号可以通过 `git stash list` 查找
- `git stash apply`: 与 pop 命令相同, 不过不会从 stash 列表中移除
- `git stash clear`: 清空所有保存的 stash
- `git stash drop stash@{0}`: 清除指定 stash
- `git stash drop`: 清除最近一次

- `git branch` 分支管理
    - `git branch test`: 从 `head` 所指向的 `commit` 处创建一个名为 `test` 的新的 `branch`
    - `git branch branch1 origin/branch1`: 从本地下载的远程 `branch1` 处在本地建立一个 `branch1` 分支
    - `git branch -r`: 显示本地所有分支
    - `git branch -a`: 显示本地及远程所有分支
    - `git branch -r`: 显示远程端所有分支
    - `git branch -vv`: 查看本地分支所关联的远程分支
    - `git branch --set-upstream-to=origin/branch1 branch1`: 设置本地 branch1 所追踪的远程分支为 `origin/branch1`
    - `git branch --set-upstream-to=origin/branch1`: 设置本地当前 branch 所追踪的远程分支为 `origin/branch1`
    - `git branch -u origin/branch branch`: 同 `--set-upstream`, 也是追踪远程分支
    - `git branch --unset-upstream`: 移除跟踪
    - `git branch -d test`: 删除名为 `test` 的 `branch`
    - `git branch -D test`: 强制删除名为 `test` 的 `branch`(即使没有被 merge 的分支也可以删掉, 如果删除之后想恢复, 那么使用 `git checkout -b branch-name hash` 即可)

        ![himg](https://a.hanleylee.com/HKMS/2022-07-02141527.png?x-oss-process=style/WaMa)

    - `git branch -r -d origin/hanley`: 删除本地已经下载的远程分支, 同时要执行以下两个命令中任意一个:
        - `git push --delete origin <branch name>`: 使用删除命令直接删除远程 `branch`
        - `git push origin:<branch name>`: 使用推送命令将一个空 `branch` 推送到远程以达到删除该 tag 的效果
    - `git branch -m <old name> <new name>`: 重命名本地分支
    - `git branch -M <old name> <new name>`: 强制重命名本地分支
    - `git branch -f <branch> <commit>`: 重新定义 branch 的起始节点到某个 `commit`
    - `git branch -m <old name> <new name>` | `git push origin:<old name>` | `git push --set-upstream origin <new name>`: 重命名远程分支 (方法 2), 先本地重命名, 然后删除远程某分支, 最后推送并设定推送到的远程 `branch` 名
    - `git branch --merged`: 查看已经合并的 `branch`
    - `git branch --no-merged`: 查看未合并的 `branch`
    - `git branch --merged | xargs git branch -d`: 删除已经合并的 `branch`
    - `git branch --show-current`: 输出当前分支, 同 `git rev-parse --abbrev-ref HEAD`
    - `git branch --contains <commit-id>`: 列出所有包含 commit 的分支
    - `git branch --contains dcc5ae4 | grep -E '(^|\s)branch$' &>/dev/nul`: 过滤包含 commit-id 的分支(可以用来判断一个分支是否包含某个 commit)
    - `git branch $(git symbolic-ref --short HEAD) --contains $COMMIT_ID`: 限定结果只展示当前分支
    - `git branch | grep -o -m1 "\b\(master\|main\)\b"`: 打印默认分支(master or main)
    - `git reflog show --data=iso master`: 查看本地 `master` 分支的创建时间
    - `git switch <branch1>`: 切换分支

- `git merge-base`: Find as good common ancestors as possible for a merge.
    - `git merge-base --is-ancestor $COMMIT_ID $BRANCH`: 判断分支是否包含指定 commit, 比 `git branch $BRANCH --contains $COMMIT_ID` 更好

- `git checkout`: 签出
    - `git checkout myfile.txt`: The contents of *myfile.txt* will be copied from the `staging area` to the `working directory`
    - `git checkout .`: Same as above, but apply to all current directory
    - `git checkout HEAD myfile.txt`: Take the version of *myfile.txt* that is in head's parent and copy it to both the *staging area* and the *working directory*
    - `git checkout 3dbs22 a.txt`: Same as above
    - `git checkout test`: 签出名为 `test` 的 `branch` 对应的 `commit`(`work dir` 与 `staged area` 的改动不会被重置, 可以使用 `-f` 参数进行重置)
    - `git checkout -f master`: 强制切换到 master, 未保存的改动(包括 `work dir` 与 `staged area`)会被丢弃
    - `git checkout HEAD^^`: 将 `HEAD` 向左两位的 `commit` 签出 (即倒数第三位)
    - `git checkout head~3`: 将 `head` 向左三位的 `commit` 签出 (即倒数第四位)
    - `git checkout 3d122b`: 将 `sha` 值为 `3d122b` 的 `commit` 签出, 此时会导致 `head` 变为 `detached` 状态, 想离开这种 `detached` 状态可以使用 `git checkout <branch name>` 命令
    - `git checkout -b test`: 创建一个名为 `test` 的 `branch` 并签出到该 `branch` 对应的 `commit`
    - `git checkout -b test origin/test`: 在本地创建名为 `test` 的 `branch` 并跟踪远端的 `test` 分支
    - `git checkout -t origin/dev`: 在本地创建名为 `dev` 的 `branch` 并跟踪远端的 `dev` 分支, 通常是在本地没有远程分支才会本命令
    - `git checkout --detach`: 使 `head` 与 `branch` 分离, 使 `head` 直接指向 `commit`
    - `git checkout --conflict=diff3 test.txt`: 将文件重置回冲突状态, 适用于 merge 时发生冲突后没有完全解决时被一些其他工具将文件标记为了解决
    - `git checkout --conflict=merge test.txt`: 将文件重置回冲突状态
    - `git checkout --ours test.txt`: 在合并冲突时选择 `ours` 作为解决方案
    - `git checkout --theirs test.txt`: 在合并冲突时选择 `theirs` 作为解决方案

- `git blame`: 责怪~
    - `git blame <filename>`: 查看某个文件的修改历史记录, 含时间, 作者, 以及内容
    - `git blame -L 11,12 <filename>`: 查看谁改动了某文件的 11~12 行
    - `git blame -L 11 <filename>`: 查看 11 行以后的所有改动人
    - `git blame -l <filename>`: 显示完整的 hash 值
    - `git blame -n <filename>`: 显示修改的行数
    - `git blame -e <filename>`: 显示作者邮箱
    - `git blame -enl -L 11 <filename>` 参数组合查看修改者

- `git restore`: 重置
    - `git restore <filename>`: 将保存区的此文件更改全部重置, 降级! 与 `git checkout -- <filename>` 功能相同
    - `git restore --staged <filename>`: 将暂存区文件转移至保存区, 降级!
        - `git checkout -- *`
        - `git checkout -- *.md`
        - `git checkout -- 123.md 345.md`

- `git reflog`: head 记录
    - `git reflog`: `reference log` 的缩写. 可查看 `Git` 仓库的 `head` 的所有移动记录. 可以在误删 branch 等情况下使用
    - `git reflog master`: 查看关于 `master` 的所有 `head` 的移动记录.
    - `git reset --hard HEAD@{3}`: 恢复到指定节点状态

    > 使用 `git reset --hard hash` 也可回退到 reflog 对应的节点上

- `git rm`: 移除
    - `git rm <filename>`: 删除对文件的跟踪, 并删除本地文件 (未添加到暂存区时使用)
    - `git rm -f <filename>`: 删除对文件的跟踪, 并删除本地文件 (已添加到暂存区时使用). `f` 是强制的意思
    - `git rm --cached <filename>`: 取消对某个文件的跟踪. 而不删除本地文件
    - `git rm -r --cached <foldername>`: 取消对某个文件夹的跟踪. `r` 为递归的意思. `git rm -r *` 会将当前目录下的所有文件与子目录删除
    - `git rm -rf.`: 清除当前目录下的所有文件, 不过不会删除 `.git` 目录
    - `-n`: 所有的 `rm` 命令后面加上此命令后, 不会删除任何东西, 仅作为提示使用

- `git clean <command>`: 清理未被 `tracked` 的文件, `git reset` 只能让跟踪的文件回复到某个版本状态, 对于未跟踪的文件无能为力, 如果想要完全移除未跟踪的文件, 那么就要使用 `git clean -df`, 此命令常与 `git reset` 配合使用 (默认情况下, `git clean` 命令只会移除没有忽略的未跟踪文件, 如果也需要移除已被 `gitignore` 忽略的文件, 则需要加 `x`)
    - `-f`: 强制删除. 如果 `Git` 配置变量 `clean.requireForce` 未设置为 `false`, `git clean` 将拒绝删除文件或目录, 除非给定 `-f`, `-n` 或 `-i`.
    - `-f <path>`: 删除指定路径下 `untracked files`
    - `-d`: 除了未跟踪的文件之外, 还要除去未跟踪的目录.
    - `-X`: 仅删除当前目录下 `gitignore` 里忽略的文件, 那些既不被 `git` 版本控制, 又不在 `gitignore` 中的文件会被保留.
    - `-x`: 不使用 `gitignore` 的忽略规则, 删除本路径下所有的 `untracked files`
    - `-n`: 将此命令加在上面三个命令前, 先看看会删除哪些文件 (相当于演习一遍). e.g. `git clean -n -xfd`
    - `-i`: 使用交互式删除, 每一个文件的删除都有提示, 更加安全

- `git tag`: 不可移动的标识点, 通常用来作为里程碑标记, 最广泛的使用就是作为版本标记

    - `git tag`: 显示所有 `tag`
    - `git ls-remote --tags origin`: 列出远程所有标签
    - `git tag <tag name>`: 为最新 commit 的创建 tag
    - `git tag <tag name> <commit name>`: 为之前的某个 commit 点创建 tag
    - `git show <tag name>`: 显示指定 tag 信息
    - `git tag -d <tag name>`: 删除本地的指定 tag; 如果想要删除远程的 tag, 需要先在删除本地 tag, 然后使用:
        - `git push origin --delete tag <tag name>`: 使用删除命令直接删除远程 `tag` (或使用 `git push origin --delete tag <tag name>`)
        - `git push origin:refs/tags/<tag name>`: 使用推送命令将一个空 tag 推送到远程以达到删除该 tag 的效果
    - `git push origin <tag name>`: 推送指定 tag 到远程
    - `git push origin --tags`: 推送所有本地 tag 到远程
    - `git ls-remote --tags origin`: 显示远程所有 tag(不加 origin 也可以)
    - `git tag -l | xargs git tag -d` && `git fetch origin --prune`: 先删除本地所有分支, 然后从远端拉取所有分支, 适用于远端的 tag 被修改但是本地 tag 仍然是旧的
    - `git tag -l v1.*`: 筛选符合条件的 tag
    - `git tag -a v1.4 -m "my version 1.4"`: 创建含标注的 tag, 并为此标注直接添加信息 (标注可通过 git log 查看)
    - `git tag -a v1.2 9fceb02`: 为之前的提交打 tag, 会进入填写 message 界面
    - `git fetch --tags`: 拉取远程所有 tag

- `git revert`: 添加与之前 `commit` 完全相反的 `commit`
    - `git revert HEAD^`: 增加一条与当前 `head` 指向的 `commit` 的内容完全相反的 `commit`. 从而达到"中和"的效果以对其进行撤销. 用在错误内容已经合并在 `master` 但是需要修改的时候.
    - `git revert OLDER_COMMIT^..NEWER_COMMIT`

- `git reset`: 重置到某个 `commit`(第一个参数是提交的 SHA-1, 默认是 HEAD, 第二个参数如果不写则是整体重置, 否则只重置单个文件)
    - `git reset a.txt`: 将文件 a.txt 从 `HEAD` 中还原到 `staged area`, 然后再退回到 `work dir` 中 (默认使用的是 `mixed`)
    - `git reset --mixed HEAD a.txt`: 是上一个命令的全称
    - `git reset HEAD./README.md`: 仅重置某文件到 `HEAD`
    - `git reset --hard HEAD^^`: `HEAD^^` 表示需要恢复到的 `commit`, 因此这个命令表示将 track 的文件直接恢复到上上一个 `commit`, 其后的所有 `commit` 全部丢弃 (如下图所示, 虽然 `commit` 不被任何 `branch` 指向了, 但是 `Git` 不会立刻删除它, 还是可以通过 `sha1` 值来复原的), 一般与 git clean 联合使用
    - `git reset 17bd20c`: 相当于把 `HEAD` 移到了 `17bd20c` 这个 `commit`, 而且不会修改 `work dir` 中的数据, 所以只要 `add` 再 `commit`, 就相当于把中间的多个 `commit` 合并到一个了.

    ![himg](https://a.hanleylee.com/HKMS/2019-12-31-15fe19c8a3235853.gif)

- `git rebase`: 变基
    - `git rebase master`: 在 `branch` 上执行此命令. 将 `branch` 上从与 `master` 交叉的 `commit` 之后的所有 `commit` 依次提交到 `master` 最新 `commit` 之后 (就是将节点 5, 6 的内容在 `master` 分支再次提交一次). 如果想指定基础点参考 [这里](#jump)

    ![himg](https://a.hanleylee.com/HKMS/2019-12-31-1600abd620a8e28c-1.gif)

    - `git rebase -i <commit>`: 交互式变基, 可合并 commit, 剔除 commit 等
    - `git rebase -i HEAD~10`: 将当前 head 向前数 10 个的所有 commit 进行变基
    - `git rebase --continue`: 解决冲突后, 解决冲突, 并 `git add`, 然后使用本命令可继续 rebase 操作, 不需要 `git commit`
    - `git rebase --abort`: 产生冲突时, 放弃本次 rebase, 恢复到 rebase 之前的状态
    - `git rebase origin/main`: 变基对象为 origin 远程分支

    > git rebase 的作用是变基, 在合并时可以先切换到 branch1, 然后对 master 进行 rebase, 没有冲突的话直接完成操作, 有冲突的话先解决冲突,
    > 然后 `git add`, 然后 ` git rebase --continue `, 这样 branch1 的 commit 就完全挪到了 master 之上, 这时再切换到 master 分支上,
    > 使用 `git rebase branch1` (或 `git merge branch1`), 可以达到 `fast-forword` 的效果. 最后可以 push 到远程仓库, 这样自己的新的 commit 就在 master
    > 上整齐地排列着了.

- `git rerere`: 自动解决冲突, 需要提前设置 `git config --global rerere.enabled true`
- `git log`: 显示 `commit` 的提交记录 (并不会显示 `add` 操作)
    - `--patch`: 是 `git log -p` 的全写, 可以查看每个 `commit` 的细节
    - `--stat`: 查看每次文件提交更改的统计信息 (修改了多少处)
    - `--oneline`: 以一行的格式查看本 `branch` 的 `commit` 记录 (仅 sha2, branch, commit title 以及顺序信息)
    - `--merges`: 只显示合并的 `commit`
    - `--no-merges`: 不显示合并的 `commit`
    - `--graph`: 图表形式 (竖线, 斜线) 显示 commit 顺序及关系
    - `--decorate`: 装饰作用, 显示当前 head, tag, branch 的效果
    - `--all`: 显示所有 `commit` 信息, 否则可能会只显示本 `branch` 的 `commit`, 省略其他分支的 `commit`
    - `-S Swift`: 显示关键字中有 `Swift` 的 commit
    - `-[number]`: 显示最近多少次的 `commit` 记录
    - `--pretty=format:"[option]"`: 以固定格式输出 `commit` 信息
        - `%H`: 提交的完整哈希值
        - `%h`: 提交的简写哈希值
        - `%T`: 树的完整哈希值
        - `%t`: 树的简写哈希值
        - `%P`: 父提交的完整哈希值
        - `%p`: 父提交的简写哈希值
        - `%an`: 作者名字
        - `%ae`: 作者的电子邮件地址
        - `%ad`: 作者修订日期 (可以用 --date= 选项 来定制格式)
        - `%ar`: 作者修订日期, 按多久以前的方式显示
        - `%cn`: 提交者的名字
        - `%ce`: 提交者的电子邮件地址
        - `%cd`: 提交日期
        - `%cr`: 提交日期 (距今多长时间)
        - `%s`: 提交说明
        - `$d`: decorate 效果 (显示当前 head, tag, branch)
        - `%C(<color>)`: 为跟在后面一个参数设置颜色或字体, e.g. `git log --pretty=format:"%C(bold red)%h%Creset -%C(bold green)%d %C(bold yellow)%s %Creset- %C(red)%cd %Creset- %C(dim green)%an" --date=format:'%Y-%m-%d %H:%M:%S' --graph`
            - 一个颜色＋一个内容
            - 颜色以％C 开头, 后边接几种颜色, 还可以设置字体, 如果要设置字体的话, 要一块加个括号
            - 能设置的颜色值包括: reset(默认的灰色), normal, black, red, green, yellow, blue, magenta, cyan, white.
            - 字体属性则有 bold, dim, ul, blink, reverse.
            - 内容可以是占位元字符, 也可以是直接显示的普通字符
    - `--date=<option>`: 通过预置的选项设置 log 中 commits 的日期格式
        - `relative`: 显示距当前时间多少, e.g. "2 hours ago"
        - `local`: 显示本地时间, e.g "Wed Feb 26 18: 03: 14 2020"
        - `default`: 显示当前时区及时间, e.g. "Wed Feb 26 18: 03: 14 2020 +0800"
        - `iso`: 以 ISO 8601 格式显示时间
        - `rfc`: 以 RFC 2822 格式显示时间
        - `short`: 只显示日期, e.g. "2020-02-26"
        - `raw`: 显示 git 的原始格式, e.g. "1582711394 +0800"
    - `--date=format:'<option>'`: 通过占位符设置 log 中 commits 的日期格式 e.g. `--date=format:'%Y-%m-%d %H:%M:%S'`
        - `%a`: Abbreviated weekday name
        - `%A`: Full weekday name
        - `%b`: Abbreviated month name
        - `%B`: Full month name
        - `%c`: Date and time representation appropriate for locale
        - `%d`: Day of month as decimal number (01 – 31)
        - `%H`: Hour in 24-hour format (00 – 23)
        - `%I`: Hour in 12-hour format (01 – 12)
        - `%j`: Day of year as decimal number (001 – 366)
        - `%m`: Month as decimal number (01 – 12)
        - `%M`: Minute as decimal number (00 – 59)
        - `%p`: Current locale's A.M./P.M. indicator for 12-hour clock
        - `%S`: Second as decimal number (00 – 59)
        - `%U`: Week of year as decimal number, with Sunday as first day of week (00 – 53)
        - `%w`: Weekday as decimal number (0 – 6; Sunday is 0)
        - `%W`: Week of year as decimal number, with Monday as first day of week (00 – 53)
        - `%x`: Date representation for current locale
        - `%X`: Time representation for current locale
        - `%y`: Year without century, as decimal number (00 – 99)
        - `%Y`: Year with century, as decimal number
        - `%z, %Z`: Either the time-zone name or time zone abbreviation, depending on registry settings; no characters if time zone is unknown
        - `%%`: Percent sign

    配置完自己喜爱的配色后, 使用可以为 git 命令定义别名方便下次使用, e.g. `git config --global alias.lg "log --pretty=format:'%C(bold red)%h%Creset -%C(bold green)%d %C(bold yellow)%s %Creset- %C(red)%cd %Creset- %C(dim green)%an' --date=format:'%Y-%m-%d %H:%M:%S' --abbrev-commit --graph"`

    - `git log --oneline --graph --all`: 以图表, 简洁形式显示 commit 信息
    - `git shortlog -sn`: 列出提交者贡献数量, 只会打印作者和贡献数量
    - `git shortlog -n`: 以提交贡献数量排序并打印出 message
    - `git shortlog -e`: 采用邮箱格式化的方式进行查看贡献度

- `git bisect`: 黑魔法, 使用二分法查看哪一个 commit 产生的 bug
    - `git bisect start [end] [start]`: 启动查错, `end` 是最近的提交, `start` 是更久以前的提交. 启动之后会定位到 `end` & `start` 的中点
    - `git bisect good`: 标记此 commit 为正确的, 意味着问题是在后半段产生的
    - `git bisect bad`: 标记此 commit 为错误的, 意味着问题是在前半段产生的
    - `git bisect reset`: 完成二分查找, 回到最近一次代码提交
- `git update-ref -d refs/remotes/origin/HEAD`: remove `origin/HEAD`
- `git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/master`: create `origin/HEAD`
- `git symbolic-ref refs/remotes/origin/HEAD`: 获得远程默认分支, master 或 main
- `git symbolic-ref --short -q HEAD`: 获得本地当前分支
- `git archive [option] [branch/commit] [from path]`: 导出代码 (可支持下载远程仓库指定文件夹, 不支持 GitHub)
    - `--format tar.gz`: 导出的格式, 使用 `git archive --list` 可以查看当前 git 所支持的所有格式; 如不指明, 则使用 --output 的文件名推断文件格式
    - `--output "./output.tar.gz"`: 将存档写入 `<file>` 而不是 stdout.
    - `--remote git@192.168.1.203:iOS/ZRCombineViewer.git`: 指定远程仓库位置, 如不指定则导出当前目录下仓库的代码
    - `--exec=<git-upload-archive>`: 与 --remote 一起用于指定 git-upload-archive 远程端的路径.
    - `--verbose`: 实时显示最新进展
    - `--prefix=<prefix>/`: 在所有文件命前加入前缀

    ```bash
    // 写入压缩文件
    git archive --remote git@192.168.1.203:iOS/ZRCombineViewer.git -o test.zip master fastlane/actions fastlane
    // 下载后解压到指定文件夹
    git archive --remote git@gitlab.com:HanleyLee/helloworld.git --format=tar --prefix=junk/ master | (mkdir ~/Desktop/t1 && cd ~/Desktop/t1/ && tar xf -)
    ```

- `git --git-dir=$HOME/projects/foo/.git --work-tree=$HOME/projects/foo status`: 查看某个文件夹的 git 状态
- `git remote set-head origin master`: 如果使用 `git branch -a` 时发现没有 `origin HEAD`, 那么可以使用本命令手动添加 HEAD
- `git remote set-head origin -d`: 与上面相反, 此命令可以删除 `origin HEAD`

## `committer` 和 `author` 的区别

`author` 是做出修改的人, `committer` 是最后提交到 `git` 中央仓库的人

## `.gitignore` 文件

git 是根据 `.gitignore` 文件来判断是否监视一个文件 (夹) 的, 如果文件在 `.gitignore` 中被列出, 那么即使该文件被添加, git 也不会提示对其进行跟踪, 如果一个文件夹下被加入到 `.gitignore` 文件, 那么其自身及其内文件 (夹) 都不会被跟踪.

如果在添加 `.gitignore` 文件之前已经不想同步的内容已经被 git 跟踪了, 那么需要将其移除出跟踪区, 使用 `git rm --cached <filename>`.

使用 `git clean -fX` 可以将被忽略的文件全部删除 (一般不用)

### 不同步指定文件

`.gitignore` 文件可以让 `git` 忽略某些文件, 或者在忽略全部文件的情况下不忽略某些文件

> 在没有 `.gitignore` 的情况下创建一个新文件 `touch.gitignore`

```bash
# 忽略根目录及子目录下名为 `secret.md` 的文件
secret.md

## 忽略根目录及子目录下 `config` 文件夹下的 `secret.md` 文件
config/secret.md

# 忽略根目录及子目录下 config 下的 Markdown 文件
config/*.md

# 忽略根目录及子目录下的 build 文件夹
build/
# 忽略根目录及子目录下的 build 文件及文件夹
build
# 忽略当前目录的 build 文件
/build
```

### 只同步指定文件

```bash
touch.gitignore
# 忽略根目录下的所有文件及文件夹
/*

# 同步名为 normal.md 的文件, 但是如果文件夹未被同步, 那么文件夹内的此文件不会被 git 跟踪到, 也自然不会被同步
!normal.md

# 同步根目录下的 `config` 文件夹及其内文件 (夹)
!/config
```

如果需要只同步子文件夹下的某个文件, 有两种方法

1. 先设置同步子目录
2. 然后设置不同步子目录所有内容
3. 再设置同步子目录指定文件

```bash
/*
!/config
/config/*
!/config/normal.md
```

### 全局忽略文件

1. `git config --global core.excludesfile.gitignore_global`

2. 在本地用户根目录下创建 `.gitignore_global` 文件, 在其中设置需要全局忽略的文件类型 (下面的忽略按需使用)

```gitignore
# "#"是.gitignore_global 中的注释行
# Compiled source
*.pyc
*.com
*.class
*.dll
*.exe
*.o
*.so

# Packages
# it's better to unpack these files and commit the raw source
# git has its own built in compression methods
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Logs and databases
*.log
*.sql
*.sqlite

# OS generated files
.DS_Store*
ehthumbs.db
Icon?
Thumbs.db
```

## git diff 信息理解

![himg](https://a.hanleylee.com/HKMS/2019-12-27-144702.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2019-12-27-144706.jpg?x-oss-process=style/WaMa)

- 被比较的文件: `diff` 命令会对两个文件进行比较, 一个文件被设定为 `a`, 另一个被设定为 `b`
- 元数据: 刚开始的 `2a3483c` 与 `53ed7d1` 代表两个文件的 `hashes`. 后面的 `100644` 代表这是一个普通文件, 如果是 `10755` 则代表是一个可执行文件, `120000` 代表是符号链接.
- a/b 文件标识: 使用 `-` 作为 `a` 的标志, 使用 `+` 代表 `b` 的标志
- 区块头: `-` 代表来自文件 `a/Test/stash.txt`, `1` 代表从第一行开始, `2` 代表从第一行开始的 `2` 行代码. 因此整句连起来: `a` 文件 (旧文件) 从第一行开始的 `2` 行内有数据被改动, `b` 文件 (新文件) 从第一行开始的 `3` 行内有数据改动
- 改动: `+` 代表是新文件的改动. 如果是 `-` 则是旧文件的改动, 而旧文件的改动就是删除内容, 新文件的改动就是增加内容

## rebase 使用

### 使用交互式 rebase 修改 / 删除之前某次提交的 commit

1. `git rebase -i 目标 commit`

    ```bash
    git rebase -i HEAD^^
    // 在 git 中有两个偏移符号 ^ 与 ~, ^ 表示根据 head, ~表示根据 branch 向左偏移. 这个命令表示将当前 commit rebase 到 HEAD 之前 2 个的 commit 上.
    ```

2. 在编辑界面中指定需要操作的  `commits`

    将 `pick` 修改为 `edit` (含义是使用这个 `commit`, 但是停下来等待修正) 『使用 `pick` 代表选取, 如果直接删除这一行就代表跳过这个 `commit`,
    那就是把这个 `commit` 删除了』

    ![img](https://a.hanleylee.com/HKMS/2019-12-31-095212.jpg?x-oss-process=style/WaMa)

3. 退出编辑界面

    ![img](https://a.hanleylee.com/HKMS/2019-12-31-095226.jpg?x-oss-process=style/WaMa)

4. 根据提示修改最后使用 `amend` 进行修正提交
5. 操作完成之后用  `git rebase --continue`  来继续  `rebase`  过程各个 `commit` 回复到原位

### git rebase --onto 撤销历史 commit

![img](https://a.hanleylee.com/HKMS/2019-12-31-095300.jpg?x-oss-process=style/WaMa)

如上图所示, `git rebase commit3` 会将 `4` 与 `5` 自动链接到目标 `commit 3` 之后, 因为 `rebase` 的起点是 `Git` 自动指定的, 起点判定为当前 `branch` 与要 `rebase` 到的 `branch` 的交点, 在此例中就是 `2`. 因此 `2` 之后的 `commit` 都会被 `rebase` 到 3 之后.

<span id="jump">
如果想指定 `rebase` 的起点, 那么就需要用 `rebase --onto`, 其语法如下
</span>

```bash
git rebase --onto commit3 commit4 branch1
// 此命令有三个参数, 依次为目标 commit, 起点 commit, 操作 branch
// 在上图中, 就是将起点 commit 之后的 5 放入目标 commit 3 之后.
```

通过这一特性可以选择性地删除 `commit`

![himg](https://a.hanleylee.com/HKMS/2020-01-03-15fe243fce5804fd.gif)

```bash
git rebase --onto HEAD^^ HEAD^ branch1
// 以当前 head 指向 commit 的前一个 commit 为起点, 将起点之后的 commit 3 提交到当前 head 指向 commit 的前 2 个 commit 上. 这样就达到了剔除 commit 2 的目的
```

### 合并同一 branch 多个 commit

目标: 将 `123` 与 `2` 合并

1. 使用 `git log --oneline` 查看当前 `branch` 的 `commit` 记录

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-144704.jpg?x-oss-process=style/WaMa)

2. 使用交互式变基, `git rebase -i dc8d`, 修改 `2` 与 `123` 的 `pick` 为 `squash` (也可以用 `fixup`, 代表丢弃子 `commit` 名称)

    ![himg](https://a.hanleylee.com/HKMS/2019-12-27-144705.jpg?x-oss-process=style/WaMa)

3. 保存退出并并根据提示为新 `commit` 赋予名称

### 使用 `--depth` 保证本地只有最新的 commit

我们有时可能只需要最新的一次 `commit` (比如出于硬盘空间考虑), 这个时候有以下两种办法:

- 在 `clone` 时使用 `git clone --depth 1 url`
- 如果已经 `clone` 了, 那么需要多步 (参考自 [stackoverflow](https://stackoverflow.com/questions/38171899/how-to-reduce-the-depth-of-an-existing-git-clone/46004595#46004595))
    1. `git pull --depth 1`
    2. `git reflog expire --expire=all --all`
    3. `git tag -l | xargs git tag -d`
    4. `git stash drop`
    5. `git gc --prune=all`

## git 辅助工具

### [gitup](https://github.com/earwig/git-repo-updater)

git 仓库批量拉取更新

#### 安装

```bash
brew install gitup
```

#### 常用命令

- `gitup --help`: 查看 gitup 帮助信息
- `gitup`: 拉取更新所有被 `add` 到书签的仓库
- `gitup.`: 更新当前路径下的所有仓库
    - `--depth <num>`: 指定递归深度, 默认为 3
- `gitup ~/repos/foo ~/repos/bar ~/repos/baz`: 指定多个路径进行批量拉取更新 (默认对每个路径递归 3 层查找所有存在的 repo)
- `gitup -a ~/repos/foo ~/repos/bar ~/repos/baz`: `--add`, 将多个仓库添加到 gitup 的书签中, 便于使用 `gitup` 命令直接一键更新
- `gitup -l`: `--list`, 列出 `gitup` 目前所有 `add` 的仓库
- `gitup -b ~/.config/gitup/bookmarks`: `--bookmark-file`, 自定义指定书签文件
- `gitup -d ~/repo`: `--delete`, 删除已经 `add` 的仓库
- `gitup -n`: `--clean`, `--cleanup`, 删除路径已经变更的仓库的书签
- `gitup -c`: `gitup --current-only`, 默认情况下 gitup 将会拉取远端所有分支, 使用此命令可以只更新当前分支
- `gitup -f`: `gitup --fetch-only`, 默认情况下会 `pull`, 此命令会只 `fetch`
- `gitup -p`: `gitup --prune`: 默认情况下会在本地保留远端已经删除的 `branch`, 此命令会保持远端与本地端 `branch` 完全一致
- `gitup -e 'echo 123'`: 对所有的 repo 执行 `echo 123` 这个命令
- `gitup -e 'bash -c "echo 123 && echo 456"'.`: 使用 `bash -c` 的目的是可以使用 `&&` 语法

### [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)

git diff 高亮优化显示

#### 安装

```bash
brew install diff-so-fancy
```

#### 配置

```bash
// Configure git to use d-s-f for *all* diff operations
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

git config --global color.ui true

git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global color.diff.meta       "11"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"
```

### icdiff

![himg](https://a.hanleylee.com/HKMS/2021-02-17215438.jpg?x-oss-process=style/WaMa)

#### 安装

```bash
brew install icdiff
```

#### 使用

```bash
function gdf() {
    params="$@"
    if brew ls --versions scmpuff > /dev/null; then
        params= `scmpuff expand "$@" 2>/dev/null`
    fi

    if [$# -eq 0]; then
        git difftool --no-prompt --extcmd "icdiff --line-numbers --no-bold" | less
    elif [${#params} -eq 0]; then
        git difftool --no-prompt --extcmd "icdiff --line-numbers --no-bold" "$@" | less
    else
        git difftool --no-prompt --extcmd "icdiff --line-numbers --no-bold" "$params" | less
    fi
}
```

### scmpuff

![himg](https://a.hanleylee.com/HKMS/2021-02-17215626.jpg?x-oss-process=style/WaMa)

#### 安装

```bash
brew install scmpuff
echo "eval "$(scmpuff init -s)"" >> ~/.zshrc
```

#### 使用

- `gs`: 显示当前所有文件状态, 类似于 `git status`
- `git add 2 3 5-7`: 按照 `gs` 的序号结果进行 `add`

## GitHub

### GitHub(或其他 git 管理平台) 使用流程

1. 在 `GitHub` 或者其他仓库管理平台创建一个仓库. 并复制仓库地址
2. 在终端中使用 `git clone` 将远程仓库下载到本地
3. 在开发时将自己仓库创建出一个分支用于自己开发新功能.
4. 新功能开发完毕后将 branch 上传到中央仓库让同事进行检查, 如果有问题的话继续修改直至没有问题. 如果没有问题的话就
    1. `checkout` 到本地仓库的 `master`
    2. `pull` 以使本地 `master` 与远端 `master` 保持同步
    3. `merge` 自己的 `branch` 到本地 `master`, `push master` 到远端
5. 实际上为了保证项目的安全, 中大型项目的远端仓库 `master` 都是被禁止直接 `push` 的, 因此步骤 4 的流程就会变成:
    1. 让同事检查是否有问题, 没有问题就提交通过远端的 `branch` 提交 `pull request` (`pull request` 是对于 `master` 分支来说的, 希望 `master` 能够
`pull` 本 `branch`)
    2. 成功 `pull request` 后删除本 `branch`

### 连接方式

目前 `GitHub` 有两种连接方式, `HTTPS` 连接与 `ssh` 连接, 在 `clone` 时要选择对应的链接.

#### 特点

- 本账户向本账户下仓库提交代码可以直接使用 `https` 或者将自己电脑生成的 `ssh key` 加入到 `GitHub` 账户.
- 本账户使用 `HTTPS` 方式向另一账户下的仓库提交代码需成为对方账户的 `collaborator`.
- 本账户使用 `ssh` 方式向另一账户的仓库提交代码需要将本账户所在电脑生成的 `ssh key` 加入到对方账户.
- `ssh` 方式连接在每次 `push` 时无需再每次访问时输入密码
- 如果 `GitHub` 账户使用了二重验证还希望使用 `HTTPs` 那么必须使用 `access token` 作为密码进行登录.

#### SSH 连接方式

1. 在终端使用 `ssh-keygen` 方式生成 ssh key
2. 将 `pub` 公钥加入到 GitHub 账户中
3. 在仓库页面选择 `ssh` 链接进行复制
4. 在本地文件夹进行 `clone`

#### 查看 / 更改连接方式

- 通过 `git remote -v` 查看当前与远程的连接方式
- 修改为 `HTTPs`: `git remote set-url origin https://github.com/HanleyLee/Lang.git`
- 修改为 `ssh`: `git remote set-url origin git@github.com:HanleyLee/Lang.git`

### 快捷功能

- 快捷键查看所有快捷键: 使用 `shift + ?` 在所有 GitHub 页面上都可以查看快捷键
- 在评论中应用表情: 在评论中使用 `:` 便会启动表情自动补全功能

### 提交信息操作 issue

我们可以在 commit 信息中添加以下格式的文本, 然后相对应的 issue 便会有相对应的操作

- 仅指向 issue
    - `#24`
- 删除对应 issue
    - `fix #24`
    - `fixes #24`
    - `fixed #24`
    - `close #24`
    - `closes #24`
    - `closed #24`
    - `resolve #24`
    - `resolves #24`
    - `resolved #24`

## 参考

- [Manage Dotfiles With a Bare Git Repository](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)
- [详解 Git 大文件存储 (Git LFS)](https://zhuanlan.zhihu.com/p/146683392)
- [Git LFS 的使用](https://www.jianshu.com/p/493b81544f80)
- [解决 GitHub 资源无法下载的问题](https://jdhao.github.io/2021/01/08/github_access_issue_in_china/)
- [我用四个命令概括了 Git 的所有套路](https://labuladong.gitbook.io/algo/mu-lu-ye-5/git-chang-yong-ming-ling)
