/**
 *  Adopted from Ink for CommonInk
 *  Copyright (c) John Sundell 2019
 *  MIT license, see LICENSE file for details
 */

import Markdown

///
/// A parser used to convert Markdown text into HTML.
///
/// You can use an instance of this type to either convert
/// a Markdown string into an HTML string, or into a `Markdown`
/// value, which also contains any metadata values found in
/// the parsed Markdown text.
///
/// To customize how this parser performs its work, attach
/// a `Modifier` using the `addModifier` method.
public struct MarkdownParser {
    private var modifiers: ModifierCollection

    /// Initialize an instance, optionally passing an array
    /// of modifiers used to customize the parsing process.
    public init(modifiers: [Modifier] = []) {
        self.modifiers = ModifierCollection(modifiers: modifiers)
    }

    /// Add a modifier to this parser, which can be used to
    /// customize the parsing process. See `Modifier` for more info.
    public mutating func addModifier(_ modifier: Modifier) {
        modifiers.insert(modifier)
    }

    /// Convert a Markdown string into HTML, discarding any metadata
    /// found in the process. To preserve the Markdown's metadata,
    /// use the `parse` method instead.
    public func html(from markdown: String) -> String {
        parse(markdown).html
    }

    /// Parse a Markdown string into a `Markdown` value, which contains
    /// both the HTML representation of the given string, and also any
    /// metadata values found within it.
    public func parse(_ markdown: String) -> FullMarkdown {
        var metadata: [String: String] = [:]

        var markdown = markdown
        if #available(macOS 13.0, *) {
            if let metadataString = markdown.metadataString() {
                markdown.removeMetadata()

                var metadataLines = metadataString.split(separator: "\n").map { $0.trimmingWhitespaces() }
                    metadataLines.removeAll(where: { $0.isEmpty })
                    let hasMetadataKV = metadataLines
                        .map { $0.contains(":") }
                        .reduce(into: true) { $0 = $0 && $1 }
                    if hasMetadataKV {
                        for string in metadataLines {
                            let firstColonIndex = string.firstIndex(of: ":")!
                            let key = String(string[string.startIndex..<firstColonIndex].trimmingWhitespaces())
                            let value = String(string[string.index(firstColonIndex, offsetBy: 1)..<string.endIndex].trimmingWhitespaces())
                            metadata[key] = value
                        }
                        // Modify Metadata
                        modifiers.applyModifiers(for: .metadataKeys) { modifier in
                            for (key, value) in metadata {
                                let newKey = modifier.closure((key, Substring(key)))
                                metadata[key] = nil
                                metadata[newKey] = value
                            }
                        }

                        modifiers.applyModifiers(for: .metadataValues) { modifier in
                            metadata = metadata.mapValues { value in
                                modifier.closure((value, Substring(value)))
                            }
                        }
                }
            }
        } else {
            fatalError("macos must greater than 13.0")
        }

        var document = Document(parsing: markdown)
        var htmlVisitor = HTMLVisitor(sourceText: markdown, modifiers: modifiers)
        let htmlText = htmlVisitor.visit(document) as String

        return FullMarkdown(
            raw: markdown,
            html: htmlText,
            title: metadata["title"] ?? "",
            metadata: metadata
        )
    }
}
