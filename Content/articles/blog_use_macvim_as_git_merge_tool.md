---
title: 使用 MacVim/GVim 作为 git 冲突解决工具 (mergetool)
date: 2022-12-24
comments: true
path: use-macvim_as_git_merge_tool
categories: Tools
tags: ⦿vim, ⦿git, ⦿merge-tool, ⦿tool
updated:
---

对于习惯了使用命令行操作 git 的人来说, 在分支合并时发生了代码冲突经常会有点束手束脚, 原因是在终端中没办法很直观地对比冲突代码并选择需要的部分. 虽然我们使用终端工具打开冲突文件一处处解决冲突, 但是当冲突涉及到的位置与文件数量都比较多时, 手动修改必然是一个痛苦的过程, 而且这样做效率是相当低下的.

![himg](https://a.hanleylee.com/HKMS/2022-12-24175719.jpg?x-oss-process=style/WaMa)

<!-- more -->

尽管有些不愿意承认, 但还是要说: 使用 GUI 工具解决代码冲突是更加清晰且高效的. 日常工作中我的所有 git 操作基本都在终端中完成, 唯有合并冲突时, 我必须要借助专门的 GUI 工具了(我用的是 Kaleidoscope). 为了解决代码冲突而专门引入一个工具, 并且此工具还收费不菲, 这让我一直如鲠在喉, 因此我一直在努力寻找一种更轻量的替代方式, 最近我终于找到了 -- **使用 MacVim/GVim 作为 git 的冲突解决工具**.

因为我一直是 vim 的拥趸, 因此使用 vim 来作为 git 的冲突解决工具对我来说没有任何额外的学习成本了, 唯一要考虑的是怎么将 vim 与 git mergetool 联动起来. 经过不断的尝试与查阅资料后, 终于将方案形成.

由于我一直使用 macos, 因此使用的 vim GUI 版是 MacVim(GVim 也是同样的配置原理)

## 配置 gitconfig

在 `$HOME/.gitconfig` 中, 我们添加如下配置:

```gitconfig
[merge]
    tool = mvimdiff
    conflictstyle = diff3
[mergetool]
    prompt = false
    keepBackup = false
[mergetool "vimdiff"]
    ; Be able to abort all diffs with `:cq` or `:cquit`
    trustExitCode = true
    ; layout = "(LOCAL,BASE,REMOTE)/MERGED"
    cmd = vimdiff -R -c '$wincmd w' -c 'wincmd J' -c 'setlocal noreadonly' -c 'cd "$GIT_PREFIX"' -f \"$LOCAL\" \"$BASE\" \"$REMOTE\" \"$MERGED\"
[mergetool "mvimdiff"]
    ; Be able to abort all diffs with `:cq` or `:cquit`
    trustExitCode = true
    ; layout = "(LOCAL,BASE,REMOTE)/MERGED"
    cmd = mvimdiff -R -c '$wincmd w' -c 'wincmd J' -c 'setlocal noreadonly' -c 'cd "$GIT_PREFIX"' -f \"$LOCAL\" \"$BASE\" \"$REMOTE\" \"$MERGED\"
[mergetool "gvimdiff"]
    ; Be able to abort all diffs with `:cq` or `:cquit`
    trustExitCode = true
    ; layout = "(LOCAL,BASE,REMOTE)/MERGED"
    cmd = gvimdiff -R -c '$wincmd w' -c 'wincmd J' -c 'setlocal noreadonly' -c 'cd "$GIT_PREFIX"' -f \"$LOCAL\" \"$BASE\" \"$REMOTE\" \"$MERGED\"
```

可以看到, 我们添加了三种 mergetool, 分别是 `vimdiff`, `mvimdiff`, `gvimdiff`. 默认使用的是 `mvimdiff`.

当我们在合并发生冲突时, 只需要使用 `git mergetool` 命令, 这时就会自动使用 `mvimdiff`, 然后其 cmd `mvimdiff -R -c '$wincmd w' -c 'wincmd J' -c 'setlocal noreadonly' -c 'cd "$GIT_PREFIX"' -f \"$LOCAL\" \"$BASE\" \"$REMOTE\" \"$MERGED\"` 被执行, 我们就能看到我们的 MacVim 被打开了一个新窗口用于合并冲突文件

![himg](https://a.hanleylee.com/HKMS/2022-12-24185752.png?x-oss-process=style/WaMa)

## vim 中用于解决冲突的相关命令

作为编辑器之神, vim 自然早早就考虑到了很多人会使用其进行冲突合并, 因此也内置了很多非常高效有用的操作命令, 我挑选了比较有用的列在下面:

- `:diffget LOCAL`: 选择 LCOAL 作为本行最终结果
- `:diffget REMOTE`: 选择 REMOTE 作为本行最终结果
- `:diffget BASE`: 选择 BASE 作为本行最终结果
- `:diffput [num]`: 放置结果到缓冲区上, `num` 为缓冲区编号
- `:diffg L`: 这里 vim 为我们做了简略命令, 同样可用于 `REMTOE` 与 `BASE` 上
- `:diffget //2`: `//2` 将被替换为左侧文件名
- `:diffget //3`: `//3` 将被替换为右侧文件名
- `:%diffget LO`: 将所有变更使用 local 的结果
- `:'<'>diffget LO`: 将当前选中范围的使用 local 的结果
- `dp/do`: 如果只有两个文件则可以使用 `dp/do` 来替代 `:diffput/:diffget`
- `:diffoff`: 关闭 diff mode
- `:diffthis`: 开启 diff mode
- `:ls!`: 显示当前所有缓冲区的号码
- `[c`: conflict, 移动到上一个冲突处
- `]c`: conflict, 移动到下一个冲突处
- `:diffsplit filename`: 已经在 vim 中时, 使用此命令与别的文件进行对比
- `:vert diffsplit filename`: 同上
- `vimidff file1 file2`: 对比 `file1` 与 `file2` 的差别
- `vim -d file1 file2`: 同上 🐷
- `:wqa`: 冲突修复完成保存退出, 如果仍然有文件冲突则进入下一个冲突
- `:cq`: 放弃修复, 终止流程(在 merge conflict 时很有用, 否则使用了 `qa` 的话想再次进入 mergetool 就必须使用 `git checkout --conflict=diff3 {file}` 了)

> 更多 vim 操作可参考 [神级编辑器 Vim 使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html) <!-- ./blog_usage_of_vim_operation.md -->

## 完成冲突合并

当我们使用 MacVim 完成了冲突文件的修复之后(或者因为其他原因不修复了), 那么以下命令你总会有用到的:

- `git merge --continue`: 冲突全部解决完后继续之前的 `merge` 操作
- `git merge --abort`: 放弃之前的 `merge` 操作
- `git checkout --conflict=diff3 test.txt`: 将文件重置回冲突状态, 适用于 merge 时发生冲突后没有完全解决时被一些其他工具将文件标记为了解决

## shell 为不同的 mergetool 定义不同的 alias

按照我们上面在 `.gitconfig` 的的配置, 因为我们配置了多个 mergetool, 那我们怎么使用其他的 mergetool 呢? 使用命令 `git mergetool --no-prompt --tool=xxx` 即可, 比如 `git mergetool --no-prompt --tool=gvimdiff`

每次输入这么长一串你肯定不喜欢, 那就在你的 `~/.zshrc` 中定义一些顺手的 alias 吧, 我定义的 alias 如下:

```zsh
alias gmt='git mergetool --no-prompt'
alias gmtv='git mergetool --no-prompt --tool=vimdiff'
alias gmtgv='git mergetool --no-prompt --tool=gvimdiff'
alias gmtmv='git mergetool --no-prompt --tool=mvimdiff'
alias gmtk='git mergetool -y --tool=Kaleidoscope'
```

## 总结

因为我的终端窗口一般较小, 而且常驻 MacVim 用于浏览各种文件, 因此对我来说更好的方式是使用 MacVim 作为 git 的 mergetool, 我想这应该也是大多数人的正确选择.

如果你坚持完全不离开终端来完成 git 的冲突合并, 那么使用 vimdiff 也是不错的选择, 因为其所有的功能都是完备的(小缺陷就是颜色和字体是跟随终端的, 且显示宽度也受终端窗口限制)

Enjoy!!! 😄
