//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation

extension Date {
    var absoluteMonth: Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year, .month], from: self)
        guard let year = component.year, let month = component.month else { fatalError() }
        return year * 12 + month
    }
}
