---
title: Rime 输入法使用
date: 2021-02-16
comments: true
path: usage-of-rime
categories: Tools
tags: ⦿rime, ⦿tool
updated:
---

久闻 Rime 输入法的大名, 在几次浅尝辄止后, 终于被其高可定制性与简洁所吸引, 进而彻底转入 Rime 的怀抱. 由于 Rime 的安装与使用有一定的难度, 因此本文记录下相关的基础操作, 用于后来查阅.

![himg](https://a.hanleylee.com/HKMS/2021-02-18124029.jpg?x-oss-process=style/WaMa)

<!-- more -->

如果你是一个 Rime 新用户, 那么请完全根据本文的顺序进行阅读及配置, 最终将得到一个你满意的输入法. 如果你对 Rime 已经有基本的使用, 那么也可以迅速按照本文目录快速找到你需要的相关配置方法.

> Rime 在不同的平台上有着不同的实现, 在 Mac OS 上是 `鼠须管`, 在 Windows 上是 `小狼毫`, 在 `Linux` 上是 `Rime`. 虽然名称不同, 但是可实现的功能是相同的. 本文仅涉及 Mac OS 上的 `鼠须管`, 其他平台的相关设定方法基本相同.

## Rime 与其他输入法的优劣对比

首先对 Rime 与其他输入法进行一个我的主观比较(可能不够严谨, 仅供参考)

|              | Rime   | 其他(搜狗/QQ/百度等) |
|--------------|--------|----------------------|
| 可配置程度   | ⭐️⭐️⭐️ | ⭐️                   |
| 开源         | ⭐️⭐️⭐️ | -                    |
| 速度         | ⭐️⭐️⭐️ | ⭐️⭐️                 |
| UI           | ⭐️⭐️⭐️ | ⭐️⭐️                 |
| 最新流行词库 | ⭐️     | ⭐️⭐️⭐️               |

## 安装 Rime

```bash
brew install --cask squirrel
```

然后, 在 `System Preferences` -> `Keyboard` -> `Input Source` 中按照如下操作即可添加 Rime 输入法:

![himg](https://a.hanleylee.com/HKMS/2021-02-18103453.png?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2021-02-18103700.png?x-oss-process=style/WaMa)

## 配置文件及路径说明

Rime 输入法没有配置页面, 所有的配置均通过 `yaml` 格式的配置文件进行配置(与 `vim` 通过 `~/.vimrc` 进行配置有异曲同工之妙)

Rime 的配置文件路径分为:

- 程序配置路径: `/Library/Input Methods/Squirrel.app/Contents/SharedSupport`
- 用户配置路径: `~/Library/Rime`

通常情况下我们只需要关注 `~/Library/Rime` 文件夹即可, 此文件夹下的所有 `.yaml` 格式文件均为 `Rime` 的配置文件. 重要的配置文件如下:

- `squirrel.custom.yaml`: Rime 程序配置文件, 主要用于控制 Rime 的外观配置.
- `default.custom.yaml`: 配置可用的输入类型(如小鹤双拼, 明月拼音等), 以及相关快捷键
- `double_pinyin_flypy.custom.yaml`: 小鹤双拼配置文件, 主要配置一些词典文件
- `luna_pinyin.custom.yaml`: 明月拼音配置文件.
- `luna_pinyin.extended.dict.yaml`: 主字典, 用于定义一些 key value 键值对以及其他导入的词典.

> Rime 的 yaml 配置文件的缩进必须严格控制, 如果缩进不能对齐的话则不会生效

具体的设置方式可参考我 [repo](https://github.com/HanleyLee/Rime) 中的对应文件. 如果你的 `~/Library/Rime` 文件夹中没有以上文件, 那么也可以从此 repo 中复制.

## [东风破](https://github.com/rime/plum) 安装

Rime 默认只提供全拼输入方式, 如果我们要使用双拼, 五笔等输入方式, 那么最简单的方式就是使用官方插件管理器 `plum`(也叫东风破)

```bash
curl -fsSL https://git.io/rime-install | bash
```

安装后我们需要进入 `~/Library/Rime/plum` 路径中执行相关命令, 如:

- `bash rime-install double-pinyin`: 安装双拼输入法
- `bash ~/Library/Rime/plum/rime-install emoji`: 安装 emoji
- `bash ~/Library/Rime/plum/rime-install emoji:customize:schema=double_pinyin_flypy`: 安装 emoji 到双拼输入法

## 相关快捷键使用

- `control + ~`: 切换输入方式
- `control + a`: 在输入状态下将光标移动到开始
- `control + e`: 在输入状态下将光标移动到结尾
- `control + b`: 在输入状态下将光标向左移动一个单词
- `control + f`: 在输入状态下将光标向右移动一个单词
- `control + h`: 在输入状态下向左删除一个字符
- `=`/`.`: 向下翻页
- `-`/`,`: 向上翻页
- `shift + backspace`: 在输入状态下删除一个单词

## 选择要使用的输入方式

在 `~/Library/Rime/default.custom.yaml` 中:

```bash
patch:
    schema_list:
        - schema: luna_pinyin
        - schema: double_pinyin_flypy
        # - schema: luna_pinyin_simp
        # - schema: luna_pinyin_fluency
        #   - schema: terra_pinyin
        #   - schema: double_pinyin_mspy
        #   - schema: emoji
        #   - scheopomofo
```

这表示我们只使用 `明月拼音` 与 `小鹤双拼` 两种输入方案.

> 每次改动配置或添加新词库后都需要部署才能生效

> ![himg](https://a.hanleylee.com/HKMS/2021-02-16231225.png?x-oss-process=style/WaMa)

## 添加词库

在 `~/Library/Rime/luna_pinyin.custom.yaml` 文件中, `"translator/dictionary": luna_pinyin.extended` 表示使用词典文件 `luna_pinyin.extended.yaml`. 在 `luna_pinyin.extended.yaml` 中:

```yaml
import_tables:
    - luna_pinyin
    - luna_pinyin.cn_en
    - luna_pinyin.computer
    - luna_pinyin.emoji
    - luna_pinyin.hanyu
    - luna_pinyin.movie
    - luna_pinyin.music
    - luna_pinyin.name
    - luna_pinyin.sgmain
    - luna_pinyin.poetry
    # 追加
    - luna_pinyin.sougou
    - hl_phrases
    - hl_secretphrases
```

我们可以看到使用了很多外部其他词典, 这些词典都是以 `.yaml` 结尾的文件移除扩展名后的名称. 具体文件可在我的 [repo](https://github.com/HanleyLee/Rime) 上看到.

> 词典内的键值对之间必须使用 Tab 隔离开来, 不能使用空格!

## 混合 emoji 提示

我们可以将 emoji 与汉字进行混合提示, 只需要通过 [`东风破`](https://github.com/rime/plum) 安装 emoji 支持即可

- `bash ~/Library/Rime/plum/rime-install emoji`: 安装 emoji
- `bash ~/Library/Rime/plum/rime-install emoji:customize:schema=double_pinyin_flypy`: 安装 emoji 到双拼输入法

然后即可看到对 emoji 的支持了

![himg](https://a.hanleylee.com/HKMS/2021-02-18111934.png?x-oss-process=style/WaMa)

如果想要移除每个 emoji 的提示信息, 只需要在 `~/Library/Rime/emoji_suggestion.yaml` 中将 `tips` 进行注释即可

![himg](https://a.hanleylee.com/HKMS/2021-02-18143343.png?x-oss-process=style/WaMa)

## 自定义词库

我们可以通过建立自定义词典文件(如 `~/Library/Rime/hl_phrases.dict.yaml`), 并在其中按照 `文字 编码 频次(可省略)` 的顺序定义单词. 示例如下:

```yaml
---
name: hl_phrases
version: "2021.02.17"
sort: by_weight
use_preset_vocabulary: true
...

# 有码表的词库, 格式
# (注意是用制表符分割):
# 文字  编码    频次(可省略)

🆘  s o s   10000
```

最后需要在 `~/Library/Rime/luna_pinyin.extended.dict.yaml` 中增加此词典:

```yaml
import_tables:
    ...
    # 追加
    - hl_phrases
    ...
```

然后进行部署, 我们就可以看到我们定义的 `sos` 了

![himg](https://a.hanleylee.com/HKMS/2021-02-18112847.png?x-oss-process=style/WaMa)

## 导入搜狗输入法词库

1. 导出搜狗输入法词库为 `***.bin` 文件
2. 下载 [深蓝词库转换](https://github.com/studyzy/imewlconverter)(目前只有 Windows 版本有图形界面, Mac 可以使用虚拟机)

3. 在转换界面的目标格式选择 `Rime`, 源格式选择 `搜狗 bin`, 导出文件为 `sogou.txt`
4. 创建 `~/Library/Rime/luna_pinyin.sougou.dict.yaml` 文件, 内容如下:

    ```yaml
    ---
    name: luna_pinyin.sougou
    version: "1.0"
    sort: by_weight
    use_preset_vocabulary: true
    ...
    ```

5. 将 `sougou.txt` 内容导入到 `~/Library/Rime/luna_pinyin.sougou.dict.yaml`

    ```bash
    cat sougou.txt >> luna_pinyin.sougou.dict.yaml
    ```

6. 在 `~/Library/Rime/luna_pinyin.extended.dict.yaml` 中添加我们的搜狗词库

    ```yaml
    import_tables:
        ...
        # 追加
        - luna_pinyin.sougou
        ...
    ```

部署之后, 然后测试发现我们的 Rime 输入法已经可以使用我们在搜狗中积累的词库了

![himg](https://a.hanleylee.com/HKMS/2021-02-18155920.png?x-oss-process=style/WaMa)

## 在多台设备间同步信息

在 `~/Library/Rime/installation.yaml` 声明:

```yaml
installation_id: hanley
sync_dir: "/Users/hanley/Library/Mobile Documents/com~apple~CloudDocs/Rime/"
```

`sync_dir` 表示会将 `~/Library/Rime` 文件夹内的相关内容同步到目标文件夹内. `installation_id` 表示会根据给定的用户名作为目标文件夹的子文件夹进行同步.

如上, 我们可以在 iCloud 中创建 `Rime` 文件夹用于同步, 在其他设备中同样进行相同设置, 然后手动触发同步功能即可进行同步

![himg](https://a.hanleylee.com/HKMS/2021-02-16230821.png?x-oss-process=style/WaMa)

为了区分和管理方便, 多台电脑里的里鼠须管 `installation_id` 最好不要重复. 由菜单栏执行 **同步用户数据** 时,  **鼠须管** 会搜索 `/Users/hanley/Library/Mobile Documents/com~apple~CloudDocs/Rime/` 下所包含的所有子目录, 合并其中的`.userdb.txt` 文件并同步到本地配置文件夹的 `main.userdb` (双向合并), 同时,  **鼠须管** 会备份配置文件夹中的`.dict.yaml` 文件到 `/Users/hanley/Library/Mobile Documents/com~apple~CloudDocs/Rime/`(单向备份).

这么设计的目的可以合并来自多个设备的用户词库, 可以理解为 MacBook Air 上的用户词库 [abc] 和 MacBook Pro 上的用户词库 [bcd], 在同步后都变成了 [abcd].

## 总结

第一阶段的定制基本上到这里就告一段落了, 实际上可以定制的点还非常的多. 推荐阅读 RIME 官方的 [定制指南](https://github.com/rime/home/wiki/CustomizationGuide) 来进一步的定制.

RIME 需要慢慢的改进配置才能达到令人满意的程度, 就像 Vim 一样, 习惯了之后就会离不开它. 对于我来说, 我是非常喜欢这种高度定制化的输入法的.  至于值不值得去长期折腾, 各位可以尝试之后自行判断.

## 参考

- [Mac 下调校 Rime](https://mritd.com/2019/03/23/oh-my-rime/)
- [鼠须管 (Squirrel) 词库添加及配置](http://pythonic.zoomquiet.top/data/20160628220349/index.html)
- [用 RIME 定制输入法](https://www.ahonn.me/blog/custom-input-methods-with-rime)
- [](https://pepcn.com/wiki/post/gtd/鼠须管词库的同步和备份.md)
