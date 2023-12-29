/**
 *  Publish
 *  Copyright (c) John Sundell 2020
 *  MIT license, see LICENSE file for details
 */

import Sweep

internal extension String {
    func normalized() -> String {
        String(lowercased().compactMap { character in
            if character.isWhitespace {
                return "-"
            }

            if character.isLetter || character.isNumber {
                return character
            }

            return nil
        })
    }

    func metadataString() -> Substring? {
        return firstSubstring(between: "---", and: "---")
    }

    mutating func removeMetadata() {
        if #available(macOS 13.0, *) {
            if let metadataString = self.firstSubstring(between: "---", and: "---"),
               let metadataRange = self.firstRange(of: "---" + metadataString + "---")
            {
                self.removeSubrange(metadataRange)
            }
        } else {
            fatalError()
        }
    }
}
