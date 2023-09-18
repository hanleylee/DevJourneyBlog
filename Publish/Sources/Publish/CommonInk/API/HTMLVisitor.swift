//
//  HTMLWriter.swift
//  
//
//  Created by Zhijin Chen on 2022/03/10.
//

import Markdown

struct HTMLVisitor: MarkupVisitor {
    typealias Result = String
    
    let sourceText: String?
    let modifiers: ModifierCollection
    
    public mutating func childrenHTML(_ markup: Markup) -> Result {
        return markup.children.map { child in
            visit(child)
        }.joined(separator: "")
    }
    
    mutating func defaultVisit(_ markup: Markup) -> Result {
        childrenHTML(markup)
    }
    
    func tryToModify(_ markUp: Markup, for target: Modifier.Target, defaultHtml html: String) -> String {
        var html = html
        if !(markUp is Table.Cell) && !(markUp is Table.Head) && !(markUp is Table.Row) && !(markUp is Table.Body)  {
            
            let formatted = Substring(markUp.format()).trimmingWhitespaces()
            modifiers.applyModifiers(for: target) { modifier in
                html = modifier.closure((html, formatted))
            }
            return html
        }
        
        guard let range = markUp.range, let rawString = sourceText?.substring(in: range) else { return html }
        modifiers.applyModifiers(for: target) { modifier in
            html = modifier.closure((html, rawString))
        }
        return html
    }
    
