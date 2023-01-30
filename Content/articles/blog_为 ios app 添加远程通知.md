---
title: 为 iOS App 添加远程通知
date: 2020-02-03
comments: true
path: add-remote-notification-on-a-ios-app
categories: iOS
tags: ⦿ios, ⦿notification
updated:
---

iOS 有本地推送与远程推送, 本文讨论远程推送的实现流程及需要注意的要点.

![himg](https://a.hanleylee.com/HKMS/2020-02-03-090549.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-02-03-090640.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 流程

1. 申请远程推送证书

    之前记录记录过 Apple 证书管理的一篇文章 [链接](https://www.hanleylee.com/process-of-applying-apple-certificate.html), 里面有涉及到远程推送证书.  这里我针对远程推送证书的另一种申请方法做下记录, 这种方法更简洁.

    1. 从系统自带的 `keychain access` 中创建`证书申请`(`csr`)文件

        ![himg](https://a.hanleylee.com/HKMS/2020-02-03-080404.png?x-oss-process=style/WaMa)

        保存名为`CertificateSigningRequest.certSigningRequest`

    2. Apple 开发者页面进入已有 App 的 identifier

        进入网址: <https://developer.apple.com/account/resources/identifiers/list>, 选择对应的 identifier.

        ![himg](https://a.hanleylee.com/HKMS/2020-02-03-081227.png?x-oss-process=style/WaMa)

    3. 激活 `Push Notification`, 并选择`Edit`

        ![himg](https://a.hanleylee.com/HKMS/2020-02-03-081319.png?x-oss-process=style/WaMa)

    4. 创建证书

        在`Edit`之后弹出的页面中选择`Create Certificate`(分为开发环境与生产环境, 生产环境即用户通过分发渠道下载安装软件然后使用的环境, 如 App Store, testflight)

        ![himg](https://a.hanleylee.com/HKMS/2020-02-03-081825.jpg?x-oss-process=style/WaMa)

        `Choose File` 后选择 **第 1 步**创建的`CertificateSigningRequest.certSigningRequest`

        ![himg](https://a.hanleylee.com/HKMS/2020-02-03-082131.png?x-oss-process=style/WaMa)

    5. 下载证书

        在`Edit 之后弹出的界面中选择`Download`, 下载证书, 默认名称为`aps_development.cer`

        ![himg](https://a.hanleylee.com/HKMS/2020-02-03-082658.png?x-oss-process=style/WaMa)

    6. 导入证书到 Mac 并导出

        商业软件的远程推送一般都是在服务器完成, 需要使用证书作为认证, 因此要从`Keychain Access`中再导出证书, 后缀为`.p12`

        ![himg](https://a.hanleylee.com/HKMS/2020-02-03-083505.png?x-oss-process=style/WaMa)

2. Xcode 开启推送功能

    ![himg](https://a.hanleylee.com/HKMS/2020-02-03-071853.png?x-oss-process=style/WaMa)

3. 注册远程推送服务

    ```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (accepted, error) in
                if accepted {
                    DDLogVerbose("用户允许消息通知. ")
                }
        }

        if !device.isSimulator {
            // 仅在真实设备情况下向APNs请求注册token
            UIApplication.shared.registerForRemoteNotifications()
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var deviceTokenString = String()
        /**
         回调函数传递给通知中心的 deviceToken 是 data 类型, 如果直接打印只显示 字节长度
         转化为 nsdata 后打印出来能显示长度为 32, 然后通过展现具体 32 个字节信息.
         字节内部全部由十六进制数字表示, 每两个数字表示一个 byte, 每 4 个 byte 1 组, 因此一共有 8 组.
         由于 deviceToken 内部均为两个十六进制数字组成的信息, 因此表示范围为 0~255, 故可以将 devicetoken 的 data 字节信息正正好好地转化为UInt8
         类型(8 个二进制位表示的整数)
         */
        let bytes = [UInt8](deviceToken)
        for item in bytes {

            // 将十进制数组中的元素一一取出, 然后转化为十六进制的数字字符串, 再拼合为一个完整的字串
            deviceTokenString += String(format:"%02x", item&0x000000FF)
        }
       // DDLogVerbose("deviceToken: \(deviceTokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DDLogError(error as! String)
    }

    func application(_ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DDLogVerbose(userInfo.description)
    }
    ```

## 坑

1. 托管证书的更新

    Provisioning Profile 可以在[Apple 开发者页面](https://developer.apple.com/account/#/membership/)进行配置, 选择性地将证书, 可用设备, 覆盖的 Apple 功能添加到其中.

    目前 xcode 比较智能, 可以在软件内实现自动托管配置文件, 不需要手动在官网进行配置.

    > 注意: xcode 托管的配置文件不会显示在官网, 即: 如果在官网没有手动为 App 添加配置文件而是使用 xcode 的托管功能的话, 那么在官网的配置文件页面仍然是空白的

    xcode 会在使用第一次点击开启托管功能时相关配置整合到一个配置文件中, 如果在开发者页面对`APP ID`新添加了某些功能后, 其不会自动更新, 此时可以进入到 `/Users/hanley/Library/MobileDevice/Provisioning Profiles`路径中将所有配置文件全部删除, 此时 xcode 即会自动拉取最新配置生成新的 Provisioning Profile.

2. 更新的延时

    在我完成了以上所有步骤后, 软件能正确请求通知权限并进行注册, 但是`func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)` 这个函数始终没有回调.

    我一度以为是我自己的设置问题, 我从网上找遍了关于远程通知设置的教程, 均没有得到答案. 我试了各种办法, 甚至关机重启都做了.  苦恼了一段时间后索性放那里研究其他东西, 结果过了一整天以后竟然莫名其妙地回调又产生了(我保证没有动任何远程通知相关的设置).

    经过这次我只能想到是 Apple 的 APNs 需要对应用的第一次推送进行处理一些数据, 而这个过程可能会持续 1 天.  如果你确认你的远程推送请求能正确弹出但是就是没有 deviceToken 的回调的话, 那么可以等到第二天再次尝试看是否有惊喜.
