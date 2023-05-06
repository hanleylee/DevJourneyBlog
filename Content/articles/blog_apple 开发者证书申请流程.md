---
title: Apple 开发者证书申请流程
date: 2019-12-01
comments: true
path: process-of-applying-apple-certificate
categories: Tools
tags: ⦿ios, ⦿apple, ⦿certificate, ⦿request
updated:
---

尽管现在 Xcode 已经集成了证书自动托管, 但是如果在远程推送等情况下仍然需要手动申请证书. 为此, 了解证书申请的原理对 iOS App 开发仍然有重要意义.

![himg](https://a.hanleylee.com/HKMS/2020-01-19-145344.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 证书分类

Apple 证书分为 *开发证书*, *发布证书*, *推送证书* 等, 申请证书需要先在 Mac 上创建 *CSR*(*Certificate Signing Request*) 文件

开发证书与发布证书与开发者账户绑定, 不与某个 APP 绑定. 即, 多个 APP 可以共用同一个开发证书或者发布证书.

推送证书与 App 有关, 推送证书是针对某一个 App 生成的, 在推送时也会需要用到此证书文件.

## 证书申请流程

1. 注册 `identifier` (一般在 xcode 创建项目后系统会自动创建 `identifier`, 不需要手动创建)
2. 从系统自带的 `keychain access` 中创建 `证书申请` (`certSigningRequest`) 文件
3. 在 [Apple 开发者页面](https://developer.apple.com/account/resources/certificates/add) 使用 `certSigningRequest` 文件创建 `开发证书` 和 `发布证书` 或其他证书 (开发证书与发布证书的数量都有限制, 目前发现只能手动申请一次)
4. 将在 Apple 开发者页面申请的的 `cer` 证书手动 **双击** 导入至 `Mac`

注: 考虑到备份的原因可以将导入的两个证书从 `keychain access` 中以 `p12` 文件格式导出, `p12 文件 = 私钥 + 证书`, 这样在重装系统或者在别的电脑上只要导入 `p12` 文件即可. 在多人开发中常用此方法

![himg](https://a.hanleylee.com/HKMS/2019-12-27-144244.jpg?x-oss-process=style/WaMa)

![himg](https://a.hanleylee.com/HKMS/2020-02-03-074947.png?x-oss-process=style/WaMa)

### 证书申请时生成的私钥有什么用

当我们生成一个 `certSigningRequest` 文件时, 会发现在 `Keychain Access` 中也生成了一个公钥一个私钥, 这个私钥会与从 [Apple 开发者页面](https://developer.apple.com/account/resources/certificates/add) 生成并下载下来的证书文件组成 `私钥-证书` 对, Xcode 在使用证书的时候会根据证书从 Keychain 中找到与之匹配的私钥，并使用私钥对 App 进行签名。

因此, **证书申请时生成的私钥** 是非常重要的, 千万不能删(我就因为不懂而删除过, 最后打包失败, 只能废弃原证书重新申请一个新的证书)

## Provisioning Profile(配置文件)

*Provisioning Profile* 是 Apple 对于一个 App 所需要的各种证书以及所覆盖功能的描述文件. 包括:

- App ID
- App 所使用的证书 (开发证书与发布发布证书, 不含推送证书)
- 已注册可在开发阶段使用的的设备
- 开发账户
- App 使用到的 Apple 的服务内容 (比如 cloudkit, push notification, game center, in-app purchase, keychain sharing 等)
-...

*Provisioning Profile* 可以在 [Apple 开发者页面](https://developer.apple.com/account/#/membership/) 进行配置, 选择性地将证书, 可用设备, 覆盖的 Apple 功能添加到其中.

目前 xcode 比较智能, 可以在软件内实现自动托管配置文件, 不需要手动在官网进行配置.  **注意: xcode 托管的配置文件不会显示在官网, 即: 如果在官网没有手动为 App 添加配置文件而是使用 xcode 的托管功能的话, 那么在官网的配置文件页面仍然是空白的**

Xcode 会在使用第一次点击开启托管功能时相关配置整合到一个配置文件中, 如果在开发者页面对 `APP ID` 新添加了某些功能后, 其不会自动更新, 此时可以进入到 `~/Library/MobileDevice/Provisioning Profiles` 路径中将所有配置文件全部删除, 此时 Xcode 即会自动拉取最新配置生成新的 *Provisioning Profile*.

## 构成

`.mobileprovision` 包含以下这些字段及内容:

- `Name`: 即 `mobileprovision` 文件.
- `UUID`: 即 `mobileprivision` 文件的真实文件名, 是一个唯一标识.
- `TeamName`: 即 Apple ID 账号名.
- `TeamIdentifier`: 即 Team Identity.
- `AppIDName`: 即 explicit/wildcard Apple ID name(ApplicationIdentifierPrefix).
- `ApplicationIdentifierPrefix`: 即完整 App ID 的前缀.
- `ProvisionedDevices`: 该 `.mobileprovision` 授权的所有开发设备的 UUID.
- `DeveloperCertificates`: 该 `.mobileprovision` 允许对应用程序进行签名的所用证书, 不同证书对应不同的开发者. 如果使用不在这个列表中的证书进行签名, 会出现 `code signing failed` 相关报错.
- `Entitlements`: 包含了一组键值对. `<key>`, `<dict>`.
    - `keychain-access-groups`: `$(AppIdentifierPrefix)`
    - `application-identifier`: 带前缀的全名. 如: `$(AppIdentifierPrefix)com.apple.garageband`
    - `com.apple.security.application-groups`: App Group ID.
    - `com.apple.developer.team-identifier`: 同 Team Identifier.

## 验证流程

![himg](https://a.hanleylee.com/HKMS/2023-04-16185458.png?x-oss-process=style/WaMa)
