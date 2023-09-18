SHELL:=/usr/bin/env bash
generate:
	swift run DevJourneyBlog
preview:
	@echo listen on http://localhost:8000
	python3 -m http.server 8000 -d ./Output
deploy:
	swift run DevJourneyBlog --deploy
a:
	@echo "a is $$0"
b:
	@echo "b is $$0"