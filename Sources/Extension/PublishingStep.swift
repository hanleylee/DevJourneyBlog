//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/1/30.
//

import Foundation
import Publish

extension PublishingStep {
    static func addModifier(modifier: Modifier, modifierName name: String = "") -> Self {
        .step(named: "addModifier \(name)") { context in
            context.markdownParser.addModifier(modifier)
        }
    }
}
