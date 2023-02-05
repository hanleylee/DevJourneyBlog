---
title: 正则表达式学习
date: 2022-09-14
comments: true
path: learning-regular-expression
categories: tools
tags: ⦿tool,⦿regex
updated:
---

在计算机科学中, 正则表达式是指一个用来描述或者匹配一系列符合某个句法规则的字符串的单个字符串. 在很多文本编辑器或其他工具里, 正则表达式通常被用来检索或替换那些符合某个模式的文本内容. 许多程序设计语言都支持利用正则表达式进行字符串操作.

本文就对正则表达式的原理与使用进行汇总, 读者可以将本文作为学习资料或查询手册使用

> 由于正则流派众多, 除明确指出某种流派的使用方式时, 本文中的其他任何正则均指 PCRE 流派

![himg](https://a.hanleylee.com/HKMS/2022-09-14131954.jpg?x-oss-process=style/WaMa)

<!-- more -->

> 把必须匹配的情况考虑周全并写出一个匹配结果符合预期的正则表达式很容易, 但把不需要匹配的情况也考虑周全并确保它们都将被排除在匹配结果以外往往要困难得多.

## 正则表达式发展简史

关于正则表达式, 最初的想法来自 20 世纪 40 年代的两位神经学家, *Warren McCulloch* 和 *Walter Pitts*, 研究出了一种用数学方式来描述神经网络的方法.

1956 年, 数学家 *Stephen Kleene* 发表了一篇标题为 *神经网络事件表示法和有穷自动机* 的论文. 这篇论文描述了一种叫做 **正则集合 (Regular Sets)** 的符号.

20 世纪 50 年代和 60 年代, 理论数学界对正则表达式进行了充分的研究. *Robert Constable* 的文章为那些对数学感兴趣的读者提供了很不错的简介.

关于在计算方面使用正则表达式的资料, 最早发表的是 1968 年 *Ken Thompson* 的文章 *Regular Expression Search Algorithm*, 在文中, 他描述了一种正则表达式编译器, 该编译器生成了 IBM 7094 的 object 代码. 由此也诞生了他的 qed, 这种编辑器后来成了 Unix 中 ed 编辑器的基础.

ed 的正则表达式并不如 qed 的先进, 但是这是正则表达式第一次在非技术领域大规模使用. ed 有条命令, 显示正在编辑的文件中能够匹配特定正则表达式的行. 该命令 `g/Regular Expression/p`, 读作 "Global Regular Expression Print". 这个功能非常实用, 最终成为独立的工具 `grep`

由于正则功能强大, 非常实用, 越来越多的语言和工具都开始支持正则. 不过遗憾的是, 由于没有尽早确立标准, 导致各种语言和工具中的正则虽然功能大致类似, 但仍然有不少细微差别.

诞生于 1986 年的 POSIX 开始进行标准化的尝试. POSIX 作为一系列规范, 定义了 Unix 操作系统应当支持的功能, 其中也包括正则表达式的规范. 因此, Unix 系统或类 Unix 系统上的大部分工具, 如 grep, sed, awk 等, 均遵循该标准. 我们把这些遵循 POSIX 正则表达式规范的正则表达式, 称为 *POSIX 流派* 的正则表达式. POSIX 把各种常见的流派分为两大类: *Basic Regular Expressions(BREs)* 和 *Extended Regular Expressions(EREs)*. POSIX 程序必须支持其中的任意一种

在 1987 年 12 月, *Larry Wall* 发布了 Perl 语言第一版, 因其功能强大一票走红, 所引入的正则表达式功能大放异彩. 之后 Perl 语言中的正则表达式不断改进, 影响越来越大.

1997 年, *Philip Hazel* 开发了 PCRE(`Perl Compatible Regular Expressions)`, 这是一套兼容 Perl 正则表达式的库, PCRE 的正则引擎质量很高, 全面仿制 Perl 的正则表达式的语法和语义. 其他的开发人员可以把 PCRE 整合到自己的工具和语言中, 为用户提供丰富而且极具表现力 (也是众所周知) 的各种正则功能. 许多流行的软件都使用了 PCRE, 例如 PHP, Apache 2, Exim, Postfix 和 Nmap.

之后, 正则表达式在各种计算机语言或各种应用领域得到了更为广泛的应用和发展.

## 正则表达式元字符

在 shell 中, `＊.txt` 能够用来选择多个文件. 在此类文件名 (称为 文件群组 `file globs` 或者通配符 `wildcards`) 中, 有些字符具有特殊的意义. 星号表示 "任意文本", 问号表示 "任意单个字符". 文件群组 `＊.txt` 以能够匹配字符的 `＊` 符号开头, 以普通文字 `.txt` 结尾, 所以, 它的意思是: 选择以任意文本开头, 以 `.txt` 结尾的所有文件.

正则表达式与文件名模式 (filename pattern) 的区别就在于, 正则表达式的元字符提供了更强大的描述能力. 文件名模式只为有限的需求提供了有限的元字符, 但是正则表达式"语言"为高级应用提供了丰富而且描述力极强的元字符.

> Shell 中的元字符会在传递给程序之前进行展开, 因此如果传递到程序的选项中含有 Shell 元字符, 那么需要使用引用的方式让其避免被提前展开

完整的正则表达式由两种字符构成:

- 元字符(metacharacters): 特殊字符 (special characters, 例如文件名例子中的 `*`)
- 文字(literal): 即普通文本字符 (normal text characters).

根据类型不同, 我将元字符进行以下分类:

- [字符及字符组](#字符及字符组)
- [量词](#量词)
- [零长度断言](#零长度断言)
- [分组与捕获](#分组与捕获)
- [模式](#模式)
- [Modifier](#modifier)
- [POSIX 字符类](#posix-字符类)
- [Unicode Property Escape](#unicode-property-escape)

### 字符及字符组

| PATTERN(PCRE) | DESCRIPTION                                             | EXAMPLE                                                              |
|---------------|---------------------------------------------------------|----------------------------------------------------------------------|
| `[xyz]`       | 匹配包含在 `[char]` 之中的任意一个字符                  | `coo[kl]` 可以匹配 `cook` 或 `cool`                                  |
| `[^xyz]`      | 匹配 `[^ char]` 之外的任意一个字符                      | `123[^45]` 不可以匹配 `1234` 或 `1235`, `1236`, `1237` 都可以        |
| `[a-z]`       | 匹配 `[]` 中指定范围内的任意一个字符, 要写成递增        | `[0-9]` 可以匹配 `1`, `2` 或 `3` 等其中任意一个数字                  |
| `.`           | 匹配除 `\n` `\r` 之外的任意单个字符                     | `ab.` 匹配 `abc` 或 `bad`, 不可匹配 `abcd` 或 `abde`, 只能匹配单字符 |
| `\d`          | 匹配单个数字字符, 等价于 `[0-9]`                        | `b\db` 匹配 `b2b`, 不匹配 `bcb`                                      |
| `\D`          | 匹配单个非数字字符, 等价于 `[^0-9]`                     | `b\Db` 匹配 `bcb`, 不匹配 `b2b`                                      |
| `\w`          | 匹配单个单词字符 (字母, 数字与_), 等价于 `[A-Za-z0-9_]` | `\w` 匹配 `1` 或 `a`, 不匹配 `&`                                     |
| `\W`          | 匹配单个非单词字符, 等价于 `[^A-Za-z0-9_]`              | `\W` 匹配非单词, 不匹配 `1` 或 `a`                                   |
| `\n`          | 匹配换行符, 等价于 `\x0a` `\cJ`                         | `\n` 匹配一个新行                                                    |
| `\r`          | 匹配回车符, 等价于 `\x0d` `\cM`                         |                                                                      |
| `\s`          | 匹配单个空白字符, 等价于 `[ \f\n\r\t\v]`                | `x\sx` 匹配 `x x`, 不匹配 `xx`                                       |
| `\S`          | 匹配单个非空白字符, 等价于 `[^ \f\n\r\t\v]`             | `x\S\x` 匹配 `xkx`, 不匹配 `xx`                                      |
| `\t`          | 匹配横向制表符, 等价于 `\x09` `\cl`                     |                                                                      |
| `\v`          | 匹配垂直制表符, 等价于 `\x0b` `\cK`                     |                                                                      |
| `\f`          | 匹配换页符, 等价于 `\x0c` `\cL`                         |                                                                      |
| `\a`          | 匹配 alarm                                              |                                                                      |
| `\e`          | 匹配 escape                                             |                                                                      |
| `\metachar`   | 将元字符进行转义, 忽略其特殊意义                        | `a\.b` 匹配 `a.b,` 但不能匹配 `ajb`                                  |
| `\xnn`        | 匹配两个十六进制表示的字符(只能表示256以内的)           | `\x41` 表示 `A`                                                      |
| `\x{nnnn}`    | 匹配任意多十六进制表示的 unicode 字符                   | `\x{0041}` 表示 `A`                                                  |
| `\o{nn}`      | 匹配八进制字符                                          | `\o53` 表示 ASCII 码为 43 的符号 `+`                                 |
| `\nnn`        | 匹配八进制字符                                          | `\033` 表示 ASCII 码为 27 的符号 `ESC`                               |
| `\cC`         | 匹配一个控制字符                                        |                                                                      |

只有在字符组内部, 连字符才是元字符, 否则它就只能匹配普通的连字符号. 其实, 即使在字符组内部, 它也不一定就是元字符. 如果连字符出现在字符组的开头, 它表示的就只是一个普通字符, 而不是一个范围. 同样的道理, 问号和点号通常被当作元字符处理, 但在字符组中则不是如此 (说明白一点就是,  `[0-9A-Z_!.?]` 里面, 真正的特殊字符就只有那两个连字符).

不妨把字符组看作独立的微型语言. 在字符组内部和外部, 关于元字符的规定 (哪些是元字符, 以及它们的意义) 是不同的.

字符组通常表示肯定断言 (positive assertion). 也就是说, 它们必须匹配一个字符. 排除型字符组仍然需要匹配一个字符, 只是它没有在字符组中列出而已. 把排除型字符组理解为"匹配未列出字符的字符组"更容易一些

### 量词

每个量词都规定了匹配成功至少需要的次数下限, 以及尝试匹配的次数上限.

| PATTERN(PCRE) | DESCRIPTION                                            | EXAMPLE                                                      |
|---------------|--------------------------------------------------------|--------------------------------------------------------------|
| `?`           | 贪婪式匹配之前的项 `1` 次或者 `0` 次, 等价于 `{0,1}`   | `colou?r` 可以匹配 `color` 或者 `colour`, 不能匹配 `colouur` |
| `??`          | 懒惰式匹配之前的项 `1` 次或者 `0` 次                   |                                                              |
| `?+`          | 占有式匹配之前的项 `1` 次或者 `0` 次                   |                                                              |
| `+`           | 贪婪式匹配之前的项 `1` 次或者多次, 等价于 `{1,}`       | `sa-6+` 匹配 `sa-6`, `sa-666`, 不能匹配 `sa-`                |
| `+?`          | 懒惰式匹配之前的项 `1` 次或者多次                      |                                                              |
| `++`          | 占有式匹配之前的项 `1` 次或者多次                      |                                                              |
| `*`           | 贪婪式匹配之前的项 `0` 次或者多次, 等价于 `{0,}`       | `co*l` 匹配 `cl`, `col`, `cool`, `coool` 等                  |
| `*?`          | 懒惰式匹配之前的项 `0` 次或者多次                      |                                                              |
| `*+`          | 占有式匹配之前的项 `0` 次或者多次                      |                                                              |
| `{n}`         | 贪婪式匹配之前的项 `n` 次, `n` 是可以为 `0` 的正整数   | `[0-9]{3}` 匹配任意一个三位数, 可以扩展为 `[0-9][0-9][0-9]`  |
| `{n}?`        | 懒惰式匹配之前的项 `n` 次, `n` 是可以为 `0` 的正整数   |                                                              |
| `{n}+`        | 占有式匹配之前的项 `n` 次, `n` 是可以为 `0` 的正整数   |                                                              |
| `{n,}`        | 贪婪式匹配之前的项至少 `n` 次                          | `[0-9]{2,}` 匹配任意一个两位数或更多位数                     |
| `{n,}?`       | 懒惰式匹配之前的项至少 `n` 次                          |                                                              |
| `{n,}+`       | 占有式匹配之前的项至少 `n` 次                          |                                                              |
| `{n,m}`       | 贪婪式匹配之前的项至少 `n` 次, 最多 `m` 次, `n<=m`     | `[0-9]{2,5}` 匹配从两位数到五位数之间的任意一个数字          |
| `{n,m}?`      | 懒惰式匹配指定之前的项至少 `n` 次, 最多 `m` 次, `n<=m` |                                                              |
| `{n,m}+`      | 占有式匹配指定之前的项至少 `n` 次, 匹配 `m` 次, `n<=m` |                                                              |

- 贪婪式匹配(匹配优先): 尽可能多地匹配内容
- 懒惰式匹配(忽略优先): 尽可能少地匹配
- 占有式匹配: 与贪婪式匹配相似, 尽可能多的内容, 但是不进行回溯; 也就是说, 它不会放弃已匹配的内容, 很自私

### 零长度断言

| PATTERN(PCRE) | DESCRIPTION                                        | EXAMPLE                                           |
|---------------|----------------------------------------------------|---------------------------------------------------|
| `^`           | 匹配字符串的开始(或多行模式下匹配每行的行首)       | `^tux` 匹配以 `tux` 开头的行                      |
| `$`           | 匹配字符串的结尾(或多行模式下匹配每行的行尾)       | `tux$` 匹配以 `tux` 结尾的行                      |
| `\A`          | 匹配字符串的开始(不受多行模式干扰)                 | `\Atux` 匹配以 `tux` 开头的行                     |
| `\z` / `\Z`   | 匹配字符串的结尾(不受多行模式干扰)                 | `tux\Z` 匹配以 `tux` 结尾的行                     |
| `\G`          | 前一次匹配结束的位置                               |                                                   |
| `\<`          | 单词左边界                                         | -                                                 |
| `\>`          | 单词右边界                                         | -                                                 |
| `\b`          | 单词边界                                           | `\bcool\b` 匹配 `cool`, 不匹配 `coolant`          |
| `\B`          | 非单词边界                                         | `cool\B` 匹配 `coolant`, 不匹配 `cool`            |
| `X(?=Y)`      | 正先行断言(aka 肯定型顺序环视) - 其右存在 Y 的 X   | `six(?=\d)` 右边是数字的 `six`, 能匹配 `six6`     |
| `X(?!Y)`      | 负先行断言(aka 否定型顺序环视) - 其右不存在 Y 的X  | `hi(?!\d)` 右边不是数字的 `hi`, 能匹配 `high`     |
| `(?<=Y)X`     | 正后发断言(aka 肯定型逆序环视) - 其左存在 Y 的 X   | `(?<=\d)th` 左边是数字的 `th`, 能匹配 `9th`       |
| `(?<!Y)X`     | 负后发断言(aka 否定型逆序环视) - 其左不存在 Y 的 X | `(?<!\d)th`  左边不是数字的 `th`, 能匹配 `health` |

### 分组与捕获

| PATTERN(PCRE) | DESCRIPTION              | EXAMPLE                                                                    |
|---------------|--------------------------|----------------------------------------------------------------------------|
| `(pattern)`   | 分组 + 捕获              | `ma(tri\|tt)?` 匹配 `max` 或 `maxtrix` 或 `matt`, 可以使用 `\1` 表示匹配值 |
| `(?:pattern)` | 分组 + 不捕获            |                                                                            |
| `x\|y`        | 多选结构                 | `ab(c\|d)` 匹配 `abc` 或 `abd`                                             |
| `\1`          | 匹配第一个子表达式的内容 | `[ ]+(\w+)[ ]+\1` 匹配连续两个的重复单词                                   |

### 模式

| PATTERN(PCRE) | DESCRIPTION                                                  | EXAMPLE                                 |
|---------------|--------------------------------------------------------------|-----------------------------------------|
| `(?i)`        | 不区分大小写模式(让整个正则或某一部分进行不区分大小写的匹配) | `((?i)cat) \1`                          |
| `(?s)`        | 点号通配模式(使点号匹配换行符)                               | `(?s).+`                                |
| `(?#)`        | 注释模式                                                     | `(\w+)(?#word) \1(?#word repeat again)` |
| `(?m)`        | 多行匹配模式(使 `^` 和 `$` 可以匹配每行的开头和结尾)         | `(?m)^the\|cat$`                        |

### Modifier

| PATTERN(PCRE) | DESCRIPTION                                                  | EXAMPLE |
|---------------|--------------------------------------------------------------|---------|
| `\l`          | 把下一个字符转换为小写(仅在替换部分使用)                     |         |
| `\L`          | 把后面的字符转换为小写, 直到遇见 `\E` 为止(仅在替换部分使用) |         |
| `\u`          | 把后面的字符转换为大写(仅在替换部分使用)                     |         |
| `\U`          | 把后面的字符转换为大写, 直到遇见 `\E` 为止(仅在替换部分使用) |         |
| `\Q`          | quote, 把后面的字符统统作为非元字符看待, 直到遇见 `\E` 为止  |         |
| `\E`          | 结束 `\L` 或 `\U` 转换                                       |         |

### POSIX 字符类

POSIX 字符类是一个形如 `[:...:]` 的特殊元序列 (meta sequence), 他可以用于匹配特定的字符范围.

| Pattern      | Description                                                           | Example              |
|--------------|-----------------------------------------------------------------------|-------------------|
| `[:alnum:]`  | 匹配任意一个字母或数字字符(等价于 `[a-zA-Z0-9]`)                      | `[[:alnum:]]+`    |
| `[:alpha:]`  | 匹配任意一个字母字符 (等价于 `[a-zA-Z]`)                              | `[[:alpha:]]{4}`  |
| `[:blank:]`  | 空格与制表符 (等价于 `[\t ]`)                                         | `[[:blank:]]*`    |
| `[:digit:]`  | 匹配任意一个数字字符(等价于 `[0-9]`)                                  | `[[:digit:]]?`    |
| `[:lower:]`  | 匹配小写字母(等价于 `[a-z]`)                                          | `[[:lower:]]{5,}` |
| `[:upper:]`  | 匹配大写字母(等价于 `[A-Z]`)                                          | `([[:upper:]]+)?` |
| `[:punct:]`  | 匹配标点符号, 既不属于`[:alnum:]` 也不属于 `[:cntrl:]` 的任何一个字符 | `[[:punct:]]`     |
| `[:space:]`  | 任何一空白字符, 包括空格(等价于 `[\f\n\r\t\v ]`)                      | `[[:space:]]+`    |
| `[:print:]`  | 任何一个可以打印的字符                                                | `[[:print:]]`     |
| `[:graph:]`  | 与 `[:print:]` 一样, 但不包含空格                                     | `[[:graph:]]`     |
| `[:xdigit:]` | 任何一个十六进制数 (等价于 `[a-fA-F0-9]` )                            | `[[:xdigit:]]+`   |
| `[:cntrl:]`  | 任何一个控制字符 (ASCII 0-31, 再加上 ASCII 127)                       | `[[:cntrl:]]`     |
| `[:ascii:]`  | 匹配单词 ASCII 字符(共128个)(BRE/ERE 不适用)                          | `[[:cntrl:]]`     |
| `[:word:]`   | 匹配单词字符(BRE/ERE 不适用)                                          | `[[:cntrl:]]`     |

这 12 个 POSIX 字符类在 `BREs` / `EREs` / `PCRE` 中都是通用的

`#[[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]]` 可以匹配 `#336633` 与 `#FFFFFF`, 其中我们使用的 POSIX 字符类是 `[:xdigit:]`, 而不是 `:xdigit:`, 外层的 `[]` 用来定义字符集合, 内层的 `[]` 是 POSIX 字符类的本身的组成部分

### Unicode Property Escape

Unicode 为我们提供了一些属性转义用于正则匹配, 这些属性转义我们可以认为也是元字符, 常用的有三种, 分别是:

- *Unicode Property*: 按功能分类, 每个字符只属于一个分类
- *Unicode Blocks*: 按码值区间分类, 各区间不相交(PCRE 不支持)
- *Unicode Scripts*: 按照书写系统来划分, 如汉语

#### Unicode Property

语言支持: Java, PHP, Golang, Ruby, Objective-C, JavaScript(ES8),.NET 等

| PATTERN                                | DESCRIPTION                                                                          |
|----------------------------------------|--------------------------------------------------------------------------------------|
| `\p{L}` / `\p{Letter}`                 | 字母                                                                                 |
| `\p{Ll}` / `\p{Lowercase_Letter}`      | 小写字母                                                                             |
| `\p{Lu}` / `\p{Uppercase_Letter}`      | 大写字母                                                                             |
| `\p{Lt}` / `\p{Titlecase_Letter}`      | 出现在单词开头的大写字母                                                             |
| `\p{L&}`                               | `\P{Ll}`, `\p{Lu}`, `\p{Lt}` 并集的简写法                                            |
| `\p{Lm}` / `\p{Modifier_Letter}`       | 少数形似字母的, 有特殊用途的字符                                                     |
| `\p{Lo}` / `\p{Other_Letter}`          | 没有大小写形式, 也不属于修饰符的字母, 包括希伯来语, 阿拉伯语, 孟加拉语, 日语         |
| `\p{M}` / `\p{Mark}`                   | 不能单独出现, 必须和其他基本字符一起出现的字符                                       |
| `\p{Mn}` / `\p{Non_Spacing_Mark}`      | 用于修饰其他字符的字符, 比如重音符号, 变音符号                                       |
| `\p{c}` / `\p{Spacing_Combining_Mark}` | 会占据一定宽度的修饰字符                                                             |
| `\p{Me}` / `\p{Encolsing_Mark}`        | 可以围住其他字符的标记, 比如圆圈方框等                                               |
| `\p{Z}`                                | 用于表示分隔, 但本身不可见的字符                                                     |
| `\p{Zs}` / `\p{Space_Separator}`       | 各种空白字符, 比如空格符, 不间断空格, 以及各种固定宽度的空白字符                     |
| `\p{Zl}` / `\p{Line_Separator}`        | LINE SEPARATOR 字符 (U+2028)                                                         |
| `\p{Zp}` /`\p{Paragraph_Separator}`    | PARAGRAPH SEPARATOR 字符(U+2029)                                                     |
| `\p{S}` / `\p{Math_Symbol}`            | 各种图形符号(Dingdats)与字母符号                                                     |
| `\p{Sm}` / `\p{Math_Symbol}`           | 数学符号, +, ÷, 表示分数的横线                                                       |
| `\p{Sc}` / `\p{Math_Symbol}`           | 货币符号                                                                             |
| `\p{Sk}` / `\p{Math_Symbol}`           | -                                                                                    |
| `\p{So}` / `\p{Math_Symbol}`           | 各种印刷符号, 框图符号, 盲文符号, 以及非字母形式的中文字符                           |
| `\p{N}`                                | 各种数字字符                                                                         |
| `\p{Nd}` / `\p{Decimal_Digit_Number}`  | 各种字母表中从 0 到 9 的数字(不包括中文, 日文和韩文)                                 |
| `\p{Nl}` / `\p{Letter_Number}`         | 几乎所有的罗马数字                                                                   |
| `\p{No}` / `\p{Other_Number}`          | 作为加密符号和记号的数字, 非阿拉伯数字的数字表示字符(不包括中文, 日文, 韩文中的字符) |
| `\p{P}` / `\p{Punctuation}`            | 标点字符                                                                             |
| `\p{Pd}` / `\p{Dash_Punctuation}`      | 各种格式的连字符和短划线                                                             |
| `\p{Ps}` / `\p{Open_Punctuation}`      |                                                                                      |
| `\p{Pe}` / `\p{Close_Punctuation}`     |                                                                                      |
| `\p{Pi}` / `\p{Initial_Punctuation}`   |                                                                                      |
| `\p{Pf}` / `\p{Final_Punctuation}`     |                                                                                      |
| `\p{Pc}` / `\p{Connector_Punctuation}` | 少数有特殊语法含义的标点, 如下划线                                                   |
| `\p{Po}` / `\p{Other_Punctuation}`     | 用于表示其他所有标点字符: !, &, ., : ...                                             |
| `\p{C}` / `\p{Other}`                  | 匹配其他任何字符(很少用于正常字符)                                                   |
| `\p{Cc}` / `\p{Control}`               | ASCII 和 Latin-1 编码中的控制字符(TAB, LF, CR 等)                                    |
| `\p{Cf}` / `\p{Format}`                | 用于表示格式的不可见字符                                                             |
| `\p{Co}` / `\p{Private_Use}`           | 分配与私人用途的代码点                                                               |
| `\p{Cn}` / `\p{Unassigned}`            | 目前尚未分配字符的代码点                                                             |

#### Unicode Blocks

语言支持: Java, Golang,.NET 等

| PATTERN        | DESCRIPTION |
|----------------|-------------|
| `\p{Arrows}`   | 箭头符号    |
| `\p{Bopomofo}` | 注音字母    |

#### Unicode Script

语言支持: PHP, Ruby 等

| PATTERN                   | DESCRIPTION |
|---------------------------|-------------|
| `\p{Common}`              |             |
| `\p{Arabic}`              |             |
| `\p{Armenian}`            |             |
| `\p{Bengali}`             |             |
| `\p{Bopomofo}`            |             |
| `\p{Braille}`             |             |
| `\p{Buhid}`               |             |
| `\p{Canadian_Aboriginal}` |             |
| `\p{Cherokee}`            |             |
| `\p{Cyrillic}`            |             |
| `\p{Devanagari}`          |             |
| `\p{Ethiopic}`            |             |
| `\p{Georgian}`            |             |
| `\p{Greek}`               | 希腊语字符  |
| `\p{Gujarati}`            |             |
| `\p{Gurmukhi}`            |             |
| `\p{Han}`                 | 中文字符    |
| `\p{Hangul}`              |             |
| `\p{Hanunoo}`             |             |
| `\p{Hebrew}`              |             |
| `\p{Hiragana}`            |             |
| `\p{Inherited}`           |             |
| `\p{Kannada}`             |             |
| `\p{Katakana}`            |             |
| `\p{Khmer}`               |             |
| `\p{Lao}`                 |             |
| `\p{Latin}`               |             |
| `\p{Limbu}`               |             |
| `\p{Malayalam}`           |             |
| `\p{Mongolian}`           |             |
| `\p{Myanmar}`             |             |
| `\p{Ogham}`               |             |
| `\p{Oriya}`               |             |
| `\p{Runic}`               |             |
| `\p{Sinhala}`             |             |
| `\p{Syriac}`              |             |
| `\p{Tagalog}`             |             |
| `\p{Tagbanwa}`            |             |
| `\p{TaiLe}`               |             |
| `\p{Tamil}`               |             |
| `\p{Telugu}`              |             |
| `\p{Thaana}`              |             |
| `\p{Thai}`                |             |
| `\p{Tibetan}`             |             |
| `\p{Yi}`                  |             |

> Use `\PP` to match non-P

### 元字符流派对比

根据 [前面](#正则表达式发展简史) 的描述 *POSIX 流派* 与 *PCRE 流派* 是目前正则表达式流派中的两大最主要的流派. 具体如下:

- POSIX
    - `POSIX Basic Regular Expressions`, 简称 `BREs`, 使用此流派的工具有 `grep`, `vi/vim`, `sed`, `csplit`, `dbx`, `dbxtool`, `more`, `ed`, `expr`, `lex`, `pg`, `nl`, `rdist`
    - `POSIX Extended Regular Expressions`, 简称 `EREs`, 使用此流派的工具有 `grep -E`, `sed -E`, `awk`, `nawk`, `bash`, `zsh`
- `Perl Compatible Regular Expressions` 简称 `PCRE`, 使用此流派的工具有:
    - 直接兼容, 与 Perl 正则表达式直接兼容的语言或工具. 比如 Perl, PHP preg, zsh, PCRE 库等, 一般称之为 Perl 系.
    - 间接兼容, 比如 Java 系 (包括 Java, Groovy, Scala 等), .Net 系 (包括 C#, VB.Net 等), Python, JavaScript 等.

以下列出各流派之间的元字符对比(如果意义和用法都相同的则省略)

<!-- markdownlint-disable MD013 -->
| -                                  | PCRE                    | POSIX BREs                  | POSIX EREs                 | Vim(magic)       |
|------------------------------------|-------------------------|-----------------------------|----------------------------|------------------|
| 单字符匹配                         | `?`                     | 不支持(GNU BREs 支持 `\?`)  | `?`                        | `\?` / `\=`      |
| 重复0次以上(懒惰)                  | `*?`                    | 不支持                      | 不支持                     | `\{-}`           |
| 重复1次以上                        | `+`                     | 不支持(GNU BREs 支持 `\+`)  | `+`                        | `\+`             |
| 重复1次以上(懒惰)                  | `+?`                    | 不支持                      | 不支持                     | `{-1,}`          |
| 量词上下限                         | `{n,m}`                 | `\{i,j\}`                   | `{n,m}`                    | `\{n,m}`         |
| 量词上下限(懒惰)                   | `{n,m}?`                | `\{i,j\}?`                  | `{n,m}?`                   | `{-n,m}`         |
| 分组捕获                           | `()`                    | `\(\)`                      | `()`                       | `\(\)`           |
| 捕获文本引用                       | `\1`                    | `\1`                        | 不支持(GNU EREs 支持 `\1`) | `\1`             |
| 多分支选择                         | `\|`                    | 不支持(GNU BREs 支持 `\\|`) | `\|`                       | `\\|`            |
| 匹配字符串的开始(不受多行模式干扰) | `\A`                    | 不支持                      | 不支持                     | `^`              |
| 匹配字符串的结尾(不受多行模式干扰) | `\z` / `\Z`             | 不支持                      | 不支持                     | 不支持           |
| 前一次匹配结束的位置               | `\G`                    | 不支持                      | 不支持                     | 不支持           |
| 单词分界符                         | `\b`                    | `\b`                        | `\b`                       | -                |
| 非单词边界                         | `\B`                    | `\B`                        | `\B`                       | -                |
| 单词左边界                         | -                       | `\<`                        | `\<`                       | `\<`             |
| 单词右边界                         | -                       | `\>`                        | `\>`                       | `\>`             |
| 字符                               | `\w`                    | 不支持 (GNU BREs 支持 `\w`) | 不支持(GNU BREs 支持 `\w`) | `\w`             |
| 非字符                             | `\W`                    | 不支持 (GNU BREs 支持 `\W`) | 不支持(GNU BREs 支持 `\W`) | `\W`             |
| 空白字符                           | `\s`                    | 不支持 (GNU BREs 支持 `\s`) | 不支持(GNU BREs 支持 `\s`) | `\s`             |
| 非空白字符                         | `\S`                    | 不支持 (GNU BREs 支持 `\S`) | 不支持(GNU BREs 支持 `\S`) | `\S`             |
| 数字                               | `\d`                    | 不支持                      | 不支持                     | `\d`             |
| 非数字                             | `\D`                    | 不支持                      | 不支持                     | `\D`             |
| 转义之后的所有元字符(直至 `\E`)    | `\Q`                    | 不支持                      | 不支持                     | 不支持           |
| 换行符                             | `\n`                    | 不支持                      | 不支持                     | `\n`             |
| 回车符                             | `\r`                    | 不支持                      | 不支持                     | `\r`             |
| 水平制表符                         | `\t`                    | 不支持                      | 不支持                     | `\t`             |
| 垂直制表符                         | `\v`                    | 不支持                      | 不支持                     | `\v`             |
| 换页符                             | `\f`                    | 不支持                      | 不支持                     | `\f`             |
| 正先行断言 - 其右存在 Y 的 X       | `X(?=Y)`                | 不支持                      | 不支持                     | `X\(Y\)\@=`      |
| 负先行断言 - 其右不存在 Y 的 X     | `X(?!Y)`                | 不支持                      | 不支持                     | `X\(Y\)\@!`      |
| 正后发断言 - 其左存在 Y 的 X       | `(?<=Y)X`               | 不支持                      | 不支持                     | `\(Y\)\@<=X`     |
| 负后发断言 - 其左不存在 Y 的 X     | `(?<!Y)X`               | 不支持                      | 不支持                     | `\(Y\)\@<!X`     |
| 不区分大小写模式                   | `(?i)`                  | 不支持                      | 不支持                     | -                |
| 点号通配模式                       | `(?s)`                  | 不支持                      | 不支持                     | -                |
| 注释模式                           | `(?#)`                  | 不支持                      | 不支持                     | -                |
| 多行匹配模式                       | `(?m)`                  | 不支持                      | 不支持                     | -                |
| 八进制字符                         | `\o{nn}` `\nnn`         | 不支持                      | 不支持                     | `\%onn`          |
| Unicode(二位)                      | `\xnn`                  | 不支持                      | 不支持                     | `\%xnn` / `%Xnn` |
| Unicode(四位)                      | `\x{nnnn}`              | 不支持                      | 不支持                     | `\%unnnn`        |
| Unicode(八位)                      | `\x{nnnnnnnn}`          | 不支持                      | 不支持                     | `\%Unnnnnnnn`    |
| Unicode 属性                       | `\p{Prop}` / `\P{Prop}` | 不支持                      | 不支持                     | 不支持           |
<!-- markdownlint-restore -->

> 以上表格中的 `\|` 都视为 `|`, 因为 markdown 的表格语法不允许直接使用 `|`

## 正则的转义

对于一个给定的字母表, 一个转义字符的目的是开始一个字符序列, 使得转义字符开头的该字符序列具有不同于该字符序列单独出现时的语义. 转义字符开头的字符序列被叫做 *转义序列*.

转义序列通常有两种应用场景:

1. 编码无法用字母表直接表示的特殊数据
2. 用于表示无法直接键盘录入的字符 (如换行符 `\n`).

在正则中, 转义字符是使用反斜杠 `\` 表示的

### 从字符串到正则表达式过程的转义

从输入的字符串到正则表达式, 其实有两步转换过程, 分别是 *字符串转义* 和 *正则转义*.

例如: 在正则中正确表示反斜杠时, 具体的过程是这样子:

1. 我们输入的字符串, 四个反斜杠 `\\\\`, 经过 *字符串转义*, 它代表的含义是两个反斜杠 `\\`
2. 这两个反斜杠再经过 *正则转义*, 它就可以代表单个反斜杠 `\` 了.

### 元字符转义

如果现在我们要查找比如星号 `*`, 加号 `+`, 问号 `?` 本身, 而不是元字符的功能, 这时候就需要对其进行转义, 直接在前面加上反斜杠就可以了.

在正则中方括号 `[]` 和花括号 `{}` 只需转义开括号, 但圆括号 `()` 两个都要转义.

- `\*`
- `\+`
- `\?`
- `\\d`
- `\\w`

根据转义序列的定义, `\d` 是由转义字符 `\` 和 `d` 组成的, 且该序列已经具有不同于该字符序列单独出现时的语义, 因此 `\d` 已经是一个转义序列了, 如果我们想要表示 `\` 之后有一个 `d` 的话, 我们需要再次转义, 即 `\\d`

### 字符组中的转义

字符组里只有三种情况需要转义

- 脱字符在中括号中, 且在第一个位置需要转义: `[\^ab]`
- 中划线在中括号中, 且不在首尾位置: `[a\-c]`
- 右括号在中括号中, 且不在首位: `[a\]b]`

## 正则引擎

正则之所以能够处理复杂文本, 就是因为采用了有穷状态自动机 (*finite automaton*).

有穷状态是指一个系统具有有限个状态, 不同的状态代表不同的意义.

自动机是指系统可以根据相应的条件, 在不同的状态下进行转移. 从一个初始状态, 根据对应的操作 (比如录入的字符集) 执行状态转移, 最终达到终止状态 (可能有一到多个终止状态).

有穷自动机的具体实现称为正则引擎, 主要有 DFA 和 NFA 两种, 其中 NFA 又分为传统的 NFA 和 POSIX NFA:

- *DFA*: 确定性有穷自动机 (`Deterministic finite automaton`), 先看文本, 再看正则表达式, 是以文本为主导的.
- *NFA*: 非确定性有穷自动机 (`Non-deterministic finite automaton`), 先看正则, 再看文本, 而且以正则为主导.
    - 传统的 NFA
    - POSIX NFA

### NFA 与 DFA 匹配的过程

```txt
str: we_live_in_shenzhen
regex: in_(beijing|shenzhen|shanghai)
```

#### NFA 引擎匹配过程

NFA 引擎的工作方式是, 先看正则, 再看文本, 而且以正则为主导.

正则中的第一个字符是 `i`, NFA 引擎在字符串中查找 `i`, 接着匹配其后是否为 `n`, 如果是 `n` 则继续, 这样一直找到 `in_`.

```txt
regex: in_(beijing|shenzhen|shanghai)
       ^
text: we_live_in_shenzhen
      ^
```

```txt
regex: in_(beijing|shenzhen|shanghai)
         ^
text: we_live_in_shenzhen
                ^
```

我们再根据正则看文本后面是不是 `s`, 发现不是, 此时 `beijing` 分支淘汰.

```txt
regex: in_(beijing|shenzhen|shanghai)
           ^
         淘汰此分支(beijing)
str: we_live_in_shenzhen
                ^
```

我们接着看其它的分支, 看文本部分是不是 `s`, 直到 `shenzhen` 整个匹配上. `shenzhen` 在匹配过程中如果不失败, 就不会看后面的 `shanghai` 分支. 当匹配上了 `shenzhen` 后, 整个文本匹配完毕, 也不会再看 `shanghai` 分支.

假设这里文本改一下, 把 `we_live_in_shenzhen` 变成 `we_live_in_shanghai`, 正则 `shenzhen` 的 `e` 匹配不上字符串 `shanghai` 的 `a` 时, 会接着使用正则 `shanghai` 来进行匹配, 重新从 `s` 开始 (NFA 引擎会记住这里).

```txt
第二个分支匹配失败
regex: in_(beijing|shenzhen|shanghai)
                     ^
                  淘汰此分支(正则 e 匹配不上文本 a)
str: we_live_in_shanghai
                  ^
再次尝试第三个分支
regex: in_(beijing|shenzhen|shanghai)
                            ^
str: we_live_in_shanghai
                ^
```

也就是说,  NFA 是以正则为主导, 反复测试字符串, 这样字符串中同一部分, 有可能被反复测试很多次.

#### DFA 引擎匹配过程

而 DFA 不是这样的, DFA 会先看文本, 再看正则表达式, 是以文本为主导的.

在具体匹配过程中, DFA 会从 `we` 中的 `w` 开始依次查找到 `i`, 定位到 `i`, 这个字符后面是 `n`. 所以我们接着看正则部分是否有 `n`, 如果正则后面是个 `n`, 那就以同样的方式, 匹配到后面的 `_`.

```txt
str: we_live_in_shenzhen
     ^
regex: in_(beijing|shenzhen|shanghai)
       ^
```

```txt
str: we_live_in_shenzhen
               ^
regex: in_(beijing|shenzhen|shanghai)
         ^
```

继续进行匹配, 文本 `_` 后面是字符 `s`, DFA 接着看正则表达式部分, 此时 `beijing` 分支被淘汰, 开头是 `s` 的分支 `shenzhen` 和 `shanghai` 符合要求.

```txt
str: we_live_in_shenzhen
                ^
regex: in_(beijing|shenzhen|shanghai)
           ^       ^        ^
          淘汰    符合     符合
```

然后 DFA 依次检查字符串, 检测到 `shenzhen` 中的 `e` 时, 只有 `shenzhen` 分支符合, 淘汰 `shanghai`, 接着看分别文本后面的 `nzhen`, 和正则比较, 匹配成功.

```txt
str: we_live_in_shenzhen
                  ^
regex: in_(beijing|shenzhen|shanghai)
                     ^        ^
                    符合     淘汰
```

从这个示例你可以看到, DFA 和 NFA 两种引擎的工作方式完全不同.

- NFA 是以表达式为主导的, 先看正则表达式, 再看文本.
- 而 DFA 则是以文本为主导, 先看文本, 再看正则表达式.

一般来说, DFA 引擎会更快一些, 因为整个匹配过程中, 字符串只看一遍, 不会发生回溯, 相同的字符不会被测试两次. 也就是说 DFA 引擎执行的时间一般是线性的. DFA 引擎可以确保匹配到可能的最长字符串. 但由于 DFA 引擎只包含有限的状态, 所以它没有反向引用功能, 它也不支持捕获子组.

NFA 以表达式为主导, 它的引擎是使用 贪心匹配回溯算法实现. NFA 通过构造特定扩展, 支持子组和反向引用. 但由于 NFA 引擎会发生回溯, 即它会对字符串中的同一部分, 进行很多次对比. 因此, 在最坏情况下, 它的执行速度可能非常慢.

#### POSIX NFA 与 传统 NFA 区别

因为传统的 NFA 引擎 **急于** 报告匹配结果, 找到第一个匹配上的就返回了, 所以可能会导致还有更长的匹配未被发现. 比如使用正则 `pos|posix` 在文本 `posix` 中进行匹配, 传统的 NFA 从文本中找到的是 `pos`, 而不是 `posix`, 而 POSIX NFA 找到的是 `posix`.

POSIX NFA 的应用很少, 主要是 Unix/Linux 中的某些工具. POSIX NFA 引擎与传统的 NFA 引擎类似, 但不同之处在于, POSIX NFA 在找到可能的最长匹配之前会继续回溯, 也就是说它会尽可能找最长的, 如果分支一样长, 以最左边的为准 (The Longest-Leftmost). 因此, POSIX NFA 引擎的速度要慢于传统的 NFA 引擎.

我们日常面对的, 一般都是传统的 NFA, 所以通常都是 最左侧 的分支优先, 在书写正则的时候务必要注意这一点.

下面是 DFA, 传统 NFA 以及 POSIX NFA 引擎的特点总结:

| 引擎类型     | 程序                                                                                    | 懒惰模式 | 捕获型括号 | 回溯     |
|--------------|-----------------------------------------------------------------------------------------|----------|------------|----------|
| DFA          | Go, MySQL, awk, egrep, flex, lex, Procmail                                              | 不支持   | 不支持     | 不支持   |
| NFA          | PCRE library, Perl, PHP, Java, Python, Ruby, grep, GNU Emacs, less, more, .NET, sed, vi | 支持     | 支持       | 支持     |
| POSIX NFA    | mawk, GNU Emacs(明确指定时使用)                                                         | 不支持   | 不支持     | 支持     |
| DFA/NFA 混合 | GNU awk, GNU grep, GNU egrep, Tcl                                                       | 支持     | 支持       | NFA 支持 |

### 正则引擎的回溯

回溯是 NFA 引擎才有的, 并且只有在正则中出现 **量词** 或 **多选分支结构** 时, 才可能会发生回溯.

比如我们使用正则 `a+ab` 来匹配文本 `aab` 的时候, 过程是这样的:

1. `a+` 是贪婪匹配, 会占用掉文本中的两个 `a`

2. 但正则接着又是 `a`, 文本部分只剩下 `b`, 只能通过回溯, 让 `a+` 吐出一个 `a`, 再次尝试.
如果正则是使用 `.*ab` 去匹配一行比较长的字符串就更糟糕了, 因为 `.*` 会吃掉整行字符串, 然后, 你会发现正则中还有 `ab` 没匹配到内容, 只能将 `.*` 匹配上的字符串吐出一个字符, 再尝试, 还不行, 再吐出一个, 逐次不断尝试.

```txt
The lab assistant was wearing a white overall.
                                             ^
The lab assistant was wearing a white overall.
                                            ^
The lab assistant was wearing a white overall.
                                           ^
The lab assistant was wearing a white overall.
                                          ^
中间过程省略, 一直回溯到 l, 发现 l 后面的 ab 可以匹配上, 停止回溯, 匹配成功

The lab assistant was wearing a white overall.
    ^
```

所以在工作中, 我们要尽量不用 `.*`, 除非真的有必要, 因为点能匹配的范围太广了, 我们要尽可能精确. 常见的解决方式有两种, 比如要提取引号中的内容时:

- 使用 `"[^"]+"`
- 或者使用非贪婪的方式 `".+?"`, 来减少匹配上的内容不断吐出, 再次尝试的过程.

## 正则匹配中文字符

| 区域                   | 范围(十六进制) | 注释                                 |
| :--------------------- | :------------- | :----------------------------------- |
| CJK 统一表意符         | 4E00–9FFF      | 常见                                 |
| CJK 统一表意符  扩展 A | 3400–4DBF      | 罕见                                 |
| CJK 统一表意符  扩展 B | 20000–2A6DF    | 罕见, 历史上用过                     |
| CJK 统一表意符  扩展 C | 2A700–2B73F    | 罕见, 历史上用过                     |
| CJK 统一表意符  扩展 D | 2B740–2B81F    | 不常见, 某些仍在使用                 |
| CJK 统一表意符  扩展 E | 2B820–2CEAF    | 罕见, 历史上用过                     |
| CJK 统一表意符  扩展 F | 2CEB0–2EBEF    | 罕见, 历史上用过                     |
| CJK 统一表意符  扩展 G | 30000–3134F    | 罕见, 历史上用过                     |
| CJK 兼容表意符         | F900–FAFF      | 重复字,可统一的变体,公司内部定义用字 |
| CJK 兼容表意符 补充    | 2F800–2FA1F    | 可以统一的变体                       |

所以, 如果要匹配常用汉字, 可以指定编码范围为 `4E00~9FFF`. 如果要包括所有汉字 (包括中日韩统一表意符及其扩展), 应该联用以上所有范围或根据需要选择, 也可以用 Unicode 的语言 Script 来判断, 如 `\p{Han}` / `\p{IsHan}`

## 常用正则实例

- `[\x{4e00}-\x{9fa5}]`: 匹配中文字符
- `[^\x00-\xff]`: 匹配双字节字符(包含汉字)
- `\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*`: 匹配 email 地址
- `(\w+\.)*\w+@(\w+\.)+[A-Za-z]+`: 匹配 email 地址
- `[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+`: 匹配 email 地址
- `[a-zA-z]+://[^\s]*`: 匹配网址 url
- `https?://[-\w.]+(:\d+)?(/([\w/_.]*)?)?`: URL 地址
- `https?://(\w*:\w*@)?[-\w.]+(:\d+)?(/([\w/_.]*(\?\S+)?)?)?`: 完整的 URL 地址
- `[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+\.?`: 匹配域名
- `[a-zA-Z][a-zA-Z0-9_]{4,15}`: 匹配帐号是否合法(字母开头, 允许5-16字节, 允许字母数字下划线)
- `[a-zA-Z]\w{5,17}`: 密码 (以字母开头, 长度在 6~18 之间, 只能包含字母, 数字和下划线)
- `(?=.*\d)(?=.*[a-z])(?=.*[A-Z])[a-zA-Z0-9]{8,10}`: 强密码 (必须包含大小写字母和数字的组合, 不能使用特殊字符, 长度在 8-10 之间)
- `(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,10}`: 强密码 (必须包含大小写字母和数字的组合, 可以使用特殊字符, 长度在 8-10 之间)
- `\d{3}-\d{8}|\d{4}-\{7,8}`: 匹配国内电话号码
- `\d{4}-\d{1,2}-\d{1,2}`: 日期(1995-08-01)
- `\d{4}-(1[0-2]|0?[1-9])-([12]\d|3[01]|0?[1-9])`: 日期(1995-08-01)
- `(\(\d{3,4}-)|\d{3.4}-)?\d{7,8}`: 匹配电话("xxx-xxxxxxx", "xxxx-xxxxxxxx", "xxx-xxxxxxx", "xxx-xxxxxxxx", "xxxxxxx"和"xxxxxxxx)
- `(13[0-9]|14[5|7]|15[0|1|2|3|4|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}`: 匹配手机号
- `1[3-9]\d{9}`: 只限制前两位的手机号
- `1(?:3\d|4[5-9]|5[0-35-9]|6[2567]|7[0-8]|8\d|9[1389])\d{8}`: 限制前三位的手机号
- `[1-9][0-9]{4,9}`: 匹配腾讯QQ号
- `(?<!\d)[1-9]\d{5}(?!\d)`: 匹配中国邮政编码
- `(\d{6})(\d{4})(\d{2})(\d{2})(\d{3})([0-9]|X)`: 匹配身份证
- `[1-8]\d{5}((18)|(19)|(20))?\d{2}[0-1]\d[0-3]\d{4}[\dx]?`: 匹配身份证
- `[1-9]\d{14}(\d\d[0-9Xx])?`: 匹配身份证
- `<(\S*?)[^>]*>.*?|<.*? />`: HTML 标记的正则表达式
- `([a-zA-Z]+-?)+[a-zA-Z0-9]+\\.[x|X][m|M][l|L]`: XML 文件
- `\d+\.\d+\.\d+\.\d+`: 匹配 IP 地址
- `(((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))\.){3}((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))`: 匹配 IP 地址
- `<!-{2,}.*?-{2,}>`: html 注释, like `<!-- Start of page -->`
- `5[1-5]\d{14}`: 信用卡号码
- `[1-9]\d*`: 匹配正整数
- `-[1-9]\d*`: 匹配负整数
- `-?[1-9]\d*`: 匹配整数
- `[1-9]\d*|0`: 匹配非负整数（正整数 + 0）
- `-[1-9]\d*|0`: 匹配非正整数（负整数 + 0）
- `\+?(\d+(\.\d+)?|\.\d+)`: 匹配正浮点数
- `-\d+(\.\d+)+`: 匹配负浮点数
- `-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)`: 匹配浮点数
- `[1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0`: 匹配非负浮点数（正浮点数 + 0）
- `(-([1-9]\d*\.\d*|0\.\d*[1-9]\d*))|0?\.0+|0`: 匹配非正浮点数（负浮点数 + 0）
- `[-+]?\d+(?:\.\d+)?`: 匹配正数负数和小数
- `[ ]+(\w+)[ ]+\1`: 匹配同一个单词的连续两次重复出现
- `"[^"]+"`: 匹配引号内的字符串
- `\$\d+(\.\d\d)?`: 匹配美元金额
- `[0-9A-Fa-f]+`: 匹配十六进制数

## Ref

- [GNU BRE Syntax](https://www.gnu.org/software/sed/manual/html_node/BRE-syntax.html)
- [GNU ERE Syntax](https://www.gnu.org/software/sed/manual/html_node/ERE-syntax.html#ERE-syntax)
- [GNU BRE vs GNU ERE](https://www.gnu.org/software/sed/manual/html_node/BRE-vs-ERE.html#BRE-vs-ERE)
- [GNU regexp extensions](https://www.gnu.org/software/sed/manual/html_node/regexp-extensions.html#regexp-extensions)
- [Perl regex syntax](https://perldoc.perl.org/perlre)
- [PCRE2 man](http://www.pcre.org/current/doc/html/)
- [regular expression unicode block](https://www.regular-expressions.info/unicode.html)
- [正则表达式入门](https://zq99299.github.io/note-book/regular/)
- <精通正则表达式 第三版 - Jeffrey E.F.Friedl>
- [regex101.com](https://regex101.com/)