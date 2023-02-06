//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish

extension DevJourneyHTMLFactory {
    func pageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        if page.path == Path("support") {
            return .supporter(for: page, context: context)
        } else {
            return .common(for: page, context: context)
        }
    }
}
