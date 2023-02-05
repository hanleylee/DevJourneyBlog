//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish

// 如果直接设置 SectionID的raw值的话,文件的目录名也会发生变化.还是这种方式灵活度更大

extension PublishingStep where Site == DevJourneyBlog {
    static func setSectionTitle() -> Self {
        .step(named: "setSectionTitle") { content in
            content.mutateAllSections { section in
                switch section.id {
                case .recent:
                    section.title = "最近更新"
                case .articles:
                    section.title = "全部文章"
                case .about:
                    section.title = "关于"
                case .tags:
                    section.title = "搜索"
                }
            }
        }
    }
}
