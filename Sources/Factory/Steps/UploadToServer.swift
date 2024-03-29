//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Publish
import ShellOut

extension PublishingStep {
    static func uploadToServer() -> Self {
        step(named: "update files to hanleylee.com") { _ in
            print("uploading......")
            do {
                try shellOut(
                    to: "scp -i ~/.ssh/id_rsa -r  Output root@xxx.xxx.xxx.xxx:/var/www")
            } catch {
                print(error)
            }
        }
    }
}
