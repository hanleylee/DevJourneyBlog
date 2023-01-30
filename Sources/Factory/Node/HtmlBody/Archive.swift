//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    static func archiveView<T: Website>(context: PublishingContext<T>) -> Node {
        func dateArchive<T: Website>(items: [Item<T>]) -> [Int: [Item<T>]] {
            let result = Dictionary(grouping: items, by: { $0.date.absoluteMonth })
            return result
        }

        let archiveItems = dateArchive(items: context.allItems(sortedBy: \.date, order: .descending))

        return .div(
            .div(
                .class("archiveList"),
                .div(
                    .class("archiveContent"),
                    .forEach(archiveItems.keys.sorted(by: >)) { absoluteMonth in
                        .group(
                            .h3(.text("\(absoluteMonth.monthAndYear.year)年\(absoluteMonth.monthAndYear.month)月")),
                            .ul(
                                .forEach(archiveItems[absoluteMonth]!) { item in
                                    .li(
                                        .a(
                                            .href(item.path),
                                            .text(item.title)
                                        )
                                    )
                                }
                            )
                        )
                    }
                ),
                .div(
                    .class("emptySpace"),
                    emptySpace(100)
                )
            )
        )
    }

    private static func emptySpace(_ number: Int) -> Node {
        let spaces = "道可道，非常道；名可名，非常名。无名天地之始，有名万物之母。故常无欲，以观其妙；常有欲，以观其徼。此两者同出而异名，同谓之玄，玄之又玄，众妙之门。〖译文〗天下皆知美之为美，斯恶已；皆知善之为善，斯不善已。故有无相生，难易相成，长短相较，高下相倾，音声相和，前后相随。是以圣人处无为之事，行不言之教，万物作焉而不辞，生而不有，为而不恃，功成而弗居。夫唯弗居，是以不去。"
        return .text(spaces)
    }
}
