//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/9/18.
//

import Foundation
import Markdown

var source = """
---
title: 版本管理工具 Git 的使用
date: 2019-12-24
comments: true
path: principle-and-usage-of-git
categories: Terminal
tags: ⦿git, ⦿terminal
updated:
---

Now you see me, **now you don't**

## second level header

| Stat   | Title             | Author          | Link                                                     |
| ------ | ----------------- | --------------- | -------------------------------------------------------- |
| ✅     | Ruby              | 易百教程        | <https://www.yiibai.com/ruby/quick-start.html>           |
| ✅     | Python            | RUNOOB.com      | <https://www.runoob.com/python3/python3-tutorial.html>   |
| ✅     | JavaScript 教程   | 网道 (阮一峰)   | <https://wangdoc.com/javascript/>                        |
| ✅     | HTML 教程         | 网道 (阮一峰)   | <https://wangdoc.com/html/index.html>                    |

"""
let document = Document(parsing: source)
//print(document.debugDescription())
let doc2 = Document(
    Paragraph(
        Text("This is a "),
        Emphasis(
            Text("paragraph.")
        )
    )
)
// print(doc2.debugDescription())
// var visitor = HTMLVisitor()
// let doc3 = visitor.visit(doc2)
// print(doc3)
