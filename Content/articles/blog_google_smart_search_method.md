---
title: 谷歌搜索的简单技巧
date: 2020-01-02
comments: true
path: smart-search-method-for-google-search
categories: Tools
tags: ⦿google, ⦿search, ⦿tips
updated:
---

谷歌搜索我们每天都在用, 但是如果你只会普通搜索, 那么搜索的效率必然不会很高.

实际上, 高级搜索的技巧只有那么几个, 多使用几次完全可以熟练掌握, 比起 `vim`, `git` 等需要掌握大量命令才能提升效率的工具来说, 学习高级搜索的投入非常值得!

<!-- more -->

## ""

精确搜索

```txt
百度智能
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145957.jpg?x-oss-process=style/WaMa)

## + (或者空格)

交集

```txt
apple +google
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-150004.jpg?x-oss-process=style/WaMa)

## -

差集, 减号左侧空一格, 右侧不能空格

```txt
计算机语言 -百度 -知乎
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145958.jpg?x-oss-process=style/WaMa)

## or

并集

```txt
百度 or 谷歌
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-150002.jpg?x-oss-process=style/WaMa)

## site

根据域名进行站内搜索

```txt
site: imooc.com 技巧
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-150000.jpg?x-oss-process=style/WaMa)

## intitle

返回标题中含有文本的网页 (冒号中间不能空格)

```txt
intitle:百度
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145959.jpg?x-oss-process=style/WaMa)

## allintitle

```txt
allintitle:Google 百度
```

![himg](https://a.hanleylee.com/HKMS/2023-12-31182951.png?x-oss-process=style/WaMa)

## inurl

链接中必须包含给定的关键词

```txt
inurl:imooc.com
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-145960.jpg?x-oss-process=style/WaMa)

## intext

文章内容中必须包含关键词

```txt
intext:慕课网
```

![himg](https://a.hanleylee.com/HKMS/2019-12-27-150003.jpg?x-oss-process=style/WaMa)

## related

搜索相关网站

```txt
related:hanleylee.com
```

![himg](https://a.hanleylee.com/HKMS/2023-12-31183114.png?x-oss-process=style/WaMa)

## imagesize

限定搜索图片尺寸

```txt
elon musk imagesize:2560x1440
```

![himg](https://a.hanleylee.com/HKMS/2023-12-31184413.png?x-oss-process=style/WaMa)

## filetype

限定文件格式

```txt
大预言模型filetype:pdf
```

![himg](https://a.hanleylee.com/HKMS/2023-12-31184728.png?x-oss-process=style/WaMa)

## 综合使用

- `intitle:"ELON MUSK" intext:"SpaceX Starship Update"`: 要求文章标题中必须包含 `ELON MUSK`, 且内容中必须包含 `SpaceX Starship Update`
- `hhkb site:hanleylee.com`
- `little cat site:gettyimages.com`
- `elon musk imagesize:2560x1440`
- `arrow filetype:png`
