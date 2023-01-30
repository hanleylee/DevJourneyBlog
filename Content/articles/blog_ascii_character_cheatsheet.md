---
title: ASCII Character Cheatsheet
date: 2022-09-17
comments: true
path: ascii-character-cheatsheet
categories: cheatsheet
tags: ⦿ascii,⦿character,⦿cheatsheet
updated:
---

本文为 ASCII 速查表格, 如果有用请收藏 ⭐ ~

<!-- more -->

<!-- markdownlint-disable -->
| 二进制     | 八进制 | 十进制 | 十六进制 | ACSII | visible | digraphs | 正则表达式 | name(en)                                              | name(cn)           |
|------------|--------|--------|----------|-------|---------|----------|------------|-------------------------------------------------------|--------------------|
| 0b00000000 | 000    | 0      | 0x00     | NUL   | ^@      | NU       | \c@        | NULL (NUL)                                            | 空字符             |
| 0b00000001 | 001    | 1      | 0x01     | SOH   | ^A      | SH       | \cA        | START OF HEADING (SOH)                                | 标题开始           |
| 0b00000010 | 002    | 2      | 0x02     | STX   | ^B      | SX       | \cB        | START OF TEXT (STX)                                   | 文本开始           |
| 0b00000011 | 003    | 3      | 0x03     | ETX   | ^C      | EX       | \cC        | END OF TEXT (ETX)                                     | 文本结束           |
| 0b00000100 | 004    | 4      | 0x04     | EOT   | ^D      | ET       | \cD        | END OF TRANSMISSION (EOT)                             | 传输结束           |
| 0b00000101 | 005    | 5      | 0x05     | ENQ   | ^E      | EQ       | \cE        | ENQUIRY (ENQ)                                         | 询问               |
| 0b00000110 | 006    | 6      | 0x06     | ACK   | ^F      | AK       | \cF        | ACKNOWLEDGE (ACK)                                     | 确认               |
| 0b00000111 | 007    | 7      | 0x07     | BEL   | ^G      | BL       | \a, \cG    | BELL (BEL)                                            | 警报字符           |
| 0b00001000 | 010    | 8      | 0x08     | BS    | ^H      | BS       | [\b], \cH  | BACKSPACE (BS)                                        | 退格符             |
| 0b00001001 | 011    | 9      | 0x09     | HT    | ^I      | HT       | \t, \cI    | CHARACTER TABULATION (HT)                             | 水平制表符         |
| 0b00001010 | 012    | 10     | 0x0A     | LF    | ^J      | LF       | \n, \cJ    | LINE FEED (LF)                                        | 换行符             |
| 0b00001011 | 013    | 11     | 0x0B     | VT    | ^K      | VT       | \v, \cK    | LINE TABULATION (VT)                                  | 垂直制表符         |
| 0b00001100 | 014    | 12     | 0x0C     | FF    | ^L      | FF       | \f, \cL    | FORM FEED (FF)                                        | 换页符             |
| 0b00001101 | 015    | 13     | 0x0D     | CR    | ^M      | CR       | \r, \cM    | CARRIAGE RETURN (CR)                                  | 回车符             |
| 0b00001110 | 016    | 14     | 0x0E     | SO    | ^N      | SO       | \cN        | SHIFT OUT (SO)                                        | 移出               |
| 0b00001111 | 017    | 15     | 0x0F     | SI    | ^O      | SI       | \cO        | SHIFT IN (SI)                                         | 移入               |
| 0b00010000 | 020    | 16     | 0x10     | DLE   | ^P      | DL       | \cP        | DATALINK ESCAPE (DLE)                                 | 数据链转义         |
| 0b00010001 | 021    | 17     | 0x11     | DC1   | ^Q      | D1       | \cQ        | DEVICE CONTROL ONE (DC1)                              | 设备控制 1（XON）  |
| 0b00010010 | 022    | 18     | 0x12     | DC2   | ^R      | D2       | \cR        | DEVICE CONTROL TWO (DC2)                              | 设备控制 2         |
| 0b00010011 | 023    | 19     | 0x13     | DC3   | ^S      | D3       | \cS        | DEVICE CONTROL THREE (DC3)                            | 设备控制 3（XOFF） |
| 0b00010100 | 024    | 20     | 0x14     | DC4   | ^T      | D4       | \cT        | DEVICE CONTROL FOUR (DC4)                             | 设备控制 4         |
| 0b00010101 | 025    | 21     | 0x15     | NAK   | ^U      | NK       | \cU        | NEGATIVE ACKNOWLEDGE (NAK)                            | 否定性确认         |
| 0b00010110 | 026    | 22     | 0x16     | SYN   | ^V      | SY       | \cV        | SYNCHRONOUS IDLE (SYN)                                | 同步空闲           |
| 0b00010111 | 027    | 23     | 0x17     | ETB   | ^W      | EB       | \cW        | END OF TRANSMISSION BLOCK (ETB)                       | 传输块结尾         |
| 0b00011000 | 030    | 24     | 0x18     | CAN   | ^X      | CN       | \cX        | CANCEL (CAN)                                          | 取消               |
| 0b00011001 | 031    | 25     | 0x19     | EM    | ^Y      | EM       | \cY        | END OF MEDIUM (EM)                                    | 介质结尾           |
| 0b00011010 | 032    | 26     | 0x1A     | SUB   | ^Z      | SB       | \cZ        | SUBSTITUTE (SUB)                                      | 替换               |
| 0b00011011 | 033    | 27     | 0x1B     | ESC   | ^[      | EC       | \e, \c[    | ESCAPE (ESC)                                          | 转义               |
| 0b00011100 | 034    | 28     | 0x1C     | FS    | ^\|     | FS       | \c\|       | FILE SEPARATOR (IS4)                                  | 文件分隔符         |
| 0b00011101 | 035    | 29     | 0x1D     | GS    | ^]      | GS       | \c]        | GROUP SEPARATOR (IS3)                                 | 分组分隔符         |
| 0b00011110 | 036    | 30     | 0x1E     | RS    | ^^      | RS       | \c^        | RECORD SEPARATOR (IS2)                                | 记录分隔符         |
| 0b00011111 | 037    | 31     | 0x1F     | US    | ^_      | US       | \c_        | UNIT SEPARATOR (IS1)                                  | 单元分隔符         |
| 0b00100000 | 040    | 32     | 0x20     | SP    | SP      | SP       | \s         | SPACE                                                 | 空格               |
| 0b00100001 | 041    | 33     | 0x21     | !     | !       |          | -          | EXCLAMATION MARK                                      | 感叹号             |
| 0b00100010 | 042    | 34     | 0x22     | "     | "       |          | -          | DOUBLE QUOTES; QUOTATION MARK; SPEECH MARKS           | 引号               |
| 0b00100011 | 043    | 35     | 0x23     | #     | #       | Nb       | -          | NUMBER SIGN                                           | 井号               |
| 0b00100100 | 044    | 36     | 0x24     | $     | $       | DO       | -          | DOLLAR SIGN                                           | 美元符             |
| 0b00100101 | 045    | 37     | 0x25     | %     | %       |          | -          | PERCENT SIGN                                          | 百分号             |
| 0b00100110 | 046    | 38     | 0x26     | &     | &       |          | -          | AMPERSAND                                             | 和号               |
| 0b00100111 | 047    | 39     | 0x27     | '     | '       |          | -          | SINGLE QUOTE OR APOSTROPHE                            | 撇号               |
| 0b00101000 | 050    | 40     | 0x28     | (     | (       |          | -          | ROUND BRACKETS OR PARENTHESES, OPENING ROUND BRACKET  | 左括号             |
| 0b00101001 | 051    | 41     | 0x29     | )     | )       |          | -          | PARENTHESES OR ROUND BRACKETS, CLOSING PARENTHESES    | 右括号             |
| 0b00101010 | 052    | 42     | 0x2A     | *     | *       |          | -          | ASTERISK                                              | 星号               |
| 0b00101011 | 053    | 43     | 0x2B     | +     | +       |          | -          | PLUS SIGN                                             | 加号               |
| 0b00101100 | 054    | 44     | 0x2C     | ,     | ,       |          | -          | COMMA                                                 | 逗号               |
| 0b00101101 | 055    | 45     | 0x2D     | -     | -       |          | -          | HYPHEN , MINUS SIGN                                   | 连字符             |
| 0b00101110 | 056    | 46     | 0x2E     | .     | .       |          | -          | DOT, FULL STOP                                        | 句号               |
| 0b00101111 | 057    | 47     | 0x2F     | /     | /       |          | -          | SLASH , FORWARD SLASH , FRACTION BAR , DIVISION SLASH | 斜线               |
| 0b00110000 | 060    | 48     | 0x30     | 0     | 0       |          | -          | NUMBER ZERO                                           | 数字 0             |
| 0b00110001 | 061    | 49     | 0x31     | 1     | 1       |          | -          | NUMBER ONE                                            | 数字 1             |
| 0b00110010 | 062    | 50     | 0x32     | 2     | 2       |          | -          | NUMBER TWO                                            | 数字 2             |
| 0b00110011 | 063    | 51     | 0x33     | 3     | 3       |          | -          | NUMBER THREE                                          | 数字 3             |
| 0b00110100 | 064    | 52     | 0x34     | 4     | 4       |          | -          | NUMBER FOUR                                           | 数字 4             |
| 0b00110101 | 065    | 53     | 0x35     | 5     | 5       |          | -          | NUMBER FIVE                                           | 数字 5             |
| 0b00110110 | 066    | 54     | 0x36     | 6     | 6       |          | -          | NUMBER SIX                                            | 数字 6             |
| 0b00110111 | 067    | 55     | 0x37     | 7     | 7       |          | -          | NUMBER SEVEN                                          | 数字 7             |
| 0b00111000 | 070    | 56     | 0x38     | 8     | 8       |          | -          | NUMBER EIGHT                                          | 数字 8             |
| 0b00111001 | 071    | 57     | 0x39     | 9     | 9       |          | -          | NUMBER NINE                                           | 数字 9             |
| 0b00111010 | 072    | 58     | 0x3A     | :     | :       |          | -          | COLON                                                 | 冒号               |
| 0b00111011 | 073    | 59     | 0x3B     | ;     | ;       |          | -          | SEMICOLON                                             | 分号               |
| 0b00111100 | 074    | 60     | 0x3C     | <     | <       |          | -          | LESS-THAN SIGN                                        | 小于号             |
| 0b00111101 | 075    | 61     | 0x3D     | =     | =       |          | -          | EQUALS SIGN                                           | 等于号             |
| 0b00111110 | 076    | 62     | 0x3E     | >     | >       |          | -          | GREATER-THAN SIGN ; INEQUALITY                        | 大于号             |
| 0b00111111 | 077    | 63     | 0x3F     | ?     | ?       |          | -          | QUESTION MARK                                         | 问号               |
| 0b01000000 | 0100   | 64     | 0x40     | @     | @       | At       | -          | COMMERCIAL AT                                         | at                 |
| 0b01000001 | 0101   | 65     | 0x41     | A     | A       |          | -          | CAPITAL LETTER A                                      | 拉丁大写字母 A     |
| 0b01000010 | 0102   | 66     | 0x42     | B     | B       |          | -          | CAPITAL LETTER B                                      | 拉丁大写字母 B     |
| 0b01000011 | 0103   | 67     | 0x43     | C     | C       |          | -          | CAPITAL LETTER C                                      | 拉丁大写字母 C     |
| 0b01000100 | 0104   | 68     | 0x44     | D     | D       |          | -          | CAPITAL LETTER D                                      | 拉丁大写字母 D     |
| 0b01000101 | 0105   | 69     | 0x45     | E     | E       |          | -          | CAPITAL LETTER E                                      | 拉丁大写字母 E     |
| 0b01000110 | 0106   | 70     | 0x46     | F     | F       |          | -          | CAPITAL LETTER F                                      | 拉丁大写字母 F     |
| 0b01000111 | 0107   | 71     | 0x47     | G     | G       |          | -          | CAPITAL LETTER G                                      | 拉丁大写字母 G     |
| 0b01001000 | 0110   | 72     | 0x48     | H     | H       |          | -          | CAPITAL LETTER H                                      | 拉丁大写字母 H     |
| 0b01001001 | 0111   | 73     | 0x49     | I     | I       |          | -          | CAPITAL LETTER I                                      | 拉丁大写字母 I     |
| 0b01001010 | 0112   | 74     | 0x4A     | J     | J       |          | -          | CAPITAL LETTER J                                      | 拉丁大写字母 J     |
| 0b01001011 | 0113   | 75     | 0x4B     | K     | K       |          | -          | CAPITAL LETTER K                                      | 拉丁大写字母 K     |
| 0b01001100 | 0114   | 76     | 0x4C     | L     | L       |          | -          | CAPITAL LETTER L                                      | 拉丁大写字母 L     |
| 0b01001101 | 0115   | 77     | 0x4D     | M     | M       |          | -          | CAPITAL LETTER M                                      | 拉丁大写字母 M     |
| 0b01001110 | 0116   | 78     | 0x4E     | N     | N       |          | -          | CAPITAL LETTER N                                      | 拉丁大写字母 N     |
| 0b01001111 | 0117   | 79     | 0x4F     | O     | O       |          | -          | CAPITAL LETTER O                                      | 拉丁大写字母 O     |
| 0b01010000 | 0120   | 80     | 0x50     | P     | P       |          | -          | CAPITAL LETTER P                                      | 拉丁大写字母 P     |
| 0b01010001 | 0121   | 81     | 0x51     | Q     | Q       |          | -          | CAPITAL LETTER Q                                      | 拉丁大写字母 Q     |
| 0b01010010 | 0122   | 82     | 0x52     | R     | R       |          | -          | CAPITAL LETTER R                                      | 拉丁大写字母 R     |
| 0b01010011 | 0123   | 83     | 0x53     | S     | S       |          | -          | CAPITAL LETTER S                                      | 拉丁大写字母 S     |
| 0b01010100 | 0124   | 84     | 0x54     | T     | T       |          | -          | CAPITAL LETTER T                                      | 拉丁大写字母 T     |
| 0b01010101 | 0125   | 85     | 0x55     | U     | U       |          | -          | CAPITAL LETTER U                                      | 拉丁大写字母 U     |
| 0b01010110 | 0126   | 86     | 0x56     | V     | V       |          | -          | CAPITAL LETTER V                                      | 拉丁大写字母 V     |
| 0b01010111 | 0127   | 87     | 0x57     | W     | W       |          | -          | CAPITAL LETTER W                                      | 拉丁大写字母 W     |
| 0b01011000 | 0130   | 88     | 0x58     | X     | X       |          | -          | CAPITAL LETTER X                                      | 拉丁大写字母 X     |
| 0b01011001 | 0131   | 89     | 0x59     | Y     | Y       |          | -          | CAPITAL LETTER Y                                      | 拉丁大写字母 Y     |
| 0b01011010 | 0132   | 90     | 0x5A     | Z     | Z       |          | -          | CAPITAL LETTER Z                                      | 拉丁大写字母 Z     |
| 0b01011011 | 0133   | 91     | 0x5B     | [     | [       | <(       | -          | LEFT SQUARE BRACKET                                   | 左方括号           |
| 0b01011100 | 0134   | 92     | 0x5C     | \     | \       | //       | -          | REVERSE SOLIDUS                                       | 反斜线             |
| 0b01011101 | 0135   | 93     | 0x5D     | ]     | ]       | )>       | -          | RIGHT SQUARE BRACKET                                  | 右方括号           |
| 0b01011110 | 0136   | 94     | 0x5E     | ^     | ^       | '>       | -          | CIRCUMFLEX ACCENT                                     | 抑扬符号           |
| 0b01011111 | 0137   | 95     | 0x5F     | _     | _       |          | -          | UNDERSCORE, UNDERSTRIKE, UNDERBAR OR LOW LINE         | 下划线             |
| 0b00100000 | 0140   | 96     | 0x60     | `     | `       | '!       | -          | GRAVE ACCENT                                          | 重音符             |
| 0b01100001 | 0141   | 97     | 0x61     | a     | a       |          | -          | LOWERCASE LETTER A , MINUSCULE A                      | 拉丁小写字母 A     |
| 0b01100010 | 0142   | 98     | 0x62     | b     | b       |          | -          | LOWERCASE LETTER B , MINUSCULE B                      | 拉丁小写字母 B     |
| 0b01100011 | 0143   | 99     | 0x63     | c     | c       |          | -          | LOWERCASE LETTER C , MINUSCULE C                      | 拉丁小写字母 C     |
| 0b01100100 | 0144   | 100    | 0x64     | d     | d       |          | -          | LOWERCASE LETTER D , MINUSCULE D                      | 拉丁小写字母 D     |
| 0b01100101 | 0145   | 101    | 0x65     | e     | e       |          | -          | LOWERCASE LETTER E , MINUSCULE E                      | 拉丁小写字母 E     |
| 0b01100110 | 0146   | 102    | 0x66     | f     | f       |          | -          | LOWERCASE LETTER F , MINUSCULE F                      | 拉丁小写字母 F     |
| 0b01100111 | 0147   | 103    | 0x67     | g     | g       |          | -          | LOWERCASE LETTER G , MINUSCULE G                      | 拉丁小写字母 G     |
| 0b01101000 | 0150   | 104    | 0x68     | h     | h       |          | -          | LOWERCASE LETTER H , MINUSCULE H                      | 拉丁小写字母 H     |
| 0b01101001 | 0151   | 105    | 0x69     | i     | i       |          | -          | LOWERCASE LETTER I , MINUSCULE I                      | 拉丁小写字母 I     |
| 0b01101010 | 0152   | 106    | 0x6A     | j     | j       |          | -          | LOWERCASE LETTER J , MINUSCULE J                      | 拉丁小写字母 J     |
| 0b01101011 | 0153   | 107    | 0x6B     | k     | k       |          | -          | LOWERCASE LETTER K , MINUSCULE K                      | 拉丁小写字母 K     |
| 0b01101100 | 0154   | 108    | 0x6C     | l     | l       |          | -          | LOWERCASE LETTER L , MINUSCULE L                      | 拉丁小写字母 L     |
| 0b01101101 | 0155   | 109    | 0x6D     | m     | m       |          | -          | LOWERCASE LETTER M , MINUSCULE M                      | 拉丁小写字母 M     |
| 0b01101110 | 0156   | 110    | 0x6E     | n     | n       |          | -          | LOWERCASE LETTER N , MINUSCULE N                      | 拉丁小写字母 N     |
| 0b01101111 | 0157   | 111    | 0x6F     | o     | o       |          | -          | LOWERCASE LETTER O , MINUSCULE O                      | 拉丁小写字母 O     |
| 0b01110000 | 0160   | 112    | 0x70     | p     | p       |          | -          | LOWERCASE LETTER P , MINUSCULE P                      | 拉丁小写字母 P     |
| 0b01110001 | 0161   | 113    | 0x71     | q     | q       |          | -          | LOWERCASE LETTER Q , MINUSCULE Q                      | 拉丁小写字母 Q     |
| 0b01110010 | 0162   | 114    | 0x72     | r     | r       |          | -          | LOWERCASE LETTER R , MINUSCULE R                      | 拉丁小写字母 R     |
| 0b01110011 | 0163   | 115    | 0x73     | s     | s       |          | -          | LOWERCASE LETTER S , MINUSCULE S                      | 拉丁小写字母 S     |
| 0b01110100 | 0164   | 116    | 0x74     | t     | t       |          | -          | LOWERCASE LETTER T , MINUSCULE T                      | 拉丁小写字母 T     |
| 0b01110101 | 0165   | 117    | 0x75     | u     | u       |          | -          | LOWERCASE LETTER U , MINUSCULE U                      | 拉丁小写字母 U     |
| 0b01110110 | 0166   | 118    | 0x76     | v     | v       |          | -          | LOWERCASE LETTER V , MINUSCULE V                      | 拉丁小写字母 V     |
| 0b01110111 | 0167   | 119    | 0x77     | w     | w       |          | -          | LOWERCASE LETTER W , MINUSCULE W                      | 拉丁小写字母 W     |
| 0b01111000 | 0170   | 120    | 0x78     | x     | x       |          | -          | LOWERCASE LETTER X , MINUSCULE X                      | 拉丁小写字母 X     |
| 0b01111001 | 0171   | 121    | 0x79     | y     | y       |          | -          | LOWERCASE LETTER Y , MINUSCULE Y                      | 拉丁小写字母 Y     |
| 0b01111010 | 0172   | 122    | 0x7A     | z     | z       |          | -          | LOWERCASE LETTER Z , MINUSCULE Z                      | 拉丁小写字母 Z     |
| 0b01111011 | 0173   | 123    | 0x7B     | {     | {       | (!       | -          | LEFT CURLY BRACKET                                    | 左花括号           |
| 0b01111100 | 0174   | 124    | 0x7C     | \|    | \|      | !!       | -          | VERTICAL LINE                                         | 竖线               |
| 0b01111101 | 0175   | 125    | 0x7D     | }     | }       | !)       | -          | RIGHT CURLY BRACKE                                    | 右花括号           |
| 0b01111110 | 0176   | 126    | 0x7E     | ~     | ~       | '?       | -          | TILDE                                                 | 波浪符             |
| 0b01111111 | 0177   | 127    | 0x7F     | DEL   | ^?      | DT       | \c?        | DELETE (DEL)                                          | 删除               |
<!-- markdownlint-restore -->

