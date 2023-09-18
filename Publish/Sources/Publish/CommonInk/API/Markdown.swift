/**
 *  Adopted from Ink for CommonInk
 *  Copyright (c) John Sundell 2019
 *  MIT license, see LICENSE file for details
 */

import Sweep

///
/// A parsed Markdown value, which contains its rendered
/// HTML representation, as well as any metadata found at
/// the top of the Markdown document.
///
/// You create instances of this type by parsing Markdown
/// strings using `MarkdownParser`.
public struct FullMarkdown {
    /// raw markdown content
    public let raw: String
    /// The HTML representation of the Markdown, ready to
    /// be rendered in a web browser.
    public let html: String
    /// The inferred title of the document, from any top-level
    /// heading found when parsing. If the Markdown text contained
    /// two top-level headings, then this property will contain
    /// the first one. Note that this property does not take modifiers
    /// into acccount.
    public let title: String
    /// Any metadata values found at the top of the Markdown
    /// document. See this project's README for more information.
    public let metadata: [String: String]
}

extension FullMarkdown {
    var exposeDescription: String {
        var raw = raw
        raw.removeMetadata()
        if let desc = raw.firstSubstring(between: "\n", and: "<!-- more -->") {
            return String(desc)
        }
        return ""
    }
}
