---
title: 神级编辑器 Vim 使用-正则替换篇
date: 2021-01-15
comments: true
path: usage-of-vim-editor-regex
categories: Terminal
updated:
tags: ⦿vim, ⦿regex, ⦿tool
---

Vim 的替换查找是其核心功能, 功能极其强大, 通过其规则匹配, 可以很快速地完成我们很多需要大量人力操作的工作, 而且可对多文件使用查找/替换功能.

![himg](https://a.hanleylee.com/HKMS/2020-01-09-vim8.png?x-oss-process=style/WaMa)

<!-- more -->

本系列教程共分为以下五个部分:

1. [神级编辑器 Vim 使用-基础篇](https://www.hanleylee.com/usage-of-vim-editor-basic.html) <!-- ./blog_usage_of_vim_basic.md -->
2. [神级编辑器 Vim 使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html) <!-- ./blog_usage_of_vim_operation.md -->
3. [神级编辑器 Vim 使用-插件篇](https://www.hanleylee.com/usage-of-vim-editor-plugin.html) <!-- ./blog_usage_of_vim_plugin.md -->
4. [神级编辑器 Vim 使用-正则操作篇](https://www.hanleylee.com/usage-of-vim-editor-regex.html) <!-- ./blog_usage_of_vim_regex.md -->
5. [神级编辑器 Vim 使用-最后](https://www.hanleylee.com/usage-of-vim-editor-last.html) <!-- ./blog_usage_of_vim_final.md -->

## 正则匹配的模式

编程界实现了多种正则匹配引擎, vim 的正则匹配引擎是独有的, 其风格类似于 `POSIX BRE`, 但是我们可通过将其匹配模式设为:

- `\v`: very magic 模式; 此模式下 `(` 已经被转义, 如果要搜索 `(`, 必须转回原义: `\(`(此模式实际上最接近 Perl 的正则)
- `\V`: very nomagic 原义模式; 此模式下直接搜索`(` 即可搜索到 `(`
- `\m`: magic 模式, 默认, 不指定任何模式时使用的就是此模式. 此模式下仅部分字符有特殊含义, `(` 没有被转义, 仍然可通过 `(` 搜索到 `(`
- `\M`: nomagic 模式; 其功能类似于 `\V` 原义开关, 不同的是, 一些字符会自动具有特殊含义, 即符号 `^` 与 `$`

其实, very magic 和 very nomagic 搜索模式分别是 Vim 对正则表达式特殊字符的两种极端处理方式. 一个通用的原则是: **如果想按正则表达式查找, 就用模式开关 \v, 如果想按原义查找文本, 就用原义开关 \V**

本文只讨论默认模式下(`\m` 模式)下的正则匹配, 其他模式下的原理类似, 读者可自行研究

## 元字符

完整的正则表达式由两种字符构成:

- 元字符(metacharacters): 特殊字符 (special characters, 例如文件名例子中的 `*`)
- 文字(literal): 即普通文本字符 (normal text characters).

### 字符 / 字符组

- `.`: 表示匹配任意 **一个** 字符. 例: `c..l` 表示任意以 c 开头, 中间有两个任意字符, l 结尾的字段.
- `.*`: 表示匹配 **任意多个** 字符. 例: `c.*l` 表示任意以 c 开头 l 结尾的字段(不会将一个字段进行跨行处理, 因此非常智能, 很频繁使用)
- `\_.*`: 表示匹配 **任意多个** 字符(包括换行符!)
- `[adz]`: 匹配 `a`, `d`, `z` 中的任意 **一个**, 括号内也可是数字, 如 `[2-5]` 表示匹配 `2`, `3`, `4`, `5` 中的任意一个数字
- `[^a]`: 匹配除 `a` 以外的任意 **字符**
- `[a-c]`: 匹配 `a`, `b`, `c` 中的任意一个, 递增的顺序
- `\%[]`: a sequence of optionally matched atoms
- `\o`: 匹配八进制数字外的任意一个字符, 等同于 `[0-7]`
- `\O`: 匹配除八进制数字外的任意一个字符, 等同于 `[^0-7]`
- `\d`: 匹配十进制数字中的任意一个, 等同于 `[0-9]`
- `\D`: 匹配除十进制数字外的任意一个字符, 等同于 `[^0-9]`
- `\x`: 匹配十六进制数字中的任意一个, 等同于 `[0-9A-Fa-f]`
- `\X`: 匹配除十六进制数字外的任意一个字符, 等同于 `[^0-9A-Fa-f]`
- `\1`: back-referencing
- `\h`: head of word character(`a,b,c...z,A,B,C...Z,_`), 等同于 `[a-zA-Z_]`
- `\H`: non-head of word character, 等同于 `[^a-zA-Z_]`
- `\a`: alphabetical character, 等同于 `[a-zA-Z]`
- `\A`: non-alphabetical character, 等同于 `[^a-zA-Z]`
- `\l`: lowercase character
- `\L`: non-lowercase character
- `\u`: uppercase character
- `\U`: non-uppercase character
- `\i`: identifier character
- `\I`: like "\i", but excluding digits
- `\k`: keyword character
- `\K`: like "\k": but excluding digits
- `\f`: file name character
- `\F`: like "\f", but excluding digits
- `\p`: match printable character
- `\p`: like "\p", but excluding digits
- `\w`: 匹配一个单词字符, 等同于 `[a-zA-Z0-9_]`(对中文来说非常鸡肋)
- `\W`: 匹配除单词字符外的所有字符, 等同于 `[^\w]`. 因为在 vim 中中文全部不被认为是单词, 因此, 此匹配会选中所有中文字段.
- `\v`: 匹配一个垂直制表符
- `\t`: 代表制表符 tab , 可使用此方法将所有 tab 替换为空格
- `\s`: 配空白字段, 包含 tab 与空格, 等同于 `[\t\n\f\r\p{Z}]`; 在 pattern 中使用此查找空白, 在 string 中就可以直接使用空格或者 tab 来输入以替换了
- `\S`: 匹配非空白字段, 等同于 `[^\s]`
- `\n`: match an `<EOL>`; When matching in a string insead of buffer text a literal newline(Line Feed = `Ctrl-J` = `^J`, ASCII value is 10) character is matched
- `\r`: newline different from `<EOL>`:
    - `<CR>` if `<EOL>` = `<CR><LF>` | `<LF>`
    - `<LF>` if `<EOL>` = `<CR>`
- `\e`: match `<ESC>`
- `\b`: match `<BS>`
- `\_x`: where *x* is any of the character above: character class with end-of-line included
- `\_s`: 匹配换行或空白(空格或 tab)
- `\_.`: 匹配任何字符(包括换行)
- `\_a`: 匹配换行或单词(因为是单词, vim 不会匹配中文)
- `/\%dnnn`: match specified **decimal character**(eg `/\%d123`)
- `/\%onnn`: match **octal character**(eg`/\%o053` will match char `+` which ascii code is `43`)
- `/\%xnn` / `/\%Xnn`: match **hex character**, point range is `00~FF, aka 00~255`(eg `/\%x2a`)
- `/\%unnnn`: match **multibyte character**, point range is `0000~FFFF, aka 0~65535`(eg `/\%u20ac`)
- `/\%Unnnnnnnn`: match **large multibyte character**, point range is `00000000~7FFFFFFFF, aka 65536~2147483647`(eg `/\%U12345678`)
- `/\%C`: match any composing characters

### 量词 multi

- `*`: 表示其前字符可以重复 *0~无数* 次. 如 `/be*` 会匹配到 `b`, `be`, `bee` ..., 因为 e 重复零次就是没有, 所以会返回 b, **greedy**
- `\+`: 表示其前字符必须重复 1~无数 次, 如 `/be\+` 会匹配到 `be`, `bee`, `beee` ..., **greedy**
- `\?` 或 `\=`: 代表其前字符必须重复 0 或者 1 次, **greedy**
- `\{n,m}`: 其前字符必须重复 n 到 m 次, **greedy**. (`\{n,}` 表示右边界范围为无限, `{,m}` 表示左边界范围为0)
- `{n}`: n, **exactly**
- `{n,}`: at least n, **greedy**
- `{,m}`: 0 to m, **greedy**
- `{}`: 0 or more, **greedy**(same as `*`)
- `\{-n,m}`: 其前字符必须重复 n 到 m 次, **lazy**. (`\{-n,}` 表示右边界范围为无限, `{-,m}` 表示左边界范围为0)
- `\{-n}`: n, exactly
- `\{-n,}`: at least n, **lazy**
- `\{-,m}`: 0 to m, **lazy**
- `\{-}`: 与 `*` 相对, `.\{-}` 与 `.*` 一样表示匹配任意多个字符, **lazy**(其实就是 `\{-0,}` 的简写)

### 零长度断言

- `$`: 匹配行尾. 例: `/d.*$` 表示匹配到以 d 开头到行尾中的所有内容, `/123$` 表示以 123 结尾的所有字段
- `^`: 匹配行首. 例: `^.*d` 表示匹配到行首到 d 的所有内容, `/^123` 表示以 123 开头的字段
- `\%^`: beginning of file, zero-width match
- `\%$`: end of file, zero-width match
- `\_^`: the beginning of a line, zero-width
- `\_$`: the end of a line, zero-width
- `\zs`: set the beginning of the match, zero-width
- `\ze`: set the end of the match, zero-width
- `\<`: beginning of word, zero-width
- `\>`: end of word, zero-width
- `\%V`: inside visual area, zero-width
- `\%#`: cursor position, zero-width
- `\%'m'`: matches with the position of mark m, zero-width
- `\%<'m'`: matches before the position of mark m, zero-width
- `\%>'m'`: matches after the position of mark m, zero-width
- `\%l`: matches in a specific line, e.g. `/\%23l` / `/\%.l`, zero-width
- `\%<l`: matches above a line(lower line number), e.g. `/\%<23l`, `/\%<.l`, zero-width
- `\%>l`: matches below a line(lower line number), e.g. `/\%>23l`, `/\%>.l`, zero-width
- `\%c`: matches at the column e.g. `/\%23c`, zero-width
- `\%<c`: matches before the cursor column, e.g. `/\%<23c`, zero-width
- `\%>c`: matches before the cursor column, e.g. `/\%>23c`, zero-width
- `\%v`: matches at virtual column e.g. `/\%23v`, zero-width
- `\%<v`: matches before virtual column e.g. `/\%<23v`, zero-width
- `\%>v`: matches after virtual column e.g. `/\%>23v`, zero-width
- `\@=`: 正先行断言, 其右存在 Y 的 X, `X\(Y\)\@=`
- `\@!`: 负先行断言, 其右不存在 Y 的 X, `X\(Y\)\@!`
- `\@<=`: 正后发断言, 其左存在 Y 的 X, `\(Y\)\@<=X`
- `\@<!`: 负后发断言, 其左不存在 Y 的 X, `\(Y\)\@<!X`

### 分组与捕获

- `\(\)`: grouping, catching
- `\%\(\)`: grouping, but not catching
- `\|`: 或的意思, 表示只要符合其前或其后任意一个字符即可. 例: `/one\|two\|three` 表示匹配 one, two, three 中的任意一个. `end\(if\|while\|for\)` 表示会查找到 endif, endwhile, endfor 中的任意一个.
- `~`: matches the last given substitute string
- `\1`: 匹配到的第一个 `\(...\)`
- `\2`: 匹配到的第二个 `\(...\)`
- `&`: 它代表与搜索模式想匹配的整个文本, 即重现搜索串. 这在试图避免重复输入文本时很有用(for substitute)
- `\0`: 同 `&`(for substitute)

### Modifier

- `\m`: 'magic' on for the following chars in the pattern
- `\M`: 'magic' off for the following chars in the pattern
- `\v`: the following chars in the pattern are "very magic"
- `\V`: the following chars in the pattern are "very no magic"
- `\%#=`: select regexp engine, zero-width
- `\C`: 区分大小写地查找或替换, 例: `/\CText` 表示只会查找`Text`, 不会查找 `text` 或 `tExt` 等
- `\c`: 不区分大小写地查找替换(已经在 vim 中设置了默认不区分了)
- `\l`: next character made lowercase(for substitute)
- `\u`: next character made uppercase(for substitute)
- `\U`: 将跟在后面的匹配串全部变成大写, 直至 `\E`(for substitute)
- `\L`: 将跟在后面的匹配串全部变成小写, 直至 `\E`(for substitute)
- `\E` / `\e`: end of `\U` and `\L`(for substitute)

### POSIX

除了 [正则表达式学习](https://www.hanleylee.com/learning-regular-expression.html#POSIX-字符类) 中列出的 12 种字符类, vim 还支持以下字符类

<!-- $HKMS/dev/basic/blog_regular_expression.md -->

| Pattern         | Description     | Example                             |
|-----------------|-----------------|-------------------------------------|
| `[:return:]`    | `[:return:]`    | the `<CR>` character                |
| `[:tab:]`       | `[:tab:]`       | the `<Tab>` character               |
| `[:escape:]`    | `[:escape:]`    | the `<Esc>` character               |
| `[:backspace:]` | `[:backspace:]` | the `<BS>` character                |
| `[:ident:]`     | `[:ident:]`     | identifier character (same as "\i") |
| `[:keyword:]`   | `[:keyword:]`   | keyword character (same as "\k")    |
| `[:fname:]`     | `[:fname:]`     | file name character (same as "\f")  |

### 转义

如上所述, `.`, `*`, `[`, `]`, `^`, `%`, `/`, `?`, `~`, `$` 等字符有特殊含义, 如果对这些进行匹配, 需要考虑添加转义字符 `\` 进行转义

> - inside a single quoted string two single quotes `''` represent one single quote `'`.

## 查找

### 查找逻辑

**`/pattern/[offset]`**

### Search offset

- `[num]`: `num` line downwards, in column 1
- `+[num]`: `num` line downwards, in column 1
- `-[num]`: `num` line upwards, in column 1
- `e[+num]`: `num` characters to the right of the *end* of the match, in column 1
- `e[-num]`: `num` characters to the left of the *end* of the match, in column 1
- `s[+num]`: `num` characters to the rigth of the *start* of the match, in column 1
- `s[-num]`: `num` characters to the left of the *start* of the match, in column 1
- `b[+num]`: same as `s[+num]`
- `b[-num]`: same as `s[-num]`

### 查找实例

- `/view`: 全文查找 view 关键字 (n 为向下方向)
- `?view`: 全文查找 view 关键字 (n 为向上方向)
- `/\cview`: 全文查找 view 关键字(大小写不敏感)
- `:100,235g/foo/#`: 在区间 `100 ~ 235` 搜索, 在控制台输出结果
- `:100,235il foo`: 同上
- `/view/e`: 默认的查找会将光标置于单词首部, 使用 `e` 保证光标位于尾部, 方便 `.` 命令的调用
- `/view/s-2`: cursor set to **start** of match minus 3
- `/view/+3`: find view **move** cursor 3 lines down
- `/^joe.*fred.*bill/`: find joe **and** bill(joe at start of line)
- `/^[A-J]`: search for lines beginning with one or more `A-J`
- `/begin\_.*end`: search over possible multiple lines
- `/fred\_s*joe`: any whitespace including newline
- `/fred\|joe`: search for fred **or** joe
- `/.*fred\&.*joe`: search for fred **and** joe in any order
- `/\<fred\>/`: search fro fred but not alfred or frederick
- `/\<\d\d\d\d\>`: search for exactly 4 digit numbers
- `/\D\d\d\d\d\D`: search for exactly 4 digit numbers
- `/\<\d\{4}\>`: same thing
- `/\([^0-9]\|^\)%.*%`: search for absence of a digit or beginning of line
- `/^\n\{3}`: find 3 empty lines
- `/^str.*\nstr`: find 2 successive lines starting with str
- `/\(^str.*\n\)\{2}`: find 2 successive lines starting with str
- `/\(fred\).*\(joe\).*\2.*\1`
- `/^\([^,]*,\)\{8}`
- `:vmap // y/<C-R>"<CR>`: search for visually highlighted text
- `:vmap <silent> //    y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR>`: with spec chars
- `/<\zs[^>]*\ze>`: search for tag contents, ignoring chevrons
- `/<\@<=[^>]*>\@=`: search for tag contents, ignoring chevrons
- `/<\@<=\_[^>]*>\@=`: search for tags across possible multiple lines
- `/\%(defg\)\@<!abc`:  anything starting with `abc` that's not (immediately) preceeded by `defg`
- `/\%(defg.*\)\@<!abc`: match `abc` as long as it's not part of `defg.*abc`
- `/\%(defg.*\)\@<!abc \%(.*defg\)\@!`: Matching `abc` only on lines where `defg` doesn't occur is similar
- `/<!--\_p\{-}-->`: search for multiple line comments
- `/fred\_s*joe/`: any whitespace including newline
- `/bugs\(\_.\)*bunny`: bugs followed by bunny anywhere in file
- `/\c\v([^aeiou]&\a){4}`: search for 4 consecutive consonants
- `/\%>20l\%<30lgoat`: search for goat between lines 20 and 30
- `/^.\{-}home.\{-}\zshome/e`: match only the 2nd occurence in a line of home
- `/^\(.*tongue.*\)\@!.*nose.*$`
- `\v^((tongue)@!.)*nose((tongue)@!.)*$`
- `.*nose.*\&^\%(\%(tongue\)\@!.\)*$`
- `:v/tongue/s/nose/&/gic`
- `'a,'bs/extrascost//gc`: trick: restrict search to between markers
- `/integ<C-L>`: Control-L to complete term
- `//e`: 匹配 `pattern` 为空则直接重用上次的逻辑进行查找
- `/\<f\>`: 使用 `<` 与 `>` 限定词首与词尾, 保证只查找单词 `f`
- `/^\n\{3}`: 查找三个空行
- `/\s\{2,}`: 查找 2 个以上的空格
- `/he\zsllo`: 查找 `hello` 并将 `llo` 作为匹配点进行高亮
- `/abc\(defg\)\@!`: 只查找 `abc`, 且后面不跟随 `defg`, 否则不匹配, `\@!` 表示 `negative look-ahead assertion`, 查看帮助 `help \@!`
- `/printer_\@!`: find any `printer` that is not followed by an `_`
- `/_\@<!printer`: find any `printer` that is not begin with an `_`
- `` `[^`]\_.\{-0,}` ``: 以 <code>&#96;</code> 开头, 以 <code>&#96;</code> 结尾, 且中间内容超过一个字符, 且内容可以跨行
- `/\%d123`: 查找 unicode 字符点为 20 的字符(20 为十六进制, 对应十进制为 32, 起 ASCII 值为 `SP`, 也就是空格)
- `/\%x2a`
- `/\%o040`
- `/\%u20`: 查找 unicode 字符点为 20 的字符(20 为十六进制, 对应十进制为 32, 起 ASCII 值为 `SP`, 也就是空格)
- `/\%u6c60`: 查找 unicode 字符点为 6c60 的字符
- `/\%U65536`: 查找 unicode 字符点为 65536 的字符

还有一种是使用 `global` 命令: `:g/pattern/d` , 含义是对 patter 进行匹配搜索, 然后执行命令 `delete`, 也是基于查找的

### 查找时的常用操作

- `:noh`: 取消查找模式的高亮匹配
- `*`: 全文查找当前光标处单词 (n 为向下方向)
- `#`: 全文查找当前光标处单词 (n 为向上方向)
- `n`: 下一个列出的关键字
- `N`: 上一个列出的关键字
- `gn`: 进入面向字符的可视模式, 并选中下一项匹配
- `gN`: 进入面向字符的可视模式, 并选中上一项匹配
- `gUgn`: 使下一处匹配改为大写
- `<C-r><C-w>`: 根据当前查找模式下已经输入的内容结合全文进行自动补全
- `/<UP>`: 直接调用上次的查找逻辑.
- `/<DOWN>`: 直接调用下次的查找逻辑.
- `/<C-n>`: 直接调用下次的查找逻辑.
- `/<C-p>`: 直接调用上次的查找逻辑.
- `/<C-r>/`: 使用寄存器 `/` 将上次查找的值直接插入到当前模式中来

## 替换

### 替换逻辑

**`:[range]s/pattern/string/flags`**

- `range`: 范围
    - `无`: 默认光标所在的行
    - `.`: 光标所在的当前行
    - `N`: 第 N 行
    - `$`: 最后一行
    - `'a`: 标记 `a` 所在的行(使用 `ma` 标记的)
    - `.+1`: 当前光标的下面一行
    - `$-1`: 倒数第二行
    - `22,23`: 第22 ~ 23行
    - `1,$`: 第一行到最后一行
    - `1,.`: 第一行到当前行
    - `.,$`: 当前行到最后一行
    - `'a, 'b`: 标记 `a` 所在的行到 标记 `b` 所在的行
    - `%`: 所有行(与 `1,$` 等价)
    - `?str?`: 从当前位置向上搜索, 找到的第一个 str 所在的行(str 可以为正则表达式)
    - `/str/`: 从当前位置向下搜索, 找到的第一个 str 所在的行
    - `1,7` 指第一行至第七行. 也可以使用 `%` 代表当前的文章(也可以理解为全部的行), `#` 代表前一次编辑的文章(基本不用)
- `s`: 代表当前的模式为替换
- `/`: 作为分隔符, 如果确实要替换文中的 `/`, 那么可以使用 `#` 代替作为分隔符. 例如 `:s#vi/#vim#g`, 代表替换 `vi/` 为 `vim`, 常用的分隔符还有 `:`, `_`, `|`
- `pattern`: 要被替换掉的字符
- `string`: 将要使用的字符
- `flags`
    - `无`: 只对指定范围内的每一行的第一个匹配项进行替换
    - `g`: global, 整行替换(基本上是必加的, 否则只会替换每一行的第一个符合字符)
    - `c`: confirm, 每次替换前会询问
    - `e`: ignore, 忽略错误(默认找不到会提示 `pattern not found`, 但是如果设置 vim 设置批量替换命令的话某一个项未匹配到不能影响到下一项的执行, 可以使用此关键字, `:silent %s/x/y/g` == `:%s/x/y/ge` )
    - `i`: ignore, 不区分大小写
    - `I`: 区分大小写

### 变量替换

在表达式中可以使用 `\(` 与 `\)` 将表达式括起来, 然后既可在后面使用 `\1` `\2` 来依次访问由 `\(` 与 `\)` 包围起来的内容.

例: `:s/\(\w\+\)\s\+\(\w\+\)/\2\t\1` 表示将 data1 data2 修改为 data2 data1

### 替换实例

- `r`: 进入单字符替换模式
- `R`: 进入替换模式
- `:&`: 重复上次替换
- `:%&`: last substitute every line
- `:%&gic`: last substitute every line confirm
- `g%`: normal mode repeat last substitute
- `g&`: last substitute on all lines
- `&`:  直接使用 `&` 也是重复上次替换的意思
- `:s/vi/vim/`: 只替换当前行的第一个 vi 为 vim
- `:s/vi/vim/g`: 替换当前行的所有 vi 为 vim
- `:%s/vi/vim/g`: 替换全文所有 vi 为 vim
- `:%s/vi/vim/gi`: 替换全文所有 vi 为 vim, 大小写不敏感
- `:n,$s/vi/vim/gci`: 替换从第 n 行到结尾所有 vi 为 vim, 每次替换提示, 不区分大小写
- `:.,$s/vi/vim/gci`: 替换从当前行到结尾所有 vi 为 vim, 每次替换提示, 不区分大小写
- `:.,+3s/^/#`: 在当前行到下面三行添加 `#` 的注释
- `:g/^\s*$/d`: 删除所有空行
- `:g/^$/d`: 删除所有空行
- `:%s/\s*$//g`: 删除行尾空格
- `:%s/^\s*//g`: 删除行首空格
- `:215,237 s/\(.\)$/\1(自定义)/c`: 将 215 至 237 行尾部添加 `(自定义)`
- `:%s/^\n$//gc/`: 替换多个空行为一个空行
- `:s:\s\+$::`: a simple regexp I use quite often to clean up a text: it drops the blanks at the end of the line.
- `:122,250s/\(201\d*\)\.\(\d*\)\.\(\d*\)\s/\1-\2-\3_/gc`: 替换 `2017.12.31`类型的字段为`2017-12-31_`
- `:%s/\(\](http:.*com\/\)\(HK.*\))/\](https:\/\/a.hanleylee.com\/\2?x-oss-process=style\/WaMa)/gc`: 将`[](http: ....com)` 替换成 https 并且尾部带有样式参数
- `:%s/\(a.*bc\)\(<.*>\)\(xy.*z\)/\3\2\1/gc`: 使用缓冲块实现对前后区域匹配并翻转位置(需要时再理解)
- `:%s/hello/&, world/`: 将会把hello替换成hello, wolrd
- `:%s/.*/(&)/`: 将会把所有行用()包含起来
- `:s/world/\U&/`: 把 world 变成 WORLD
- `:%s ; /user1/tim;/home/time;g`: `/user1/tim`改为`/home/time`, 除了 `/` 字符外, 还可以使用除反斜杆 `\`, 双引号`"`, 和竖直线 `|` 之外的任何非字母表, 非空白字符作为分隔符, 在对路径名进行修改时, 这点尤其便利
- `:s`: 与 `:s//~/`相同, 重复上次替换
- `:%s/\<child\>/children/g`: 保证在 child 是个完整单词的情况下进行替换
- `:g/mg[ira]box/s/box/square/g`: 将 `mgibox routine, mgrbox routine, mgabox routine,` 中的 box 换为 square
- `:%s/fred/joe/igc`: general substitute command
- `:%s//joe/igc`: substitute your last replacement string
- `:%s/~/sue/igc`: substitute your last replacement string
- `:%s/\r//g`: delete DOS return `^M`
- `:%s/\r/\r/g`: turn DOS return `^M` into real returns
- `:%s=  *$==`: delete end of line blanks
- `:%s= \+$==`: Same thing
- `:%s#\s*\r\?$##`: Clean both trailing spaces AND DOS returns
- `:%s#\s*\r*$##`: same thing
- `:%s/^\n\{3}//`: delete blocks of 3 empty lines
- `:%s/^\n\+/\r/`: compressing empty lines
- `:%s#.*\(\d\+hours\).*#\1#`: delete all but memorised string
- `:%s#><\([^/]\)#>\r<\1#g`: split jumbled up XML file into one tag per line [N]
- `:%s/</\r&/g`: simple split of html/xml/soap  [N]
- `:%s#<[^/]#\r&#gic`: simple split of html/xml/soap  but not closing tag [N]
- `:%s#<[^/]#\r&#gi`: parse on open xml tag [N]
- `:%s#\[\d\+\]#\r&#g`: parse on numbered array elements [1] [N]
- `ggVGgJ`: rejoin XML without extra spaces (gJ) [N]
- `:%s=\\n#\d=\r&=g`: parse PHP error stack [N]
- `:%s#^[^\t]\+\t##`: Delete up to and including first tab [N]
- `:'a,'bg/fred/s/dick/joe/igc`: VERY USEFUL
- `:%s= [^ ]\+$=&&=`: duplicate end column
- `:%s= \f\+$=&&=`: Dupicate filename
- `:%s= \S\+$=&&`: usually the same
- `:%s#example#& = &#gic`: duplicate entire matched string [N]
- `:%s#.*\(tbl_\w\+\).*#\1#`: extract list of all strings tbl_* from text  [NC]
- `:s/\(.*\):\(.*\)/\2 : \1/`: reverse fields separated by
- `:%s/^\(.*\)\n\1$/\1/`: delete duplicate lines
- `:%s/^\(.*\)\(\n\1\)\+$/\1/`: delete multiple duplicate lines [N]
- `:%s/^.\{-}pdf/new.pdf/`: delete to 1st occurence of pdf only (lazy)
- `:%s#^.\{-}\([0-9]\{3,4\}serial\)#\1#gic`: delete up to 123serial or 1234serial [N]
- `:%s#\<[zy]\?tbl_[a-z_]\+\>#\L&#gc`: lowercase with optional leading characters
- `:%s/<!--\_.\{-}-->//`: delete possibly multi-line comments
- `:s/fred/<c-r>a/g`: sub "fred" with contents of register "a"
- `:s/fred/<c-r>asome_text<c-r>s/g`
- `:s/fred/\=@a/g`: better alternative as register not displayed
- `:s/fred/\=@*/g`: replace string with contents of paste register
- `:%s/\f\+\.gif\>/\r&\r/g | v/\.gif$/d | %s/gif/jpg/`
- `:%s/a/but/gie|:update|:next`: then use @: to repeat
- `:%s/goat\|cow/sheep/gc`: ORing (must break pipe)
- `:'a,'bs#\[\|\]##g`: remove [] from lines between markers a and b [N]
- `:%s/\v(.*\n){5}/&\r`: insert a blank line every 5 lines [N]
- `:s/__date__/\=strftime("%c")/`: insert datestring
- `:inoremap \zd <C-R>=strftime("%d%b%y")<CR>`: insert date eg 31Jan11 [N]
- `:%s:\(\(\w\+\s\+\)\{2}\)str1:\1str2:`
- `:%s:\(\w\+\)\(.*\s\+\)\(\w\+\)$:\3\2\1:`
- `:%s#\<from\>\|\<where\>\|\<left join\>\|\<\inner join\>#\r&#g`
- `:redir @*|sil exec 'g#<\(input\|select\|textarea\|/\=form\)\>#p'|redir END`
- `:nmap ,z :redir @*<Bar>sil exec 'g@<\(input\<Bar>select\<Bar>textarea\<Bar>/\=form\)\>@p'<Bar>redir END<CR>`
- `:%s/^\(.\{30\}\)xx/\1yy/`: substitute string in column 30 [N]
- `:%s/\d\+/\=(submatch(0)-3)/`: decrement numbers by 3
- `:g/loc\|function/s/\d/\=submatch(0)+6/`: increment numbers by 6 on certain lines only
- `:%s#txtdev\zs\d#\=submatch(0)+1#g`
- `:%s/\(gg\)\@<=\d\+/\=submatch(0)+6/`: increment only numbers gg\d\d  by 6 (another way)
- `:let i=10 | 'a,'bg/Abc/s/yy/\=i/ |let i=i+1`: convert yy to 10,11,12 etc
- `:let i=10 | 'a,'bg/Abc/s/xx\zsyy\ze/\=i/ |let i=i+1` # convert xxyy to xx11,xx12,xx13
- `:%s/"\([^.]\+\).*\zsxx/\1/`
- `:vmap <leader>z :<C-U>%s/\<<c-r>*\>/`
- `:'a,'bs/bucket\(s\)*/bowl\1/gic`
- `:%s,\(all/.*\)\@<=/,_,g`: `replace all / with _ AFTER "all/"`
- `:s#all/\zs.*#\=substitute(submatch(0), '/', '_', 'g')#`
- `:s#all/#&^M#|s#/#_#g|-j!`: Substitute by splitting line, then re-joining
- `:%s/.*/\='cp '.submatch(0).' all/'.substitute(submatch(0),'/','_','g')/`: Substitute inside substitute
- `:%s/home.\{-}\zshome/alone`: substitute only the 2nd occurence of home in any line
- `:%s/.*\zsone/two/`: substitute only the last occurrence of one

替换时系统会对用户进行询问, 有 (`y/n/a/q/1/^E/^Y`)

- `y`: 表示同意当前替换
- `n`: 表示不同意当前 替换
- `a`: 表示替换当前和后面的并且不再确认
- `q`: 表示立即结束替换操作
- `1`: 表示把当前的替换后结束替换操作
- `^E`: 向上滚屏
- `^Y`: 向下滚屏,

## Global

global 语法有两种

1. `:[range]g/{pattern}/[cmd]`: 在 range 内搜索 pattern, 如果符合要求就执行 cmd
2. `:g/pattern1/,/pattern2/[cmd]`: 在 `/p1/`, `p2/` 之间执行 cmd

- `:g/re/d`: 删除所有匹配到 `re` 的行
- `:g/re/p`: 打印所有匹配到 `re` 的行
- `:g//d`: 使用上次的查找结果进行匹配然后删除
- `:g/^$/,/./-j`: reduce multiple blank to a single blank
- `:10,20g/^/ mo 10`: reverse the order of the lines starting from the line 10 up to the line 20.
- `:'a,'b g/^Error/ . w >> errors.txt`: in the text block marked by `'a` and `'b` find all the lines starting with Error and copy (append) them to `errors.txt` file. Note: . (current line address) in front of the `w` is very important, omitting it will cause `:write` to write the whole file to `errors.txt` for every Error line found.
- `:g/^Error:/ copy $ | s /Error/copy of the error/`: will copy all Error line to the end of the file and then make a substitution in the copied line. Without giving the line address `:s` will operate on the current line, which is the newly copied line.
- `:g/^Error:/ s /Error/copy of the error/ | copy $`: here the order is reversed: first modify the string then copy to the end.
- `:v/re/d`: v 是 global 的反面, 等价于 `g!`, 只保留匹配到 `re` 的行
- `:g/TODO/yank A`: 将结果匹配到 `TODO` 的行复制到寄存器 `a` 的原内容尾部
- `:g/TODO/t$`: 将结果匹配到 `TODO` 的行复制到本缓冲区的尾部
- `:g/{/.+1,/}/-1 sort`: 会在每个 `{` 开始找, 然后在之后一直执行到 `}` 为止, 进行排序
- `:g/{/sil.+1,/}/-1 >`: 会在每个 `{` 开始找, 然后在之后一直执行到 `}` 为止, 进行缩进 (加入 sil 是为了屏蔽提示信息)
- `:g/从这里删除/.,$ d`: 从内容中搜出的第一个 `从这里删除` 开始, 一直删除到文章结尾
- `:g/^\(.*\)$\n\1$/d`: 去除重复行
- `:g/\%(^\1$\n\)\@<=\(.*\)$/d`: 去除重复行
- `:g/\%(^\1\>.*$\n\)\@<=\(\k\+\).*$/d`: 去除重复行
- `:g/gladiolli/#`: display with line numbers
- `:g/gred.*joe.*dick/`: display all lines fred, joe & dick
- `:g/\<fred\>/`: display all lines fred but not freddy
- `:g/^\s*$/d`: delete all blank lines
- `:g!/^dd/d`: delete lines not containing pattern
- `:v/^dd/d`: delete lines not containing pattern
- `:g/joe/,/fred/d`: not line based
- `:g/joe/,/fred/j`: join lines
- `:g/-----/.-10,.d`: delete string & 10 previous lines
- `:g/{/ ,/}/- s/\n\+\r/g`: delete empty lines but only between `{...}`
- `:v/\S/d`: delete empty lines
- `:v/./,/./-j`: compress empty lines
- `:g/^$/,/./-j`: compress empty lines
- `:g/<input\|<form/p`:ORing
- `:g/^/put_`: double space file (pu = put)
- `:g/^/m0`: reverse file(m = move)
- `:g/^/m$`: no effect!
- `:'a,'bg/^/m'b`: reverse a section a to b
- `:g/^t.`: duplicate every line
- `:g/fred/t$`: copy(transfer) lines matching fred to EOF
- `:g/stage/t'a`: copy(transfer) lines matching stage to marker a
- `:g/^chapter/t.|s/./-/g`: automatically underline selecting headings
- `:g/\(^I[^^I]*\)\{80}/d`: delete all lines containing at least 80 tabs
- `:g/^/ if line('.')%2|s/^/zz /`: perform a substitute on every other line
- `:'a,'bg/somestr/co/otherstr/`: co(py) or mo(ve)
- `:'a,'bg/str1/s/str1/&&&/|mo/str2/`: as above but also do a substitution
- `:%norm jdd`: delete every other line
- `:.,$g/^\d/exe "norm! \<c-a>"`: increment numbers " incrementing numbers (type `<c-a>` as 5 characters)
- `:'a,'bg/\d\+/norm! ^A`: increment numbers
- `:g/fred/y A`: append all lines fred to register a
- `:g/fred/y A | :let @*=@a`: put into paste buffer
- `:g//y A | :let @*=@a`: put last glob into paste buffer [N]
- `:let @a=''|g/Barratt/y A |:let @*=@a`
- `:'a,'bg/^Error/ . w >> errors.txt`: filter lines to a file (file must already exist)
- `:g/./yank|put|-1s/'/"/g|s/.*/Print '&'/`: duplicate every line in a file wrap a print '' around each duplicate
- `:g/^MARK$/r tmp.txt | -d`: replace string with contents of a file, -d deletes the "mark"
- `:g/<pattern>/z#.5`: display with context
- `:g/<pattern>/z#.5|echo "=========="`: display beautifully
- `:g/|/norm 2f|r*`: replace 2nd | with a star
- `:nmap <F3>  :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR><CR>`
- `:'a,'bg/fred/s/joe/susan/gic`:  can use memory to extend matching
- `:/fred/,/joe/s/fred/joe/gic`:  non-line based (ultra)
- `:/biz/,/any/g/article/s/wheel/bucket/gic`:  non-line based
- `:/fred/;/joe/-2,/sid/+3s/sally/alley/gIC`
- `?Statement?;/StatusLine/s/pattern/replace/g`
- `:g/^/exe ".w ".line(".").".txt"`: create a new file for each line of file eg 1.txt,2.txt,3,txt etc
- `:.g/^/ exe ".!sed 's/N/X/'" | s/I/Q/`: chain an external command
- `:g/^$/;/^$/-1!sort`: Sort each block (note the crucial ;)

## Operate until string found

- `d/fred/`: delete until fred
- `y/fred/`: yank until fred
- `c/fred/e`: change until fred end
- `v12|`: visualise/change/delete to column 12

## 正则相关的 vimscript 方法

- `'a' =~# '\a'`: 匹配返回 1, 不匹配返回 0, 不忽略大小写
- `'a' =~? '\a'`: 同上, 但忽略大小写
- `'a'!~# '\a'`: 匹配返回 0, 不匹配返回 1, 不忽略大小写
- `'a'!~? '\a'`: 同上, 但忽略大小写
- `substitute( {expr}, {pat}, {sub}, {flags})`: 使用 `flags`, 替换 `expr` 里面的 `pat` (即 pattern 表示的正则) 为 `sub`
- `match( {expr}, {pat}[, {start}[, {count}]])`: 返回 `pat` 在 `expr` 里面所匹配的位置, 可设置开始位置和重复次数
- `matchstr({expr}, {pat}[, {start}[, {count}]])`: 返回 `expr` 里面 `pat` 所匹配的字符串, 无匹配返回空字符串
- `matchend( {expr}, {pat}[, {start}[, {count}]])`: 跟 `match` 函数一样, 但是返回最后一个字符的匹配位置
- `matchlist({expr}, {pat}[, {start}[, {count}]])`: 返回匹配的列表, 第一项是完整匹配, 后面是其它子匹配项

## 正则表达式执行顺序

以下由最高优先级至最低进行排列

| Precedence | Regexp              | Description                                                                              |
|------------|---------------------|------------------------------------------------------------------------------------------|
| 1          | `\(pattern\)`       | grouping, capturing                                                                      |
| 2          | `\=,\+,*,\{n}` etc. | quantifiers                                                                              |
| 3          | `abc\t\.\w`         | sequence of characters/ metacharacters, not containing quantifiers or grouping operators |
| 4          | `\|`                | alternation                                                                              |

## 零宽度断言 (前后预查/环视)

| PCRE 正则符号 | vim 正则符号 | 描述                           | PCRE 示例 | vim 示例     |
|---------------|--------------|--------------------------------|-----------|--------------|
| `?=`          | `\@=`        | 正先行断言 - 其右存在 Y 的 X   | `X(?=Y)`  | `X\(Y\)\@=`  |
| `?!`          | `\@!`        | 负先行断言 - 其右不存在 Y 的 X | `X(?!Y)`  | `X\(Y\)\@!`  |
| `?<=`         | `\@<=`       | 正后发断言 - 其左存在 Y 的 X   | `(?<=Y)X` | `\(Y\)\@<=X` |
| `?<!`         | `\@<!`       | 负后发断言 - 其左不存在 Y 的 X | `(?<!Y)X` | `\(Y\)\@<!X` |

先行断言和后发断言都属于 **非捕获簇**(不捕获文本, 也不针对组合计进行计数). 先行断言用于判断所匹配的格式是否在另一个确定格式之前, 匹配结果不包含该确定格式 (仅作为约束).

例如, 我们想要获得所有跟在 `$` 符号后的数字, 我们可以使用正后发断言 `(?<=\$)[0-9\.]*`. 这个表达式匹配 `$` 开头, 之后跟着 `0,1,2,3,4,5,6,7,8,9,.` 这些字符可以出现大于等于 0 次.

### `?=...` 正先行断言

`?=...` 正先行断言, 用于筛选所有匹配结果, 筛选条件为 **其后跟随着断言中定义的格式**. (即第一部分表达式之后必须跟着 `?=...` 定义的表达式)

返回结果只包含满足匹配条件的第一部分表达式. 定义一个正先行断言要使用 `()`. 在括号内部使用一个问号和等号: `(?=...)`. 正先行断言的内容写在括号中的等号后面.

例如, 表达式 `(T|t)he(?=\sfat)` 匹配 `The` 和 `the`, 在括号中我们又定义了正先行断言 `(?=\sfat)`, 即 `The` 和 `the` 后面紧跟着 `\nfat`.

```txt
"(T|t)he(?=\\sfat)" => **The** fat cat sat on the mat.
```

### `?!...` 负先行断言

`?!` 负先行断言, 用于筛选所有匹配结果, 筛选条件为 **其后不跟随着断言中定义的格式**. `负先行断言` 定义和 `正先行断言` 一样, 区别就是 `=` 替换成 `!` 也就是 `(?!...)`.

例如, 表达式 `(T|t)he(?!\sfat)` 匹配 `The` 和 `the`, 且其后不跟着 `\nfat`.

```txt
"(T|t)he(?!\\sfat)" => The fat cat sat on **the** mat.
```

### `?<=...` 正后发断言

正后发断言记作 `(?<=...)` 用于筛选所有匹配结果, 筛选条件为 **其前跟随着断言中定义的格式**.

例如, 表达式 `(?<=(T|t)he\s)(fat|mat)` 匹配 `fat` 和 `mat`, 且其前跟着 `The` 或 `the`.

```txt
"(?<=(T|t)he\\s)(fat|mat)" => The **fat** cat sat on the **mat**.
```

### `?<!...` 负后发断言

负后发断言记作 `(?<!...)` 用于筛选所有匹配结果, 筛选条件为 **其前不跟随着断言中定义的格式**.

例如, 表达式 `(?<!(T|t)he\s)(cat)` 匹配 `cat`, 且其前不跟着 `The` 或 `the`.

```txt
"(?<!(T|t)he\\s)(cat)" => The cat sat on **cat**.
```

## 多文件查找与替换

多文件操作的基础是一定要 **设置好工作目录**, 因为添加文件到操作列表是以当前路径下的文件进行判断筛选的, 设置当前路径可使用以下方式:

- 手动 `:cd path`
- `NERDTree` 插件的 `cd` 命令
- `netrw` 插件的 `cd` 命令
- 在 `.vimrc` 中设置 `set autochair` 自动切换当前工作路径

### 多文件查找

![himg](https://a.hanleylee.com/HKMS/2021-01-21194140.png?x-oss-process=style/WaMa)

#### 逻辑

**`vimgrep /pattern/[g][j] <range>`**

- `vimgrep`: 批量查找命令, 其后可直接加 `!` 代表强制执行. 也可以使用`lvimgrep` , 结果显示在 list 中
- `patten`: 需要查找的内容, 支持正则表达式, 高级用法见元字符
- `g`: 如果一行中有多个匹配是否全部列出
- `j`: 搜索完后直接定位到第一个匹配位置
- `range`: 搜索的文件范围
    - `%`: 在当前文件中查找
    - `**/*.md`: 在当前目录即子目录下的所有 .md 文件中
    - `*`: 当前目录下查找所有(不涉及子目录)
    - `**`: 当前目录及子目录下所有
    - `*.md`: 当前目录下所有.md 文件
    - `**/*`: 只查找子目录

查找的结果使用 `quick-fix` 来进行展示, 可使用 `:copen` 查看所有结果项并进行相应跳转, 具体操作参考 [神级编辑器 Vim 使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html)

#### 实例

- `:vimgrep /hello/g **`: 在当前目录及子目录下的所有文件内查找 `hello` 字符串

#### quickfix-list 与 location-list 的区别

quickfix-list 是一个完整的窗口, 可以移动上下光标, 按下 enter 进行打开文件

location-list 只是一个局部的显示区域, 只能简单显示查找结果的信息, 目前看来没有必要使用此选项

### 多文件替换

多文件替换所依赖的是 vim 中的参数列表概念, 这里仅对流程命令进行演示, 具体的参数列表操作参考 [神级编辑器 Vim
使用-操作篇](https://www.hanleylee.com/usage-of-vim-editor.html)

- `:args`: 显示当前的所有参数列表
- `:args *.md aa/**/*.md` 表示添加子文件夹下的 `md` 文件及 `aa` 文件夹下的和其子文件夹下的 `md` 文件到参数列表中
- `:argdo %s/oldword/newword/egc | update`: 对所有存在参数列表中的文件执行命令, `s` 代表替换, `%` 指对所有行进行匹配, `g` 代表整行替换(必用), `e` 指使用正则表达式, `c` 代表每次替换前都会进行确认, `update` 表示对文件进行读写
- `:argdo %s/!\[.*\]/!\[img\]/gc`: 将所有参数列表中的以 `![` 开头, 以 `]` 结尾的所有字段改为 `[img]`
- `:argdo write`: 将所有参数列表中的内容进行缓冲区保存

## 常见疑问

### `<EOL>` 与 `newline`

EOL does not mean "there is an empty line after here", it means **this marks the end of the line, any further characters are to be displayed on another line**

当 Vim 加载文件时, 会首先确定文件的 `fileformat`, 然后根据 `fileformat` 进而确定出 `<EOL>` 是什么字符, `<EOL>` 代表每行的结束, `<EOL>` 字符之后的字符就位于一个新的行. 这样, vim 就展示出了多行的效果.

`<EOL>`(end-of-line) 在不同的 `fileformat` 下有着不同的定义(通过 `set ff?` 查看), `newline` 是 vim 内部用来存储换行的符号, 在不同的 `fileformat` 下是不同的值:

| `fileformat` | 对应的 `<EOL>`        | 对应的 `newline` 值 |
|--------------|-----------------------|---------------------|
| `dos`        | `<CR><LF>`(0x0d 0x0a) | `<CR>`(0x0d)        |
| `unix`       | `<LF>`(0x0a)          | `<CR>`(0x0d)        |
| `mac`        | `<CR>`(0x0d)          | `<LF>`(0x0a)        |

可见, `newline` 的定义刻意地避开了与 `<EOL>` 的内容相同

使用 `<C-V><C-M>` / `<C-V><ENTER>` 可以输入 `newline`, 使用 `<C-V><C-J>` 输入 `<NUL>`

### `\n` 与 `\r` 的区别到底是什么

首先, 明确一点, Vim 在内存中使用 `\n` 表示 `<NUL>`(aka `^@`), 使用 `\r` 表示 `newline`, 因此, 当 `\n` 与 `\r` 位于替换部分中时, 会插入相应的字符; 当 `\n` 与 `\r` 位于匹配部分时, 会按照其元字符的定义匹配对应的内容:

| -    | 搜索时                                                   | 替换时         |
|------|----------------------------------------------------------|----------------|
| `\n` | 在 buffer 中匹配 `<EOL>`; 或者在字符串中匹配换行符字面值 | 插入 `<NUL>`   |
| `\r` | 匹配不是 `<EOL>` 一部分的 `<CR>`                         | 插入 `newline` |

## 最后

我的 vim 配置仓库: [HanleyLee/dotvim](https://github.com/HanleyLee/dotvim)

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow

## 参考

- [pattern.txt]($VIMRUNTIME/doc/pattern.txt)
- [vim pattern.txt](https://vimhelp.org/pattern.txt.html)
- [理解使用 vim 中的正则表达式](https://zhuanlan.zhihu.com/p/26155536)
- [Learn REGEX](https://github.com/ziishaned/learn-regex/blob/master/translations/README-cn.md)
- [vim 中使用零宽度断言](https://breezetemple.github.io/2019/10/16/vim-regex-positive-negative/)
