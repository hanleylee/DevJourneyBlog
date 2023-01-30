---
title: HEXO 网站搭建遇坑记录
date: 2020-01-06
comments: true
path: make-personal-website-by-hexo
categories: Hexo
updated:
---

刚开始是使用的 `wordpress` 作为个人网址, 用于 App 官网以及个人博客记录. 之后喜欢上了 `Markdown` 语法的简洁和 git 的安全以及终端操作的优美, 所以就找到了 Hexo, 从安装到使用确实很满意, 但是在安装过程中确实遇到了很多的坑. 为了避免下次再遇坑, 这次必须记录下来.(之前的 `wordpress` 流程就不写了, 以后估计也不会用了)

<!-- more -->

## 主机

购买云主机: 腾讯云, 阿里云, `vultr` 都可以

## 使用

远程主机的系统一般都是 `Linux`, 在操作时也没有图形界面, 绝大部分时间都是在终端中进行操作, 所以这时就需要用 `ssh` 远程连接工具进行连接.  目前我使用的是在 App Store 付费下载的 `Craft shell` 远程登录云主机, 非常好用, 而且还有文件面板功能

在管理主机和网站过程中, `ngix` 和数据库等软件是必不可少的, 使用一款图形化工具能更清晰直观的了解运行状态. 我选择安装宝塔面板, 界面直观, 功能丰富.  安装过程如下:

1. 终端中输入`yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh`
2. 输入升级专业版代码`wget -O updatepro_6.sh    http://oss.yuewux.com/updatepro_6.sh    && bash updatepro_6.sh`
3. 重启宝塔面板. 然后就会自动转换为专业版本. 此时即可安装所有专业版插件了

注: 宝塔软件是从淘宝购买, 与主机 ip 绑定, 只要是这个 ip 就可以自己重复安装, 但是如果换了 ip 就只能找卖家帮忙换 ip 了

## 域名

### 购买

国内域名需要备案, 比较麻烦, 而且名声不好; 国外域名公开透明而且可以转移, 不用备案, 在众多国外域名厂商中口碑较好的是 `nameslio`, 也有缺点: 界面比较复古.

这里有一个 **大坑**, 因为中国法律规定, 网络服务架设在国内的所有网站, 必须经过备案, 如果不备案的话不能展开服务. 我刚开始在 `nameslio` 购买的域名, 然后考虑到国外的 vps 还是贵, 国内的只需要 100 块 / 年, 因此就想用国外的域名与国内的服务器搭配, 尝试了一下还真能正常访问. 觉得自己占了大便宜了.  但是我还是高兴地太早了.

在我用`国外域名 + 国内服务器`一个多月之后, 网站突然打不开了, 腾讯云提示我的网站没有经过注册, 不能展开任何服务, 被他们官方给封了. 我就服了, 刚开始用你们家的时候不说, 现在东西都弄得好好的了突然给封了, 但是可能国内的主机提供商都是这样的吧, 我作为小消费者也就只能认栽了, 没办法只能转移到国内来备案了.

这个时候又有一个坑, 如果一个域名注册后不满两个月是不能进行转移的, 我当时还没有满两个月, 因此只能掐着日子倒计时...

另外如果转移域名, 需要在新的域名注册商那里续费一年, 续的一年直接在原有时长基础上添加, 不会造成重复浪费, 这一点还是很好的.

### 备案

将服务器假设在中国那就必须要经过政府的审核, 就叫做备案. 备案分为两种备案

1. ICP 备案 (工信部)
2. 公安部备案

ICP 备案比较简单, 在域名服务商的网站上就可以申请, 然后上传一些证件照片和必要的资料, 在通过域名服务商的初审后, 审核申请就会被递交到工信部.  初审一般两天内完成. 工信部审核时间就比较长了, 官网说在 20 天内, 具体时长也差不多, 我就等了十多天

公安部备案在 ICP 备案之后, 目前没有通过, 之后再补充

### 使用

域名服务商都会提供域名解析服务, 直接在设置中将自己的主机 ip 地址填入解析栏中, 这个解析时间有时会比较久, 因为服务商会将解析的条件一层层向上传递到域名解析服务器, 用户在访问的时候都是向域名服务器进行询问, 域名服务器会将域名对应的 ip 地址返回给用户, 然后用户再根据对应的 ip 打开对应的网站.

解析时分为带 `www` 和不带 `www` 两个, 根据官网填写就行.

