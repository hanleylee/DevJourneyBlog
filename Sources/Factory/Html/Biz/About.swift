//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/2/6.
//

import Files
import Foundation
import Plot
import Publish

extension HTML {
    static func about<Site>(for page: Section<Site>, context: PublishingContext<Site>) -> HTML {
        guard let aboutFilePath = Bundle.module.path(forResource: "About", ofType: "md") else { return .notFound() }

        do {
            let aboutFile = try File(path: aboutFilePath)
            let aboutContent = try aboutFile.readAsString()

            return HTML(
                .lang(context.site.language),
                .siteHeader(for: page, on: context.site),
                .body(
                    .pageHeader(for: context, selectedSection: DevJourneyBlog.SectionID.about as? Site.SectionID),
                    .container(
                        .wrapper(
                            .div(
                                .class("about"),
                                .article(
                                    .div(
                                        .class("content"),
                                        .raw(context.markdownParser.parse(aboutContent).html)
                                    )
                                )
                            )
                        )
                    ),
                    .commonFooter(for: context.site)
                )
            )
        } catch(let error) {
            debugPrint(error.localizedDescription)
            return .notFound()
        }
    }
}
