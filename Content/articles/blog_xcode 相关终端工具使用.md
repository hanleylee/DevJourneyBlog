---
title: Xcode 相关终端工具使用
date: 2020-01-04
comments: true
path: usage-of-xcode-terminal-tools
categories: Tools
tags: ⦿ios, ⦿xcode, ⦿terminal, ⦿tools
updated:
---

xcode 最主要的终端指令命令就是 `xcodebuild ...`, 此指令必须在包含 `**.xcodeproj` 文件夹的目录下才能使用, 其作用是构建 xcode 项目或工作区

![himg](https://a.hanleylee.com/HKMS/2020-06-06-170912.jpg?x-oss-process=style/WaMa)

<!-- more -->

## configuration 与 scheme 关系

![himg](https://a.hanleylee.com/HKMS/2020-06-06-170912.jpg?x-oss-process=style/WaMa)

## 常用工具

### `xcode-select`

下载及安装 Command Line Tools, 比手动下载更便捷. 并且还能解决另外问题, 就是如果我们装有多个 Xcode, 我们在使用 Command Line Tools 相关工具时, 系统就会不知道该去使用哪个版本或者哪个位置的 Command Line Tools, 使用这个工具可以帮助我们设置及切换当前默认使用的 Command Line Tools.

- `xcode-select --install`: 安装 `command line tools`
- `xcode-select -p`: 显示当前指定的 Xcode 路径
- `xcode-select -s <path>`: 指定 Xcode 路径
- `xcode-select -r`: 重置 Xcode 路径

> - 通过 xcode-select 安装的 CLI 路径位于: */Library/Developer/CommandLineTools/*
> - Xcode 内嵌的 CLI 路径位于: */Applications/Xcode.app/Contents/Developer/usr/bin*

### dwarfdump

解析目标文件, 存档和.dSYM 包中的 DWARF 节, 并以人类可读的形式打印其内容;

使用场景: Crash 符号化;

路径: `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dwarfdump`

#### 实例

- `dwarfdump --uuid xx.app/xx`: 查看 xx.app 文件的 UUID
- `dwarfdump --uuid xx.app.dSYM`: 查看 xx.app.dSYM 文件的 UUID
- `dwarfdump --debug-info xx.app.dSYM > debug_info.txt`: 导出 debug_info 的信息到文件 debug_line.txt 中
- `dwarfdump --debug-line xx.app.dSYM > debug_line.txt`: 导出 debug_line 的信息到文件 debug_line.txt 中
- `dwarfdump --verify iOSTest.app.dSYM`: 校验 DWARF 的有效性
- `dwarfdump --arch arm64 --lookup 0x100006694 iOSTest.app.dSYM`: 查找指定地址的相关信息, 一般用在 Crash 解析时

### dsymutil

作用: 可以使用 dsymutil 从 二进制中 中提取 dSYM 文件以及对 dSYM 文件进行一些操作;

使用场景: 当 dSYM 文件丢失后, 可以将其作为找回 dSYM 文件的一种方式;

路径: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dsymutil;

#### 实例

- `dsymutil XXX`: # 从二进制文件中还有 `DSYM` 信息的二进制包中抽取形成 `.dysm` 文件
- `dsymutil -symbol-map /Users/XXXXX/Library/Developer/Xcode/Archives/2019-09-27/YYYY.xcarchive/BCSymbolMaps 0f1e9458-9741-36fb-b47c-694546728ea1.dSYM`: 使用指定的符号映射更新现有的 `dSYM`, 处理开启 bitcode 选项的 dsym 文件

### symbolicatecrash

作用: 是一个 perl 脚本, 里面整合了逐步解析的操作 (可以将命令拷贝出来, 直接进行调用);

场景: Crash 文件符号化;

路径: /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash

#### 实例

- `export DEVELOPER_DIR="/Applications/XCode.App/Contents/Developer"`: 需要先运行该命令, 不然下面 symbolicatecrash 命令会出现: `Error: "DEVELOPER_DIR" is not defined at ./symbolicatecrash line 69`
- `symbolicatecrash log.crash -d xxx.app.dSYM > symbol.log`: 运行命令前需要将崩溃日志, dSYM 以及 symbolicatecrash 复制到同一个目录下

### atos

作用: Crash 符号化;

路径: /Applications/Xcode.app/Contents/Developer/usr/bin/atos;

#### 实例

- `atos -arch arm64  -o iOSTest.app.dSYM/Contents/Resources/DWARF/iOSTest -l 0x0000000100298000 0x000000010029e694 -i`: `0x0000000100298000 为 load address;  0x000000010029e694 为 symbol address`, 最后一个 i 表示显示内联函数

### `xcodebuild`

编译出 `.app` 包, 与 `⌘ B` 效果相同

#### 命令

- `xcodebuild [action] [opt]`: 执行
    - `action`:
        - `build`: 在根目录执行 build 操作, 也是默认的操作.
        - `build-for-testing`: 在根目录执行 build 操作, 要求指定一个 scheme, 然后会在 derivedDataPath/Build/Products 目录下生成一个. xctestrun 文件, 这个文件包含执行测试的必要信息. 对于每个测试目标, 它都包含测试主机路径的条目, 一些环境变量, 命令行参数等待
        - `analyze`: 在根目录执行 analyze 操作, 要求指定一个 scheme
        - `archive`: 在根目录执行 archive 操作, 要求指定一个 scheme
        - `test`: 在根目录执行 test 操作, 要求指定一个 scheme
        - `test-without-build`: 在已经编译好的 bundle 上执行 test 操作, 如果提供了 `-scheme` 选项, 则在 derivedDataPath 下寻找 bundle, 如果提供了 `-xctestrun` 选项, 则在给定的路径下寻找 bundle.
        - `clean`: 在根目录执行 clean 操作. 在 `debug(release)` 下, `clean` 操作其实就是做了删除 `derivedDataPath/Debug-iphoneos(Release-iphoneos)` 下的 `.app` 文件和 `.dSYM` 文件还有 `derivedDataPath/.build` 下的文件夹的操作.
        - `install`: `build` 项目, 会在 `.dst` 目录下生成一个 `.app` 文件, 例如这路径: `/tmp/UnitTest.dst/Applications/UnitTest.app`
    - `opt`:
        - `-destination`: 代表的是设备的描述. e.g.: `-destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2'`, 其中 platform 下有 iOS Simulator 和 iOS
            - `iOS Simulator` 说明选择的是 iOS 模拟器, 需要提供 `name`, `OS` 或者 `id` .
            - `iOS` 说明选择的是真实设备, 需要提供 `name` 或者 `id`.
        - `-project <PROJECT_NAME>`: 指定 projectname
        - `-target <targetname>` 指定 targetname
        - `-alltargets`: 指定项目中的所有 target
        - `-workspace <workspacename>`: 指定 workspacename
        - `-scheme [schemename]`: 指定 scheme
        - `-destination <destinationspecifier>`: 通过 destination 描述来指定设备, 例如'platform=iOS Simulator,name=iPhone 6s,OS=11.2'
        - `-destination-timeout <time>`: 指定搜索目标设备的超时时间, 默认值是 30 秒
        - `-configuration <configurationname>`: 指定构建方式, Debug 或者 Release
        - `-arch <architecture>` 指定 architecture
        - `-sdk <sdkname>`: 指定 sdk, 例如 iphoneos11.2
        - `-showsdks`: 列出 Xcode 知道的所有可用 SDK, 包括适合使用的规范名称与 - sdk. 不启动构建.
        - `-list <yse/no>`: 列出项目中的目标和配置, 或工作区中的方案. 不启动构建.
        - `-derivedDataPath <path>`: 指定生产 DerivedData 的文件路径
        - `-resultBundlePath <path>`: 指定生产 result 的文件路径, 其中会包含一个 info.plist
        - `-showBuildSettings`: 列出 target 的 Build settings
        - `-enableAddressSanitizer <yes/no>`: 项目 scheme 里 Diagnostics 下的选项, 暂未研究具体能做什么.
        - `-enableThreadSanitizer <yes/no`: 项目 scheme 里 Diagnostics 下的选项, 暂未研究具体能做什么.
        - `-enableCodeCoverage <yes/no>`: 项目 scheme 里 test 里 info 下的选项, 可以控制是否生成代码覆盖率
        - `-testLanguage <language>`: 使用 ISO 639-1 语种名称来指定 test 时的 APP 语言
        - `-testRegion <region>`: 使用 ISO 3166-1 地区名称来指定 test 时的 APP 地区
        - `-allowProvisioningUpdates`: 允许 xcodebuild 与 Apple Developer 网站进行通信. 对于自动签名的目标, xcodebuild 将创建并更新配置文件, 应用程序 ID 和证书. 对于手动签名的目标, xcodebuild 将下载缺失或更新的供应配置文件, 需要在 Xcode 的帐户首选项窗格中添加开发者帐户.
        - `-exportArchive`: 导出 IPA 文件. 需要 - archivePath, -exportPath 和 -exportOptionsPlist 一起使用. 不能与 action 一起使用.
        - `-archivePath <path>`: 指定 archive 操作生成归档的路径. 或者在使用 - exportArchive 时指定归档的路径.
        - `-exportPath <path>`: 指定导出 IPA 文件到哪个路径, 其中在最后要包括 IPA 文件的名称.
        - `-exportOptionsPlist <path>`: 导出 IPA 文件时, 需要指定一个 ExportOptions.plist 文件, 如果不知道怎么填写这个文件, 可以先用 Xcode 手动打包一次, 导出文件中会有 ExportOptions.plist, 然后手动 copy 就好.
        - `-exportLocalizations`: 将本地化导出到 XLIFF 文件. 需要 - project 和 - localizationPath. 不能与 action 一起使用.
        - `-importLocalizations`: 从 XLIFF 文件导入本地化. 需要 - project 和 - localizationPath. 不能与 action 一起使用.
        - `-localizationPath <path>`: 指定目录或单个 XLIFF 本地化文件的路径.
        - `-exportLanguage <language>`: 指定包含在本地化导出中的可选 ISO 639-1 语言, 可以重复指定多种语言, 可能被排除以指定导出仅包含开发语言字符串.
        - `-xcconfig <path>`: 构建 target 时使用自定义的设置. 这些设置将覆盖所有其他设置, 包括在命令行上的设置.
        - `-xctestrun <path>`: 指定. xctestrun 文件的路径, 只能在 test-without-building 操作中存在
        - `-skip-testing <TestClass/TestMethod>`: 跳过指定的测试单元, 然后 test 剩下的测试单元, 测试单元可以是一个测试类或者测试方法
        - `-only-testing <TestClass/TestMethod>`: 只 test 指定的测试单元, -only-testing 优先于 - skip-testing
        - `-disable-concurrent-testing`: 限制并发测试, 只能在指定的设备上串行测试
        - `-dry-run, -n`: 打印将执行的命令, 但不执行它们.
        - `-skipUnavailableActions`: 跳过无法执行的操作而不是失败的操作. 这个选项是只有在 scheme 通过的情况下才会被使用.
        - `-toolchain <identifier/name>`: 使用 identifier 或 name 指定的 toolchain
        - `-quiet`: 除了警告和错误外, 不打印任何输出.
        - `-verbose`: 会打印额外的一些状态信息.
        - `-version`: 显示 xcode 版本信息. 不会触发构建. 当和 - sdk 一起使用时, 将会显示 SDK 的版本或者所有的 SKDs
        - `-license`: 显示 Xcode 和 SDK 许可协议. 允许接受许可协议, 而无需启动 Xcode 本身.
        - `-checkFirstLaunchStatus`: 检查是否需要执行首次启动任务.
        - `-runFirstLaunch`: 安装软件包并同意许可证.
        - `-usage`: 打印 Xcode 的 usage 信息
        - `-allowProvisioningDeviceRegistration`: 如有必要, 允许 xcodebuild 在 Apple Developer 网站上注册您的目标设备
        - `-enableUndefinedBehaviorSanitizer <yes/no>`: 项目 scheme 里 Diagnostics 下的选项, 暂未研究具体能做什么.
        - `-maximum-concurrent-test-device-destinations <number>`: 限制最多多少台真实设备并发测试
        - `-maximum-concurrent-test-simulator-destinations <number>`: 限制最多多少台并发测试

#### 示例

- `xcodebuild test -project PROJECT_NAME.xcodeproj -scheme SCHEME_NAME -destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2' -configuration Debug -derivedDataPath output`: 在 iOS11.2 的模拟器 iPhone6s 上对 scheme 为 UnitTestTests 执行单元测试, 并把生成的缓存文件存储在./output 里
- `xcodebuild archive -workspace PROJECT_NAME.xcworkspace -scheme SCHEME_NAME -configuration release -archivePath EXPORT_ARCHIVE_PATH`: 以 release 模式归档项目到 EXPORT_ARCHIVE_PATH 路径
- `xcodebuild -exportArchive -exportOptionsPlist {PATH_TO_PROJECT_ROOT}/ios/build/info.plist -archivePath {PATH_TO_ARCHIVE_MADE_USING_XCODE} /App.xcarchive -exportPath {PATH_TO_EXPORT_THE_APP}/App.ipa -allowProvisioningUpdates`: 用 exportOptionsPlist 文件里的导出配置信息来导出放在 EXPORT_ARCHIVE_PATH 路径下 的 xcarchive 文件, 导出 IPA 文件到 EXPORT_IPA_PATH 路径下. 并且允许自动更新 Provision 文件
- `xcodebuild test -project PROJECT_NAME.xcodeproj -scheme SCHEME_NAME -destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.2' -only-testing: SCHEME_NAME/CLASS_NAME/FUNC_NAME`: 指定测试单个用例方法

- `xcodebuild clean -target targetName`: 清理工程
- `xcodebuild build -target targetName`: 编译工程 (也可以隐藏 `build`, 因为 `build` 是默认的)

- `xcodebuild build -target targetName CODE_SIGN_IDENTITY="iPhone Distribution:XXXXXX"`: 使用签名证书进行编译
- `xcodebuild archive -workspace 'MyFramework.xcworkspace' -scheme 'MyFramework' -configuration Release -destination 'generic/platform=iOS' -archivePath '/path/to/archives/MyFramework-iphoneos' SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES`: Archive device slice
- `xcodebuild archive -workspace 'MyFramework.xcworkspace' -scheme 'MyFramework' -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath '/path/to/archives/MyFramework-iphonesimulator' SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES`: Archive simulator slice
- `xcodebuild -create-xcframework -framework '/path/to/archives/MyFramework-iphoneos.xcarchive/Products/Library/Frameworks/MyFramework.framework' -framework '/path/to/archives/MyFramework-iphonesimulator.xcarchive/Products/Library/Frameworks/MyFramework.framework'`: Create the XCFramework containing all the slices previously generated.

### xcrun

将由 `xcodebuild` 生成的 `.app` 文件转换为 `.ipa` 文件, 可以指定签名以生成不同的版本

> xcrun 是 Xcode 基本的命令行工具, 很多情况下我们也使用它来调用其他 Command Line Tools 工具, 在使用 xcrun 调用其他工具时, xcrun 会从 xcode-select 选择的路径及 *Developer/usr*, *Developer/Platforms*, *Developer/ToolChain* 中寻找可执行文件

#### 命令

- `xcrun [option] file -o file`
    - `-v, --verbose`: 显示详细信息
    - `-sdk <sdk name>`: 使用什么 sdk, 如 `iphoneos`
    - `--sign <signature>`: 使用签名证书
    - `-n, --no-cache`: 不使用缓存
    - `-h, --help`: 帮助

#### 示例

- `/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${RELEASE_BUILDDIR}/${APPLICATION_NAME}.app" -o "${BUILD_HISTORY_DIR}/${APPLICATION_NAME}.ipa" --sign "${DEVELOPER_NAME}" --embed "${PROVISONING_PROFILE}"`
- `/usr/bin/xcrun -sdk iphoneos PackageApplication -v path/To/xxx.app -o xxx.ipa`: 将. app 包装为 .ipa
- `xcrun -sdk iphoneos PackageApplication -v path/To/xxx.app -o xxx.ipa --sign "iPhone Distribution:XXXXXX"`: 在有签名的情况下将 .app 包装为 .ipa
- `/usr/bin/xcrun -sdk iphoneos  PackageApplication -v MyApp.app -o MyApp.ipa  --sign  9c8b212f6a2c2382847b104e387a01b246d4ce42 --embed MyApp.app/embed.mobileprovision`
- `xcrun --find clang`: Finds the path to the clang binary in the default SDK.
- `xcrun --sdk iphoneos --find texturetool`: Finds the path to the texturetool binary in the iOS SDK.
- `xcrun --sdk macosx --show-sdk-path`: Prints the path to the current Mac OS X SDK.
- `xcrun --sdk macosx clang test.c`: 指定以 macosx 的 SDK 运行 clang 来编译 `test.c` 文件

### clang

#### 命令

`clang [option] <input>`

- `-ccc-print-phases`: 查看编译的步骤
- `-###`: 查看操作内部命令
- `-rewrite-objc`: 查看编译结果
- `-E`: 查看 clang 在预编译处理的操作步骤
- `-fmodules`: 允许 modules 的语言特性
- `-fsyntax-only`: 防止编译器生成代码
- `-Xclang <arg>`: 向 clang 编译器传递参数
- `-dump-tokens`: 运行预处理器, 拆分内部代码段为各种 token
- `-ast-dump`: 构建抽象语法树 AST, 然后对其进行拆解和调试
- `-S`: 只运行预处理和编译步骤 (会生成汇编级)
- `-fobjc-arc`: 为 OC 对象生成 retain 和 release 的调用
- `-emit-llvm`: 使用 LLVM 描述汇编和对象文件
- `-o <file>`: 输出到目标文件 (作为参数时写在最后)
- `-c`: 只运行预处理 && 编译 && 汇编步骤 (没有链接部分, 生成机器码级)
- `--shared`: 生成共享库文件

#### 示例

- `clang -fmodules -fsyntax-only -Xclang -dump-tokens main.m`: 词法分析
- `clang -fmodules -fsyntax-only -Xclang -ast-dump main.m`: 语法分析
- `clang -S -fobjc-arc -emit-llvm main.m -o main.ll`: 生成 `LLVM IR`
- `clang -O3 -S -fobjc-arc -emit-llvm main.m -o main.ll`: 优化级别 `O3`, 生成 `LLVM IR`
- `clang -emit-llvm -c main.m -o main.bc`: 生成 bitcode
- `clang -S -fobjc-arc main.m -o main.s`: 生成汇编
- `clang -fmodules -c main.m -o main.o`: 生成目标文件 (mach-o 文件)
- `clang main.o -o main`: 生成可执行文件

### swiftc

与 clang 不同的是, swiftc 专注于 swift 语言的分析与编译

#### 命令

`swift [option] files`

- `-o <file>`: 输出到目标文件
- `-dump-ast`: 构建抽象语法树

    ![himg](https://a.hanleylee.com/HKMS/2020-11-30-102342.jpg?x-oss-process=style/WaMa)

- `-emit-sil`: 生成中间层语言

    ![himg](https://a.hanleylee.com/HKMS/2020-11-30-102355.jpg?x-oss-process=style/WaMa)

- `-emit-ir s.swift`: 生成 llvm 中间表示层

    ![himg](https://a.hanleylee.com/HKMS/2020-11-30-102447.jpg?x-oss-process=style/WaMa)

- `-emit-assembly`: 显示目标文件

#### 示例

- `swiftc -emit-ir s.swift`: 生成 llvm 中间表示层
- `swiftc -o s.o s.swift`: 生成目标文件

### libtool

创建库, 我们在 linux, window, mac 上编译静态库动态库时使用的命令是不同的:

- linux 动态库 (gcc 版): `gcc -shared -fPIC foo.c -o libfoo.so`
- linux 动态库 (clang 版): `clang -shared -fPIC foo.c -o libfoo.so`
- windows 动态库 (gcc 版): `gcc -shared -fPIC foo.c -o libfoo.dll`

但是如果使用 libtool 的话可以全全平台统一处理, 这就是 libtool 存在的意义, libtool 是一个一万多行的一个 bash 脚本

#### 命令

`libtool --tag=<...> --mode=<...> <tool> [option]`

- `--tag`: 代码使用的语言, 目前支持七种

- `CC`: `C`
- `CXX`: `C++`
- `GCJ`: `Java`
- `F77`: `Fortran 77`
- `FC`: `Fortran`
- `GO`: `Go`
- `RC`: `Windows Resource`

- `--mode`: 设定 libtool 的工作模式
    - `compile`: 编译
    - `link`: 链接
- `-static`: 链接合并 `.o` 文件为 `.a` 文件

#### 示例

- `libtool --tag=CC --mode=compile gcc -c foo.c -o libfoo.lo`: 编译
- `libtool --tag=CC --mode=link gcc libfoo.lo -rpath /usr/local/lib -o libfoo.la`: 链接
- `libtool -static -o ../xxx.a *.o`: 链接合并 `.o` 文件 为 `.a` 文件

### ar

create and maintain library archives

这个命令用于创建和管理归档 (archive) 文件. 主要应用是解决第三方库冲突, 例如 ffmpeg 冲突就可以用 ar 分离出冲突文件, 并打包.

#### 选项

- `-d` 删除备存文件中的成员文件.
- `-m` 变更成员文件在备存文件中的次序.
- `-p` 显示备存文件中的成员文件内容.
- `-q` 将问家附加在备存文件末端.
- `-r` 将文件插入备存文件中.
- `-t` 显示备存文件中所包含的文件.
- `-x` 自备存文件中取出成员文件.

#### 示例

- `ar rv one.bak a.c b.c`: 打包 `a.c`  `b.c` 文件
- `ar rv two.bak *.c`: 打包以 `.c` 结尾的文件
- `ar t two.bak`: 显示打包内容
- `ar d two.bak a.c b.c c.c`: 删除打包文件的成员文件
- `ar -d lib.a conflict.o`: 将 `.o` 从 `.a` 静态库中删除
- `ar -x lib.a`: 将 .a 文件解压缩

### lipo

create or operate on universal files

lipo 主要用于处理通用 Fat File, 可以查看 CPU 架构, 提取特定架构, 整合和拆分库文件

#### 命令

- `-info`: 查看静态库支持的 CPU 架构
- `-create`: 合并不同的 CPU 架构的库文件为一个
- `-thin`: 拆分提取一个库的 CPU 架构
- `-detailed_info`: 查看可执行文件头详细信息

#### 示例

- `lipo -info a.framework/a`: 查看架构信息
- `lipo -create Debug-iphoneos/a.framework/a Debug-simulators/a.framework/a -output aout`: 合并生成一个胖包
- `lipo a.framework/a -thin armv7 -output aout`: 分离出 armv7 版本库
- `lipo -detailed_info xxx.a`: 查看可执行文件头详细信息

### nm

查看一个文件的符号表信息

```bash
nm -nm a.out # 展示符号信息
```

### otool

object file displaying tool

#### 命令

- `-f`: print the fat headers
- `-a`: print the archive header
- `-h`: 打印 mach header
- `-l`: 打印 load commands
- `-L`: 打印 shared libraries used
- `-D`: print shared library id name
- `-t`: print the text section (disassemble with -v)
- `-p <routine name>`: start dissassemble from routine name
- `-s <segname> <sectname>`: print contents of section
- `-d`: 打印 data section
- `-o`: print the Objective-C segment
- `-r`: print the relocation entries
- `-S`: print the table of contents of a library
- `-T`: print the table of contents of a dynamic shared library
- `-M`: print the module table of a dynamic shared library
- `-R`: print the reference table of a dynamic shared library
- `-I`: print the indirect symbol table
- `-H`: print the two-level hints table
- `-G`: print the data in code table
- `-v`: 可读性, verbosely
- `-V`: print disassembled operands symbolically
- `-c`: print argument strings of a core file
- `-X`: print no leading addresses or headers
- `-m`: don't use archive(member) syntax
- `-B`: force Thumb disassembly (ARM objects only)
- `-q`: use llvm's disassembler (the default)
- `-Q`: use otool(1)'s disassembler
- `-m cpu=arg`: use `arg` as the cpu for disassembly
- `-j`: print opcode bytes
- `-P`: print the info plist section as strings
- `-C`: print linker optimization hints

比 nm 更强大, 可以详细查看 mach-o 文件信息.

```bash
otool -L a.out # 查看依赖动态库
otool -v -t a.out # 查看反汇编代码段
```

### objdump

display information from object files

反汇编目标文件或可执行文件.

#### 命令

- `-f`: 显示文件头信息
- `-D`: 反汇编所有 `section` (-d 反汇编特定 section)
- `-h`: 显示目标文件各个 section 的头部摘要信息
- `-x`: 显示所有可用的头信息, 包括符号表, 重定位入口. -x 等价于 -a -f -h -r -t 同时指定.
- `-i`: 显示对于 -b 或者 -m 选项可用的架构和目标格式列表.
- `-r`: 显示文件的重定位入口. 如果和 -d 或者 -D 一起使用, 重定位部分以反汇编后的格式显示出来.
- `-R`: 显示文件的动态重定位入口, 仅仅对于动态目标文件有意义, 比如某些共享库.
- `-S`: 尽可能反汇编出源代码, 尤其当编译的时候指定了 -g 这种调试参数时, 效果比较明显. 隐含了 -d 参数.
- `-t`: 显示文件的符号表入口. 类似于 nm -s 提供的信息

#### 示例

- `objdump -x a.out`: 反汇编 a.out 的所有 header 信息
- `objdump -D a.out`: 反汇编 a.out 的所有 section 信息

### install_name_tool

> change dynamic shared library install names

这个工具用的比较少, 它可以修改动态库的找寻路径.

例如 cmake 生成的动态库添加到工程可能存在 dyld: Library not loaded 的错误, 这个时候, 我们先用 otool 查看一下这个动态库的路径:

```bash
otool -L a.framework/a
```

### xcode-install

Xcode 多版本在开发中很常见, 通常是最新的 beta 版本与最新的正式发行版本同时安装, 此时多版本的下载, 安装与切换的管理就很有必要了

安装多个 xcode 时可以使用第三方的命令行工具或者从官方网站下载压缩包进行安装. 最好使用命令行工具 xcode-install 进行安装. 方便简单快捷. 不能使用 Mac App Store, 因为不稳定, 升级困难, 不能同时装多版本.

![himg](https://a.hanleylee.com/HKMS/2020-01-19-103958.jpg?x-oss-process=style/WaMa)

#### xcode-install 安装

```bash
gem install xcode-install
```

#### xcode-install 基本命令

- `xcversion help`: 显示 xcversion 可用命令
- `xcversion list`: 列出 xcode 的可用版本
- `xcversion update`: 更新 `xcode-install` 的列表
- `xcversion install 8`: 安装 xcode 8
- `xcversion install '13 beta 5'`: 安装 `13 beta 5` 版本
- `xcversion install 11.3-beta`: 安装 11.3 beta 版本
- `xcversion uninstall 11.3-beta`: 卸载 11.3 beta 版本
- `xcversion installed`: 显示所有已安装的 xcode
- `xcversion select 11.3`: 选择 xcode 11.3 版本作为默认版本, 等价于 `sudo xcode-select -s /Applications/Xcode-11.3.app`
- `xcversion selected`: 显示当前选择的默认版本
- `xcversion simulators`: 查看可安装的模拟器列表
- `xcversion simulators --install=iOS 8.4`: 安装 `iOS 8.4` 版本

#### xcode-install 与 XVim 的结合使用

Apple 自 2016 年开始不允许在 xcode 中安装第三方插件, 如果要安装非官方渠道的插件的话必须将 xcode 的 signature 给 strip 掉, 方法按照 xvim 的 GitHub 页面指导一步一步进行即可.

但是由 signature 被 strip 掉的 xcode 打包的 App 不能被 App Store 审核通过. 而且 signature 被 strip 后不恢复到原来的 signature(之前有工具可以, 但是现在已经不维护了). 因此如果希望使用 xvim 的同时又可以自己打包 App 上架, 那么就必须要使用两个版本的 xcode 了

目前 (2020-1-4) 我的方案是

- 使用 `xcode-install` 安装两个版本的 xcode(一个 beta 版, 一个最新正式版)
- 将 beta 版本通过 `codesign` 进行 strip
- 将默认版本使用 `xcode-select` 切换到 beta 版本
- 将 xvim 安装到 beta 版本上 (xvim 会被安装到默认 xcode 版本路径上, 因此在安装时一定确认当前版本路径为 beta 版)

这样就达到了既使用 xvim, 又能完美打包应用, 而且还能随时体验到最新 beta 版本的特性

#### xcode 版本切换

切换版本的含义是切换默认打开项目文件的 xcode 版本, 其实如果不使用这些命令切换的话也是可以用指定版本的 xcode 打开的, 有两种办法

- 右键打开方式里面选择指定版本, 不过此方法不能设为默认, 每次都需要手动选择
- 在 `Applications/` 文件夹中直接打开指定版本的 xcode, 然后在软件界面打开项目

因此, 切换版本就是为了节省一些打开软件的时间而已.

切换版本可以使用官方的 `xcode-select` 命令行工具

或者 xcode-install 也有相关选项

- `xcversion selected`: 查看当前选择的 xcode 版本
- `xcversion select 8`: 选定版本 8 用作当前版本
- `xcversion select 9 --symlink`: 选定版本 9 并改变 `/Applications/Xcode` 中的符号链接

#### xcode 安装多版本后不能使用插件

如果已经安装了多个版本, 会导致从 `Mac App Store` 下载的插件不能使用, 如果要重新启用的话需要对相应版本的 Xcode 进行重新注册

```bash
# 重新注册, 最后的 Xcode.app 为自定义的 Xcode 版本
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Xcode.app
```
