//
//  String+Extension.swift
//  
//
//  Created by Zhijin Chen on 2022/03/13.
//
import Markdown

//fileprivate var lineLocationCache : [String: [String.Index]] = [:]
public extension String {

    private func index(at location: SourceLocation) -> String.Index? {
//        if lineLocationCache[self] == nil {
//            lineLocationCache[self] = [self.startIndex] + self.indices.filter { self[$0].isNewline }.map { self.index($0, offsetBy: 1) }
//        }
//        guard let newLineLocations = lineLocationCache[self] else { return nil }
//
//        guard let lineStartInUtf8 = newLineLocations[location.line - 1].samePosition(in: self.utf8) else { return nil }
//        return self.utf8.index(lineStartInUtf8, offsetBy: location.column - 1).samePosition(in: self)

        let newLineLocations = [self.startIndex] + self.indices.filter { self[$0].isNewline }.map { self.index($0, offsetBy: 1) }

        guard let lineStartInUtf8 = newLineLocations[location.line - 1].samePosition(in: self.utf8) else { return nil }
        return self.utf8.index(lineStartInUtf8, offsetBy: location.column - 1).samePosition(in: self)
    }
    
    func substring(in range: SourceRange) -> Substring? {
        guard let lowerBound = self.index(at: range.lowerBound), let upperBound = self.index(at: range.upperBound) else { return nil }
        return self[lowerBound..<upperBound]
    }
}

