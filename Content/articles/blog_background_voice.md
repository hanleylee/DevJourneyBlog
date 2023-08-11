---
title: iOS 推送方式实现收款语音播报
date: 2023-05-19
comments: true
path: ios-push-background-notification-voice
tags: ⦿iOS, ⦿push, ⦿notification
updated:
---

近期开发了新需求 -- **收款语音播报**, 这里记录一下实现思路

![himg](https://a.hanleylee.com/HKMS/2023-07-04233024.jpg?x-oss-process=style/WaMa)

<!-- more -->

首先需求点大概是这样的:

- app 可以在前台收到通知然后播报用户收到的金额
- 在 app 未启动情况下 (之前已登录) 仍然可以在收到通知后播报用户收到的金额
- 语音播报的声音文件可以由客户端合成或者由请求后端生成

## 总体思路

如果只是要求在 app 处于前台情况下进行语音播报, 那么技术实现很简单, 只需要根据推送的通知调用 AVAudioPlayer 进行相应的播放即可; 但是我们需要在 app 处于后台情况下也进行语音播报, 那么我们就把方向确定在了 [Notification Service Extension](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension) 上了: 使用 `Notification Service Extension` 可以保证在 app 未启动时仍然可以收到通知并进行处理

## 技术实现 - app 处于后台时

当 app 处于后台时, 我们可以通过 `UNNotificationSound(named: xxx)` **将通知声音替换为我们自己的一个语音文件** 来达到播放自定义语音的目的, 该 api 中的 name 会在如下路径查找相应文件:

- APP 的 *Library/Sounds* 文件夹
- APP 和 Extension 共享 Group 的 *Library/Sounds* 文件夹
- App Bundle

此方式必须保证有一个语音文件, 那么语音文件我们怎么获得呢? 有两种方式:

1. 后台下发通知内容中包含语音文件链接, 客户端收到通知内容后下载语音文件, 存储在共享 Group 的 *Library/Sounds* 文件夹中

    ```swift
    class NotificationService: UNNotificationServiceExtension {
        var contentHandler: ((UNNotificationContent) -> Void)?
        var bestAttemptContent: UNMutableNotificationContent?

        private var disposeBag: DisposeBag = .init()

        override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
            self.contentHandler = contentHandler
            self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

            if let bestAttemptContent = bestAttemptContent,
               let userInfoDic = (bestAttemptContent.userInfo as? [String: Any]) {
                let pushModel = NotificationPushMainModel.deserialize(from: userInfoDic) ?? .init()
                if pushModel.voiceUrl.isNotEmpty, pushModel.pushType == .voice {
                    NotificationServiceApi.requestVoice(url: pushModel.voiceUrl)
                        .request()
                        .asObservable()
                        .subscribe(onNext: { [weak self] (res) in
                            guard let self = self else { return }
                            let audioName = pushModel.voiceUrl.by.md5
                            self.playCustomNotificationSound(audioName: audioName, audioData: res.data)
                        }, onError: { (error) in
                            print(error.localizedDescription)
                            contentHandler(bestAttemptContent)
                        })
                        .disposed(by: disposeBag)
                } else {
                    contentHandler(bestAttemptContent)
                }

            }
        }

        func playCustomNotificationSound(audioName: String, audioData: Data) {
            let fileManager = FileManager.default
            let soundBaseDir = fileManager.groupPath(with: "/Library/Sounds")
            do {
                try fileManager.createDirectory(atPath: soundBaseDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // Directory already exists
            }
            if let oldFiles = try? fileManager.contentsOfDirectory(atPath: soundBaseDir) {
                for oldFileName in oldFiles {
                    let oldFilePath = soundBaseDir + "/" + oldFileName
                    try? fileManager.removeItem(atPath: oldFilePath)
                }
            }

            let soundPath =  "\(soundBaseDir)/\(audioName)"
            fileManager.createFile(atPath: soundPath, contents: audioData)

            DispatchQueue.main.async {
                let sound = UNNotificationSound(named: .init(rawValue: audioName))
                guard let bestAttemptContent = self.bestAttemptContent else { return }
                bestAttemptContent.sound = sound
                bestAttemptContent.userInfo["audio_path"] = soundPath
                self.contentHandler?(bestAttemptContent)
            }
        }

        override func serviceExtensionTimeWillExpire() {
            if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
        }
    }
    ```

2. 通过一系列小语音文件合成为一个大语音文件, 存储在共享 Group 的 *Library/Sounds* 文件夹中

    代码与第一种方式基本相同, 需要注意的是合并音频文件方法

    ```swift
    func mergeAVAsset(with sourcePathArr: [String], rate: Double = 1.0, completed: @escaping (String?) -> Void) {
        // 创建音频轨道, 并获取多个音频素材的轨道
        let composition = AVMutableComposition()
        // 音频插入的开始时间, 用于记录每次添加音频文件的开始时间
        var beginTime = CMTime.zero

        for audioFilePath in sourcePathArr {
            // 获取音频素材
            guard let audioAsset = AVURLAsset(url: URL(fileURLWithPath: audioFilePath)) as AVAsset? else { continue }
            // 音频轨道
            let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            // 获取音频素材轨道
            guard let audioAssetTrack = audioAsset.tracks(withMediaType: .audio).first else { continue }
            // 音频合并 - 插入音轨文件
            try? audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAssetTrack, at: beginTime)
            // 记录尾部时间
            beginTime = CMTimeAdd(beginTime, audioAsset.duration)
        }
        let finalTimeValue = composition.duration.value * Int64(10 * rate)
        let finalTimeScale = composition.duration.timescale * 10
        composition.scaleTimeRange(.init(start: .zero, end: composition.duration), toDuration: .init(value: finalTimeValue, timescale: finalTimeScale))
        // 导出合并后的音频文件
        guard let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else { completed(nil); return }
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH:mm:ss-SSS"
        let timeFromDateStr = formater.string(from: Date())
        let sharedHomePath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.NotificationManager")?.path ?? ""
        let outPutFilePath = sharedHomePath + "/Library/Caches/sound-\(timeFromDateStr).m4a"

        // 音频文件输出
        session.outputURL = URL(fileURLWithPath: outPutFilePath)
        session.outputFileType = AVFileType.m4a // 与上述的`preset`相对应
        session.shouldOptimizeForNetworkUse = true // 优化网络
        session.exportAsynchronously {
            if session.status == .completed {
                print("合并成功 ----\(outPutFilePath)")
                completed(outPutFilePath)
            } else {
                // 其他情况, 具体请看这里`AVAssetExportSessionStatus`.
                print("合并失败 ----\(session.status.rawValue)")
                completed(nil)
            }
        }
    }
    ```

## 技术实现 - app 处于前台时

当 app 在后台时, 收到的通知会被的 `Notification Service Extension` 处理并发出通知声音与 banner; 当我们的 app 处于前台情况下时, `Notification Service Extension` 仍然会被触发, 然后在即将显示的时候会触发我们 app 主程序 `UNUserNotificationCenterDelegate` 协议的 `userNotificationCenter(_:willPresent:withCompletionHandler:)` 代理方法

为了共享 `Notification Service Extension` 生成的音频文件, 我们可以将已生成的音频文件地址 `audio_path` 放入 `bestAttemptContent` 的 `userInfo` 中, 然后在 `userNotificationCenter(_:willPresent:withCompletionHandler:)` 取出该 `userInfo` 中的音频文件地址, 使用 `AVAudioPlayer` 进行播放

```swift
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive _: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        completionHandler([.badge])
        if let audio_path = userInfo["audio_path"] as? String {
            let url = URL(fileURLWithPath: audio_path)
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
    }
}
```

## 坑

做推送语音播报功能的时候遇到了很多坑, 这里记录一下

### 不能使用 `AVSpeechSynthesizer`

- 不能使用 `AVSpeechSynthesizer` 直接进行播放, iOS 12 之后苹果禁用了其在后台发音的功能
- 不能使用 `AVSpeechSynthesizer` 的 `writeto` api 转音频文件, 转出来的音频文件只有 1s 长度

### 不能在 `Notification Service Extension` 中判断当前 app 状态

一开始我的想法是在 `Notification Service Extension` 中通过 `UIApplication.shared.applicationState` 判断 app 当前处于后台还是前台, 如果是后台的话就是用替换系统通知声音的方式播放语音, 如果是前台的话就原地使用 AVAudioPlayer 播放语音

然而, 有点出乎意料的是 `UIApplication.shared.applicationState` 在 `App Extension` 中无法使用, 报错信息:

```text
'shared' is unavailable in application extensions for iOS: Use view controller based solutions where appropriate instead.
```

无奈, 只好在 `Notification Service Extension` 中通过 `userInfo` 迂回地传递 `audio_path` 给主程序进而在前台情况下进行语音播报了

### 通知显示时间与批量发送问题

由于在后台播报的原理是替换了系统通知声音, 那么我们知道每一个通知停留的时间是有限的, 如果用户没有主动关闭通知, 通知 banner 一般会停留 8s 左右, 那么如果我们的语音文件播放长度大于 8s, 那么会直接中断 (如果长度大于 30s 的话通知不会发出任何声音)

`Notification Service Extension` 留给我们处理的时间最多是 30s, 如果超出 30s, 会调用 `serviceExtensionTimeWillExpire()` 方法直接发出通知. 如果后端没有控制好语音消息推送, 一次性推送了大量的语音播报, 那么会出现同时多个语音一同播报的情况. 这个问题暂时没有想到好的解决方案.

## Ref

- [iOS 推送播放语音播报更新](https://mp.weixin.qq.com/s/_DJuegHxZ_p22wRZPqArEw)
