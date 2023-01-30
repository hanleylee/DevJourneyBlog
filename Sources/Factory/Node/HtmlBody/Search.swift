//
//  File.swift
//
//
//  Created by Hanley Lee on 2023/1/13.
//

import Foundation
import Plot
import Publish
import Sweep

extension Node where Context == HTML.DocumentContext {
    static func searchHead<T: Website>(
        for location: Location,
        on site: T,
        titleSeparator: String = " | ",
        stylesheetPaths: [Path] = ["/styles.css"],
        rssFeedPath: Path? = .defaultForRSSFeed,
        rssFeedTitle: String? = nil
    ) -> Node {
        var title = location.title

        if title.isEmpty {
            title = site.name
        } else {
            title.append(titleSeparator + site.name)
        }

        var description = location.description

        if description.isEmpty { description = site.description }

        return .head(
            .encoding(.utf8),
            .siteName(site.name),
            .url(site.url(for: location)),
            .title(title),
            .description(description),
            .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
            .meta(.name("twitter:site"), .content("@Hanley_Lei")),
            .meta(.name("twitter:creator"), .content("@Hanley_Lei")),
            .meta(.name("referrer"), .content("no-referrer")),
            .forEach(stylesheetPaths) { .stylesheet($0) },
            .viewport(.accordingToDevice),
            .unwrap(site.favicon) { .favicon($0) },
            .unwrap(
                rssFeedPath,
                { path in let title = rssFeedTitle ?? "Subscribe to \(site.name)"
                    return .rssFeedLink(path.absoluteString, title: title)
                }
            ),
            .unwrap(
                location.imagePath ?? site.imagePath,
                { path in
                    let url = site.url(for: path)
                    return .socialImageLink(url)
                }
            ),
            .script(.src("//cdn.bootcss.com/jquery/3.2.1/jquery.min.js"))
        )
    }
}

extension Node where Context == HTML.BodyContext {
    static func searchResult() -> Node {
        .div(
            .id("local-search-result"),
            .class("local-search-result-cls")
        )
    }

    static func searchInput() -> Node {
        .div(
            .class("searchform"),
            .form(
                .class("site-search-form"),
                .input(
                    .class("st-search-input"),
                    .attribute(named: "type", value: "text"),
                    .id("local-search-input"),
                    .required(true),
                    .placeholder("请输入你要搜索的内容...")
                ),
                .a(
                    .class("clearSearchInput"),
                    .href("javascript:"),
                    .onclick("""
                    document.getElementById('local-search-input').value = '';
                    """)
                )
            ),
            .script(
                .id("local.search.active"),
                .raw(
                    """
                        var inputArea  = document.querySelector("#local-search-input");
                        inputArea.onclick   = function(){
                            getSearchFile();
                            this.onclick = null
                        }
                        inputArea.onkeydown = function(){
                            if(event.keyCode == 13) return false
                        }
                    """
                )
            ),
            .script(
                .raw(searchJS)
            ),
            // 窗口变化
            .script(
                .raw(
                    """
                        var resizeTimer = null;

                        $(window).resize(function(){
                            setHeight();
                        // if(resizeTimer){
                        //     clearTimeout(resizeTimer);
                        // }
                        // resizeTimer = setTimeout(function(){
                        //     setHeight();
                        // },100)
                        })
                    """
                )
            ),
            // 设置search-result height
            .script(
                .raw("""
                    var setHeight = function(){
                        // swiftlint:disable line_length
                        var totalHeight = $('.local-search-result-cls').get(0).offsetHeight + $('.site-search-form').get(0).offsetHeight + $('.all-tags').get(0).offsetHeight + $('footer').get(0).offsetHeight + $('header').get(0).offsetHeight + 70
                        var padding = parseInt($('.wrapper').css('padding-top')) + parseInt($('.wrapper').css('padding-bottom')) ;
                        if (totalHeight < window.innerHeight) {
                            $('.wrapper').height( window.innerHeight - 50 - $('footer').get(0).offsetHeight - $('header').get(0).offsetHeight );
                        }
                        else {
                            $('.wrapper').height( $('.local-search-result-cls').get(0).offsetHeight + $('.site-search-form').get(0).offsetHeight + $('.all-tags').get(0).offsetHeight + 20);
                        }
                     }
                    """
                )
            ),
            .script(
                .raw(
                    """
                    $(document).ready(function(){
                        var emote_list = document.getElementById('local-search-result');
                        emote_list.addEventListener('DOMSubtreeModified', function () {
                           setHeight()
                        }, false);
                    })
                    """
                )
            ),
            .script(
                .raw(
                    """
                    $(document).ready(function(){
                      //setTimeout(function(){
                            setHeight();
                      //  },100)
                    })
                    """
                )
            )
        )
    }
}

