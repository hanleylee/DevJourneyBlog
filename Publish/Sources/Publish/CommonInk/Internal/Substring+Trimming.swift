/**
*  Adopted from Ink for CommonInk
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal extension Substring {
    func trimmingWhitespaces() -> Self {
        var trimmed = self
        
        while trimmed.first?.isWhitespace == true {
            trimmed = trimmed.dropFirst()
        }
        
        while trimmed.last?.isWhitespace == true {
            trimmed = trimmed.dropLast()
        }

        return trimmed
    }
}

internal extension String {
    var escaped: String {
        self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }
}
