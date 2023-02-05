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
        formatter.dateFormat = "发布于 yyyy 年 MM 月 dd 日"
        return formatter
    }
}
