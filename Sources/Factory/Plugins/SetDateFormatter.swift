//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish

extension Plugin {
    static func setDateFormatter() -> Self {
        Plugin(name: "setDateFormatter") { context in
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-DD"
//            dateFormatter.timeZone = .current
//            context.dateFormatter = dateFormatter
            context.dateFormatter.dateFormat = "yyyy-MM-dd"
        }
    }
}
