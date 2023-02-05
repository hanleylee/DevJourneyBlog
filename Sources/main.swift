import Foundation
import Markdown
import Plot
import Publish
import Sweep

/// Delete all **strong** elements in a markup tree.
struct StrongDeleter: MarkupRewriter {
    mutating func visitStrong(_ strong: Strong) -> Markup? {
        return nil
    }
}

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

struct DevJourneyBlog: Website {
    enum SectionID: String, WebsiteSectionID {
        case home
        case articles
        case about
        case tags
    }

    struct ItemMetadata: WebsiteItemMetadata {
        var author: String?
    }

    var url = URL(string: "https://hanleylee.com")!
    var name = "闪耀旅途"
    var description = "Programming & Life"
    var language: Language { .chinese }
    var favicon: Favicon? { .init(path: "img/icon_site.JPG", type: "image/jpeg") }
    var imagePath: Path? { nil }
}

try DevJourneyBlog().publish(
    using: [
        .addModifier(modifier: hrefOpenNewTab, modifierName: "hrefOpenNewTab"),
        .copyResources(),
        .setSectionTitle(),
        .installPlugin(.setDateFormatter()), // 设置时间显示格式, 必须在 addMarkdownFiles() 之前, 涉及到时间解析格式问题
        .installPlugin(.splash(withClassPrefix: "")),
        .addMarkdownFiles(),
        .makeDateArchive(),
        .installPlugin(.countTags()), // 计算tag的数量,tag 必须在 addMarkDownFiles() 之后,否则alltags没有值
        .installPlugin(.colorfulTags(defaultClass: "tag", variantPrefix: "variant", numberOfVariants: 8)), // 给tag多种颜色
        .sortItems(by: \.date, order: .descending), // 对所有文章排序
        .generateShortRSSFeed(including: [.articles], itemPredicate: nil),
        .generateHTML(withTheme: .devJourney),
        //        .makeSearchIndex(includeCode: false),
        .generateSiteMap(),
        .unwrap(.git("ssh://root@81.68.187.219:66/home/hanleylee.com/hexo.git", branch: "master"), PublishingStep.deploy),
    ]
)
