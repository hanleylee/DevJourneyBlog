//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Foundation
import Publish

extension Theme where Site == DevJourneyBlog {
    /// HanleyTheme
    static var devJourney: Theme {
        Theme(htmlFactory: DevJourneyHTMLFactory(), resourcePaths: [])
//        Theme(htmlFactory: DevJourneyHTMLFactory(), resourcePaths: [])
    }
}
