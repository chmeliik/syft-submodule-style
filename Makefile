.PHONY: build-image
build-image:
	podman build -t localhost/rh-syft:latest .

.PHONY: prepare-for-patching
prepare-for-patching:
	if [ -d patches ]; then \
		cd syft && \
		git apply ../patches/* && \
		git add --update && \
		git commit -m 'temp: apply redhat patches'; \
	fi

.PHONY: print-patch
print-patch:
	@cd syft && git diff

.PHONY: finish-patching
finish-patching:
	# reset back to the tracked commit
	git submodule update --force
