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
        guard let sectionType = section.id as? DevJourneyBlog.SectionID else { fatalError() }
        switch sectionType {
        case .recent:
            return try indexHTML(for: section, context: context)
        case .articles:
            return articlesHTML(for: section, context: context)
        case .about:
            return .about(for: section, context: context)
        case .search:
            return .search(for: section, context: context)
        }
    }
}
