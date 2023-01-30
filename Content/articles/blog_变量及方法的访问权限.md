---
title: iOS 中属性与方法的访问权限等级
date: 2019-10-01
comments: true
path: various-authority-for-property-and-method-in-ios
categories: iOS
tags: ⦿ios, ⦿access, ⦿level
updated:
---

在 Xcode 中共有五种对变量和方法的访问权限, 其等级从低到高依次是:

1. `private`
2. `fileprivate`
3. `internal`
4. `public`
5. `open`

<!-- more -->

## 五种等级 (由低到高)

### private

只在本文件且本类 (或本类扩展) 中可以被访问

如果此类在其他文件中有 `extension`, 那么在其他文件的该类的 `extension` 中是不能被访问到的

如果在一个文件中且任何类外声明一个 `private` 属性, 那么该属性可被该文件所有位置访问到, 但是外部文件不能访问到此属性

### fileprivate

只在本文件中可以被访问

一般来说一个文件中只有一个类, 此时使用 `private` 与 `fileprivate` 没有什么区别, 但是如果一个文件中有两个及以上的类的话, 那么被 `fileprivate` 标记的就可以在本文件的多个类中被访问, 而被 `private` 访问的就只能在本文件的本类 `extension` 中被访问

### internal

本模块内可以使用

`xcode` 默认使用本种权限, `cocoapods` 即一个单独的模块 `module`

### public

`public`: 本项目中各 `module` 任意读取, 不能在其他 `module` 中继承重写. 框架, api, 库中经常用, 个人开发很少用

### open

本项目中各 `module` 任意读取, 重写, 继承

## 对 getter 与 setter 设置不同的访问级别

```swift
// 把 getter 设为 public 级别, setter 设为 private 级别
public private(set) var disposeBag = DisposeBag()
// 把 getter 设为默认的 internal 级别, setter 设为 private 级别
private(set) var name: String?
```

## 迪米特法则与实践

迪米特法则(LoD, Law of Demeter), 如果一个类知道了太多不属于它本身的内容, 则代表这个类与外部的耦合程度越高, 越不灵活, 越难以复用.  但是如果这个类完全不知道外部信息, 那么物件之间也无法合作, 整个应用也就无法运行. 因此我们要保证每个类对外界开放最少的属性, 拥有对外界最少的知识, 这样既可以确保物件之间的合作, 也较灵活, 便于复用与解耦

> law 的意思是法则, 比原则 principle 要强势的多. 在 principle 的世界中, 如果两个 principle 之间有所抵触, 那么我们会衡量彼此的价值, 然后取其中地位较高的, 也就是说 principle 之间是可以相互妥协的, 但是 law 就不是这样的, 他代表一种绝对的法则, 没有什么可以撼动 Lod 的地位.

iOS 开发中,  因为 Swift 语言对于声明的属性是 internal 级别的, 这样并不能保证每个类的最少暴露. 我的建议是养成在定义方法或者属性的时候手动添加 `private` 或 `fileprivate` 的习惯, 这样长此以往我们可以将这些经典的设计模式融入到我们的骨髓中.

> 我一直在想为什么 Swift 不将默认的级别设为 `private`, 而是设为模块内均可以访问的 `internal`, 现在我的看法是 Swift 为了让基础差的人容易上手, 更容易接受.
