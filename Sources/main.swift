import Foundation
import Plot
import Publish

struct DevJourneyBlog: Website {
    enum SectionID: String, WebsiteSectionID {
        case recent
        case articles
        case about
        case search
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

/**

 Swift CLI 程序入口点有两种:

 - *main.swift*
 - type marked with `@main`

    ```swift
     @main
     struct DevJourneyBlogCLI { // the name is arbitrary
         static func main() async throws {
             setbuf(stdout, nil)
             // your code goes here
         }
     }
    ```

 这两种入口不能同时存在. 如果在 *main.swift* 文件中再使用 `@main`, 就会报错
  */

try DevJourneyBlog()
    .publish(
        using: [
            .addModifier(modifier: hrefOpenNewTab, modifierName: "hrefOpenNewTab"),
            .copyResources(at: "Resources", to: "/", includingFolder: false),
            .setSectionTitle(),
            .installPlugin(.setDateFormatter()), // 设置时间显示格式, 必须在 addMarkdownFiles() 之前, 涉及到时间解析格式问题
            .installPlugin(.highlightJS()),
//        .installPlugin(.splash(withClassPrefix: "")),
            .addMarkdownFiles(),
            .makeDateArchive(),
            .installPlugin(.countTags()), // 计算 tag 的数量, tag 必须在 addMarkDownFiles() 之后,否则 alltags 没有值
            .installPlugin(.colorfulTags(defaultClass: "tag", variantPrefix: "variant", numberOfVariants: 8)), // 给tag多种颜色
            .installPlugin(.readingTime()),
            .sortItems(by: \.date, order: .descending), // 对所有文章排序
            .generateShortRSSFeed(including: [.articles], itemPredicate: nil),
            .generateHTML(withTheme: .devJourney),
//        .generateSearchIndex(includeCode: false),
            .generateSiteMap(),
//        .unwrap(.git("ssh://root@81.68.187.219:66/home/hanleylee.com/web.git", branch: "master"), PublishingStep.deploy),
            .unwrap(.git("ssh://Ctyun-1C2G/home/hanleylee.com/web.git", branch: "master"), PublishingStep.deploy),
        ]
    )

// print(ProcessInfo.processInfo.environment["hello"])
