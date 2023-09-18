//
//  File.swift
//  
//
//  Created by Hanley Lee on 2023/1/30.
//

import Foundation
import Publish
import Splash

public extension Plugin {
    static func splash(withClassPrefix classPrefix: String) -> Self {
        Plugin(name: "Splash") { context in
            let format = HTMLOutputFormat(classPrefix: classPrefix)
            context.markdownParser.addModifier(.splashCodeBlocks(withFormat: format))
        }
    }
}

public extension Modifier {
    static func splashCodeBlocks(withFormat format: HTMLOutputFormat = .init()) -> Self {
        let highlighter = SyntaxHighlighter(format: format)

        return Modifier(target: .codeBlocks) { html, markdown in
            let begin = markdown.components(separatedBy: .newlines).first ?? "```"
            let language = begin.dropFirst("```".count)

            guard language != "no-highlight" else {
                return html
            }

            let code = markdown
                .drop(while: { !$0.isNewline })
                .dropFirst()
                .dropLast("\n```".count)

            let highlighted = highlighter.highlight(String(code))
            return "<pre><code>" + highlighted + "\n</code></pre>"
        }
    }
}
