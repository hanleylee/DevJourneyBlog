---
title: C/C++ 头文件路径在编译时及工具中的设置
date: 2021-03-01
comments: true
path: header-file-use
categories: Language
tags: ⦿c/cpp, ⦿header, ⦿path
updated:
---

使用 `C/CPP`, 避免不了要和各种头文件打交道, 系统库还好, 基本上不需要操心, 已经被自动预置入头文件列表中了. 棘手的是使用第三方库, 这时就要手动指定其头文件位置与库文件位置. 本文记录下在终端中手工编译与某些工具内编译的设置方式.

![himg](https://a.hanleylee.com/HKMS/2021-03-01234614.png?x-oss-process=style/WaMa)

<!-- more -->

## 终端中使用 gcc/clang/makefile 手工编译

通常情况下, 我们可以使用 `gcc -I/include -c test.c -o test.o` 与 `gcc test.o -L/libs -o test` 命令来分别指定头文件与库文件位置, 但是对于一个比较大的第三方库, 其头文件和库文件的数量是比较多的. 如果我们一个个手动地写, 那将是相当麻烦的. 所以, `pkg-config` 就应运而生了

简言之, `pkg-config` 为库提供编译与链接 flag 的功能.

### pkg-config 安装

```bash
brew install pkg-config
```

### pkg-config 常用命令

- `pkg-config --help`: 查看帮助
- `pkg-config --list-all`: 列出目前系统上所有支持 pkg-config 的库
- `pkg-config --cflags glib-2.0`: 指定头文件
- `pkg-config --libs glib-2.0`: 指定库文件

`pkg-config` 自然还有其他的功能, 可以通过 `pkg-config --help` 看到所有可用命令

### 使用 pkg-config 在终端进行编译

最基础的用法就是直接将 `pkg-config --cflags --libs glib-2.0` 作为 gcc 的参数之一写在其后.

```bash
# 注意 ` 是 grave/tilde 键, 不是单引号
$gcc main.c `pkg-config --cflags --libs glib-2.0` -o main
```

### pkg-config 的原理及自定义位置

其实 pkg-config 所做的事情非常简单, 它通过第三方库定义的 `.pc` 文件进行头文件与库文件的定位, 例如 `glib` 的 pc 文件如下:

```txt
prefix=/usr/local/Cellar/glib/2.66.7
libdir=${prefix}/lib
includedir=${prefix}/include

bindir=${prefix}/bin
glib_genmarshal=${bindir}/glib-genmarshal
gobject_query=${bindir}/gobject-query
glib_mkenums=${bindir}/glib-mkenums

Name: GLib
Description: C Utility Library
Version: 2.66.7
Requires.private: libpcre >=  8.31
Libs: -L${libdir} -lglib-2.0 -L/usr/local/opt/gettext/lib -lintl
Libs.private: -Wl,-framework,CoreFoundation -Wl,-framework,Carbon -Wl,-framework,Foundation -Wl,-framework,AppKit -liconv -lm
Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I/usr/local/opt/gettext/include
```

可以很清楚地看出, glib 在其 `/usr/local/Cellar/glib/2.66.7/lib/pkgconfig/glib-2.0.pc` 中已经定义好了相关的关键信息, 如 `Libs` 及 `Cflags`. 默认情况下 `glib` 会将其 pc 文件做一个软链接放置到 `/usr/local/lib/pkgconfig` 中

![himg](https://a.hanleylee.com/HKMS/2021-03-01-17-43-46.jpg?x-oss-process=style/WaMa)

某些软件可能没有自动创建软链接的功能, 或者我们自定义一个 `.pc` 文件, 那么这时就需要在 `.zshrc` 中添加如下配置:

```bash
# 添加自定义的 pkg-config 路径, 默认的路径为 /usr/local/lib/pkgconfig
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/zlib/lib/pkgconfig
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/ruby/lib/pkgconfig
export PKG_CONFIG_PATH
```

这样当我们使用 `gcc main.c 'pkg-config --cflags --libs zlib' -o main` 的时候 `pkg-config` 就会自动找到相应的 `.pc` 文件了

## vim 中配置头文件

### youcompleteme 依赖的头文件路径

ycm 所依赖的补全依赖的头文件路径有:

- 系统的 `C_INCLUDE_PATH` / `CPLUS_INCLUDE_PATH`
- `~/.vimrc` 中定义的 `set path=***`
- ycm 中定义的 `.ycm_extra_conf` 文件

    ycm 的 `.ycm_extra_conf.py` 我通常定义在 `.vimrc` 中, 作为一个固定配置

    ```vim
    # ~/.vimrc
    let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py' " 默认配置文件路径
    ```

    在 `~/.ycm_extra_conf.py` 文件中, flags 表示我们使用的配置选项, 其中的 `/usr/local/include` 就代表了将 Homebrew 安装的头文件进行补全提示,
    如果不够还可以直接添加自定义路径

    ```python
    # ~/.ycm_extra_conf.py
    flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-fexceptions',
    '-DNDEBUG',
    '-std=c11',
    '-x',
    'c',
    '-isystem', '/usr/local/include',
    '-isystem', '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include',
    '-I./include',
    ]
    ```

    当然如果每个第三方库的路径都需要手动添加的话那就太麻烦了, 我们可以通过简单的一个 python 方法将系统的 `pkg-config` 输出作为路径导入到 `flags` 中

    ```python
    # ~/.ycm_extra_conf.py
    # 通过 pkg-config 便捷添加头文件路径到 ycm 补全
    def pkg_config(pkg):
      def not_whitespace(string):
        return not (string == '' or string == '\n')
      output = subprocess.check_output(['pkg-config', '--cflags', pkg]).decode().strip()
      return list(filter(not_whitespace, output.split(' ')))

    flags += pkg_config('glib-2.0')
    ```

以上路径都可以起到辅助 ycm 进行补全的作用.

### ale 所依赖的头文件路径

`ale` 是 `lint` 工具, 可以支持很多种语言. 实际上 `ale` 就是多种 `linter` 的一个集合平台, 针对于不同的语言提供了多种 `linter` 进行支持, 我们选择其中的一种即可. 比如我选择了 `clangd` 作为 `c` / `cpp` 的 linter. `ale` 对每一个 `linter` 都提供了设置选项, 自然 `clangd` 也不例外:

```bash
# ~/.vimrc
# 添加自定义的pkg-config路径, 默认的路径为 /usr/local/lib/pkgconfig
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/zlib/lib/pkgconfig
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/ruby/lib/pkgconfig
export PKG_CONFIG_PATH

