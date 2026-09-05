#
# Task runners for this project's development lifecycle.
#

.PHONY: install help

help:
	@echo "Available targets:"
	@echo "  install  - Symlink devtools configurations into place, backing up any existing files"
	@echo "  help     - Show this help message"

install:
	./run/install
