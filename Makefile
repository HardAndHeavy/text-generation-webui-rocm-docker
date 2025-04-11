TG_DIR = $(PWD)/data/tg-webui
CUR_VERSION = 2.6.1
CONDA_DIR = $(PWD)/data/miniconda_v$(CUR_VERSION)

build:
	docker build -t text-generation-webui-rocm:$(tag) .

publish:
	docker image tag text-generation-webui-rocm:$(tag) hardandheavy/text-generation-webui-rocm:$(tag)
	docker push hardandheavy/text-generation-webui-rocm:$(tag)
	docker image tag text-generation-webui-rocm:$(tag) hardandheavy/text-generation-webui-rocm:latest
	docker push hardandheavy/text-generation-webui-rocm:latest

seed:
	if [ ! -f "$(CONDA_DIR)/conda-check-seed-file" ]; then \
		docker run -it --rm \
			-v $(CONDA_DIR):/opt/miniconda_seed \
			hardandheavy/text-generation-webui-rocm:$(CUR_VERSION) sh -c \
				"cp -r /opt/miniconda/* /opt/miniconda_seed && \
				touch /opt/miniconda_seed/conda-check-seed-file"; fi
	if [ ! -f "$(TG_DIR)/tg-check-seed-file" ]; then \
		docker run -it --rm \
			-v $(TG_DIR):/tg-webui \
			hardandheavy/text-generation-webui-rocm:$(CUR_VERSION) sh -c \
				"cp -r /app/* /tg-webui && \
				touch /tg-webui/tg-check-seed-file"; fi

bash: seed
	docker run -it --rm \
		-p 80:80 \
		--device=/dev/kfd \
		--device=/dev/dri \
		-v $(CONDA_DIR):/opt/miniconda \
		-v $(TG_DIR):/tg-webui \
		-w /tg-webui \
		hardandheavy/text-generation-webui-rocm:$(CUR_VERSION) bash

run: seed
	docker run -it --rm \
		-p 80:80 \
		--device=/dev/kfd \
		--device=/dev/dri \
		-v $(CONDA_DIR):/opt/miniconda \
		-v $(TG_DIR):/tg-webui \
		-w /tg-webui \
		hardandheavy/text-generation-webui-rocm:$(CUR_VERSION)
