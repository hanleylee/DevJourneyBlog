//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish

extension PublishingContext {
    /// Item count
    var itemCount: Int {
        allItems(sortedBy: \.date, order: .descending).count
    }
}
