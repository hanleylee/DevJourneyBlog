//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/8.
//

import Foundation
import Plot
import Publish

extension Node where Context == HTML.BodyContext {

    // static func toc(_ nodes: Node<HTML.BodyContext>...) -> Node {
    //     .element(named: "sidebar", nodes: nodes)
    // }


    static func sideNav(_ nodes: Node...) -> Node {
        .div(
            .class("side-nav"),
            .group(nodes)
        )
    }


}

/*
 <!-- Baidu Tongji -->

 <script>
     // dynamic User by Hux
     var _baId = '14e5d60a3ea6276655f9d14c58b1fcd0';

     // Originial
     var _hmt = _hmt || [];
     (function() {
       var hm = document.createElement("script");
       hm.src = "//hm.baidu.com/hm.js?" + _baId;
       var s = document.getElementsByTagName("script")[0];
       s.parentNode.insertBefore(hm, s);
     })();
 </script>
 */