## HEXO 安装

`HEXO` 生成静态博客的思路其实搞清楚了很简单, 在本地通过 `node.js` 服务构建一个框架, 框架中含有 `git` 仓库, 用户添加博客后点击部署, 此时 HEXO 会根据主机 ip 将变更的内容通过 `ssh` 的方式进行连接上传. 此时, 在主机端, `HEXO` 上传的内容被传入主机的一个 `git` 仓库中, 这个仓库有点特殊, 是有钩子的, 这个钩子会勾住另一个文件夹, 使得另一个文件夹的内容与 `git` 仓库的内容保持一致. 而这个文件夹就被设置为网站的目录.  用户在访问的时候就会看到这个目录生成的静态页面.

这样, 就完成了作者上传内容更新, 访问者能及时看到网站内容更新的一整个流程了.

### 服务端安装

服务端很简单, 不需要执行 hexo 的任何内容, 在满足安装环境的情况下仅创建一个带有钩子的仓库即可

#### 安装前提

1. 本地端已经生成了公钥, 并将公钥上传到主机的`.ssh/authorized_keys`目录, 且已经将私钥添加到本地端的`.ssh/config`文件中
2. 安装了 git

#### 安装步骤

1. 在`home`目录创建仓库目录并加入钩子

    ```bash
    #创建 网站 文件夹
    mkdir /home/hanleylee.com/
    mkdir /home/hanleylee.com/web
    chown -R $USER:$USER /home/hanleylee.com/
    chmod -R 755 /home/hanleylee.com/

    #在 git 文件夹内初始化一个仓库
    cd /home/hanleylee.com/
    git init --bare hexo.git
    ```

2. 在 hexo 的 git 仓库内添加入钩子

    ```bash
    #创建钩子文件的配置并打开进行编辑
    cd /home/hanleylee.com/hexo.git/hooks/
    touch post-receive
    vim post-receive

    # 添加下面两行
    #!/bin/bash
    git --work-tree=/home/hanleylee.com/web --git-dir=/home/hanleylee.com/hexo.git checkout -f

    # 修改文件权限, 使得其可执行
    chmod +x /home/hanleylee.com/hexo.git/hooks/post-receive
    ```

就这样, 服务端就安装完了

### 本地端安装

1. 首先安装 node.js

    这个安装方法很多, 我的方法是先安装 nvm, 然后通过 nvm 进行安装 nodo.js, 非常方便

2. 通过 npm 安装 hexo 命令行组件

    ```bash
    npm install hexo-cli hexo-server -g
    ```

3. 通过 hexo 命令工具创建一个文件夹, 以后的所有内容都会存入这个文件夹中

    ```bash
    makir ~/hexo && cd ~/hexo
    hexo init
    ```

4. 安装部署工具

    ```bash
    npm install hexo-deployer-git --save
    ```

5. 编辑 hexo 文件夹下的`_config.yml`文件

    ```bash
    deploy:
      type: git
      repo: ssh://root@xx.xx.xx.xx:[port]/home/hanleylee.com/hexo.git  //xx.xx.xx.xx 为服务器地址, port 为服务器端口
      branch: master
    ```

此时就搭建好了本地端. 在写完博客放入 hexo 文件夹中之后在 hexo 文件夹中通过`hexo clean`, `hexo generate`, `hexo deploy` 这几个步骤既可以发送到主机端

### 宝塔端设置

宝塔端需要设置的很少, 只需要在左侧栏点击添加站点, 将站点的目录设置为前面设置的主机上被仓库勾住的文件夹即可

有一个坑, 在宝塔安装了 nginx 并设置网站根目录后其并不会将 nginx 配置中的网站根目录改变过来, 因此需要手动修改. 在主机端作如下操作:

```bash
vim /etc/nginx/nginx.conf

# 将 nginx.conf 文件的如下部分做相应修改
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /home/hexoBlog;    #需要修改

    server_name evenyao.com; #博主的域名, 需要修改成对应的域名

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;
    location / {
    }
    error_page 404 /404.html;
        location = /40x.html {
    }

# 最后重启 nginx 服务
service nginx restart
```

## 插件安装

### 文章观看量统计插件

根据 leancloud 进行安装

[GitHub 指导](https://github.com/theme-next/hexo-theme-next/blob/master/docs/zh-CN/LEANCLOUD-COUNTER-SECURITY.md)