    /**
     Visit a `BlockQuote` element and return the result.
     - parameter blockQuote: A `BlockQuote` element.
     - returns: The result of the visit.
     */
    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        let html = "<blockquote>\(childrenHTML(blockQuote))</blockquote>"
        return tryToModify(blockQuote, for: .blockquotes, defaultHtml: html)
    }

    /**
     Visit a `CodeBlock` element and return the result.
     - parameter codeBlock: An `CodeBlock` element.
     - returns: The result of the visit.
     */
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        let languageClass: String =  codeBlock.language != nil ? " class=\"language-\(codeBlock.language!)\"" : ""
        let html = "<pre><code\(languageClass)>\(codeBlock.code.escaped)</code></pre>"
        return tryToModify(codeBlock, for: .codeBlocks, defaultHtml: html)
    }

    /**
     Visit a `CustomBlock` element and return the result.
     - parameter customBlock: An `CustomBlock` element.
     - returns: The result of the visit.
     */
    mutating func visitCustomBlock(_ customBlock: CustomBlock) -> Result {
        fatalError()
    }

    /**
     Visit a `Document` element and return the result.
     - parameter document: An `Document` element.
     - returns: The result of the visit.
     */
    mutating func visitDocument(_ document: Document) -> Result {
        let html = childrenHTML(document)
        return tryToModify(document, for: .document, defaultHtml: html)
    }

    /**
     Visit a `Heading` element and return the result.
     - parameter heading: An `Heading` element.
     - returns: The result of the visit.
     */
    mutating func visitHeading(_ heading: Heading) -> Result {
        let html = "<h\(heading.level)>" + childrenHTML(heading) + "</h\(heading.level)>"
        return tryToModify(heading, for: .headings, defaultHtml: html)
    }

    /**
     Visit a `ThematicBreak` element and return the result.
     - parameter thematicBreak: An `ThematicBreak` element.
     - returns: The result of the visit.
     */
    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Result {
        let html = "<hr />"
        return tryToModify(thematicBreak, for: .horizontalLines, defaultHtml: html)
    }
    
    /**
     Visit an `HTML` element and return the result.
     - parameter html: An `HTML` element.
     - returns: The result of the visit.
     */
    mutating func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        return tryToModify(html, for: .html, defaultHtml: html.format())
    }
    
    /**
     Visit a `ListItem` element and return the result.
     - parameter listItem: An `ListItem` element.
     - returns: The result of the visit.
     */
    mutating func visitListItem(_ listItem: ListItem) -> Result {
        let html: String
        
        
        if let checkbox = listItem.checkbox {
            if checkbox == .checked {
                html = "<li ><input checked=\"\" disabled=\"\" type=\"checkbox\">" + childrenHTML(listItem) + "</li>"
            } else {
                html = "<li ><input disabled=\"\" type=\"checkbox\">" + childrenHTML(listItem) + "</li>"
            }
        } else {
            html = "<li>" + childrenHTML(listItem) + "</li>"
        }
        
        return tryToModify(listItem, for: .listItem, defaultHtml: html)
    }

    /**
     Visit a `OrderedList` element and return the result.
     - parameter orderedList: An `OrderedList` element.
     - returns: The result of the visit.
     */
    mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        
        
        var itemsHTML = ""
        for item in orderedList.listItems {
            itemsHTML.append(visit(item))
        }
        
        let start: String
        if let item = orderedList.children.first(where: { $0 is ListItem }) as? ListItem {
            if let number = Int(item.format().split(separator: ".").first ?? "") {
                start = " start=\"\(number)\""
            } else if let number = Int(item.format().split(separator: ")").first ?? "") {
                start = " start=\"\(number)\""
            } else {
                start = ""
            }
        } else {
            start = ""
        }
        
        var html = "<ol\(start)>" + itemsHTML + "</ol>"
        html = tryToModify(orderedList, for: .lists, defaultHtml: html)
        return tryToModify(orderedList, for: .orderedList, defaultHtml: html)
    }

    /**
     Visit a `UnorderedList` element and return the result.
     - parameter unorderedList: An `UnorderedList` element.
     - returns: The result of the visit.
     */
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        var itemsHTML = ""
        
        //print(unorderedList.debugDescription())
        
        for item in unorderedList.listItems {
            itemsHTML.append(visit(item))
        }
        var html = "<ul>" + itemsHTML + "</ul>"
        html = tryToModify(unorderedList, for: .lists, defaultHtml: html)
        return tryToModify(unorderedList, for: .unorderedList, defaultHtml: html)
    }
    
    /**
     Visit a `Paragraph` element and return the result.}
     - parameter paragraph: An `Paragraph` element.
     - returns: The result of the visit.
     */
    mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        if paragraph.parent is ListItem, paragraph.parent!.children.filter({ $0 is Paragraph }).count == 1 {
            let html = childrenHTML(paragraph)
            return tryToModify(paragraph, for: .paragraphs, defaultHtml: html)
        }
        let html = "<p>" + childrenHTML(paragraph) + "</p>"
        return tryToModify(paragraph, for: .paragraphs, defaultHtml: html)
    }

    /**
     Visit a `BlockDirective` element and return the result.
     - parameter blockDirective: A `BlockDirective` element.
     - returns: The result of the visit.
     */
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
        let html = childrenHTML(blockDirective)
        return tryToModify(blockDirective, for: .blockDirective, defaultHtml: html)
    }

    /**
     Visit a `InlineCode` element and return the result.
     - parameter inlineCode: An `InlineCode` element.
     - returns: The result of the visit.
     */
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        let html = "<code>" + inlineCode.code.escaped + "</code>"
        return tryToModify(inlineCode, for: .inlineCode, defaultHtml: html)
    }

    /**
     Visit a `CustomInline` element and return the result.
     - parameter customInline: An `CustomInline` element.
     - returns: The result of the visit.
     */
    mutating func visitCustomInline(_ customInline: CustomInline) -> Result {
        fatalError()
    }

    /**
     Visit a `Emphasis` element and return the result.
     - parameter emphasis: An `Emphasis` element.
     - returns: The result of the visit.
     */
    mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
        let html = "<em>\(childrenHTML(emphasis))</em>"
        return tryToModify(emphasis, for: .emphasis, defaultHtml: html)
    }

    /**
     Visit a `Image` element and return the result.
     - parameter image: An `Image` element.
     - returns: The result of the visit.
     */
    mutating func visitImage(_ image: Image) -> Result {
        var alt = image.title ?? ""
        if !alt.isEmpty {
            alt = " alt=\"\(alt)\""
        }
        let html = "<img src=\"\(image.source ?? "")\"\(alt)/>"
        return tryToModify(image, for: .images, defaultHtml: html)
    }

    /**
     Visit a `InlineHTML` element and return the result.
     - parameter inlineHTML: An `InlineHTML` element.
     - returns: The result of the visit.
     */
    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        let html = inlineHTML.rawHTML
        return tryToModify(inlineHTML, for: .inlineHTML, defaultHtml: html)
    }

    /**
     Visit a `LineBreak` element and return the result.
     - parameter lineBreak: An `LineBreak` element.
     - returns: The result of the visit.
     */
    mutating func visitLineBreak(_ lineBreak: LineBreak) -> Result {
        return "<br>"
    }

    /**
     Visit a `Link` element and return the result.
     - parameter link: An `Link` element.
     - returns: The result of the visit.
     */
    mutating func visitLink(_ link: Link) -> Result {
        let html = "<a href=\"\(link.destination ?? "")\">\(childrenHTML(link))</a>"
        return tryToModify(link, for: .links, defaultHtml: html)
    }
    
    /**
     Visit a `SoftBreak` element and return the result.
     - parameter softBreak: An `SoftBreak` element.
     - returns: The result of the visit.
     */
    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> Result {
        return " "
    }

    /**
     Visit a `Strong` element and return the result.
     - parameter strong: An `Strong` element.
     - returns: The result of the visit.
     */
    mutating func visitStrong(_ strong: Strong) -> Result {
        let html = "<strong>" + childrenHTML(strong) + "</strong>"
        return tryToModify(strong, for: .strong, defaultHtml: html)
    }

    /**
     Visit a `Text` element and return the result.
     - parameter text: A `Text` element.
     - returns: The result of the visit.
     */
    mutating func visitText(_ text: Text) -> Result {
        
        
        let html = text.string.split(separator: "\n").filter({ !$0.hasPrefix("[comment]: #") }).joined(separator: "\n").escaped
        return tryToModify(text, for: .text, defaultHtml: html)
    }

    /**
     Visit a `Strikethrough` element and return the result.
     - parameter strikethrough: A `Strikethrough` element.
     - returns: The result of the visit.
     */
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        let html = "<s>\(childrenHTML(strikethrough))</s>"
        return tryToModify(strikethrough, for: .strikethrough, defaultHtml: html)
    }

    /**
     Visit a `Table` element and return the result.
     - parameter table: A `Table` element.
     - returns: The result of the visit.
     */
    mutating func visitTable(_ table: Table) -> Result {
        let html = "<table>\(childrenHTML(table))</table>"
        return tryToModify(table, for: .tables, defaultHtml: html)
    }

    /**
     Visit a `Table.Head` element and return the result.
     - parameter tableHead: A `Table.Head` element.
     - returns: The result of the visit.
     */
    mutating func visitTableHead(_ tableHead: Table.Head) -> Result {
        let html = "<thead>\(childrenHTML(tableHead))</thead>".replacingOccurrences(of: "<td>", with: "<th>").replacingOccurrences(of: "</td>", with: "</th>")
        return tryToModify(tableHead, for: .tableHead, defaultHtml: html)
    }

    /**
     Visit a `Table.Body` element and return the result.
     - parameter tableBody: A `Table.Body` element.
     - returns: The result of the visit.
     */
    mutating func visitTableBody(_ tableBody: Table.Body) -> Result {
        let html = "<tbody>\(childrenHTML(tableBody))</tbody>"
        return tryToModify(tableBody, for: .tableBody, defaultHtml: html)
    }

    /**
     Visit a `Table.Row` element and return the result.
     - parameter tableRow: A `Table.Row` element.
     - returns: The result of the visit.
     */
    mutating func visitTableRow(_ tableRow: Table.Row) -> Result {
        let html = "<tr>\(childrenHTML(tableRow))</tr>"
        return tryToModify(tableRow, for: .tableRow, defaultHtml: html)
    }

    /**
     Visit a `Table.Cell` element and return the result.
     - parameter tableCell: A `Table.Cell` element.
     - returns: The result of the visit.
     */
    mutating func visitTableCell(_ tableCell: Table.Cell) -> Result {
        let html = "<td>\(childrenHTML(tableCell))</td>"
        return tryToModify(tableCell, for: .tableCell, defaultHtml: html)
    }

    /**
     Visit a `SymbolLink` element and return the result.
     - parameter symbolLink: A `SymbolLink` element.
     - returns: The result of the visit.
     */
    mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> Result {
        //symbolLink.plainText
        fatalError()
    }
}


extension ListItemContainer {
    func isLoose() -> Bool {
        if self.format().contains("\n\n") {
            return true
        }
        //if self.children.
        return false
    }
}
