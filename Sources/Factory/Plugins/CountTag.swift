//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish

extension Plugin {
    /// 计算每个 tag 的数量
    static func countTags() -> Self {
        return Plugin(name: "countTag") { content in
            Tag.generateCount(content: content)
        }
    }
}
