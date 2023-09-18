//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/18.
//

import Foundation

struct CommonTools {
    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
