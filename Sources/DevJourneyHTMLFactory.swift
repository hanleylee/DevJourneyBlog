//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Plot
import Publish

struct DevJourneyHTMLFactory<Site: Website>: HTMLFactory {
    // 首页
    func makeIndexHTML(for index: Index, context: PublishingContext<Site>) throws -> HTML {
        return try indexHTML(for: index, context: context)
    }

    // home/articles/about/tags
    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        return try sectionHTML(for: section, context: context)
    }

    // 文章页面
    func makeItemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        return try itemHTML(for: item, context: context)
    }

    // Pages, 不属于 Section
    func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        return try pageHTML(for: page, context: context)
    }

    // Tag 列表
    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        return nil // 这里我们不生成 tags 了, 避免与 section 的 search 混淆
//        return try tagListHTML(for: page, context: context)
    }

    // Tag 详情
    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        return try tagDetailsHTML(for: page, context: context)
    }
}
