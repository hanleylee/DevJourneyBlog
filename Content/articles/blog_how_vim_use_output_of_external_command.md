---
title: 如何在 Vim 中使用外部命令的输出
date: 2021-11-30
comments: true
path: how-vim-use-output-of-external-command
categories: vim
tags: ⦿vim, ⦿tool, ⦿tool
updated:
---

在 vim 中我们可以用添加前缀 `!` 的方式执行外部命令, 例如 `!ls`, 其结果将被在底部输出

![himg](https://a.hanleylee.com/HKMS/2021-11-30211000.png?x-oss-process=style/WaMa)

那么我们如果想使用外部命令的结果, 该怎么做呢?

<!-- more -->

## 使用 `:read`

`:read` 可以读取命令执行结果到当前 buffer 中, 如果我们想插入外部命令的结果, 那么使用 `:read !ls` 即可

![himg](https://a.hanleylee.com/HKMS/2021-11-30220358.png?x-oss-process=style/WaMa)

## 使用 `system()`

如果我们不想将一个命令的执行结果插入当前 buffer 中, 有没有办法可以保存在变量中呢? 也是有的, vim 提供了函数 `system()` 用来获得输出外部命令的结果, 如果你使用过 shell 的话就会知道, 这种使用方式就像使用 `$(command)` 或 `` `command` `` 一样. 在脚本中我们使用 `let var = system("command")` 的形式了获得输出结果

在终端中我们可以通过 `$?` 来得到上一个命令的执行结果, 根据此结果来判断是否继续执行还是终止程序. 在 vim 中我们也可以按照相同的思路去思考, 使用预设变量 `v:shell_error` 可以获得最近一个外部命令的执行结果

如下是一个综合使用 `system()` 与 `v:shell_error` 的例子

```vim
" Swap between target path and source path
function! hl#chezmoi#swap_between_target_and_source()
    let current_path = expand('%:p')
    if current_path =~# '.local/share/chezmoi/' " current path is located in ~/.local/share/chezmoi/, now we are inside the source path
        let target_path = s:get_target_file(current_path)
        exec 'edit ' . target_path
    else " now we are in the target path, so we should check this file have corresponding source file or not
        let target_path = system('chezmoi source-path ' . current_path)
        if v:shell_error != 0
            echom 'Current file is not managed by chezmoi!!!'
        else
            exec 'edit ' . target_path
        endif
    endif
endfunction
```

## 实际案例

### Redir

我们可以定义一个方法用来捕获 vim 内部命令或外部命令的输出, 将捕获的结果输出到一个新窗口中

```vim
"`:Redir` followed by either shell or vim command
command! -nargs=+ -complete=command Redir silent call Redir(<q-args>)

" Redirect output to a single window
function! Redir(cmd)
    for win in range(1, winnr('$'))
        if getwinvar(win, 'scratch')
            execute win . 'windo close'
        endif
    endfor
    if a:cmd =~ '^!'
        let output = system(matchstr(a:cmd, '^!\zs.*'))
    else
        redir => output
        execute a:cmd
        redir END
    endif
    botright vnew
    let w:scratch = 1
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    call setline(1, split(output, "\n"))
endfunction
```

## GetOutput

同样, 我们可以仅仅将结果返回, 这在脚本中对变量赋值非常有用, 更加灵活, 使用方法为 `let var1 = GetOutput("!python --version")`

```vim
" Get output of a command
function! GetOutput(cmd)
    if a:cmd =~ '^!'
        let output = system(matchstr(a:cmd, '^!\zs.*'))
    else
        redir => output
        silent execute a:cmd
        redir END
    endif
    let output = substitute(output, '[\x0]', '', 'g')
    return output
endfunction
```

## Reference

- [Append output of an external command](https://vim.fandom.com/wiki/Append_output_of_an_external_command)
- [get exit status from system() call](https://vi.stackexchange.com/questions/19773/get-exit-status-from-system-call)
