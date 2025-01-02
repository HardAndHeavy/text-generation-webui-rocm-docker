ROCM_GPU ?= $(strip $(shell rocminfo | grep -m 1 -E gfx[^0]{1} | sed -e 's/ *Name: *//'))
ifeq ($(ROCM_GPU), gfx1030)
  HSA_OVERRIDE_GFX_VERSION = 10.3.0
else ifeq ($(ROCM_GPU), gfx1100)
  HSA_OVERRIDE_GFX_VERSION = 11.0.0
else
  HSA_OVERRIDE_GFX_VERSION = "GFX version detection error"
endif
CONDA_DIR = $(PWD)/data/miniconda_sd_v2.4.0

build:
	docker build -t text-generation-webui-rocm:$(tag) -f docker/Dockerfile .

publish:
	docker image tag text-generation-webui-rocm:$(tag) hardandheavy/text-generation-webui-rocm:$(tag)
	docker push hardandheavy/text-generation-webui-rocm:$(tag)
	docker image tag text-generation-webui-rocm:$(tag) hardandheavy/text-generation-webui-rocm:latest
	docker push hardandheavy/text-generation-webui-rocm:latest

seed-conda:
	if [ ! -f "$(CONDA_DIR)/conda-check-seed-file" ]; then \
		docker run -it --rm \
			-v $(CONDA_DIR):/opt/miniconda_seed \
			hardandheavy/text-generation-webui-rocm:latest sh -c \
				"cp -r /opt/miniconda/* /opt/miniconda_seed && \
				touch /opt/miniconda_seed/conda-check-seed-file"; fi

bash-dev: seed-conda
	docker run -it --rm \
		-p 80:80 \
		--device=/dev/kfd \
		--device=/dev/dri \
		-e HSA_OVERRIDE_GFX_VERSION=$(HSA_OVERRIDE_GFX_VERSION) \
		-v ./data/check:/check \
		-v ./data/home:/root \
		-v ./data/miniconda_sd_v$(tag):/opt/miniconda \
		-v ./data/tg-webui:/tg-webui \
		text-generation-webui-rocm:$(tag) bash

run: seed-conda
	docker run -it --rm \
		-p 80:80 \
		--device=/dev/kfd \
		--device=/dev/dri \
		-e HSA_OVERRIDE_GFX_VERSION=$(HSA_OVERRIDE_GFX_VERSION) \
		-v ./data/check:/check \
		-v ./data/home:/root \
		-v $(CONDA_DIR):/opt/miniconda \
		-v ./data/tg-webui:/tg-webui \
		hardandheavy/text-generation-webui-rocm:latest
