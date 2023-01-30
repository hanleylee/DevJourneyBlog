---
title: iOS 之 URL Scheme
date: 2020-03-01
comments: true
path: url-scheme-of-ios
categories: iOS
tags: ⦿ios, ⦿url-scheme, ⦿universal-link
updated:
---

![himg](https://a.hanleylee.com/HKMS/2020-03-02-044608.png?x-oss-process=style/WaMa)

<!-- more -->

URL Scheme 是苹果设计用来在本应用内打开其他应用 (并在其他打开其他指定页面, 亦可传递参数) 的一个方法, 其格式与 URL 的请求格式类似, 对比如下:

- URL: `https://www.hanleylee.com`
- URL Scheme: `scheme://host:port/path`

比如微信扫一扫功能的 URL Scheme 就是 `weixin://dl/scan`

## URL Scheme 的优缺点对比

1. 优点

2. 缺点

## iOS 项目中使用 URL Scheme

本 App 可以打开第三方其他 App; 同理, 第三方 App 也可以打开我们的 App, 这涉及到两方面的设置

### 本应用唤醒其他应用

1. 在 `Info.plist` 的 `LSApplicationQueriesSchemes` 中注册要打开的应用的 `URL Scheme` (这一步也被称为设置 "白名单". 除系统组件不需要额外注册外, 其他第三方 App 都需要注册, fb 也不能例外)

    ![himg](https://a.hanleylee.com/HKMS/2020-03-01-041546.png?x-oss-process=style/WaMa)

2. 在要执行打开其他 App 的位置执行以下程序 (注意, 要先用 `canOpenUrl` 来确认是否可以打开)

    ```swift
    if let url1 = URL(string: "fb://profile/100041507435168"), let url2 = URL(string: "https://www.facebook.com/hanley.lei") {
        if UIApplication.shared.canOpenURL(url1) {
            UIApplication.shared.open(url1, options: [:]) { (success) in }
        }
        else {
            UIApplication.shared.open(url2, options: [:]) { (success) in }
        }
    }
    ```

### 其他应用唤醒本应用

1. 在 `Info.plist` 文件中的 `URL types` → `Item 0` → `URL Schemes` → `Item 0` 做如下设置

    ![himg](https://a.hanleylee.com/HKMS/2020-03-01-044832.png?x-oss-process=style/WaMa)

    注意:

    - **URL Scheme 名不可以数字开头!**
    - `URL identifier` 这一项, 我很好奇是什么作用, 看了一大堆博客, 每个博客都互相抄, 说是 "该字符串是你自定义的 URL scheme 的名字.  建议采用反转域名的方法保证该名字的唯一性", 我感觉他们自己都不知道这是干什么的. 我查了下 alipay 中 `Info.plist` 文件这一项的设置, 发现 alipay 自己都没有对自己的 `URL Scheme` 组设置 `Identifier`, 而只是对其他三个组设置了 `Identifier`, 所以我认为这一项完全就是给自己看的, 用来进行分组, 设置不设置见仁见智, 可有可无.

    ![himg](https://a.hanleylee.com/HKMS/2020-03-01-045444.png?x-oss-process=style/WaMa)

2. 在 `Appdelegate.swift` 文件中实作 `optional func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool` 方法, 以根据用户输入的不同 `Scheme URL` 在进入本 App 时执行不同的动作

    ```swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == nil {
            return true;
        }

        // 获取来源应用的 Identifier
        // print("来源 App: \(options[UIApplication.OpenURLOptionsKey.sourceApplication]!)")
        if url.path == "123" {
            print("123")
        } else {
            print("32")
        }

        // 获取 url 以及参数
        let urlString = url.absoluteString
        let queryArray = urlString.components(separatedBy: "/")
        print(urlString)

        simpleInfoAlert(info: "\(queryArray[2])  \(queryArray[3])", duration: 2, interact: true)
        return true
    }
    ```

### 注意

- 在 `Info.plist` 的 `LSApplicationQueriesSchemes` 中最多注册 100 个 `URL Scheme`, 这是因为 Apple 担心某些 App 使用此功能配合 `canOpenUrl` 检测用户装了哪些 App, 这会触犯到用户的隐私
- 如果两个 App 的 `URL Scheme` 相同, 那么最近安装 App 的 `URL Scheme` 将会替代前面安装 App 的 `URL Scheme`

## 常用的 URL Scheme

### 系统

| 打开项                                   | 对应 URL Scheme                                               |
|------------------------------------------|---------------------------------------------------------------|
| 短信                                     | `sms://`                                                      |
| app store                                | `itms-apps://`                                                |
| 电话                                     | `tel://`                                                      |
| 备忘录                                   | `mobilenotes://`                                              |
| 设置                                     | `prefs:root=SETTING`                                          |
| E-Mail                                   | `MESSAGE://`                                                  |
| iCloud                                   | `prefs:root=CASTLE`                                           |
| iCloud Backup                            | `prefs:root=CASTLE&path=BACKUP`                               |
| Wi-Fi                                    | `prefs:root=WIFI`                                             |
| Bluetooth                                | `prefs:root=Bluetooth`                                        |
| Cellular                                 | `prefs:root=MOBILE_DATA_SETTINGS_ID`                          |
| Personal Hotspot                         | `prefs:root=INTERNET_TETHERING`                               |
| Personal Hotspot ⇾ Family Sharing        | `prefs:root=INTERNET_TETHERING&path=Family%20Sharing`         |
| Personal Hotspot ⇾ Wi-Fi Password        | `prefs:root=INTERNET_TETHERING&path=Wi-Fi%20Password`         |
| VPN                                      | `prefs:root=General&path=VPN`                                 |
| Notifications                            | `prefs:root=NOTIFICATIONS_ID`                                 |
| Notifications ⇾ Siri Suggestions         | `prefs:root=NOTIFICATIONS_ID&path=Siri%20Suggestions`         |
| Sounds                                   | `prefs:root=Sounds`                                           |
| Ringtone                                 | `prefs:root=Sounds&path=Ringtone`                             |
| Do Not Disturb                           | `prefs:root=DO_NOT_DISTURB`                                   |
| Do Not Disturb ⇾ Allow Calls From        | `prefs:root=DO_NOT_DISTURB&path=Allow%20Calls%20From`         |
| Screen Time                              | `prefs:root=SCREEN_TIME`                                      |
| Screen Time ⇾ Downtime                   | `prefs:root=SCREEN_TIME&path=DOWNTIME`                        |
| Screen Time ⇾ App Limits                 | `prefs:root=SCREEN_TIME&path=APP_LIMITS`                      |
| Screen Time ⇾ Always Allowed             | `prefs:root=SCREEN_TIME&path=ALWAYS_ALLOWED`                  |
| General                                  | `prefs:root=General`                                          |
| General ⇾ About                          | `prefs:root=General&path=About`                               |
| General ⇾ Software Update                | `prefs:root=General&path=SOFTWARE_UPDATE_LINK`                |
| General ⇾ CarPlay                        | `prefs:root=General&path=CARPLAY`                             |
| General ⇾ Background App Refresh         | `prefs:root=General&path=AUTO_CONTENT_DOWNLOAD`               |
| General ⇾ Multitasking (iPad-only)       | `prefs:root=General&path=MULTITASKING`                        |
| General ⇾ Date & Time                    | `prefs:root=General&path=DATE_AND_TIME`                       |
| General ⇾ Keyboard                       | `prefs:root=General&path=Keyboard`                            |
| General ⇾ Keyboard ⇾ Keyboards           | `prefs:root=General&path=Keyboard/KEYBOARDS`                  |
| General ⇾ Keyboard ⇾ Hardware Keyboard   | `prefs:root=General&path=Keyboard/Hardware%20Keyboard`        |
| General ⇾ Keyboard ⇾ Text Replacement    | `prefs:root=General&path=Keyboard/USER_DICTIONARY`            |
| General ⇾ Keyboard ⇾ One Handed Keyboard | `prefs:root=General&path=Keyboard/ReachableKeyboard`          |
| General ⇾ Language & Region              | `prefs:root=General&path=INTERNATIONAL`                       |
| General ⇾ Dictionary                     | `prefs:root=General&path=DICTIONARY`                          |
| General ⇾ Profiles                       | `prefs:root=General&path=ManagedConfigurationList`            |
| General ⇾ Reset                          | `prefs:root=General&path=Reset`                               |
| Control Center                           | `prefs:root=ControlCenter`                                    |
| Control Center ⇾ Customize Controls      | `prefs:root=ControlCenter&path=CUSTOMIZE_CONTROLS`            |
| Display                                  | `prefs:root=DISPLAY`                                          |
| Display ⇾ Auto Lock                      | `prefs:root=DISPLAY&path=AUTOLOCK`                            |
| Display ⇾ Text Size                      | `prefs:root=DISPLAY&path=TEXT_SIZE`                           |
| Accessibility                            | `prefs:root=ACCESSIBILITY`                                    |
| Wallpaper                                | `prefs:root=Wallpaper`                                        |
| Siri                                     | `prefs:root=SIRI`                                             |
| Apple Pencil (iPad-only)                 | `prefs:root=Pencil`                                           |
| Face ID                                  | `prefs:root=PASSCODE`                                         |
| Emergency SOS                            | `prefs:root=EMERGENCY_SOS`                                    |
| Battery                                  | `prefs:root=BATTERY_USAGE`                                    |
| Battery ⇾ Battery Health (iPhone-only)   | `prefs:root=BATTERY_USAGE&path=BATTERY_HEALTH`                |
| Privacy                                  | `prefs:root=Privacy`                                          |
| Privacy ⇾ Location Services              | `prefs:root=Privacy&path=LOCATION`                            |
| Privacy ⇾ Contacts                       | `prefs:root=Privacy&path=CONTACTS`                            |
| Privacy ⇾ Calendars                      | `prefs:root=Privacy&path=CALENDARS`                           |
| Privacy ⇾ Reminders                      | `prefs:root=Privacy&path=REMINDERS`                           |
| Privacy ⇾ Photos                         | `prefs:root=Privacy&path=PHOTOS`                              |
| Privacy ⇾ Microphone                     | `prefs:root=Privacy&path=MICROPHONE`                          |
| Privacy ⇾ Speech Recognition             | `prefs:root=Privacy&path=SPEECH_RECOGNITION`                  |
| Privacy ⇾ Camera                         | `prefs:root=Privacy&path=CAMERA`                              |
| Privacy ⇾ Motion                         | `prefs:root=Privacy&path=MOTION\`                             |
| App Store                                | `prefs:root=STORE`                                            |
| App Store ⇾ App Downloads                | `prefs:root=STORE&path=App%20Downloads`                       |
| App Store ⇾ Video Autoplay               | `prefs:root=STORE&path=Video%20Autoplay`                      |
| Wallet                                   | `prefs:root=PASSBOOK`                                         |
| Passwords & Accounts                     | `prefs:root=ACCOUNTS_AND_PASSWORDS`                           |
| Passwords & Accounts ⇾ Fetch New Data    | `prefs:root=ACCOUNTS_AND_PASSWORDS&path=FETCH_NEW_DATA`       |
| Passwords & Accounts ⇾ Add Account       | `prefs:root=ACCOUNTS_AND_PASSWORDS&path=ADD_ACCOUNT`          |
| Mail                                     | `prefs:root=MAIL`                                             |
| Mail ⇾ Preview                           | `prefs:root=MAIL&path=Preview`                                |
| Mail ⇾ Swipe Options                     | `prefs:root=MAIL&path=Swipe%20Options`                        |
| Mail ⇾ Notifications                     | `prefs:root=MAIL&path=NOTIFICATIONS`                          |
| Mail ⇾ Blocked                           | `prefs:root=MAIL&path=Blocked`                                |
| Mail ⇾ Muted Thread Action               | `prefs:root=MAIL&path=Muted%20Thread%20Action`                |
| Mail ⇾ Blocked Sender Options            | `prefs:root=MAIL&path=Blocked%20Sender%20Options`             |
| Mail ⇾ Mark Addresses                    | `prefs:root=MAIL&path=Mark%20Addresses`                       |
| Mail ⇾ Increase Quote Level              | `prefs:root=MAIL&path=Increase%20Quote%20Level`               |
| Mail ⇾ Include Attachments with Replies  | `prefs:root=MAIL&path=Include%20Attachments%20with%20Replies` |
| Mail ⇾ Signature                         | `prefs:root=MAIL&path=Signature`                              |
| Mail ⇾ Default Account                   | `prefs:root=MAIL&path=Default%20Account`                      |
| Contacts                                 | `prefs:root=CONTACTS`                                         |
| Calendar                                 | `prefs:root=CALENDAR`                                         |
| Calendar ⇾ Alternate Calendars           | `prefs:root=CALENDAR&path=Alternate%20Calendars`              |
| Calendar ⇾ Sync                          | `prefs:root=CALENDAR&path=Sync`                               |
| Calendar ⇾ Default Alert Times           | `prefs:root=CALENDAR&path=Default%20Alert%20Times`            |
| Calendar ⇾ Default Calendar              | `prefs:root=CALENDAR&path=Default%20Calendar`                 |
| Notes                                    | `prefs:root=NOTES`                                            |
| Notes ⇾ Default Account                  | `prefs:root=NOTES&path=Default%20Account`                     |
| Notes ⇾ Password                         | `prefs:root=NOTES&path=Password`                              |
| Notes ⇾ Sort Notes By                    | `prefs:root=NOTES&path=Sort%20Notes%20By`                     |
| Notes ⇾ New Notes Start With             | `prefs:root=NOTES&path=New%20Notes%20Start%20With`            |
| Notes ⇾ Sort Checked Items               | `prefs:root=NOTES&path=Sort%20Checked%20Items`                |
| Notes ⇾ Lines & Grids                    | `prefs:root=NOTES&path=Lines%20%26%20Grids`                   |
| Notes ⇾ Access Notes from Lock Screen    | `prefs:root=NOTES&path=Access%20Notes%20from%20Lock%20Screen` |
| Reminders                                | `prefs:root=REMINDERS`                                        |
| Reminders ⇾ Default List                 | `prefs:root=REMINDERS&path=DEFAULT_LIST`                      |
| Voice Memos                              | `prefs:root=VOICE_MEMOS`                                      |
| Phone                                    | `prefs:root=Phone`                                            |
| Messages                                 | `prefs:root=MESSAGES`                                         |
| FaceTime                                 | `prefs:root=FACETIME`                                         |
| Maps                                     | `prefs:root=MAPS`                                             |
| Maps ⇾ Driving & Navigation              | `prefs:root=MAPS&path=Driving%20%26%20Navigation`             |
| Maps ⇾ Transit                           | `prefs:root=MAPS&path=Transit`                                |
| Compass                                  | `prefs:root=COMPASS`                                          |
| Measure                                  | `prefs:root=MEASURE`                                          |
| Safari                                   | `prefs:root=SAFARI`                                           |
| Safari ⇾ Content Blockers                | `prefs:root=SAFARI&path=Content%20Blockers`                   |
| Safari ⇾ Downloads                       | `prefs:root=SAFARI&path=DOWNLOADS`                            |
| Safari ⇾ Close Tabs                      | `prefs:root=SAFARI&path=Close%20Tabs`                         |
| Safari ⇾ Clear History and Data          | `prefs:root=SAFARI&path=CLEAR_HISTORY_AND_DATA`               |
| Safari ⇾ Page Zoom                       | `prefs:root=SAFARI&path=Page%20Zoom`                          |
| Safari ⇾ Request Desktop Website         | `prefs:root=SAFARI&path=Request%20Desktop%20Website`          |
| Safari ⇾ Reader                          | `prefs:root=SAFARI&path=Reader`                               |
| Safari ⇾ Camera                          | `prefs:root=SAFARI&path=Camera`                               |
| Safari ⇾ Microphone                      | `prefs:root=SAFARI&path=Microphone`                           |
| Safari ⇾ Location                        | `prefs:root=SAFARI&path=Location`                             |
| Safari ⇾ Advanced                        | `prefs:root=SAFARI&path=ADVANCED`                             |
| News                                     | `prefs:root=NEWS`                                             |
| Health                                   | `prefs:root=HEALTH`                                           |
| Shortcuts                                | `prefs:root=SHORTCUTS`                                        |
| Music                                    | `prefs:root=MUSIC`                                            |
| Music ⇾ Cellular Data                    | `prefs:root=MUSIC&path=com.apple.Music:CellularData`          |
| Music ⇾ Optimize Storage                 | `prefs:root=MUSIC&path=com.apple.Music:OptimizeStorage`       |
| Music ⇾ EQ                               | `prefs:root=MUSIC&path=com.apple.Music:EQ`                    |
| Music ⇾ Volume Limit                     | `prefs:root=MUSIC&path=com.apple.Music:VolumeLimit`           |
| Settings ⇾ TV                            | `prefs:root=TVAPP`                                            |
| Photos                                   | `prefs:root=Photos`                                           |
| Camera                                   | `prefs:root=CAMERA`                                           |
| Camera ⇾ Record Video                    | `prefs:root=CAMERA&path=Record%20Video`                       |
| Camera ⇾ Record Slo-mo                   | `prefs:root=CAMERA&path=Record%20Slo-mo`                      |
| Books                                    | `prefs:root=IBOOKS`                                           |
| Game Center                              | `prefs:root=GAMECENTER`                                       |

### 支付宝

| 打开项       | 对应 URL Scheme                                                           |
|--------------|---------------------------------------------------------------------------|
| 支付宝       | `alipay://`                                                               |
| 蚂蚁庄园     | `alipays://platformapi/startapp?appId=66666674`                           |
| 蚂蚁森林     | `alipays://platformapi/startapp?appId=60000002`                           |
| 蚂蚁宝卡     | `alipays://platformapi/startapp?appId=60000057`                           |
| 款码         | `alipayqr://platformapi/startapp?saId=20000056`                           |
| 扫码         | `alipays://platformapi/startapp?saId=10000007`                            |
| 红包         | `alipays://platformapi/startapp?appId=88886666`                           |
| 股票         | `alipays://platformapi/startapp?appId=20000134`                           |
| 生活缴费     | `alipays://platformapi/startapp?appId=20000193`                           |
| 手机充值     | `alipays://platformapi/startapp?appId=10000003`                           |
| 彩票         | `alipays://platformapi/startapp?appId=10000011`                           |
| 淘票票       | `alipays://platformapi/startapp?appId=20000131`                           |
| 查快递       | `alipays://platformapi/startapp?appId=20000754`                           |
| AA 收款      | `alipays://platformapi/startapp?appId=20000263`                           |
| 收款         | `alipays://platformapi/startapp?appId=20000123`                           |
| 转账         | `alipays://platformapi/startapp?appId=20000221`                           |
| 还信用卡     | `alipays://platformapi/startapp?appId=09999999`                           |
| 滴滴出行     | `alipays://platformapi/startapp?appId=20000778`                           |
| 钉钉         | `dingtalk://`                                                             |
| 淘宝网       | `taobao://`                                                               |
| 淘宝旅行     | `taobaotravel://`                                                         |
| 淘宝宝贝搜索 | `taobao://http://s.taobao.com/?q=: prompt`                                |
| 淘宝店铺搜索 | `taobao://http://shopsearch.taobao.com/browse/shop_search.htm?q=: prompt` |
| 天猫         | `tmall://`                                                                |

### QQ

| 打开项          | 对应 URL Scheme                                                                        |
|-----------------|----------------------------------------------------------------------------------------|
| QQ              | `mqq://`                                                                               |
| QQ 群组         | `mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin={QQ 群号}` |
| QQ 联系人       | `mqqapi://card/show_pslcard?src_type=internal&version=1&uin={QQ 号码}`                 |
| QQ 国际版       | `mqqiapi://`                                                                           |
| QQ 音乐         | `qqmusic://`                                                                           |
| QQ 音乐最近播放 | `qqmusic://today?mid=31&k1=2&k4=0`                                                     |
| QQ 浏览器       | `qq browser://`                                                                        |
| QQ 邮箱         | `qqmail://`                                                                            |
| 腾讯企业邮箱    | `qqbizmailDistribute2://`                                                              |
| 腾讯视频        | `tenvideo://` 或 `tenvideo2://` 或 `tenvideo3://`                                      |
| 腾讯新闻        | `qqnews://`                                                                            |
| 腾讯微云        | `weiyun://`                                                                            |
| 腾讯地图        | `sosomap://`                                                                           |
| 腾讯视频        | `tenvideo://`                                                                          |
| QQ 斗地主       | `tencent382://`                                                                        |
| QQ 浏览器       | `mttbrowser://`                                                                        |
| QQ 安全中心     | `qmtoken://`                                                                           |
| 腾讯手机管家    | `mqqsecure://`                                                                         |
| 腾讯微博        | `TencentWeibo://`                                                                      |
| 天天星连萌      | `tencent100689806://`                                                                  |
| 天天爱消除      | `tencent100689805://`                                                                  |
| 天天酷跑        | `tencent100692648://`                                                                  |
| 天天飞车        | `tencent100695850://`                                                                  |
| 节奏大师        | `tencentrm://`                                                                         |

### 微信

| 打开项              | 对应 URL Scheme                |
|---------------------|--------------------------------|
| 微信                | `weixin://`                    |
| 微信-扫一扫         | `weixin://scanqrcode`          |

### 百度

| 打开项     | 对应 URL Scheme                         |
|------------|-----------------------------------------|
| 百度       | `baiduboxapp:// 或 BaiduSSO://`         |
| 百度地图   | `baidumap://`                           |
| 百度贴吧   | `com.baidu.tieba://`                    |
| 百度云     | `baiduyun://`                           |
| 百度音乐   | `baidumusic://`                         |
| 百度视频   | `baiduvideoiphone://` 或 `bdviphapp://` |
| 百度糯米   | `bainuo://`                             |
| 百度魔图   | `photowonder://`                        |
| 百度魔拍   | `wondercamera://`                       |
| 百度导航   | `bdNavi://`                             |
| 百度输入法 | `BaiduIMShop://`                        |

### 网易

| 打开项     | 对应 URL Scheme                  |
|------------|----------------------------------|
| 网易邮箱   | `neteasemail://`                 |
| 网易新闻   | `newsapp://`                     |
| 网易云音乐 | `orpheuswidget://`               |
| 有道词典   | `yddict://` 或 `yddictproapp://` |
| 有道云笔记 | `youdaonote://`                  |
| 网易公开课 | `ntesopen://`                    |
| 网易将军令 | `netease-mkey://`                |

### 美团

| 打开项   | 对应 URL Scheme                      |
|----------|--------------------------------------|
| 美团外卖 | `meituanwaimai://`                   |
| 美团     | `imeituan://`                        |
| 点评     | `dianping://` 或 `dianping://search` |

### Tweetbot

| 打开项          | 对应 URL Scheme                                                    |
|-----------------|--------------------------------------------------------------------|
| Open            | `tweetbot://`                                                      |
| Timeline        | `tweetbot://<screenname>/timeline`                                 |
| Mentions        | `tweetbot://<screenname>/mentions`                                 |
| Retweets        | `tweetbot://<screenname>/retweets`                                 |
| Direct Messages | `tweetbot://<screenname>/direct_messages`                          |
| Lists           | `tweetbot://<screenname>/lists`                                    |
| Favorites       | `tweetbot://<screenname>/favorites`                                |
| Search          | `tweetbot://<screenname>/search[?query=<text>&callback_url=<url>]` |
| Status          | `tweetbot://<screenname>/status/<tweet_id>?callback_url=<url>`     |
| Favorite        | `tweetbot://<screenname>/favorite/<tweet_id>`                      |
| Unfavorite      | `tweetbot://<screenname>/unfavorite/<tweet_id>`                    |
| Retweet         | `tweetbot://<screenname>/retweet/<tweet_id>`                       |
| List            | `tweetbot://<screenname>/list/<list_id>?callback_url=<url>`        |

### WhatsApp

| 打开项                                     | 对应 URL Scheme                                 |
|--------------------------------------------|-------------------------------------------------|
| only open whatsApp                         | `whatsapp://`                                   |
| only open whatsApp(universal-link)         | `https://wa.me/`                                |
| start a chat                               | `whatsapp://send?phone=1234`                    |
| start a chat(universal-link)               | `https://wa.me/1234`                            |
| start chat to phone number                 | `whatsapp://send?phone=1234&text=Hello%20world` |
| start chat to phone number(universal-link) | `https://wa.me/1234/?text=Hello%20world`        |

### Surge

| 打开项                                    | 对应 URL Scheme                   |
|-------------------------------------------|-----------------------------------|
| Open                                      | `surge://`                        |
| Start with selected configuration         | `surge://start[?autoclose=true]`  |
| Stop current session                      | `surge://stop[?autoclose=true]`   |
| Start or stop with selected configuration | `surge://toggle[?autoclose=true]` |
| Install a configuration from a URL        | `surge:///install-config?url=URL` |

### 其他常用 APP

| 打开项                  | 对应 URL Scheme                         |
|-------------------------|-----------------------------------------|
| 12306                   | `cn.12306://`                           |
| 京东                    | `openApp.jdMobile://` 或 `jd://`        |
| 今日头条                | `snssdk141://`                          |
| 高德地图                | `iosamap://`                            |
| 新浪微博                | `weibo://` 或 `sinaweibo://`            |
| 微博国际版              | `weibointernational://`                 |
| 优酷                    | `youku://`                              |
| 爱奇艺                  | `iqiyi://` 或 `qiyi-iphone://`          |
| 爱奇艺 PPS              | `ppstream://`                           |
| 土豆视频                | `tudou://`                              |
| PPTV                    | `pptv://`                               |
| 暴风影音                | `com.baofeng.play://`                   |
| 搜狐视频                | `sohuvideo-iphone://` 或 `sohuvideo://` |
| 搜狐新闻                | `sohunews://`                           |
| 虾米音乐                | `xiami://`                              |
| 酷我音乐                | `com.kuwo.kwmusic.kwmusicForKwsing://`  |
| 酷狗音乐                | `kugouURL://`                           |
| 天天动听                | `ttpod://`                              |
| 摩拜单车                | `mobike://`                             |
| ofo                     | `ofoapp://`                             |
| chrome                  | `googlechrome://`                       |
| Gmail                   | `googlegmail://`                        |
| 印象笔记                | `evernote://`                           |
| 挖财记账                | `wacai://`                              |
| 猎豹浏览器              | `sinaweibosso.422729959://`             |
| UC 浏览器               | `ucbrowser://`                          |
| 名片全能王              | `camcard://`                            |
| 豆瓣 fm                 | `doubanradio://`                        |
| 微盘                    | `sinavdisk://`                          |
| 人人                    | `renren://`                             |
| 我查查                  | `wcc://`                                |
| 1 号店                  | `wccbyihaodian://`                      |
| 知乎                    | `zhihu://`                              |
| 墨客                    | `com.moke.moke-1://`                    |
| 扫描全能王              | `camscanner://`                         |
| TuneIn Radio            | `tunein://` 或 `tuneinpro://`           |
| OfficeSuite             | `mobisystemsofficesuite://`             |
| WPS Office              | `KingsoftOfficeApp://`                  |
| Line                    | `line://`                               |
| 1Password               | `onepassword://`                        |
| Clear(著名的 Todo 应用) | `clearapp://`                           |
| Calendars 5             | `calendars://`                          |
| GoodReader 4            | `com.goodreader.sendtogr://`            |
| PDF Expert 5            | `pdfexpert5presence://`                 |
| Documents 5             | `rdocs://`                              |
| nPlayer                 | `nplayer-http://`                       |
| GPlayer                 | `gplayer://`                            |
| AVPlayer                | `HD AVPlayerHD://`                      |
| AVPlayer                | `AVPlayer://`                           |
| Ace Player              | `aceplayer://`                          |
| 12306 订票助手          | `trainassist://`                        |
| 金山词霸                | `com.kingsoft.powerword.6://`           |
| 凤凰新闻                | `comIfeng3GifengNews://`                |
| 高铁管家                | `gtgj://`                               |
| 飞信                    | `fetion://`                             |
| 大智慧                  | `dzhiphone://`                          |
| 布卡漫画                | `buka://`                               |
| 哔哩哔哩动画            | `bilibili://`                           |
| 56 视频                 | `com.56Video://`                        |
| 365 日历                | `rili365://`                            |
| 58 同城                 | `wbmain://`                             |
| 遇见                    | `iaround://`                            |
| 陌陌                    | `momochat://`                           |
| 旺旺卖家版              | `wangwangseller://`                     |
| 掌阅 iReader            | `iReader://`                            |
| 艺龙旅行                | `elongIPhone://`                        |
| 迅雷 + 迅雷云播         | `thunder://`                            |
| 熊猫公交                | `wb1405365637://`                       |
| 携程无线                | `CtripWireless://`                      |
| 无线苏州                | `SuZhouTV://`                           |
| 唯品会                  | `vipshop://`                            |
| 微视                    | `weishiiosscheme://`                    |
| 微拍                    | `wpweipai://`                           |
| 旺信                    | `wangxin://`                            |
| 万年历                  | `youloft.419805549://`                  |
| 同花顺                  | `amihexin://`                           |
| 天涯社区                | `tianya://`                             |
| 天气通 Pro              | `sinaweatherpro://`                     |
| 天气通                  | `sinaweather://`                        |
| 墨迹天气                | `rm434209233MojiWeather://`             |
| 蜻蜓 FM                 | `qtfmp://`                              |
| 浦发银行                | `wx1cb534bb13ba3dbd://`                 |
| 招商银行                | `cmbmobilebank://`                      |
| 建设银行                | `wx2654d9155d70a468://`                 |
| 工商银行                | `com.icbc.iphoneclient://`              |
| 保卫萝卜 2              | `wb2217954495://`                       |
| 保卫萝卜                | `wb1308702128://`                       |
| 搜狗输入法              | `com.sogou.sogouinput://`               |
| 随手记                  | `FDMoney://`                            |
| weico 微博              | `weico://`                              |
| TestFilght              | `itms-beta://`                          |

## 如何查找第三方 App 的 URL Scheme

1. `iMazimg` → `Manage Apps` → `Download to Library` -> `Export.IPA`

    ![himg](https://a.hanleylee.com/HKMS/2020-03-02-044608.png?x-oss-process=style/WaMa)

2. 将后缀名 `.ipa` 修改为 `.zip`, 并解压文件
3. 打开 `payload` → `***.app` → `显示包内容`, 查找 `info.plist`, 这个就跟自己 `app` 的 `info.plist` 一样了, app 注册了哪些自定义的 URL Scheme 就一目了然了

## Reference

- <https://www.cnblogs.com/guoshaobin/p/11163919.html>
- [URL Scheme 查询指南](https://sspai.com/post/66334)