CPPFLAGS+=$(pkg-config --cflags glib-2.0 zlib ruby-3.0)
export CPPFLAGS

CFLAGS+=$(pkg-config --cflags glib-2.0 zlib ruby-3.0)
export CFLAGS

LDFLAGS+="-I/usr/local/opt/openjdk/include"
LDFLAGS+=$(pkg-config --libs glib-2.0 zlib ruby-3.0)
export LDFLAGS
```

```vim
let g:ale_linters = {
            \   'c': ['clangd'],
            \   'cpp': ['clangd'],
            \   'markdown': ['markdownlint'],
            \}

let g:ale_c_clangd_options = $CFLAGS
let g:ale_cpp_clangd_options = $CFLAGS
let g:ale_markdown_markdownlint_options='-c $HOME/.markdownlint.json'
```

这里我在 `~/.zshrc` 中使用 `CFLAGS` 导出自定义的 header 配置, 可以达到 **一处定义, 多处使用的** 的效果

### 编译运行所依赖的头文件路径

通常我使用 [skywind3000/asyncrun](https://github.com/skywind3000/asyncrun.vim) 来执行相关 `c` / `cpp` 文件, 那么相关的头文件定义就很简单了, 直接在相关命令处加上 `pkg-config` 的相关参数即可, 如下:

```vim
map <F2> : call Run()<CR>

func Run()
    exec 'w'
    if &filetype == 'c'
        exec 'AsyncRun! gcc `pkg-config --cflags --libs glib-2.0` -Wall -O2 "$(VIM_FILEPATH)" -o "$HOME/.cache/build/C/$(VIM_FILENOEXT)" && "$HOME/.cache/build/C/$(VIM_FILENOEXT)"'
    elseif &filetype == 'cpp'
        exec 'AsyncRun! g++ `pkg-config --cflags --libs glib-2.0` -Wall -O2 "$(VIM_FILEPATH)" -o "$HOME/.cache/build/cpp/$(VIM_FILENOEXT)" && "$HOME/.cache/build/cpp/$(VIM_FILENOEXT)"'
    elseif &filetype == 'java'
        exec 'AsyncRun! javac %; time java %<'
    elseif &filetype == 'sh'
        exec "AsyncRun! time bash %"
    elseif &filetype == 'python'
        exec 'AsyncRun! time python3 "%"'
    endif
endfunc
```

这样在 `c` 文件下, 只需要按下 `<F2>` 即可立即执行

## Xcode 中配置头文件及库文件

在 `TARGETS` -> `Build Settings` -> `Search Path` -> `Header Search Paths` / `Library Search Paths` 中设置相应的 header 及库文件路径即可

![himg](https://a.hanleylee.com/HKMS/2021-03-01-18-47-08.png?x-oss-process=style/WaMa)

## 总结

万变不离其宗, 虽然对于头文件与库文件有各种不同的配置方式, 但是都是围绕着如何方便地列出头文件与库文件的路径以供编译链接使用. 掌握了这个点, 我们即使在使用其他工具的时候也可以按照这个思路去尝试, 去解决.

## 参考

- [pkg-config 原理及用法](https://www.cnblogs.com/sddai/p/10266624.html)
