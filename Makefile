TG_DIR = $(PWD)/data/tg-webui

build:
	docker build -t text-generation-webui-rocm:$(tag) .

publish:
	docker image tag text-generation-webui-rocm:$(tag) hardandheavy/text-generation-webui-rocm:$(tag)
	docker push hardandheavy/text-generation-webui-rocm:$(tag)
	docker image tag text-generation-webui-rocm:$(tag) hardandheavy/text-generation-webui-rocm:latest
	docker push hardandheavy/text-generation-webui-rocm:latest

seed:
	if [ ! -f "$(TG_DIR)/tg-check-seed-file" ]; then \
		docker run -it --rm \
			-v $(TG_DIR):/tg-webui \
			hardandheavy/text-generation-webui-rocm:latest sh -c \
				"cp -r /app/* /tg-webui && \
				touch /tg-webui/tg-check-seed-file"; fi

run: seed
	docker run -it --rm \
		-p 80:80 \
		--device=/dev/kfd \
		--device=/dev/dri \
		-v $(TG_DIR):/tg-webui \
		-v ./data/cloudflared:/etc/cloudflared \
		-w /tg-webui \
		hardandheavy/text-generation-webui-rocm:latest
