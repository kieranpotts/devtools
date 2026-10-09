#
# Task runners for this project's development lifecycle.
#

.PHONY: install install-zeta help

help:
	@echo "Available targets:"
	@echo "  install       - Symlink devtools configurations into place, backing up any existing files"
	@echo "  install-zeta  - Pull the Zeta 2.1 edit prediction model into Ollama, for Zed"
	@echo "  help          - Show this help message"

install:
	./run/install

install-zeta:
	./run/install-zeta
