---
title: 将 iOS framework 产物由 git 仓库迁移至 maven
date: 2024-01-21
comments: true
path: migrate-ios-framework-from-git-to-maven
tags: ⦿framework, ⦿cocoapods,⦿git, ⦿maven
updated:
---

最近为了解决 iOS 编译产物存储与引用的问题, 深入调研了一番 cocoapods 源码与 maven 技术, 最后开发出了一套以 maven 为核心的 ios 编译产物存储引用方案, 包含上传脚本与 cocoapods 下载插件

![himg](https://a.hanleylee.com/HKMS/2024-01-22162629.png?x-oss-process=style/WaMa)

<!-- more -->

## 背景

根据 [Flutter 官方集成文档](https://docs.flutter.dev/add-to-app/ios/project-setup), iOS 原生项目中引入 Flutter 技术栈基本上有两种方式:

1. 在 Podfile 中使用声明 `flutter_application_path = '../my_flutter'`, 然后在调用 `install_all_flutter_pods(flutter_application_path)` 方法
2. 在 flutter 工程目录下使用 `flutter build ios-framework` 命令编译出后缀为 `.xcframework` 的编译产物, 再拖入 iOS 工程中.

为了避免非 flutter 开发人员编译时也需要安装 flutter 环境, 因此我们排除了第一种集成方案, 选择了第二种. 又因为我们项目是基于 cocoapods 做的组件化方案, 因此我们的最终方案是将 `flutter build ios-framework` 产生的二进制产物进一步制作为一个独立的 cocoapods 库放在 gitlab 中被主工程引用.

主工程引用的大致形式是这样的:

```ruby
platform :ios, '12.0'

source 'git@192.168.6.1:iOS/Flutter/FlutterSpecs.git'
source 'https://cdn.cocoapods.org/'


target 'Example' do
  # ...

  # flutter
  pod 'App', :git => 'git@192.168.6.1:xxx_iOS/Flutter/App.git', :tag => '0.4.5'
  pod 'flutter_common_plugins', :git => 'git@192.168.6.1:xxx_iOS/Flutter/flutter_common_plugins.git', :tag => '0.0.1'
  pod 'Flutter', :git => 'git@192.168.6.1:xxx_iOS/Flutter/Flutter.git', :tag => '0.0.3'
end
```

这种方案可行, 但是有一个致命的缺点: git 对二进制的存储支持挺差的, 你提交了一个新的二进制, 那你的仓库体积基本上就会增加那个新二进制体积一样的大小.

![himg](https://a.hanleylee.com/HKMS/2024-01-21113624.png?x-oss-process=style/WaMa)

鉴于这个特点, 对于那种一年可能也更新不了一次的二进制产物仓库, 这种方案的缺点倒也不大. 但是领导对 flutter 技术非常青睐, 因此我们的 flutter 代码库更新很频繁 (基本上每周都有涉及 flutter 的生产版本, 同时有多个 flutter 开发的需求提测), flutter 产物仓库体积越来越大, 一年多下来, 已经接近 2GB 了😱

```txt
hanley@Hanleys-Mac-mini-home ~/.cache/repo/App  on git:master x   ✔︎ 0
$ dutree --depth=1
[ App 1.84 GiB ]
├─ .git                   │ ███████████████████████████████████████████████████│  99%      1.82 GiB
├─ App.xcframework        │                                                    │   0%     15.97 MiB
├─ .DS_Store              │                                                    │   0%      6.00 KiB
├─ upload.sh              │                                                    │   0%      2.38 KiB
├─ App.podspec.json       │                                                    │   0%         795 B
└─ LICENSE                │                                                    │   0%           3
```

这导致我们开发人员每次使用 `pod update` 更新代码时都会在 `pod App` 这里停留很久. 近一年来我一直在想找一个妥善的解决方案, 但是一直没有好的思路. 最近业务需求渐少, 那就集中精力研究这个问题吧 💪

PS: 本文内容涉及多个方案优劣取舍对比, 细节较多, 篇幅较长, 如想直接查看最终方案及实现, 可跳转至 [最终方案](#plan-maven-plugin) 和 [最终效果](#最终效果)

## 能想到的解决方案

### 方案一: 剥离出变化的二进制产物 + 每次新提交时如果已经有该分支则使用 `git commit --amend` 命令

#### 剥离出变化的二进制产物

这个方案其实就是我一年前使用的临时解决方案, 也是靠着这个方案在一年多时间里让仓库体积只增长到了 2GB, 而不是 10GB 🤡

具体思路是这样的, `flutter build ios-framework` 其实会编译出很多二进制产物, 如下

```txt
build
└── ios
    ├── framework
    │   └── Release
    │       ├── App.xcframework
    │       ├── FBLPromises.xcframework
    │       ├── FirebaseCore.xcframework
    │       ├── FirebaseCoreInternal.xcframework
    │       ├── FirebaseCrashlytics.xcframework
    │       ├── FirebaseInstallations.xcframework
    │       ├── Flutter.xcframework
    │       ├── FlutterPluginRegistrant.xcframework
    │       ├── GoogleDataTransport.xcframework
    │       ├── GoogleUtilities.xcframework
    │       ├── firebase_core.xcframework
    │       ├── firebase_crashlytics.xcframework
    │       ├── flutter_boost.xcframework
    │       └── nanopb.xcframework
    └── pod_inputs.fingerprint
```

经过多次对比, 我们知道, Flutter 的编译产物分为三部分:

- *App.xcframework*: 这个是 flutter 代码编译后的产物, 只要 flutter 代码有改动, 那么每次编译出的这部分产物就会不同
- *Flutter.xcframework*: 这个是 Flutter 引擎产物, 只要 flutter 版本没有改变, 那么每次编译产生的这部分的产物都是相同的
- Plugins: 这个是 flutter 使用的原生插件编译出的产物, 只要插件代码不变, 那么每次编译产生的这部分的产物都是相同的

我们项目的 Flutter 版本是锁死的, 因此每次编译的 `Flutter.xcframework` 可以确定是不变的. 又因为我们项目是以原生为主的混合开发, 因此不涉及 plugin 业务代码, 编译产物中的 Plugins 产物都是第三方库产生的, 因为第三方库的版本也是固定的, 因此每次编译的 Plugins 产物也可以确定是不变的. 那么变化的就只有 `App.xcframework` 了, 因此我们可以把 `App.xcframework` 单独剥离开做一个独立的仓库, 每次 flutter 业务改动后, 只需要将 `App.xcframework` 提交到仓库即可

#### `git commit --amend` 压缩无用的历史记录

flutter 业务在开发时, 一个业务需求会对应一个分支, 提测时执行打包脚本, 脚本会在 App 产物仓库中自动创建该分支并提交第一个 commit, 后面 flutter 代码的每次修改又会执行打包脚本, 继续在分支上提交新的 commit, 分支模型大致就是这样的:

```txt
   * commit3 <- feature/t1
   |
   * commit2
   |
   * commit1
  /
*  <- master
```

可以看到, 在 `feature/t1` 分支上因为提交了三次, 所以产生了三个 commit, 代表着存储了三个版本的二进制文件. 那我们可想而知 git 仓库的体积肯定也增加了三倍二进制文件大小. 其实我们仔细想想在提交 commit3 的时候,  commit1 和 commit2 的内容在以后对我们就没有意义了, 我们不会在以后想 checkout 到这些节点上查看二进制文件内容. 因此我们在提交 commit3 时可以提前判断业务分支是否有过一个 commit, 若没有则创建新 commit; 若有则直接使用 `git commit --amend` 命令修改当前的 commit 并 `git push -f` 强制推送. 具体脚本放这里供大家参考:

```bash
#!/usr/bin/env bash
set -x
set -e

FRAMEWORKS=(
    App
    # commonlib
    # flutter_boost
    # Flutter
    # FlutterPluginRegistrant
)
# ORIGIN_DIR=$(dirname -- "$( readlink -f -- "$0")")
FLUTTER_MAIN="$HOME/.jenkins/workspace/FlutterBuild"
CURRENT_REMOTE_BRANCH=$1
CURRENT_LOCAL_BRANCH=${CURRENT_REMOTE_BRANCH#origin/}
# AMEND=$2

cd "$FLUTTER_MAIN"
# git
git reset --hard HEAD
git fetch --all
git checkout "${CURRENT_REMOTE_BRANCH}"

# flutter
# flutter clean
flutter doctor -v
flutter pub upgrade
flutter build ios-framework --no-debug --no-profile --verbose

for framework in "${FRAMEWORKS[@]}"; do
    FRAMEWORK_DIR="${HOME}/.cache/repo/${framework}"
    if [[ ! -d "${FRAMEWORK_DIR}" ]]; then
        FRAMEWORK_GIT_URL="git@192.168.138.192:xxx_iOS/Flutter/${framework}.git"
        # MARK: clone if not exist
        git clone "${FRAMEWORK_GIT_URL}" "${FRAMEWORK_DIR}" --progress
    fi

    # MARK: fetch all branch
    git -C "${FRAMEWORK_DIR}" reset --hard HEAD
    git -C "${FRAMEWORK_DIR}" checkout master
    git -C "${FRAMEWORK_DIR}" fetch --all --prune

    # HAS_LOCAL_BRANCH=$(git -C "${FRAMEWORK_DIR}" branch --contains "${CURRENT_LOCAL_BRANCH}")

    # MARK: checkout branch
    if git -C "${FRAMEWORK_DIR}" branch -r --contains "${CURRENT_REMOTE_BRANCH}" &>/dev/null; then # 有远程分支
        git -C "${FRAMEWORK_DIR}" checkout "${CURRENT_LOCAL_BRANCH}"

        git -C "${FRAMEWORK_DIR}" reset --hard "${CURRENT_REMOTE_BRANCH}" # 不使用 pull, 防止合并冲突, 直接 reset 到远程 commit
    else
        git -C "${FRAMEWORK_DIR}" checkout master
        git -C "${FRAMEWORK_DIR}" pull
        git -C "${FRAMEWORK_DIR}" checkout -b "${CURRENT_LOCAL_BRANCH}"
        git -C "${FRAMEWORK_DIR}" push -u origin "${CURRENT_LOCAL_BRANCH}"
    fi

    # MARK: Make changes
    RELEASE_FRAMEWORK="${FLUTTER_MAIN}/build/ios/framework/Release/${framework}.xcframework"
    cp -fr "${RELEASE_FRAMEWORK}" "${FRAMEWORK_DIR}"

    # MARK: Add changes
    git -C "${FRAMEWORK_DIR}" add -A

    # MARK: Commit & push
    # if git -C "${FRAMEWORK_DIR}" branch --contains HEAD | grep -E '(^|\s)master$' &>/dev/null; then # 如果当前 HEAD 还在 master 分支之上, 需要创建新 commit
    if git -C "${FRAMEWORK_DIR}" merge-base --is-ancestor HEAD master; then # 如果当前 HEAD 还在 master 分支之上, 需要创建新 commit
        git -C "${FRAMEWORK_DIR}" commit -m "feature add"
        git -C "${FRAMEWORK_DIR}" push
    else # 反之, 只需要在原 commit 上 amend 即可
        git -C "${FRAMEWORK_DIR}" commit --amend --message="feature update $(date "+%Y-%m-%d %H:%M:%S")"
        git -C "${FRAMEWORK_DIR}" push -f
    fi

    git -C "${FRAMEWORK_DIR}" checkout master
done
```

另外再每隔一段时间清理无效的分支, 效果显著. 但是每周至少总是要在 master 分支上提交一个 tag 节点的, 这个节点我们永远不会删除, 因此仓库体积每周稳定增长 10MB 左右 (`App.xcframework` 体积为 10MB 左右)

这种方式只能缓解燃眉之急, 想要根本解决产物存储问题, 还要另寻他法

### 方案二: pod 使用 `:tag => 'xxx' 格式

根据这篇 [blog](https://andresalla.com/en/stop-using-branch-in-your-podfiles/) 对 cocoapods 源码的分析, 我们在使用 `pod xxx, :git => 'xxx'` 时, 建议使用 `:tag  => 'xxx'` 而不是 `:branch => 'xxx'`. 这样可使 cocoapods 使用 `git clone --depth 1 ...` 的命令进行 shallow clone, 进而忽略仓库的海量历史, 只聚焦最后一次 commit, 体积也会大大减小.

```txt
hanley@Hanleys-Mac-mini-home ~/Downloads    ✔︎ 0
$ git clone --depth=1 git@192.168.138.192:xxx_iOS/Flutter/App.git
Cloning into 'App'...
remote: Enumerating objects: 174, done.
remote: Counting objects: 100% (174/174), done.
remote: Compressing objects: 100% (152/152), done.
remote: Total 174 (delta 4), reused 169 (delta 4), pack-reused 0
Receiving objects: 100% (174/174), 6.56 MiB | 4.15 MiB/s, done.
Resolving deltas: 100% (4/4), done.

hanley@Hanleys-Mac-mini-home ~/Downloads    ✔︎ 0
$ dutree --depth=1 App
[ App 22.59 MiB]
├─ App.xcframework           │ ████████████████████████████████████████████████████████████████████████████│  70%     15.97 MiB
├─ .git                      │                                               ██████████████████████████████│  29%      6.62 MiB
├─ upload.sh                 │                                                                             │   0%      2.38 KiB
├─ App.podspec.json          │                                                                             │   0%         795 B
└─ LICENSE                   │                                                                             │   0%           3 B
```

可以看到, 使用了 `--depth 1` 参数后, 克隆后的文件夹体积仅有 20MB 左右 🆒️

这样能解决开发同事使用 `pod update` 更新到 `pod 'App'` 时等待很久的问题.

但是在提交 git 更新时操作一个超级大的仓库仍然很慢, 且可以预见到这个产物仓库会越来越大, 最后甚至可能会突破 10GB. 另外我觉得使用 `:tag => 'xxx'` 可以触发 `--depth 1` 参数属于 cocoapods 开发团队的这个问题属于设计缺陷

最终, 我认为这个方案仍然不能从根本上解决问题, 不值得采用

### 方案三: pod 使用 `:http => 'xxx'` 格式 + maven 存储

cocoapods 也支持 http 链接形式的远程压缩包作为资源文件, 格式为 `pod 'Flutter', :http => 'https://storage.flutter-io.cn/xxx/ios-release/artifacts.zip'`

继续延伸想下去, 我们也可以使用脚本将 `App.xcframework` 压缩为 zip 文件, 放在公司内网服务器上, 然后在 Podfile 中使用这种 http 链接形式. 经过沟通, 我们公司内部的 nexus 可以用于做这个事情 (nexus 是 maven 的仓库管理器, java 后端与安卓的产物文件一般都是放在这个上面, 是 maven 仓库最常见的一种解决方案)

这样我们在 Podfile 中的书写形式大概是这样的:

```ruby
  pod 'App', :http => 'http://192.168.6.1:8081/repository/ios-framework/com/xxx/ios/App/0.0.1/App-0.0.1.zip'
```

这下我觉得可能找到最终解决方案了, 但在验证可行性时又遇到了问题: 同一个链接在被下载过一次后, 我们再去更新该链接对应的远程压缩文件, 然后使用 `pod update` 并不会拉取远程更新的文件.

看了下源码, [CocoaPods/lib/cocoapods/downloader/cache.rb](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/downloader/cache.rb) 中的下载逻辑是这样的:

```ruby
module Pod
  module Downloader
    class Cache

      def download_pod(request)
        cached_pod(request) || uncached_pod(request)
      rescue Informative
        raise
      rescue
        UI.puts("\n[!] Error installing #{request.name}".red)
        raise
      end

      def cached_pod(request)
        cached_spec = cached_spec(request)
        path = path_for_pod(request)

        return unless cached_spec && path.directory?
        spec = request.spec || cached_spec
        Response.new(path, spec, request.params)
      end

      def cached_spec(request)
        path = path_for_spec(request)
        path.file? && Specification.from_file(path)
      rescue JSON::ParserError
        nil
      end

      def path_for_pod(request, slug_opts = {})
        root + request.slug(**slug_opts)
      end

      def path_for_spec(request, slug_opts = {})
        path = root + 'Specs' + request.slug(**slug_opts)
        Pathname.new(path.to_path + '.podspec.json')
      end

      def uncached_pod(request)
        in_tmpdir do |tmp_dir|
          result, podspecs = download(request, tmp_dir)
          result.location = nil

          # Split by pods that require a prepare command or not to speed up installation.
          no_prep_cmd_specs, prep_cmd_specs = podspecs.partition { |_, spec| spec.prepare_command.nil? }.map(&:to_h)

          # Pods with a prepare command currently copy the entire repo, run the prepare command against the whole
          # repo and then clean it up. We configure those first to ensure the repo is pristine.
          prep_cmd_specs.each do |name, spec|
            destination = path_for_pod(request, :name => name, :params => result.checkout_options)
            copy_source_and_clean(tmp_dir, destination, spec)
            write_spec(spec, path_for_spec(request, :name => name, :params => result.checkout_options))
            if request.name == name
              result.location = destination
            end
          end

          specs_by_platform = group_subspecs_by_platform(no_prep_cmd_specs.values)

          # Remaining pods without a prepare command can be optimized by cleaning the repo first
          # and then copying only the files needed.
          pod_dir_cleaner = Sandbox::PodDirCleaner.new(tmp_dir, specs_by_platform)
          Cache.write_lock(tmp_dir) do
            pod_dir_cleaner.clean!
          end

          no_prep_cmd_specs.each do |name, spec|
            destination = path_for_pod(request, :name => name, :params => result.checkout_options)
            file_accessors = pod_dir_cleaner.file_accessors.select { |fa| fa.spec.root.name == spec.name }
            files = Pod::Sandbox::FileAccessor.all_files(file_accessors).map(&:to_s)
            copy_files(files, tmp_dir, destination)
            write_spec(spec, path_for_spec(request, :name => name, :params => result.checkout_options))
            if request.name == name
              result.location = destination
            end
          end

          result
        end
      end
end
```

`Pod::Downloader::Cache.download_pod` 方法是下载触发点, 然后在 `cached_pod` 中判断是否有缓存路径, 有的话就直接返回该路径, 否则再触发 `uncached_pod` 方法, 这个是真正去下载资源的方法, 下载完成后会缓存到指定路径. `:http` 形式的真正下载执行方法在 [cocoapods-downloader/lib/cocoapods-downloader/http.rb](https://github.com/CocoaPods/cocoapods-downloader/blob/master/lib/cocoapods-downloader/http.rb) 中:

```ruby
require 'cocoapods-downloader/remote_file'

module Pod
  module Downloader
    class Http < RemoteFile
      USER_AGENT_HEADER = 'User-Agent'.freeze

      private

      executable :curl

      def download_file(full_filename)
        parameters = ['-f', '-L', '-o', full_filename, url, '--create-dirs', '--netrc-optional', '--retry', '2']
        parameters << user_agent_argument if headers.nil? ||
            headers.none? { |header| header.casecmp(USER_AGENT_HEADER).zero? }

        headers.each do |h|
          parameters << '-H'
          parameters << h
        end unless headers.nil?

        curl! parameters
      end

      # Returns a cURL command flag to add the CocoaPods User-Agent.
      #
      # @return [String] cURL command -A flag and User-Agent.
      #
      def user_agent_argument
        "-A '#{Http.user_agent_string}'"
      end
    end
  end
end
```

所以, 一旦我们使用 `:http` 形式指定了链接, 第一次下载完成后就会缓存到 `~/Library/Caches/CocoaPods` 文件夹下, 后续只要不更改链接且不清理缓存情况下, 那么以后执行 `pod update` 就能找到缓存文件夹, 就不会再重新下载了, 即使同一个链接指向的远程文件有了更新!

但是我们的编译产物更新了之后, 肯定是希望 `pod update` 能取到最新资源的, 那么如何做到呢?

- 上传新产物到 maven 时换一个新的版本号, 比如 `feature1.beta.1`, 这样能得到一个新的资源链接, 然后在我们的主工程更新链接, 提交改动
- 每次 `pod update` 前, 强制使用 `pod cache clean App --all` 清理指定 pod 的缓存

第一种方式, 每次都要更改主工程代码并提交 commit, 不能接受; 第二种方式, 如果只考虑到 Flutter 编译产物情况下, 是可以接受的, 可是如果以后有更多的 pod 使用了二进制产物形式引用, 那么就需要在 `pod update` 前清理很多缓存, 而这些 pod 在远程很可能是没有更新的, 那我们每次都要去下载会浪费很多时间和资源, 因此也不可取.

 <span id="plan-maven-plugin">

### 方案四 (最终方案): maven + cocoapods 插件 + 上传脚本

经过了以上几种方案的分析, 我们目前能确定的一点是资源存储位置为 maven, 然后我们就尝试以这个点出发, 解决其他能想象到的问题

#### 如何让 cocoapods 在 pod update 时能获取到该链接在 maven 上的更新?

还是看源码, 我们发现使用 `:git => 'xxx'` 形式引用的 pod 是能自动检测到远端更新并判断是否下载的, 这是怎么实现的呢?

原来在 [Cococapods/lib/cocoapods/downloader.rb](https://github.com/CocoaPods/CocoaPods/blob/d3fe96e1d4a41db133d7d978105b5977b98758cc/lib/cocoapods/downloader.rb#L29-L60) 中:

```ruby
module Pod
  module Downloader

    # ...
    def self.download(
      request,
      target,
      can_cache: true,
      cache_path: Config.instance.cache_root + 'Pods'
    )
      can_cache &&= !Config.instance.skip_download_cache

      request = preprocess_request(request)

      if can_cache
        raise ArgumentError, 'Must provide a `cache_path` when caching.' unless cache_path
        cache = Cache.new(cache_path)
        result = cache.download_pod(request)
      else
        raise ArgumentError, 'Must provide a `target` when caching is disabled.' unless target

        require 'cocoapods/installer/pod_source_preparer'
        result, = download_request(request, target)
        Installer::PodSourcePreparer.new(result.spec, result.location).prepare!
      end

      if target && result.location && target != result.location
        UI.message "Copying #{request.name} from `#{result.location}` to #{UI.path target}", '> ' do
          Cache.read_lock(result.location) do
            FileUtils.rm_rf(target)
            FileUtils.cp_r(result.location, target)
          end
        end
      end
      result
    end

    def self.preprocess_request(request)
      Request.new(
        :spec => request.spec,
        :released => request.released_pod?,
        :name => request.name,
        :params => Downloader.preprocess_options(request.params))
    end

    # ...
  end
end
```

下载的时候会走到一定会走到 `Pod::Downloader.download` 方法, 然后会调用 `Pod::Downloader.preprocess_request` 方法, 进而调用 `Downloader.preprocess_options`, 这样, [cocoapods-downloader/lib/cocoapods-downloader/git.rb](https://github.com/CocoaPods/cocoapods-downloader/blob/master/lib/cocoapods-downloader/git.rb) 中的 `Pod::Downloader::Git.preprocess_options` 方法就被调用到了

```ruby
module Pod
  module Downloader
    class Git < Base
      # ...

      def self.preprocess_options(options)
        return options unless options[:branch]

        input = [options[:git], options[:commit]].map(&:to_s)
        invalid = input.compact.any? { |value| value.start_with?('--') || value.include?(' --') }
        raise DownloaderError, "Provided unsafe input for git #{options}." if invalid

        command = ['ls-remote',
                   '--',
                   options[:git],
                   options[:branch]]

        output = Git.execute_command('git', command)
        match = commit_from_ls_remote output, options[:branch]

        return options if match.nil?

        options[:commit] = match
        options.delete(:branch)

        options
      end
    end
  end
end
```

从上面源码我们可以看到, Git 类的 `preprocess_options` 会使用 `git ls-remote...` 命令获取该仓库在远程某分支最新的 commit, 然后将 commitid 放入 options 并回传给调用方.

然后在 [CocoaPods/lib/cocoapods/downloader/cache.rb](https://github.com/CocoaPods/CocoaPods/blob/master/lib/cocoapods/downloader/cache.rb) 中, 生成 cache 路径的时候使用到了 `path_for_pod` 方法

```ruby
module Pod
  module Downloader
    class Cache
      def path_for_pod(request, slug_opts = {})
        root + request.slug(**slug_opts)
      end
    end
  end
end

# ...

module Pod
  module Downloader
    class Request

      def slug(name: self.name, params: self.params, spec: self.spec)
        checksum = spec && spec.checksum && '-' << spec.checksum[0, 5]
        if released_pod?
          "Release/#{name}/#{spec.version}#{checksum}"
        else
          opts = params.to_a.sort_by(&:first).map { |k, v| "#{k}=#{v}" }.join('-')
          digest = Digest::MD5.hexdigest(opts)
          "External/#{name}/#{digest}#{checksum}"
        end
      end
    end
  end
end
```

最终, `Pod::Downloader::Request.slug` 方法被调用, 使用了 `params` 参数来生成 digest 和 checksum 作为路径名的一部分, 那这个 params 是哪里传来的呢? 这是在之前调用 `Pod::Downloader.preprocess_request` 初始化生成的, 也就是 `Pod::Downloader.preprocess_options` 生成返回的, 终于闭环了 👍

那按照这样, 我们可以 **创建一个 cocoapods plugin**, 像 `Pod::Downloader::Git` 一样, 创建一个继承自 `Pod::Downloader::Base` 的子类, 然后重写 `preprocess_options` 方法, 在其中请求 maven HTTP API 该产物是否有更新即可

#### 如何自定义一个类似 `:http` 形式的 `:maven` 命令

我们知道 cocoapods 支持 `:http`, `:git` 这种使用形式, 因为我们要使用 maven 上的资源, 因此希望能使用 `:maven` 形式引用一个 maven 上的资源, 那我们能不能自定义这样一个参数呢? 当看到了开源插件 [cocoapods-s3-download](https://github.com/samuelabreu/cocoapods-s3-download) 后, 我发现这不就是我想要的效果嘛! 感谢开源社区 🙏

原来在 [cocoapods-downloader/lib/cocoapods-downloader.rb](https://github.com/CocoaPods/cocoapods-downloader/blob/master/lib/cocoapods-downloader.rb) 中, 这些引用形式是通过 `downloader_class_by_key` 这个哈希表来定义好的

```ruby
module Pod
  module Downloader
    def self.downloader_class_by_key
      {
        :git  => Git,
        :hg   => Mercurial,
        :http => Http,
        :scp  => Scp,
        :svn  => Subversion,
      }
    end
  end
end
```

由于 ruby 语言允许我们重载一个类的方法, 所以我们可以这样添加:

```ruby
module Pod
  module Downloader
    class <<self
      alias_method :real_downloader_class_by_key, :downloader_class_by_key
    end

    def self.downloader_class_by_key
      original = self.real_downloader_class_by_key
      original[:maven] = Maven
      original
    end
  end
end
```

`original[:maven] = Maven` 中的 `Maven` 代表着我们自己的下载类, 我们的 `preprocess_options` 也正是要在这个类中实现

#### 如何设计下载地址

一般来说, mavens 上产物的链接地址一般为 `http://192.168.6.1:8081/repository/maven-hosts/com/xxx/ios/App/0.0.1/App-0.0.1.zip` 这种形式, 拼接形式很复杂, 在更新 `pod App` 的版本时, 很容易写错. 有没有根据参数获取下载链接的方法呢? 经过研究, 我发现 maven 提供的 REST API 中有一个 `/v1/search/assets`

![himg](https://a.hanleylee.com/HKMS/2024-01-21161351.png?x-oss-process=style/WaMa)

这个 api 中可以将需要查找的版本号, 产物名, 仓库等作为 url 链接参数传入, 例如 `http://192.168.6.1:8081/service/rest/v1/search/assets?sort=version&repository=ios-framework&maven.groupId=com.xxx.ios&maven.artifactId=App&maven.baseVersion=0.0.1&maven.extension=zip&prerelease=false`, 然后返回符合条件的产物信息, 返回格式如下:

```json
{
    "items": [
        {
            "downloadUrl": "http://192.168.6.1:8081/repository/ios-framework/com/xxx/ios/App/0.0.1/App-0.0.1.zip",
            "path": "com/xxx/ios/App/master/App-master.zip",
            "id": "aW9zLWZyYW1ld29yazphYTMxNTBhNGQxZWMyZTQzZmRhMmY2MWJiMzE5NmU4YQ",
            "repository": "ios-framework",
            "format": "maven2",
            "checksum": {
                "sha1": "b3578a883bd82996d20465d76fd4646236bd73f5",
                "md5": "e63546235d0aa73e55e9e9f1ead1faa3"
            }
        }
    ],
    "continuationToken": null
}
```

其中包含了我们想要的 `downloadUrl`, 然后我们就可以那这个链接进行下载. 返回结果中同时还包含了 `checksum` 字段, 对应了当前产物的唯一 id, 这正好满足了我们 `preprocess_options` 的检查更新要求

因此为了更方便地组装参数请求 API, 最终确定我们的 maven pod 引用形式为 `pod 'xxx', :maven => 'http://192.168.6.1:8081', :repo => 'ios-framework', :group => 'com.xxx.ios', :artifact => 'App', :type => 'zip', :version => 'tech/t1'`

#### 设计上传脚本

maven 支持使用 curl 上传产物, 也可以使用官方提供的终端命令 `mvn` 进行上传, 出于稳定考虑, 最终选择了官方命令行工具 `mvn`. 如下是完整脚本, 供参考

```bash
#!/usr/bin/env bash
set -x
set -e

FRAMEWORKS=(
    App
    # Flutter
    # flutter_common_plugins
)
SCRIPT_REPO="$HOME/repo/Script"
# FLUTTER_MAIN="$HOME/.jenkins/workspace/FlutterBuild_v2"
CURRENT_REMOTE_BRANCH=$1
CURRENT_LOCAL_BRANCH=${CURRENT_REMOTE_BRANCH#origin/}
# AMEND=$2

MVN_PACKAGING="zip"
GROUP_ID="com.xxx.ios"
NEXUS_REPO_SERVER="http://192.168.6.1:8081/repository/ios-framework/"
DATABASE_FILE="$HOME/.secrets/database.json"
NEXUS_USR=$(jq -r '.maven.usr' "$DATABASE_FILE")
NEXUS_PWD=$(jq -r '.maven.pwd' "$DATABASE_FILE")
VERSION="${CURRENT_LOCAL_BRANCH//\//_}" # test/v0.1 => test_v0.1

# flutter
# flutter clean
flutter doctor -v
flutter pub upgrade
flutter build ios-framework --no-debug --no-profile --verbose

for framework in "${FRAMEWORKS[@]}"; do

    ARTIFACT_CACHE_DIR="${HOME}/.cache/framework_artifact"
    FRAMEWORK_DIR="${ARTIFACT_CACHE_DIR}/${framework}"
    rm -rf "$FRAMEWORK_DIR" || true
    mkdir -p "$FRAMEWORK_DIR"

    RELEASE_FRAMEWORK="${PWD}/build/ios/framework/Release/${framework}.xcframework"
    cp -r "$RELEASE_FRAMEWORK" "$FRAMEWORK_DIR"
    cp "$SCRIPT_REPO/resources/template/${framework}.podspec" "$FRAMEWORK_DIR"

    TARGET_ZIP="$ARTIFACT_CACHE_DIR/$framework/${framework}.zip"
    pushd "$FRAMEWORK_DIR"
    zip -r "$TARGET_ZIP" "."
    popd

    mvn deploy:deploy-file \
        -DgroupId="$GROUP_ID" \
        -DartifactId="$framework" \
        -Dversion="$VERSION" \
        -DgeneratePom=false \
        -Dpackaging="$MVN_PACKAGING" \
        -DrepositoryId="scripted-nexus" \
        -Durl="$NEXUS_REPO_SERVER" \
        -Dfile="$TARGET_ZIP" \
        -Drepo.usr="$NEXUS_USR" \
        -Drepo.pwd="$NEXUS_PWD"
done
```

该脚本执行时使用业务分支名为参数, 例如 `./uploadFrameworkToMaven.sh feature/t1`

以上脚本中的 podspec 文件按照自己需要编写, 内容参考如下:

```ruby
Pod::Spec.new do |s|
  s.name             = 'App'
  s.version          = '0.1.0'
  s.summary          = 'Google Utilities for Apple platform SDKs'
  s.description      = <<-DESC
Internal Google Utilities including Network, Reachability Environment, Logger and Swizzling for\nother Google CocoaPods. They're not intended for direct public usage.
                       DESC
  s.homepage         = 'http://192.168.6.1/xxx_iOS/Flutter/App.git'
  s.license          = { :type => 'Apache' }
  s.author           = { 'Google, Inc.' => 'flutter-dev@googlegroups.com' }
  # s.source           = { :git => 'git@192.168.6.1:xxx_iOS/Flutter/App.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.vendored_frameworks = 'App.xcframework'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.dependency 'Flutter'
  s.dependency 'flutter_common_plugins'
end
```

注意, `mvn` 会去 `~/.m2/settings.xml` 文件中查找服务器登录字段, 该文件内容如下(如果没有, 则创建一个):

```xml
<settings>
    <servers>
        <server>
            <id>scripted-nexus</id>
            <username>${repo.usr}</username>
            <password>${repo.pwd}</password>
        </server>
    </servers>
</settings>
```

## 最终方案效果

上面说了最终方案这么多实现细节, 最后看下最终使用效果吧

1. flutter 需求第一次打包时
    1. 执行 `uploadFrameworkToMaven.sh`, 编译并上传产物到 maven
    2. 在主工程的 Podfile 中, 填写引用 `pod 'App', :maven => 'http://192.168.6.1:8081', :repo => 'ios-framework', :group => 'com.xxx.ios', :artifact => 'App', :type => 'zip', :version => 'feature/t1'`
2. 后续该需求 flutter 代码更新后, 只需重复直接执行 `uploadFrameworkToMaven.sh`, iOS 不需要改动直接重新打包即可

## 项目开源

目前项目已经开源在 [Github](https://github.com/hanleylee/cocoapods-maven), 并上传到了 [RubyGems](https://rubygems.org/gems/cocoapods-maven) 上, 欢迎使用❤️️

## 开发中的坑

在设计编译产物存储方案过程中, 走了很多弯路, 在这里也总结下

### ruby 开发要合理使用 bundle

开发 cocoapods-maven 插件的时候, 按照网上的标准插件开发教程, 开发流程是:

1. 修改插件代码
2. `gem build cocoapods.maven && gem install cocoapods-maven-0.0.1.gem`
3. 等待...
4. `pod install` 查看效果

每次改一处代码就需要重新执行一遍上面流程, 大概要阻塞 20s 左右, 很低效

后面我发现使用 bundle 就好啦!

1. 在 iOS Demo 项目中的 `Gemfile` 文件中定义 `gem cocoapods-maven,:path => '../cocoapods-maven'`
2. `bundle install`
3. 后续任何改动后, 直接执行 `bundle exec pod install` 即可实时查看效果 ✌

### 使用 RubyMine 能大大提高 ruby 源码阅读速度

工欲善其事, 必先利其器.

一般情况下我喜欢使用 Vim 编写脚本或查看源码, 方案调研开始阶段看 cocoapods 源码也是使用 vim + [coc-solargraph](https://github.com/neoclide/coc-solargraph) 进行的, 发现很多方法无法跳转, 只能靠全局搜索才能看相关方法及属性的引用, 很痛苦. 后面就想那些每天使用 ruby 写工程的人会用什么工具呢? 我想起来 JetBrain 有一款 Ruby IDE 叫 RubyMine, 于是就下载了尝试一下, 然后一发不可收拾, 太幸福了.

在 RubyMine 下, 无论是跳转第三方库, 系统库的定义, 还是查看方法的引用, 以及注释文档的渲染, 都让人非常满意, 强烈建议所有需要阅读大型 ruby 工程代码的人体验一下👍

## 最后

本文作者 Hanley Lee, 首发于 [闪耀旅途](https://www.hanleylee.com), 如果对本文比较认可, 欢迎 Follow

## Ref

- [microsoft/cocoapods-azure-universal-packages](https://github.com/microsoft/cocoapods-azure-universal-packages)
- [samuelabreu/cocoapods-s3-download](https://github.com/samuelabreu/cocoapods-s3-download)
- [cocoapods-downloader/lib/cocoapods-downloader/remote_file.rb](https://github.com/CocoaPods/cocoapods-downloader/blob/master/lib/cocoapods-downloader/remote_file.rb)
