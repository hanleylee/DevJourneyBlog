---
title: 使用 Visual Studio Code 编写 Markdown 文件
date: 2020-12-12
comments: true
path: write-markdown-by-vscode
categories: Tools
tags: ⦿vscode, ⦿markdown, ⦿tool
updated:
---

`Visual Studio Code`(以下简称 `vscode`) 应该是当今最流行的文字编辑器(之一)了, 除了用其来写代码, 我们还可以使用它来撰写技术文档, 譬如 `Markdown`文件.  本文将带你一步步将 `vscode` 打造成一个出色的 `Markdown` 编辑器

![himg](https://a.hanleylee.com/HKMS/2020-12-12165012.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 基础配置

```json
"files.defaultLanguage": "markdown", // 设置 vscode 新建的文件默认语言为 markdown, 扩展为 .md
"[markdown]": { // 控制在格式为 markdown 下vscode 的特殊显示格式
    "editor.defaultFormatter": "yzhang.markdown-all-in-one", // 设置 markdown 的格式化工具, 在 md 文件中使用 ⇧ ⌥ F 时会使用本设置指定的工具
    "editor.wordWrap": "bounded",
    // "editor.fontFamily": "Sarasa Term SC",
    "editor.wordWrapColumn": 150,
    "editor.insertSpaces": true,
},
```

## 插件

通过安装一些插件, 我们可以让编辑器自动纠正我们的 markdown 语法, 并使用一些可以快速插入的片段

`vscode` 丰富的扩展是其一大特色, 我们可以在 `MARKETPLACE` 中找到各种各样的扩展, 但是太多的选择往往会让人迷失, 我们应该尽可能使用最少的插件满足我们的所有需求. 因此对于 Markdown 来说, 我只会推荐 2 款插件: `MarkdownLint` 与 `Markdown-All-in-One`

这里对插件的使用方法仅做 `抛砖引玉`式的介绍, 更全面的使用方法可以参考官网教程

### [MarkdownLint](https://github.com/DavidAnson/vscode-markdownlint)

![himg](https://a.hanleylee.com/HKMS/2020-12-12142838.png?x-oss-process=style/WaMa)

MarkdownLint 可以提示我们语法的错误, 而且支持自动根据建议修正错误. 甚至如果我们与预设的规则不满意的话, 还可以对预设规则进行自定义.

```json
"editor.codeActionsOnSave": { // 在保存的时候自动调用 Markdownlint 的全部修复功能
    "source.fixAll.markdownlint": true,
},

// === markdownlint ===
"markdownlint.config": { // 对预设的规则进行自定义
    "default": true,
    "no-hard-tabs": true,
    "MD007": { "indent": 4 },
    "MD024": false
},
```

### [Markdown All in One](https://github.com/yzhang-gh/vscode-markdown)

![himg](https://a.hanleylee.com/HKMS/2020-12-12142748.png?x-oss-process=style/WaMa)

Markdown All in One 是一款工具集插件, 集合了 格式化, 自动生成目录, 预览, 列表缩进, 表格书写 等一系列功能

基本使用方法如下:

```json
// === markdown all in one ===
"markdown.extension.list.indentationSize": "inherit", // 对列表的缩进级别进行继承, 继承自上一行列表
"[markdown]": { // 控制在格式为 markdown 下vscode 的特殊显示格式
    "editor.defaultFormatter": "yzhang.markdown-all-in-one" // 设置 markdown 的格式化工具, 在 md 文件中使用 ⇧ ⌥ F 时会使用本设置指定的工具
},
```

## Tips

code

### 自动提示功能

vscode 拥有自动提示功能, 默认情况下会根据我们全文的已经输入的单词进行提示, 这个功能对于写代码或者是写英文文档是很有用的, 因为英文都是以单词来进行划分的, 但是如果你书写的是中文文档那么情况可能会不太一样, 因为vscode 对中文是按照句来进行划分的:

![himg](https://a.hanleylee.com/HKMS/2020-12-12143441.png?x-oss-process=style/WaMa)

像上面一样, 当我们输入了一个 `对`时, vscode 会将含 `对`的这三句话都列出来供我们选择, 这样的匹配度我们基本上用不到. 因此我们可以考虑关闭基于全文文字的补全推断, 但是我们同时还需要保留一些有用的 snippet 提示:

![himg](https://a.hanleylee.com/HKMS/2020-12-12143808.png?x-oss-process=style/WaMa)

因此我们可以这样做:

```json
"[markdown]": { // 控制在格式为 markdown 下vscode 的特殊显示格式
    //...
    "editor.quickSuggestions": true,
    "editor.wordBasedSuggestions": false // 移除根据字符自动弹出的建议
},
```

## 与 [Path Autocomplete](https://github.com/ionutvmi/path-autocomplete) 结合时的问题

Path Autocomplete 是一款文件路径补全工具, 可以根据当前文件的相对路径或系统绝对路径进行路径补全, 但是其默认会被 `tlide` 键激活

![himg](https://a.hanleylee.com/HKMS/2020-12-12144448.png?x-oss-process=style/WaMa)

可以使用如下设置来解决此问题

```json
{
    "path-autocomplete.ignoredPrefixes": ["`",],
}
```

## 配置总结

```json
{
    // MARK: - Main
    "files.defaultLanguage": "markdown",
    "editor.codeActionsOnSave": {
        "source.fixAll.markdownlint": true,
    },
    "[markdown]": {
        "editor.defaultFormatter": "yzhang.markdown-all-in-one",
        "editor.wordWrap": "bounded",
        // "editor.fontFamily": "Sarasa Term SC",
        "editor.wordWrapColumn": 150,
        "editor.insertSpaces": true,
        "editor.quickSuggestions": true,
        "editor.wordBasedSuggestions": false // 移除根据字符自动弹出的建议
    },

    // MARK: ======= 第三方插件 =======

    // === markdown all in one ===
    "markdown.extension.list.indentationSize": "inherit",

    // === markdownlint ===
    "markdownlint.config": {
        "default": true,
        "no-hard-tabs": true,
        "MD007": { "indent": 4 },
        "MD024": false
    },
    // === path autocomplete ===
    "path-autocomplete.ignoredPrefixes": ["`",],
},
```
