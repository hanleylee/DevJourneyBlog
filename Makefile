SHELL:=/usr/bin/env bash

.PHONY: all copy_origin generate preview

all: copy_origin generate preview

copy_origin:
	shopt -s globstar # 开启通配符模式
	# rm -r ${HOME}/repo/hanleylee.com/source/_posts/* || true
	# fd -t f -e md blog ${HOME}/repo/hkms/ -x cp -irv {} "${HOME}/repo/hanleylee.com/source/_posts/{/}"
	rm -r Content/articles/* || true
	fd -t f -e md '^blog' ${HOME}/repo/hkms/ -x cp -irv {} "Content/articles/{/}"
	# for file in **/*.md; do # Whitespace-safe and recursive
	#    filename=$(echo "$file" | sed 's/^.*\///')
	#    # filename=${str##*/} # 也可以使用贪婪匹配
	#    [[ $file =~ "Blog" ]] && cp -iv "$file" "/Users/hanley/HL/00_Repo/04_hanleylee.com/source/_posts/$filename"
	# done
generate:
	swift run DevJourneyBlog
preview:
	@echo listen on http://localhost:8000
	@( sleep 1 ; open -a Safari.app http://localhost:8000 ) &
	python3 -m http.server 8000 -d ./Output
deploy:
	swift run DevJourneyBlog --deploy
a:
	@echo "a is $$0"
b:
	@echo "b is $$0"
