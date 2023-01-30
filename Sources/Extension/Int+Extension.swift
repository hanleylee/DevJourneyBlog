//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation

extension Int {
    var monthAndYear: (year: Int, month: Int) {
        var month = self % 12
        var year = self / 12
        if month == 0 {
            month = 12
            year -= 1
        }
        return (year, month)
    }
}
