//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

struct ShortRSSFeedGenerator<Site: Website> {
    let includedSectionIDs: Set<Site.SectionID>
    let itemPredicate: Predicate<Item<Site>>?
    let config: RSSFeedConfiguration
    let context: PublishingContext<Site>
    let date: Date
}

extension ShortRSSFeedGenerator {
    struct Cache: Codable {
        let config: RSSFeedConfiguration
        let feed: String
        let itemCount: Int
    }

    func generate() throws {
        let outputFile = try context.createOutputFile(at: config.targetPath)
        let cacheFile = try context.cacheFile(named: "feed")
        let oldCache = try? cacheFile.read().decoded() as Cache
        var items = [Item<Site>]()

        for sectionID in includedSectionIDs {
            items += context.sections[sectionID].items
        }

        items.sort { $0.date > $1.date }

        if let predicate = itemPredicate?.inverse() {
            items.removeAll(where: predicate.matches)
        }

        if let date = context.lastGenerationDate, let cache = oldCache {
            if cache.config == config, cache.itemCount == items.count {
                let newlyModifiedItem = items.first { $0.lastModified > date }

                guard newlyModifiedItem != nil else {
                    return try outputFile.write(cache.feed)
                }
            }
        }

        let feed = makeFeed(containing: items).render(indentedBy: config.indentation)

        let newCache = Cache(config: config, feed: feed, itemCount: items.count)
        try cacheFile.write(newCache.encoded())
        try outputFile.write(feed)
    }

    func makeFeed(containing items: [Item<Site>]) -> RSS {
        RSS(
            .title(context.site.name),
            .description(context.site.description),
            .link(context.site.url),
            .language(context.site.language),
            .lastBuildDate(date, timeZone: context.dateFormatter.timeZone),
            .pubDate(date, timeZone: context.dateFormatter.timeZone),
            .ttl(Int(config.ttlInterval)),
            .atomLink(context.site.url(for: config.targetPath)),
            .forEach(items.prefix(config.maximumItemCount)) { item in
                .item(
                    .guid(for: item, site: context.site),
                    .title(item.rssTitle),
                    .description(item.description),
                    .link(item.rssProperties.link ?? context.site.url(for: item)),
                    .pubDate(item.date, timeZone: context.dateFormatter.timeZone),
                    .shortContent(for: item, site: context.site)
                )
            }
        )
    }
}

