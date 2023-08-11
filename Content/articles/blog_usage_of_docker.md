---
title: Docker 使用
date: 2020-05-20
comments: true
path: usage-of-docker
categories: Terminal
tags: ⦿docker, ⦿tools
updated:
---

Docker 是一个开源的应用容器引擎, 基于 Go 语言 并遵从 Apache2.0 协议开源.

Docker 可以让开发者打包他们的应用以及依赖包到一个轻量级, 可移植的容器中, 然后发布到任何流行的 Linux 机器上, 也可以实现虚拟化.

容器是完全使用沙箱机制, 相互之间不会有任何接口 (类似 iPhone 的 app), 更重要的是容器性能开销极低.

![himg](https://a.hanleylee.com/HKMS/2020-12-12164218.jpg?x-oss-process=style/WaMa)

<!-- more -->

## 安装

### Linux

1. 卸载旧版本

    ```bash
    $ sudo yum remove docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-engine
    ```

2. 安装依赖

    ```bash
    $ sudo yum install -y yum-utils \
      device-mapper-persistent-data \
      lvm2
    ```

3. 设置仓库

    ```bash
    # 官方
    $ sudo yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    # 或者选择 阿里源
    # sudo yum-config-manager \
    # --add-repo \
    # http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    ```

4. 安装 Docker Engine-Community

    ```bash
    sudo yum install docker-ce docker-ce-cli containerd.io
    ```

    > 默认安装的 docker-ce 是最新版, 如果想要安装其他版本的话可以:
    >
    > 1. 先使用 `yum list docker-ce --showduplicates | sort -r` 命令找出所有可用版本
    > 2. 然后使用 `sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io` 安装具体版本

5. 启动 Docker

    ```bash
    sudo systemctl start docker
    ```

6. 运行 hello-world 来验证是否正确安装了 Docker Engine-Community

    ```bash
    sudo docker run hello-world
    ```

### MacOS

```bash
brew cask install docker
```

## 命令使用

- `sudo service docker status`
- `sudo service docker start`

- `docker network`: 管理 docker 网络
- `docker image`: 管理 docker 镜像
- `docker container`: 管理 docker 容器

---

- `docker login`: 登录 docker 账户, 需在 [Hub Docker](https://hub.docker.com/) 提前注册账户, 登录后能拉取账号下的所有镜像
- `docker logout`:: 退出登录

- `docker run [options] <id/name> [command]`: 运行一个镜像 (也是创建一个新的容器)
    - `-b`:
    - `-d`: 在后台运行
    - `-i`: 进入交互式操作
    - `-t`: 终端
    - `-v /minio/data:/mnt/data`: 将主机上的 `minio/data` 目录挂载到容器内的 `/mnt/data`, 用于持久化存储数据
    - `-e "MINIO_CONFIG_ENV_FILE=/etc/config.env"`: 设置环境变量
    - `--name "minio_local"`: 指定容器名称为 minio_local
    - `-P`: 将容器内部使用的网络端口以 **随机** 方式映射到我们使用的主机上

        ```bash
        $ docker run -d -P training/webapp python app.py
        $ docker ps

        2a8df02af645  training/webapp "python app.py"  2 hours ago    Up 2 hours       0.0.0.0:32768->5000/tcp    hanley
        ```

    - `-p`: 将容器内部使用的网络端口 **指定** 映射到我们使用的主机上

        ```bash
        $ docker run -d -p 127.0.0.1:5001:5000 training/webapp python app.py
        $ docker ps

        2e8a12599649  training/webapp  "python app.py" 2 hours ago   Up 2 hours      127.0.0.1:5001->5000/tcp   kind_bassi
        ```

    ```bash
    docker run -i -t ubuntu:15.10 /bin/bash # 进入 ubuntun 的 15.10 版本镜像 (需提前 pull), 并指定 shell 为 /bin/bash, 并进入交互模式
    docker run -itd --name ubuntu-hanley ubuntu:15.10 /bin/bash # 以后台, 终端, 交互式方式运行 ubuntu 这个镜像的 15.10 版本, 并将其命名为 ubuntu-hanley
    ```

- `exit`: 在既然怒容器后的环境中执行, 退出一个容器
- `docker stop <id/name>`: 停止一个正在运行的容器
- `docker start <id/name>`: 启动一个已停止的容器
- `docker restart <id/name>`: 重启一个容器
- `docker kill <id/name>`: 停止一个容器
- `docker ps`: 查看当前正在运行的容器, 等价于 `docker container ls`, 如果需要列出所有的 (含已经被 exit 的) 容器需要使用 `docker ps -a`

    ```bash
    $ docker ps

    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                      NAMES
    31e46c0aad34        ubuntu              "/bin/bash"         2 hours ago         Up 2 hours                                     test1
    2e8a12599649        training/webapp     "python app.py"     2 hours ago         Up 2 hours          127.0.0.1:5001->5000/tcp   kind_bassi

    $ docker ps -a

    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS                      NAMES
    31e46c0aad34        ubuntu              "/bin/bash"         2 hours ago         Up 2 hours                                            test1
    2e8a12599649        training/webapp     "python app.py"     2 hours ago         Up 2 hours                 127.0.0.1:5001->5000/tcp   kind_bassi
    62b13f6c9b2f        training/webapp     "python app.py"     2 hours ago         Exited (137) 2 hours ago                              keen_jackson

    $ docker ps -l

    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
    31e46c0aad34        ubuntu              "/bin/bash"         2 hours ago         Up 2 hours                                     test1
    ```

- `docker images`: 列出所有的位于本地的镜像
- `docker attach <id/name>`: 运行容器使用 `-d` 参数后会在后台运行, 使用 `attach` 可以进入此容器
- `docker exec`: 与 attach 类似, 但是在此命令下使用 exit 并不会导致容器停止运行, 因此这种方式更好.

    ```bash
    docker exec -it
    ```

- `docker rm <id/name>`: 删除某个容器, `docker rm -f 1e560fca3906`
- `docker container ls -a`: 查看所有容器 (包括运行的与停止的, 等价于 `docker ps -a`)
- `docker container prune`: 删除所有不在运行的容器
- `docker rmi <image name>`: 删除某个镜像
- `docker port <id/name>`: 查看某个容器的映射端口详情

    ```bash
    $ docker port 1e560fca3906
    5000/tcp -> 0.0.0.0:5000

    $ docker port wizardly_chandrasekhar
    5000/tcp -> 0.0.0.0:5000
    ```

- `docker logs <id/name>`: 查看某个容器的内部标准输出, `-f` 像使用 `tail -f` 一样来输出容器内部的标准输出
- `docker top <id/name>`: 查看某个容器的内部运行的进程信息

    ```bash
    $docker top 1e560fca3906
    UID    PID        PPID     C     STIME     TTY  TIME       CMD
    root   14019      14002    0     May23?    00:00:01   python app.py
    ```

- `docker inspect <id/name>`: 查看容器的底层信息, 会返回一个 json 文件记录 docker 容器的配置与状态信息
- `docker export <id/name> > <name>`: 导出一个容器快照到本地, `docker export 1e560fca3906 > ubuntu.tar`
- `docker import`: 从本地导入容器快照, `cat docker/ubuntu.tar | docker import - test/ubuntu:v1`, 另外也可以通过指定 URL 或者某个目录来导入
    - `docker import http://example.com/exampleimage.tgz example/imagerepo`
- `docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]`: 将容器的改变更新到镜像
    - `-a`:    Author (e.g., "John Hannibal Smith <hannibal@a-team.com>")
    - `-c`:      Apply Dockerfile instruction to the created image
    - `-m`:   Commit message
    - `-p`:            Pause container during commit (default true)
    - `docker commit -m="has update" -a="hanleylee" e218edb10161 hanleylee/ubuntu:v2`
- `docker tag <id/name> <new name>`: 为镜像添加一个新的标签, `new name` 格式为 `用户名 / 镜像名:tag`

    ```bash
    $ docker tag 860c279d2fec hanleylee/ubuntu:v3

    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    hanleylee/ubuntu    6.7                 860c279d2fec        5 hours ago         190.6 MB
    hanleylee/ubuntu    dev                 860c279d2fec        5 hours ago         190.6 MB
    ```

- `docker rename`
- `docker search <image name>`: 根据 name 搜索一个镜像
- `docker pull <image name>`: 从远程仓库载入镜像, `docker pull ubuntu`; 也可以指定版本: `docker pull ubuntu:15.10`
- `docker push <image name>`: 推送本地创建或更新的镜像到远程自己的仓库中, `docker push hanlyelee/ubuntu:18.04`
- `docker history`

- `--help`: 使用帮助查看具体命令的使用, `docker image --help`
- `--name`: 以现有镜像创建自定义名称的容器, `docker run -itd --name test1 --network test-net ubuntu /bin/bash`
- `--network`: 以现有镜像创建使用自定义网络的容器

## 容器属性

使用 `docker ps -a` 可列出所有存在的容器

```bash
$ docker ps -a

CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS                      NAMES
8e7f63c63e6b        ubuntu              "/bin/bash"         2 hours ago         Up 2 hours                                            test2
31e46c0aad34        ubuntu              "/bin/bash"         2 hours ago         Up 2 hours                                            test1
2a8df02af645        training/webapp     "python app.py"     2 hours ago         Up 2 hours                 0.0.0.0:32768->5000/tcp    hanley
2e8a12599649        training/webapp     "python app.py"     2 hours ago         Up 2 hours                 127.0.0.1:5001->5000/tcp   kind_bassi
dc33b04b866b        training/webapp     "python app.py"     2 hours ago         Created                                               cranky_hawking
62b13f6c9b2f        training/webapp     "python app.py"     2 hours ago         Exited (137) 2 hours ago                              keen_jackson
```

容器有以下属性:

- `CONTAINER ID`: 容器 ID.
- `IMAGE`: 使用的镜像.
- `COMMAND`: 启动容器时运行的命令.
- `CREATED`: 容器的创建时间.
- `STATUS`: 容器状态.
    - `created`: 已创建
    - `restarting`: 重启中
    - `running`: 运行中
    - `removing`: 迁移中
    - `paused`: 暂停
    - `exited`: 停止
    - `dead`: 死亡
- `PORTS`: 容器的端口信息和使用的连接类型 (tcp\udp).
- `NAMES`: 自动分配的容器名称.

## 镜像属性

使用 `docker images` 可列出所有存在的镜像

```bash
$ docker images

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              14.04               90d5884b1ee0        5 days ago          188 MB
php                 5.6                 f40e9e0f10c8        9 days ago          444.8 MB
nginx               latest              6f8d099c3adc        12 days ago         182.7 MB
mysql               5.6                 f2e8d6c772c0        3 weeks ago         324.6 MB
httpd               latest              02ef73cf1bc0        3 weeks ago         194.4 MB
ubuntu              15.10               4e3b13c8a266        4 weeks ago         136.3 MB
hello-world         latest              690ed74de00f        6 months ago        960 B
training/webapp     latest              6fae60ef3446        11 months ago       348.8 MB
```

镜像有以下属性:

- `REPOSITORY`: 表示镜像的仓库源
- `TAG`: 镜像的标签

    在一个仓库源中, 可能有多个 tag, tag 不同则代表不同的版本, 表示不同的镜像, 哪怕两个镜像完全一致, 只有 tag 不一致, 那也是不同的镜像

- `IMAGE` ID: 镜像 ID
- `CREATED`: 镜像创建时间
- `SIZE`: 镜像大小

## 实际使用

### 更新镜像

```bash
$ docker run -t -i ubuntu:15.10 /bin/bash # 首先创建一个容器
root@e218edb10161 apt-get update # 更新此容器
root@e218edb10161 exit
$ docker commit -m="has update" -a="hanleylee" e218edb10161 hanleylee/ubuntu:v2 # 根据更新后的容器创建新镜像 hanleylee/ubuntu:v2
$ docker images

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hanleylee/ubuntu    v2                  70bf1840fd7c        15 seconds ago      158.5 MB
ubuntu              15.10               4e3b13c8a266        4 weeks ago         136.3 MB
mysql               5.6                 f2e8d6c772c0        3 weeks ago         324.6 MB
httpd               latest              02ef73cf1bc0        3 weeks ago         194.4 MB
hello-world         latest              690ed74de00f        6 months ago        960 B
training/webapp     latest              6fae60ef3446        12 months ago       348.8 MB
```

### 容器互联

```bash
$ docker run -d -P --name hanley training/webapp python app.py
$ docker ps -l
CONTAINER ID     IMAGE            COMMAND...     PORTS                     NAMES
43780a6eabaa     training/webapp   "python app.py"...     0.0.0.0:32769->5000/tcp   hanley

$ docker network create -d bridge test-net # 创建网络, -d: 参数指定 Docker 网络类型, 有 bridge, overlay.
$ docker run -itd --name test1 --network test-net ubuntu /bin/bash # 运行一个容器并连接到新建的 test-net 网络
$ docker run -itd --name test2 --network test-net ubuntu /bin/bash # 打开新的终端, 再运行一个容器并加入到 test-net 网络

$ docker exec -it test1 /bin/bash
root@ed123dfvcxd: ping test2

64 bytes from test2. test-net...... # 正确接收到来自 test2 的信息

root@ed123dfvcxd: exit

$ docker exec -it test2 /bin/bash
root@1sdaf124232: ping test1

64 bytes from test1. test-net...... # 正确接收到来自 test1 的信息
```

### 获取容器创建时的参数

使用 `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock assaflavie/runlike <container_id>`

ref: <https://stackoverflow.com/a/32774347/11884593>

## docker-compose

Docker Compose 使用 YAML 格式的配置文件 `docker-compose.yaml`, 该文件中定义了应用程序的各个组件, 每个组件对应的 Docker 镜像, 相应的服务, 网络等.

使用 Docker Compose 可以更加方便地在本地或生产环境中管理多个 Docker 容器. 通过定义 Compose 文件, 您可以轻松地启动, 停止, 重新构建, 扩展和升级整个应用程序的不同组件.

### 编写 Compose 文件

Docker Compose 使用 YAML 文件来定义应用程序的组件和它们之间的联系. 下面是一个使用 Docker Compose 启动 web 应用程序的样例文件:

```yaml
version: '3'
services:
  web:
    build: .
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```

该文件定义了两个服务:

- `web`: Dockerfile 位于当前目录下, 端口映射为 5000.
- `redis`: 使用 Redis 的官方 Docker 镜像, 并以 Alpine Linux 为基础镜像.

我们可以在 Compose 文件中定义其他组件, 例如数据库, 缓存服务器和消息队列等.

Compose 文件使用 YAML 格式定义应用程序的组件, 服务, 网络和卷等. 以下是 Compose 文件的一些常见选项:

- `version`: 指定 Compose 文件格式的版本.
- `services`: 定义要启动的服务列表及每个服务的配置.
- `image`: 指定要使用的 Docker 镜像名称. 如果不存在, 则自动从 Docker Hub 下载.
- `build`: 指定 Dockerfile 的路径或 URL, 用于构建自定义 Docker 镜像.
- `ports`: 指定端口映射规则, 将主机的端口映射到容器中的端口.
- `volumes`: 指定挂载的卷目录, 将主机的目录和容器中的目录进行映射.
- `restart`: 指定容器的自动启动策略
- `cpus`: 指定容器最大可使用的 cpu 资源, 0.5 代表 0.5 个 cpu 核心
- `environment`: 可指定多个环境变量

```yaml
version: '3.3'
services:
  qinglong_app:
    image: whyour/qinglong:latest
    container_name: qinglong
    volumes:
      - ./data:/ql/data
    ports:
      - "0.0.0.0:35700:5700"
    environment:
      # 部署路径非必须，以斜杠开头和结尾，比如 /test/
      QlBaseUrl: '/'
    restart: unless-stopped
    cpus: 0.5
```

### 一些常用的 Docker Compose 命令

我们可以在包含 `docker-compose.yaml` 文件的目录下直接执行 `docker-compose up -d` 来创建并启动相关服务, 常用的 `docker-compose` 命令如下:

- `docker-compose up -d`: 创建并启动容器, 后台运行
- `docker-compose down`: 停止并移除相关资源(会移除已创建的 container)
- `docker-compose stop`: 停止所有服务
- `docker-compose start`: 启动所有服务
- `docker-compose restart` 重启所有服务
- `docker-compose build`: 构建 Compose 文件中定义的服务
- `docker-compose build <service_name>`: 只构建 Compose 文件中的某个服务
- `docker-compose up --build`: 重新构建服务并强制重新生成镜像
- `docker-compose up --force-recreate --build`: 在需要升级服务时, 使用此命令强制重新构建并启动服务(将删除并重新创建所有容器)
- `docker-compose -f docker-compose.yml up -d`

## 参考

- [webdav 服务端安装以及 RaiDrive 客户端使用](https://my.oschina.net/u/729139/blog/3141819)
