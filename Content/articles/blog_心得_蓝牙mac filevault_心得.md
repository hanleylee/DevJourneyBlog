---
title: Mac Filevault 与 蓝牙的冲突
date: 2019-12-21
comments: true
path: conflict-between-FileVault-and-bluetooth
categories: Mac
tags: ⦿mac, ⦿filevault, ⦿solution
updated:
---

前段时间买了一个 HHKB 蓝牙键盘, 在使用过程中发现如果重启 Mac 的话蓝牙设备均不能正常连接, 经过多次实验终于发现罪魁祸首-FileVault

![himg](https://a.hanleylee.com/HKMS/2020-01-19-IMG_3189.jpeg?x-oss-process=style/WaMa)

<!-- more -->

## 什么是 FileVault

Filevault是 Apple 官方的数据加密工具, 可以加密硬盘数据, 使得硬盘数据更加安全. 如果设备丢失也不用担心旁人能获取到其内的数据.

但是, 不能在初次开机时自动连接之前已建立连接关系的蓝牙设备.

![himg](https://a.hanleylee.com/HKMS/2019-12-27-154554.png?x-oss-process=style/WaMa)

## 优点

- 数据安全性高, 不用担心丢失设备的情况下被别人通过重置密码方式获取到其内的数据

## 缺点

- 如果Mac 要开启 FileVault, 系统会将所有的数据逐一进行加密, 因此如果数据量较大会耗时极久, 一天以上都有可能.  在系统对数据逐一进行加密的过程中不能手动停止. 从开启状态改为关闭状态需要耗费同等时间.
- 系统的开机速度被被 FileVault 设置拖慢, 能明显感知到.
- 系统的运行速度会被 FileVault 拖慢, 没有明显感知, 但从理论上来说会产生不小的影响
- **如果Mac 使用了蓝牙键鼠设备, 在 FileVault 开启状态下不能在重启后登录前自动连接, 必须使用有线连接的键鼠设备或者 MacBook 的自身键盘才能输入登录密码进行登录. 登录后蓝牙键鼠设备会自动进行连接.**

## 总结

综上, 由于本人喜欢蓝牙键鼠的简洁性, 对数据安全没有那么高的需求, 因此果断关闭 FileVault.
