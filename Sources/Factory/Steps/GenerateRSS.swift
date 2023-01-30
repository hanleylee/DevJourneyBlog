//
//  File.swift
//  File
//
//  Created by Hanley Lee on 2023/1/13.
//

import Files
import Foundation
import Plot
import Publish
import Sweep

extension PublishingStep {
    static func generateShortRSSFeed(
        including includedSectionIDs: Set<Site.SectionID>,
        itemPredicate: Predicate<Item<Site>>? = nil,
        config: RSSFeedConfiguration = .default,
        date: Date = Date()
    ) -> Self {
        guard !includedSectionIDs.isEmpty else { return .empty }

        return step(named: "Generate RSS feed") { context in
            let generator = ShortRSSFeedGenerator(
                includedSectionIDs: includedSectionIDs,
                itemPredicate: itemPredicate,
                config: config,
                context: context,
                date: date
            )

            try generator.generate()
        }
    }
}
