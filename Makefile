IMAGE ?= chirpy-dev
NAME  ?= chirpy-dev
RUN    = podman run --rm -v "$(CURDIR)":/srv/jekyll:Z

.DEFAULT_GOAL := help
.PHONY: help build up start stop logs shell prod test clean new-post lock

help: ## Tampilkan daftar perintah
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-10s %s\n", $$1, $$2}'

build: ## Build image (sekali, atau saat Gemfile berubah)
	podman build -t $(IMAGE) -f Containerfile .

up: ## Jalankan dev server (foreground) di http://localhost:4000
	podman run --rm -it --name $(NAME) -p 4000:4000 -p 35729:35729 -v "$(CURDIR)":/srv/jekyll:Z $(IMAGE)

start: ## Jalankan dev server di background
	podman run -d --rm --name $(NAME) -p 4000:4000 -p 35729:35729 -v "$(CURDIR)":/srv/jekyll:Z $(IMAGE)

stop: ## Hentikan dev server background
	-podman stop $(NAME)

logs: ## Lihat log server background
	podman logs -f $(NAME)

shell: ## Masuk shell di dalam container
	$(RUN) -it $(IMAGE) bash

prod: ## Build produksi ke _site/
	$(RUN) -e JEKYLL_ENV=production $(IMAGE) bundle exec jekyll build

test: ## Build produksi + html-proofer
	$(RUN) -e JEKYLL_ENV=production $(IMAGE) sh -c 'bundle exec jekyll build && bundle exec htmlproofer _site --disable-external'

lock: ## Update Gemfile.lock (bundle update)
	$(RUN) $(IMAGE) bundle update

clean: ## Hapus _site dan cache
	rm -rf _site .jekyll-cache .sass-cache

new-post: ## Buat postingan baru: make new-post TITLE="Judul"
	@test -n "$(TITLE)" || { echo 'Gunakan: make new-post TITLE="Judul"'; exit 1; }
	@slug=$$(echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$$//g'); \
	f="_posts/$$(date +%F)-$$slug.md"; \
	printf -- '---\ntitle: "%s"\ndate: %s\ncategories: [Blog]\ntags: []\n---\n\n' "$(TITLE)" "$$(date '+%F %T %z')" > "$$f"; \
	echo "Dibuat: $$f"
