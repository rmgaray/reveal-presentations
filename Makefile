MAKEFLAGS += --no-print-directory

watch:
	@rm -f inotify.fifo
	@mkfifo inotify.fifo
	@inotifywait -e modify -m src/ > inotify.fifo &
	@./call_pandoc.sh

live_watch:
	@rm -f inotify.fifo
	@mkfifo inotify.fifo
	@inotifywait -e modify -m src/ > inotify.fifo &
	@websocketd -port 8080 --devconsole ./call_pandoc.sh &
	@miniserve site/ -p 8000

site/html/%.html: src/%.md
	@pandoc -t revealjs -s $< -o $@ --variable live-reload --template revealjs_template.html

pdfs/%.pdf: src/%.md
	@pandoc -t beamer -s $< -o $@ --metadata theme=default --resource-path site/html
	
