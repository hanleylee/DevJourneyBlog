//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/09/1.
//

import Foundation
import Plot
import Publish

public extension Plugin {
    static func highlightJS() -> Self {
        Plugin(name: "HighlightJS") { context in
            context.markdownParser.addModifier(
                .highlightCodeBlocks()
            )
        }
    }
}

public extension Modifier {
    static func highlightCodeBlocks() -> Self {
        let highlighter = HighlightJS()

        return Modifier(target: .codeBlocks) { html, markdown in
            let begin = markdown.components(separatedBy: .newlines).first ?? "```"
            let language = begin.dropFirst("```".count)

            guard language != "no-highlight" else { return html }

            // 找到第一个 \n 的位置
            guard let firstNewlineIndex = markdown.firstIndex(of: "\n") else { return html }
            let startIndex = markdown.index(after: firstNewlineIndex)
            // 找到最后一个 \n 的位置
            guard let lastNewlineIndex = markdown.lastIndex(of: "\n") else { return html }
            // 确保第一个和最后一个 \n 不同
            guard firstNewlineIndex != lastNewlineIndex else { return html }
            // 获取第一个和最后一个 \n 之间的内容
            let code = String(markdown[startIndex ..< lastNewlineIndex])
//            print(result)

            let highlighted = highlighter.highlight(code, as: String(language))

            let randomId = Int.random(in: 1...100000000)
            let codeNode = Node<HTML.BodyContext>.div(
                .class("codeSection"),
                .div(
                    .class("codeHeader"),
                    .div(
                        .class("codeLanguage"),
                        .text(String(language))
                    ),
                    .button(.class("copyButton"),
                            .id("copyButton_\(randomId)"),
//                            .onclick("const text = `\(escapeForJavaScript(code))`; navigator.clipboard.writeText(text);")
                            .script(.raw("""
document.getElementById('copyButton_\(randomId)').addEventListener('click', () => {
const text = `\(code)`;
navigator.clipboard.writeText(text);
})

"""))
                    )
                ),
                .pre(
                    .data(named: "language", value: "\(highlighted.language)"),
                    .class("hljs"),
                    .code(.raw(highlighted.value))
                )
            )
            return codeNode.render()
//            return Node<HTML.BodyContext>.div().render() + "<pre data-language=\"\(highlighted.language)\" class=\"hljs\"><code>\(highlighted.value)\n</code></pre>"
        }
    }
}

func escapeForJavaScript(_ string: String) -> String {
    var escapedString = string
    let replacements = [
        "\\": "\\\\",
        "\"": "\\\"",
        "\'": "\\\'",
        "\n": "\\n",
        "\r": "\\r",
        "\u{000C}": "\\f",
        "\u{0008}": "\\b",
        "\u{0009}": "\\t"
    ]

    for (original, replacement) in replacements {
        escapedString = escapedString.replacingOccurrences(of: original, with: replacement)
    }

    return escapedString
}
