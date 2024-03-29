---
title: Linux filesystem
date: 2023-07-05
comments: true
path: linux-filesystem
categories: tools
tags: ⦿linux
updated:
---

Linux 文件系统基础知识

![himg](https://a.hanleylee.com/HKMS/2023-12-28165301.jpg?x-oss-process=style/WaMa)

<!-- more -->

## Linux 系统目录结构

```bash
      2 dr-xr-xr-x.  18 root root 4.0K May 20 00:42.
      2 dr-xr-xr-x.  18 root root 4.0K May 20 00:42..
     16 lrwxrwxrwx.   1 root root    7 May 11  2019 bin -> usr/bin
      2 dr-xr-xr-x.   6 root root 1.0K May 13 23:38 boot
   1025 drwxr-xr-x.  21 root root 3.4K Jun  1 12:23 dev
2097153 drwxr-xr-x. 152 root root  12K Jun  1 12:23 etc
      2 drwxr-xr-x.   4 root root 4.0K May 13 23:01 home
     12 lrwxrwxrwx.   1 root root    7 May 11  2019 lib -> usr/lib
     14 lrwxrwxrwx.   1 root root    9 May 11  2019 lib64 -> usr/lib64
     11 drwx------.   2 root root  16K May 13 22:51 lost+found
2228225 drwxr-xr-x.   4 root root 4.0K May 13 23:40 media
1835009 drwxr-xr-x.   2 root root 4.0K May 11  2019 mnt
 131073 drwxr-xr-x.   3 root root 4.0K May 17 21:47 opt
      1 dr-xr-xr-x. 305 root root    0 Jun  1 12:22 proc
3145729 dr-xr-x---.   7 root root 4.0K May 24 03:27 root
  11699 drwxr-xr-x.  49 root root 1.5K Jun  1 12:25 run
     15 lrwxrwxrwx.   1 root root    8 May 11  2019 sbin -> usr/sbin
     13 lrwxrwxrwx.   1 root root   19 May 14 23:44 snap -> /var/lib/snapd/snap
 786433 drwxr-xr-x.   2 root root 4.0K May 11  2019 srv
      1 dr-xr-xr-x.  13 root root    0 Jun  1 12:23 sys
     17 -rw-r--r--.   1 root root 3.1M May 20 00:42 @System.solv
2490369 drwxrwxrwt.  46 root root  20K Jun  1 12:27 tmp
1310721 drwxr-xr-x.  12 root root 4.0K May 13 22:52 usr
1048577 drwxr-xr-x.  23 root root 4.0K May 16 23:33 var
```

- `/bin`: bin 是 Binary 的缩写, 这个目录存放着系统普通用户使用的命令.
- `/boot`: 这里存放的是启动 Linux 时使用的一些核心文件, 包括一些连接文件以及镜像文件.
- `/dev`: Devices, 该目录下存放的是 Linux 的外部设备, 在 Linux 中访问设备的方式和访问文件的方式是相同的.
- `/etc`: Editable Text Configuration, 这个目录用来存放所有的系统管理所需要的配置文件和子目录. **更改文件可能导致系统不能启动**
    - `/etc`: 目录包含各种系统配置文件, 下面说明其中的一些. 其他的你应该知道它们属于哪个程序, 并阅读该程序的 man 页. 许多网络配置文件也在 /etc 中.
    - `/etc/rc` 或 `/etc/rc.d` 或 `/etc/rc?.d`:  启动, 或改变运行级时运行的脚本或脚本的目录.
    - `/etc/passwd`:  用户数据库, 其中的域给出了用户名, 真实姓名, 用户起始目录, 加密口令和用户的其他信息.
    - `/etc/fdprm`:  软盘参数表, 用以说明不同的软盘格式. 可用 setfdprm 进行设置. 更多的信息见 setfdprm 的帮助页.
    - `/etc/fstab`:  指定启动时需要自动安装的文件系统列表. 也包括用 swapon -a 启用的 swap 区的信息.
    - `/etc/group`:  类似 /etc/passwd, 但说明的不是用户信息而是组的信息. 包括组的各种数据.
    - `/etc/inittab`:  init 的配置文件.
    - `/etc/issue`:  包括用户在登录提示符前的输出信息. 通常包括系统的一段短说明或欢迎信息. 具体内容由系统管理员确定.
    - `/etc/magic`:  "file" 的配置文件. 包含不同文件格式的说明,  "file" 基于它猜测文件类型.
    - `/etc/motd`:  motd 是 message of the day 的缩写, 用户成功登录后自动输出. 内容由系统管理员确定. 常用于通告信息, 如计划关机时间的警告等.
    - `/etc/mtab`:  当前安装的文件系统列表. 由脚本 (scritp) 初始化, 并由 mount 命令自动更新. 当需要一个当前安装的文件系统的列表时使用 ( 例如 df 命令).
    - `/etc/shadow`:  在安装了影子 (shadow) 口令软件的系统上的影子口令文件. 影子口令文件将 /etc/passwd 文件中的加密口令移动到 /etc/shadow 中, 而后者只对超级用户 (root) 可读. 这使破译口令更困难, 以此增加系统的安全性.
    - `/etc/login.defs`:  login 命令的配置文件.
    - `/etc/printcap`:  类似 /etc/termcap, 但针对打印机. 语法不同.
    - `/etc/profile`, `/etc/csh.login`, `/etc/csh.cshrc`:  登录或启动时 bourne 或 cshells 执行的文件. 这允许系统管理员为所有用户建立全局缺省环境.
    - `/etc/securetty`:  确认安全终端, 即哪个终端允许超级用户 (root) 登录. 一般只列出虚拟控制台, 这样就不可能 ( 至少很困难) 通过调制解调器 (modem) 或网络闯入系统并得到超级用户特权.
    - `/etc/shells`:  列出可以使用的 shell.  chsh 命令允许用户在本文件指定范围内改变登录的 shell. 提供一机器 ftp 服务的服务进程 ftpd 检查用户 shell 是否列在 `/etc/shells` 文件中, 如果不是, 将不允许该用户登录.
    - `/etc/termcap`:  终端性能数据库. 说明不同的终端用什么 "转义序列" 控制. 写程序时不直接输出转义序列 ( 这样只能工作于特定品牌的终端), 而是从 /etc/termcap 中查找要做的工作的正确序列. 这样, 多数的程序可以在多数终端上运行.
- `/home`: 用户的主目录, 在 Linux 中, 每个用户都有一个自己的目录, 一般该目录名是以用户的账号命名的.
- `/lib`: Library, 这个目录里存放着系统最基本的动态连接共享库, 其作用类似于 Windows 里的 DLL 文件. 几乎所有的应用程序都需要用到这些共享库.
- `/lost+found`:  这个目录一般情况下是空的, 当系统非法关机后, 这里就存放了一些文件.
- `/media`: linux 系统会自动识别一些设备, 例如 U 盘, 光驱等等, 当识别后, linux 会把识别的设备挂载到这个目录下.
- `/mnt`: 系统提供该目录是为了让用户临时挂载别的文件系统的, 我们可以将光驱挂载在 /mnt / 上, 然后进入该目录就可以查看光驱里的内容了.
- `/opt`: Optional application software packages, 这是给主机额外安装软件所摆放的目录. 比如你安装一个 ORACLE 数据库则就可以放到这个目录下. 默认是空的.
- `/proc`: Processes, 这个目录是一个虚拟的目录, 它是系统内存的映射, 我们可以通过直接访问这个目录来获取系统信息.  这个目录的内容不在硬盘上而是在内存里, 我们也可以直接修改里面的某些文件, 比如可以通过下面的命令来屏蔽主机的 ping 命令, 使别人无法 ping 你的机器:

    ```bash
    echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
    ```

- `/root`: 该目录为系统管理员, 也称作超级权限者的用户主目录.
- `/run`: 是一个临时文件系统, 存储系统启动以来的信息. 当系统重启时, 这个目录下的文件应该被删掉或清除. 如果你的系统上有 /var/run 目录, 应该让它指向 run.
- `/sbin`: Superuser BINaries, 这里存放的是 root 管理员使用的系统管理程序.
- `/srv`: 该目录存放一些服务启动之后需要提取的数据.(不用服务器就是空)
- `/sys`: 这是 `linux2.6` 内核的一个很大的变化. 该目录下安装了 2.6 内核中新出现的一个文件系统 sysfs. sysfs 文件系统集成了下面 3 种文件系统的信息

    - 针对进程信息的 proc 文件系统
    - 针对设备的 devfs 文件系统
    - 针对伪终端的 devpts 文件系统.

    该文件系统是内核设备树的一个直观反映.  当一个内核对象被创建的时候, 对应的文件和目录也在内核对象子系统中被创建.

- `/tmp`: TeMPorary, 这个目录是用来存放一些临时文件的.
- `/usr`: Unix Shared Resources, 这是一个非常重要的目录, 用户的很多应用程序和文件都放在这个目录下, 类似于 windows 下的 program files 目录.
    - `/usr/bin`: 系统普通用户使用的应用程序.
    - `/usr/sbin`: root 用户使用的比较高级的管理程序和系统守护程序.
    - `/usr/src`: 内核源代码默认的放置目录.
- `/var` VARiable, 包含系统一般运行时要改变的数据. 通常这些数据所在的目录的大小是要经常变化或扩充的. 原来 `/var` 目录中有些内容是在 `/usr` 中的, 但为了保持 `/usr` 目录的相对稳定, 就把那些需要经常改变的目录放到 /var 中了. 每个系统是特定的, 即不通过网络与其他计算机共享. 下面列出一些重要的目录 (一些不太重要的目录省略了).
    - `/var/catman`:  包括了格式化过的帮助 (man) 页. 帮助页的源文件一般存在 `/usr/man/catman` 中; 有些 man 页可能有预格式化的版本, 存在 /usr/man/cat 中. 而其他的 man 页在第一次看时都需要格式化, 格式化完的版本存在 /var/man 中, 这样其他人再看相同的页时就无须等待格式化了.  (/var/catman 经常被清除, 就像清除临时目录一样.)
    - `/var/lib`:  存放系统正常运行时要改变的文件.
    - `/var/local`:  存放 /usr/local 中安装的程序的可变量据 (即系统管理员安装的程序). 注意, 如果必要, 即使本地安装的程序也会使用其他 /var 目录, 例如 /var/lock.
    - `/var/lock`:  锁定文件. 许多程序遵循在 /var/lock 中产生一个锁定文件的约定, 以用来支持他们正在使用某个特定的设备或文件.  其他程序注意到这个锁定文件时, 就不会再使用这个设备或文件.
    - `/var/log`:  各种程序的日志 (log) 文件, 尤其是 login (/var/log/wtmplog 纪录所有到系统的登录和注销) 和 syslog (/var/log/messages 纪录存储所有核心和系统程序信息).  /var/log 里的文件经常不确定地增长, 应该定期清除.
    - `/var/run`:  保存在下一次系统引导前有效的关于系统的信息文件. 例如,  /var/run/utmp 包含当前登录的用户的信息.
    - `/var/spool`:  放置 "假脱机 (spool)" 程序的目录, 如 mail,  news, 打印队列和其他队列工作的目录. 每个不同的 spool 在 /var/spool 下有自己的子目录, 例如, 用户的邮箱就存放在 /var/spool/mail 中.
    - `/var/tmp`:  比 /tmp 允许更大的或需要存在较长时间的临时文件. 注意系统管理员可能不允许 /var/tmp 有很旧的文件.

## Linux 文件属性

```bash
[root@www /]# ls -l
total 64
dr-xr-xr-x   2 root root 4096 Dec 14  2012 bin
dr-xr-xr-x   4 root root 4096 Apr 19  2012 boot
```

实例中, bin 文件的第一个属性用 "d" 表示. "d" 在 Linux 中代表该文件是一个目录文件.

在 Linux 中第一个字符代表这个文件是目录, 文件或链接文件等等.

- `d`: 则是目录
- `-`: 则是文件;
- `l`: 则表示为链接文档 (link file);
- `b`: 则表示为装置文件里面的可供储存的接口设备 (可随机存取装置);
- `c`: 则表示为装置文件里面的串行端口设备, 例如键盘, 鼠标 (一次性读取装置).

接下来的字符中, 以三个为一组, 且均为 `rwx` 的三个参数的组合. 其中, `r` 代表可读 (read), `w` 代表可写 (write), `x` 代表可执行 (execute).  要注意的是, 这三个权限的位置不会改变, 如果没有权限, 就会出现减号 `-` 而已.

每个文件的属性由左边第一部分的 10 个字符来确定 (如下图).

![himg](https://a.hanleylee.com/HKMS/2020-06-01-050936.jpg?x-oss-process=style/WaMa)

> 如果一个文件位于一个目录 A 中, 用户对目录 A 没有访问权限, 那么自然就没有该目录下的所有文件的访问权限, `if [ -f path/to/dir/text.txt]` 就会失败

### 文件的属主与属组

对于一个文件来说, 共有四类用户:

- 属主用户: 文件的所有者
- 属组用户: 与属主用户同组的用户, 使用 `cat /etc/group` 可查看所有用户组及各用户组中包含的用户
- root 用户: 即 root
- 其他用户: 不属于以上三者的其他用户

### 文件的权限

- `r`(Read, 读取): 对文件而言, 具有读取文件内容的权限; 对目录来说, 具有浏览目录的权限.
- `w`(Write, 写入): 对文件而言, 具有新增, 修改, 删除文件内容的权限; 对目录来说, 具有新建, 删除, 修改, 移动目录内文件的权限.
- `x`(Execute, 执行): 对文件而言, 具有执行文件的权限; 对目录了来说该用户具有进入目录的权限.

一些关于权限的常见误区

- 目录的只读访问不允许使用 `cd` 进入目录, 必须要有执行的权限才能进入.
- 只对目录有执行权限 `x` 的话只能进入该目录, 不能看到该目录下的内容, 要想看到目录下的文件名和目录名, 还需要可读权限 `r`.
- 一个文件能不能被删除, 主要看该文件所在的目录对用户是否具有写权限, 如果目录对用户没有写权限 `r`, 则该目录下的所有文件都不能被删除, 文件所有者除外
- 目录的 `w` 位不设置, 即使你拥有目录中某文件的 `w` 权限也不能写该文件

新建文件默认权限 `777`, 新建目录默认权限 `666`. 在 Unix 或者 Linux 中, 每创建一个文件或者目录时, 这个文件或者目录都具有一个默认的权限, 比如目录 `755`, 文件 `644`, 这些默认权限是通过 `umask` 权限掩码控制的. 一般默认的 `umask` 值为 `022`, 其最终效果就是新创建的目录权限为 `755`, 文件权限为 `644`. 所以只要修改了用户的 `umask` 值, 就可以控制默认权限.

#### pseudo users: 伪用户

这些用户在 `/etc/passwd` 文件中也占有一条记录, 但是不能登录, 因为它们的登录 Shell 为空. 它们的存在主要是方便系统管理, 满足相应的系统进程对文件属主的要求.

常见的伪用户如下所示:

- `bin`: 拥有可执行的用户命令文件
- `sys`: 拥有系统文件
- `adm`: 拥有帐户文件
- `uucp`: UUCP 使用
- `lp`: lp 或 lpd 子系统使用
- `nobody`: NFS 使用

除了上面列出的伪用户外, 还有许多标准的伪用户, 例如: `audit`, `cron`, `mail`, `usenet` 等, 它们也都各自为相关的进程和文件所需要.

## Linux 下的一些重要文件

### `/etc/passwd`

所有的用户信息, 每一行代表一个用户, 每行的信息分别代表如下:

`[用户名]:[密码]:[UID]:[GID]:[身份描述]:[主目录]:[登录 shell]`

```passwd
root:*:0:0:System Administrator:/var/root:/bin/sh
daemon:*:1:1:System Services:/var/root:/usr/bin/false
# ...
_oahd:*:441:441:OAH Daemon:/var/empty:/usr/bin/false
```

### `/etc/group`

所有用户组的信息, 格式如下:

```group
组名:口令:组标识号:组内用户列表
```

- `组名`: 是用户组的名称, 由字母或数字构成. 与 `/etc/passwd` 中的登录名一样, 组名不应重复
- `口令`: 字段存放的是用户组加密后的口令字. 一般 Linux 系统的用户组都没有口令, 即这个字段一般为空, 或者是 `*`
- `组标识号`: 与用户标识号类似, 也是一个整数, 被系统内部用来标识组
- `组内用户列表`: 是属于这个组的所有用户的列表, 不同用户之间用逗号 `,` 分隔. 这个用户组可能是用户的主组, 也可能是附加组

```group
root::0:root
bin::2:root,bin
sys::3:root,uucp
adm::4:root,adm
daemon::5:root,daemon
lp::7:root,lp
users::20:root,sam
```

### `/etc/shadow`

由于 `/etc/passwd` 文件是所有用户都可读的, 如果用户的密码太简单或规律比较明显的话, 一台普通的计算机就能够很容易地将它破解, 因此对安全性要求较高的 Linux 系统都把加密后的口令字分离出来, 单独存放在一个文件中, 这个文件是 `/etc/shadow` 文件.  有超级用户才拥有该文件读权限, 这就保证了用户密码的安全性.

`/etc/shadow` 中的记录行与 `/etc/passwd` 中的一一对应, 它由 `pwconv` 命令根据 `/etc/passwd` 中的数据自动产生

它的文件格式与 `/etc/passwd` 类似, 由若干个字段组成, 字段之间用 `:` 隔开. 这些字段是:

```passwd
登录名:加密口令:最后一次修改时间:最小时间间隔:最大时间间隔:警告时间:不活动时间:失效时间:标志
```

- `登录名`: 是与 / etc/passwd 文件中的登录名相一致的用户账号
- `口令`: 字段存放的是加密后的用户口令字, 长度为 13 个字符. 如果为空, 则对应用户没有口令, 登录时不需要口令; 如果含有不属于集合 {./0-9A-Za-z} 中的字符, 则对应的用户不能登录.
- `最后一次修改时间`: 表示的是从某个时刻起, 到用户最后一次修改口令时的天数. 时间起点对不同的系统可能不一样. 例如在 SCO Linux 中, 这个时间起点是 1970 年 1 月 1 日.
- `最小时间间隔`: 指的是两次修改口令之间所需的最小天数.
- `最大时间间隔`: 指的是口令保持有效的最大天数.
- `警告时间`: 字段表示的是从系统开始警告用户到用户密码正式失效之间的天数.
- `不活动时间`: 表示的是用户没有登录活动但账号仍能保持有效的最大天数.
- `失效时间`: 字段给出的是一个绝对的天数, 如果使用了这个字段, 那么就给出相应账号的生存期. 期满后, 该账号就不再是一个合法的账号, 也就不能再用来登录了.

```passwd
root:Dnakfw28zf38w:8764:0:168:7:::
daemon:*::0:0::::
bin:*::0:0::::
sys:*::0:0::::
adm:*::0:0::::
uucp:*::0:0::::
nuucp:*::0:0::::
auth:*::0:0::::
cron:*::0:0::::
listen:*::0:0::::
lp:*::0:0::::
sam:EkdiSECLWPdSa:9740:0:0::::
```

## Linux 管理员与 root 的区别

在 Linux 系统中, 管理员 (也称为系统管理员) 和 root 用户都是可以管理系统的特权用户, 但它们之间是有一些区别的.

管理员通常是一个普通的用户账户, 拥有一定的权限来管理系统. 管理员可以使用 `sudo` 命令获取超级用户的权限, 以执行需要特权用户才能完成的任务, 如安装软件包, 配置网络, 创建新用户等等. 但是管理员并不是拥有完全控制系统的特权用户.

而 root 用户是 Linux 系统中的超级用户, 拥有系统的最高权限. root 用户可以执行任何操作, 包括修改系统设置, 安装 / 删除软件, 管理用户, 访问系统文件等等. 因此 root 用户的权限非常高, 需要谨慎使用, 以免意外操作导致系统崩溃或数据丢失等问题.

在实际使用中, 管理员和 root 用户都是需要认证登录的, 但管理员需要通过 `sudo` 命令来获取超级用户的权限. 因此, 管理员相对于 root 用户更安全, 因为管理员不能在没有特权的情况下执行危险的操作, 而且管理员的行为也可以被系统管理员进行审计.

总之, 管理员和 root 用户都是可以管理 Linux 系统的用户, 但是它们之间的权限不同, 管理员需要通过 sudo 命令来获取超级用户权限, 而 root 用户拥有系统的最高权限. 在实际使用中, 管理员相对于 root 用户更安全, 因为它们不能在没有特权的情况下执行危险的操作.

## Linux 下创建一个跟 root 一样权限的超级管理员方法如下

1. 添加一个用户 admin: `useradd admin`
2. 给 admin 设置密码: `passwd admin`
3. 修改用户配置文件
4. 把其中的 uid 改为 0, gid 改为 0 权限就跟 root 一样了

    ```bash
    vim /etc/passwd

    # admin:x:0:0::/home/admin:/bin/bash
    ```

## Ref

- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html)
