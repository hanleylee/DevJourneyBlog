//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/18.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {
    /*
     <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/gitalk@1/dist/gitalk.css">
     */
//    static func gitTalk(topicID: String) -> Node {
//        .raw("""
//        <div id="gitalk-container"></div>
//        <link rel="stylesheet" href="https://cdn.fatbobman.com/gitalk_new.css">
//        <script src="https://cdn.jsdelivr.net/npm/gitalk@1/dist/gitalk.min.js"></script>
//        <script type="text/javascript">
//        var gitalk = new Gitalk({
//        clientID: 'fcf61195c7f73253dc8b',
//        clientSecret: '0ac2907be08248a1fcb5312e27480ad535c682e5',
//        repo: 'blogComments',
//        owner: 'fatbobman',
//        admin: ['fatbobman'],
//        id: '\(topicID)'.split("/").pop().substring(0, 49),      // Ensure uniqueness and length less than 50
//        distractionFreeMode: true,  // Facebook-like distraction free mode
//        createIssueManually: true,
//        language: 'zh-CN'
//        });
//
//        gitalk.render('gitalk-container');
//
//        </script>
//        """)
//    }
}
