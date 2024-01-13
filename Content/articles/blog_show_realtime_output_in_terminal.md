---
title: 如何在终端中显示程序的实时输出 -- stream buffering
date: 2024-01-13
comments: true
path: show-realtime-output-in-terminal
tags: ⦿buffer, ⦿stream, ⦿terminal
updated:
---

```swift
// main.swift
import Foundation

print(123)
sleep(1)
print(456)
sleep(1)
print(789)
```

上面是一段可以执行至少两秒钟的 Swift 代码, 我们可以在命令行中以 `nohup swift main.swift &>output.txt &` 命令执行, 然后在另一个命令行窗口中使用 `tail -f output.txt` 命令实时查看文件内容变化. 按照我们直觉, 程序会在执行的第 0 秒打印 `123`, 第 1 秒打印 `456`, 第 2 秒打印 `789`, 但是结果是直到第 2 秒一次性打印了所有内容, why?

![himg](https://a.hanleylee.com/HKMS/2024-01-13213558.png?x-oss-process=style/WaMa)

<!-- more -->

原因在于 **stream buffering**, 我们的输出内容首先被缓存了起来, 在缓存量达到阈值或者程序终止的时候再将缓存内容全部输出

## Stream Buffering

当我们在将内容写入到文件时, 底层系统会调用 [write(2)](https://man7.org/linux/man-pages/man2/write.2.html) 将数据写入文件描述符. 该方法获取一个文件描述符和一个字节缓冲区, 并将字节缓冲区中的数据写入文件描述符. 大多数语言都有非常快的用户空间函数调用, C 等编译语言中用户空间函数调用的开销仅为几个 CPU 周期. 然而系统调用的成本要高得多. Linux 上的系统调用需要接近一千个 CPU 周期, 并且隐含着 [上下文切换](https://en.wikipedia.org/wiki/Context_switch). 因此, 系统调用比常规用户空间函数调用要昂贵得多. 存在 Buffering 的主要原因是为了分摊这些系统调用的成本. 当程序执行大量此类写入调用时, 摊销尤其重要.

考虑一下当使用 grep 在输入文件 (或标准输入) 中搜索模式时会发生什么. 假设我们正在 grep nginx 日志中查找来自特定 IP 地址的行, 这些匹配行的长度可能是 100 个字符. 如果不使用缓冲, 对于 grep 需要打印的输入文件中的每个匹配行, 它将调用 `write(2)` 系统调用. 这种情况会一遍又一遍地发生, 每次平均缓冲区大小将为 100 字节. 相反, 如果使用 4096 字节缓冲区大小, 则在 4096 字节缓冲区填满之前不会刷新数据. 这意味着在此模式下 grep 命令将等到大约 40 行输入后字节缓冲区填满. 然后, 它将通过使用指向 4096 字节缓冲区的指针调用 `write(2)` 来刷新缓冲区. 这有效地将 40 个系统调用转换为 1 个, 系统调用开销因此减少了 40 倍.

## Stream Buffering Type

实际上 Stream Buffering 有多种类型:

- **fully-buffered**(**block-buffered**): `_IOFBF`, 完全缓存, 直至 buffer size 填满后对 stream 进行回写
- **line-buffered**: `_IOLBF`, 以行为单位进行缓存, 在遇到换行符时即对 stream 进行回写
- **unbuffered**: `_IONBF`, 不缓存, 将输入的内容立刻对 stream 进行回写

在 glibc 中, 对 `stdin`, `stdout`, `stderr` 的默认缓存类型规则是不同的:

| Stream            | Type   | Behavior       |
|-------------------|--------|----------------|
| stdin             | input  | line-buffered  |
| stdout(TTY)       | output | line-buffered  |
| stdout(not a TTY) | output | fully-buffered |
| stderr            | output | unbuffered     |

当然我们可以调用 `setvbuf` 对 `stdout` 的默认行为进行更改

```c
setvbuf(stdout, NULL, _IONBF, 0);
```

在写入文件时也可以通过 `setvbuf()` 函数设置 `buffer` 类型与大小

```c
char buffer[BUFSIZ];
FILE *fp = fopen("test.txt", "w+");
setvbuf(fp, buffer, _IOFBF, BUFSIZ)
```

## 如何让输出实时刷新

回到我们开头的问题, 为什么使用 `nohup swift main.swift &>output.txt &` 后不能实时看到 `output.txt` 内容的输出? 因为在这个命令里, 我们的 stdout 被重定向到了 `output.txt` 这个文件, 而不是 TTY, 因此根据上面的规则, `stdout(not a TTY)` 会使用 `fully-buffered` 的方式 (这里推测 Swift 与 C 语言有相同的处理逻辑)

分析出来原因后, 我们再想解决就简单了, 可以使用如下这些方式:

- 使用 `stderr`, 因为 `stderr` 默认是 `unbuffered`

    ```swift
    fputs("123\n", stderr)
    ```

- 使用 `stdout` + `fflush()`

    ```swift
    print("123")
    fflush(stdout)
    ```

- 禁用 stdout 的缓存能力

    ```c
    setvbuf(stdout, nil, _IONBF, 0)
    print("123")
    ```

- 在终端调用时使用 `stdbuf` 命令, `stdbuf` 是 GNU Coreutils 中的一个命令

    ```bash
    stdbuf -i0 -o0 -e0 nohup swift main.swift &>output.txt & # set unbuffered
    # stdbuf -iL -oL -eL command # set line-buffered
    ```

    > 不过这种方式我没有测试成功 😥

## python 输出的 buffer type

默认情况下, 当作为后台进程运行时, python 写入 stdout 的所有内容会使用 `fully-buffered` 的方式进行缓存, 直到程序退出或调用 `sys.stdout.flush()` 为止.

另外, python 支持环境变量 `PYTHONUNBUFFERED` 以禁用 stdout 缓冲. 所以, 如果你想在不调用 `flush()` 的情况下查看 python 的实时输出, 你可以在 `.zshrc` / `.bashrc` 中添加 `export PYTHONUNBUFFERED=1`

## Ref

- [Stdout Buffering](https://eklitzke.org/stdout-buffering)
- [Why does printf not flush after the call unless a newline is in the format string?](https://stackoverflow.com/a/1716621/11884593)
- [linux man setbuf](https://man7.org/linux/man-pages/man3/setbuf.3.html#DESCRIPTION)
- [Can't see the realtime output when running a python script](https://github.com/skywind3000/asyncrun.vim/wiki/FAQ#cant-see-the-realtime-output-when-running-a-python-script)

## Example

这里列举一些终端组合命令时, 何时会 line-buffered, 何时会 fully-buffered

> 如果 grep 的输出是 TTY, 那么它将是行缓冲的. 如果 grep 的输出发送到文件或管道, 它将被完全缓冲, 因为输出目标不是 TTY.

- `grep RAREPATTERN /var/log/mylog.txt`: line-buffered, 因为 stdout 是 tty
- `grep RAREPATTERN /var/log/mylog.txt >output.txt`: fully-buffered, 因为 stdout 被重定向到了一个 `output.txt` 文件
- `tac /var/log/mylog.txt | grep RAREPATTERN`: line-buffered, 因为 stdout 是 tty
- `grep RAREPATTERN /var/log/mylog.txt | cut -f1`: fully-buffered, 因为 grep 的 stdout 现在是一个管道描述符 (file descriptor for a pipe), **Pipes are not TTYs**
- `grep --line-buffered RAREPATTERN /var/log/mylog.txt | cut -f1`: line-buffered, 使用 `--line-buffered` 参数强制 grep 为 line-buffered
