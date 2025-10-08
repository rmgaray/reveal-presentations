MAKEFLAGS += --no-print-directory
FIFO := inotify.fifo

watch:
	@./watch.sh

live_watch:
	@./live_watch.sh

presentations/%.html: src/%.md
	@pandoc -t revealjs -s $< -o $@ --variable live-reload --template templates/revealjs_template.html --resource-path site/presentations

presentations/%.pdf: src/%.md
	@pandoc -t beamer -s $< -o $@ --metadata theme=default --resource-path site/presentations
	
