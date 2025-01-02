CHECK_SEED_FILE = /check/check-seed-file

init:
	if [ ! -f $(CHECK_SEED_FILE) ]; then \
		git clone https://github.com/oobabooga/text-generation-webui /tg-webui && \
		cd /tg-webui && \
		pip install -r requirements_amd.txt && \
		touch $(CHECK_SEED_FILE); fi

run: init
	cd /tg-webui && \
	python server.py \
		--listen-port= 80 \
		--listen-host=0.0.0.0
