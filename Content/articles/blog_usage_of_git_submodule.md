---
title: Git Submodule 使用
date: 2021-05-18
comments: true
path: usage-of-git-submodule
categories: Terminal
tags: ⦿git, ⦿submodule
updated:
---

![himg](https://a.hanleylee.com/HKMS/2021-05-18-09-26-54.jpg?x-oss-process=style/WaMa)

git 的 `submodule` 作为一个独立的 `repo`, 其拥有普通 `repo` 全部的功能, 我们可以完全按照普通的 `repo` 管理命令来进入 `submodule` 中进行手动管理.  不过如果存在多个 `submodule` 位于同一 `superproject` 下时, 掌握一些 `git submodule ...` 命令就变得尤为重要了.

本文列出了常用的一些 `git submodule` 管理命令, 并举出实际应用中遇到的问题及解决方案.

<!-- more -->

## submodule 介绍

在 git 仓库 `superproject` 的目录中使用 `git submodule add https://github/HanleyLee/C` 即可将 <https://github/HanleyLee/C> 作为一个 `submodule` 被
`superproject` 依赖与管理.

当 `submodule` 被修改时我们可以在 `superproject` 中得到通知:

- 在 `submodule` 中添加了新文件:

    ![himg](https://a.hanleylee.com/HKMS/2021-05-07211554.png?x-oss-process=style/WaMa)

- 修改了 `submodule` 中的内容 (没有 `new commit`):

    ![himg](https://a.hanleylee.com/HKMS/2021-05-07211409.png?x-oss-process=style/WaMa)

- 在 `submodule` 中产生了 `new commit`:

    ![himg](https://a.hanleylee.com/HKMS/2021-05-07211734.png?x-oss-process=style/WaMa)

## submodule 特点

在 `repo Test` 作为 `submodule` 被 `superproject` 管理后:

- 我们仍然可以进入 `repo Test` 的目录中对相关内容进行修改, 然后通过常用的 git 命令进行操作.
- 在 `superproject` 下可以通过 `git submodule ***` 命令来管理其下的所有子仓库, 使其与远程库保持同步或推送到远程库.

## submodule 的版本如何被管理的 (大致思路)

添加 `git submodule` 的方法很简单, 使用 `git submodule add <repo url>` 即可. 添加完之后, 在 `superproject` 的目录下会产生一个 `.gitmodule` 文件,
文件的结构如下:

```gitconfig
[submodule "C"]
    path = C
    url = git@github.com:HanleyLee/C.git
[submodule "Cpp"]
    path = Cpp
    url = git@github.com:HanleyLee/Cpp.git
```

可以看到, `.gitmodule` 文件中标记了每一个 `submodule` 的 `path` 与 `url`.

然后我们进入 `./C`:

```bash
$ cd ./C
$ ls -l
$ ls -lhia

    35107110 drwxr-xr-x   9 hanley  staff   288B May  7 21:15 .
    35107043 drwxr-xr-x  14 hanley  staff   448B May  7 20:45 ..
    35107127 -rw-r--r--   1 hanley  staff    26B May  7 19:59 .git

$ cat .git

    gitdir: ../.git/modules/C
```

我们发现 `./C/.git` 竟然是一个文件 (常规 git 目录中的 .git 是文件夹), 然后其内容指向了另一个文件夹 (类似于指针), 我们再去到那个文件夹:

```bash
$ cd ../git/modules/C
$ ls -lhia

    35107128 drwxr-xr-x  16 hanley  staff   512B May  7 21:17 .
    35107126 drwxr-xr-x   9 hanley  staff   288B May  7 19:59 ..
    35112722 -rw-r--r--   1 hanley  staff    17B May  7 21:17 COMMIT_EDITMSG
    35109064 -rw-r--r--   1 hanley  staff     0B May  7 21:44 FETCH_HEAD
    35109063 -rw-r--r--   1 hanley  staff    16B May  7 21:44 FETCH_LOG
    35112529 -rw-r--r--   1 hanley  staff    21B May  7 20:25 HEAD
    35116056 -rw-r--r--   1 hanley  staff    41B May  7 21:15 ORIG_HEAD
    35114647 -rw-r--r--   1 hanley  staff   319B May  7 20:47 config
    35107131 -rw-r--r--   1 hanley  staff    73B May  7 19:59 description
    35107132 drwxr-xr-x  15 hanley  staff   480B May  7 19:59 hooks
    35116224 -rw-r--r--   1 hanley  staff   1.7K May  7 21:17 index
    35107129 drwxr-xr-x   3 hanley  staff    96B May  7 19:59 info
    35107178 drwxr-xr-x   4 hanley  staff   128B May  7 19:59 logs
    35107159 drwxr-xr-x   9 hanley  staff   288B May  7 21:40 objects
    35107174 -rw-r--r--   1 hanley  staff   112B May  7 19:59 packed-refs
    35107146 drwxr-xr-x   5 hanley  staff   160B May  7 19:59 refs
```

我们发现这个文件夹才是 `submodule` 的真实 `.git` 文件夹, 我们对于 `submodule` 的所做的 commit 信息也都保存在这里.

## submodule 常用命令

- `git submodule`: 显示所有 `submodule`, 等同于`git submodule status`
- 添加 submodule 到现有项目
    1. Run `git submodule add -b <branch> --name <name> <repo-url> <local dir>`
    2. Commit both files on the superproject
- 从当前项目移除 submodule
    1. `git submodule deinit -f <submodule_path>`
    2. `rm -rf .git/modules/<submodule_path>`
    3. `git rm -f <submodule_path>`
- 复制含 submodule 项目到本地
    1. Clone the superproject as usual
    2. Run `git submodule init` to init the submodules
    3. Run `git submodule update` to have the submodules on a detached HEAD

    或者直接执行 `git clone --recurse-submodules <repo-url>`

- `git submodule init`: 将本项目所依赖的 `submodule` 进行初始化
- `git submodule update`: 更新 submodule 为 `superproject` 本次 commit 所记录的版本 (本地版本为旧版本的话那么就与旧版本保持同步!)
- `git submodule update --init`: 前面两个命令的合并
- `git submodule update --init --recursive`: 前面三个命令的合集, `--recursive` 是为了保证即使 `submodule` 又嵌套了 `sub-submodule`, 也可以被执行到.  这个命令比较全面, 会经常使用
- `git submodule update --remote`: 更新 submodule 为远程项目的最新版本 (更为常用!)
- `git submodule update --remote <submodule-name>`: 更新指定的 submodule 为远程的最新版本
- `git push --recurse-submodules=`
    - `check`: 检查 `submodule` 是否有提交未推送, 如果有, 则使本次提交失败
    - `on-demand`: 先推送 submodule 的更新, 然后推送主项目的更新 (如果 submodule 推送失败, 那么推送任务直接终止)
    - `while`: 所有的 `submodule` 会被依次推送到远端, 但是 `superproject` 将不会被推送
    - `no`: 与 `while` 相反, 只推送 `superproject`, 不推送其他 `submodule`
- `git pull --recurse-submodules`: 拉取所有子仓库 (fetch) 并 merge 到所跟踪的分支上
- `git diff --submodule`: 查看 submodule 所有改变
- `git submodule foreach '<arbitrary-command-to-run>'`: 对所有 submodule 执行命令, 非常有用, 如 `git submodule foreach 'git checkout main'`

## 为什么 `superproject` 在 `git pull` 之后 `submodule` 没有切到最新节点?

默认情况下, git pull 命令会递归地抓取子模块的更改 (fetch), 然而, 它不会将 submodule merge 到所跟踪的分支上. 因此我们还需要执行 `git submodule update`.

如果我们想一句话解决, 那么可以使用 `git pull --recurse-submodule`, 这个可以在拉取完 submodule 后再将其 merge 到所跟踪的分支上.

如果我们想让 Git 总是以 `--recurse-submodules` 拉取, 可以将配置选项 `submodule.recurse` 设置为 `true`. 具体命令为 `git config --global submodule.recurse true`. 此选项会让 Git 为所有支持 `--recurse-submodules` 的命令使用该选项 (除 clone 以外).

> `git pull --recurse-submodule` 会让我们的 pull 命令递归地用于所有 `submodule`, 如果你的 `submodule` 数量过多的话可能会等较长时间. 这时可以使用 `git pull && git submodule update --init --recursive` 一句话命令来只拉取更新了的 `submodule` 并更新到最新 `commit`, 使用 `git config --global alias.sdiff '!'"git diff && git submodule foreach 'git diff'"` 为此命令设置 `alias`

## 在 `submodule` 没有提交`commit`的情况下推送 `superproject` 的`commit`

如果我们在主项目中提交并推送但并不推送子模块上的改动, 其他尝试检出我们修改的人会遇到麻烦,  因为他们无法得到依赖的子模块改动.  那些改动只存在于我们本地的拷贝中.

为了确保这不会发生, 我们可以让 Git 在推送到主项目前检查所有 `submodule` 是否已推送. `git push` 命令接受可以设置为 `check` 或 `on-demand` 的 `--recurse-submodules` 参数.  如果任何提交的 `submodule` 改动没有推送那么 `check` 选项会直接使 push 操作失败.(此外还有 `demand`, `while`, `no` 选项, 参考前节命令列表进行理解)

为了以后方便, 我们可以设置默认检查 `git config --global push.recurseSubmodules check`

## 为什么每次 update 后 submodule 的 HEAD 状态变为了 detached?

很多人用了 git submodule 后, 都发现每次 update 之后, submodule 中的 `HEAD` 都是 `detached` 状态的, 即使本次 `git checkout master` 后, 下次更新仍然恢复原样, 难道就没有办法使其固定在某个 `branch` 上吗? 经过研究, 参考 [stackoverflow](https://stackoverflow.com/questions/18770545/why-is-my-git-submodule-head-detached-from-master) 的答案, 我发现是可以解决的.

问题的关键在于 `.gitmodule` 的配置:

```gitconfig
[submodule "C"]
    path = C
    url = git@github.com:HanleyLee/C.git
    update = rebase
[submodule "Cpp"]
    path = Cpp
    url = git@github.com:HanleyLee/Cpp.git
    update = rebase
```

我们需要添加 `update = rebase` 这行, 根据 [git official](https://git-scm.com/docs/git-submodule#Documentation/git-submodule.txt-update--init--remote-N--no-fetch--no-recommend-shallow-f--force--checkout--rebase--merge--referenceltrepositorygt--depthltdepthgt--recursive--jobsltngt--ltpathgt82308203) 的说明

```txt
checkout
    the commit recorded in the superproject will be checked out in the submodule on a detached HEAD.

    If --force is specified, the submodule will be checked out (using git checkout --force), even if the commit specified in the index of the
    containing repository already matches the commit checked out in the submodule.

rebase
    the current branch of the submodule will be rebased onto the commit recorded in the superproject.

merge
    the commit recorded in the superproject will be merged into the current branch in the submodule.
```

`submodule` 的 update 有多种选择, 默认情况下是 `checkout`, 其会根据 `superproject` 所记录的 `submodule` 的 `commit` 进行 checkout. 类似于 `git checkout 4eda5fgrd`, 这必然导致 `submodule` 的 `HEAD` 处于 `detached` 状态. 解决办法就是使用 `rebase`(`merge` 也可以), 这样当我们对 `submodule` 设置了一个初始的 `branch` 后, 其以后都只会在这个 branch 上对远程的最新 `commit` 进行 `rebase`, 不会导致 `detached` 状态的产生.

以 `submodule` 的目录为 `./C/` 为例. 具体的解决步骤如下:

```bash
$ cd C/
$ git checkout main
$ cd ..
$ git config -f .gitmodules submodule.C.update rebase
```

此时, 以后再使用 `git submodule update` 就不会有 `detached` 状态的产生了

> 另外, 在 `.gitmodule` 文件中也可以指定 branch, 这里指定的 branch 表示跟踪的远程仓库的分支, 如果不指定, 则默认为跟踪远程的 `HEAD` 所指向的 `branch`

## 如何删除 submodule

1. `git submodule deinit -f -- a/submodule`
2. `rm -rf .git/modules/a/submodule`
3. `git rm -f a/submodule`

## 常用 alias

在 `~/.gitconfig` 中添加如下 alias 可以增加工作效率 (斟酌添加)

```gitconfig
[alias]
    sdiff =!git diff && git submodule foreach 'git diff'
    supdate = submodule update --rebase --init --recursive
    spull =!git pull --rebase --recursive
```

## 参考

- [Git Tools - Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
