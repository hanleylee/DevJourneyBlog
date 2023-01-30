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
    func sectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        switch section.id.rawValue {
        case "home":
            return HTML(.text("Hello home!"))
        case "articles":
            return try postsHTML(for: section, context: context)
        case "about":
            return HTML(.text("Hello about!"))
        default:
            return try postsHTML(for: section, context: context)
        }
    }
}
