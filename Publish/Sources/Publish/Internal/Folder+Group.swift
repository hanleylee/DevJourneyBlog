/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Files

public extension Folder {
    public struct Group {
        public let root: Folder
        public let output: Folder
        public let `internal`: Folder
        public let caches: Folder
    }
}
