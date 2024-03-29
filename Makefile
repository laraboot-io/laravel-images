.DEFAULT_GOAL := dev

.PHONY: dev features
dev: ## dev build
dev: clean

.PHONY: ci
ci: ## CI build
ci: dev

.PHONY: clean
clean: ## remove files created during build pipeline
	$(call print-target)
	rm -rf dist

features:
	chmod +x ./scripts/features.sh
	./scripts/features.sh --with-breeze --with-jetstream

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

define print-target
    @printf "Executing target: \033[36m$@\033[0m\n"
endef