fileprivate let searchJS =
    #"""
    var searchFunc = function(path, search_id, content_id) {
        'use strict';

    $.ajax({
            url: path,
            dataType: "xml",
            success: function( xmlResponse ) {
                // get the contents from search data
                var datas = $( "entry", xmlResponse ).map(function() {
                    return {
                        title: $( "title", this ).text(),
                        content: $("content",this).text(),
                        url: $( "url" , this).text()
                    };
                }).get();

                var $input = document.getElementById(search_id);
                if (!$input) return;
                var $resultContent = document.getElementById(content_id);
                if ($("#local-search-input").length > 0) {
                    $input.addEventListener('input', function () {
                        var str = '<ul class=\"search-result-list\">';
                        var keywords = this.value.trim().toLowerCase().split(/[\s\-]+/);
                        $resultContent.innerHTML = "";
                        if (this.value.trim().length <= 0) {
                            return;
                        }
                        // perform local searching
                        datas.forEach(function (data) {
                            var isMatch = true;
                            var content_index = [];
                            if (!data.title || data.title.trim() === '') {
                                data.title = "Untitled";
                            }
                            var data_title = data.title.trim().toLowerCase();
                            var data_content = data.content.trim().replace(/<[^>]+>/g, "").toLowerCase();
                            var data_url = data.url;
                            var index_title = -1;
                            var index_content = -1;
                            var first_occur = -1;
                            // only match artiles with not empty contents
                            if (data_content !== '') {
                                keywords.forEach(function (keyword, i) {
                                    index_title = data_title.indexOf(keyword);
                                    index_content = data_content.indexOf(keyword);

                                    if (index_title < 0 && index_content < 0) {
                                        isMatch = false;
                                    } else {
                                        if (index_content < 0) {
                                            index_content = 0;
                                        }
                                        if (i == 0) {
                                            first_occur = index_content;
                                        }
                                        // content_index.push({index_content:index_content, keyword_len:keyword_len});
                                    }
                                });
                            } else {
                                isMatch = false;
                            }
                            // show search results
                            if (isMatch) {
                                str += "<li><a href='" + data_url + "' class='search-result-title'>" + data_title + "</a>";
                                var content = data.content.trim().replace(/<[^>]+>/g, "");
                                if (first_occur >= 0) {
                                    // cut out 100 characters
                                    var start = first_occur - 60;
                                    var end = first_occur + 120;

                                    if (start < 0) {
                                        start = 0;
                                    }

                                    if (start == 0) {
                                        end = 180;
                                    }

                                    if (end > content.length) {
                                        end = content.length;
                                    }

                                    var match_content = content.substring(start, end);

                                    // highlight all keywords
                                    keywords.forEach(function (keyword) {
                                        var regS = new RegExp(keyword, "gi");
                                        match_content = match_content.replace(regS, "<em class=\"search-keyword\">" + keyword + "</em>");
                                    });

                                    str += "<p class=\"search-result\">" + match_content + "...</p>"
                                }
                                str += "</li>";
                            }
                        });
                        str += "</ul>";
                        $resultContent.innerHTML = str;
                    });
                }
            }
        });
    }

    var getSearchFile = function(){
        var path = "/search.xml";
        searchFunc(path, 'local-search-input', 'local-search-result');
    }

    """#