## Vim 中输入特殊字符

### diagraph

在 vim 中使用 `<C-k>digraphs` 可以输入指定的特殊字符(大小写敏感)

### digit

在 vim 中使用 `<C-v>***` 可以输入不常用字符, 具体 `***` 可参考如下:

| first char | mode        | max nr of chars | example                 | max value             |
|------------|-------------|-----------------|-------------------------|-----------------------|
| (none)     | decimal     | 3               | `<C-v>122`              | 255                   |
| o or O     | octal       | 3               | `<C-v>o033`             | 377  (255)            |
| x or X     | hexadecimal | 2               | `<C-v>x2a` / `<C-v>X2a` | ff   (255)            |
| u          | hexadecimal | 4               | `<C-v>u002a`            | ffff (65535)          |
| U          | hexadecimal | 8               | `<C-v>U0000002a`        | 7fffffff (2147483647) |

> :h i_CTRL-V_digit

## ASCII 与 unicode 关系

- 标准的 ASCII 只有 128 个字符, Unicode 是标准 ASCII 的超集, 是完全兼容的
- 除了标准 ASCII, 还有一个 Extended ASCII, 有 256 个字符, Extended ASCII 的 128~255 字符是与 Unicode 不兼容的; 出于通用化考虑, Extended ASCII 可以不用考虑了~

## Ref

- [vim digraph](https://vimhelp.org/digraph.txt.html)
- [theasciicode.com](https://theasciicode.com.ar)
