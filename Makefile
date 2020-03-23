# -*- Mode: makefile -*-
#
# Basic Makefile to aid automation of document building
#

.PHONY: help
help:
	@echo "Build the VIRTIO specification documents."
	@echo ""
	@echo "Possible operations are:"
	@echo
	@echo " $(MAKE) clean                Remove all intermediate files"


.PHONY: clean
clean:
	@rm -f (git ls-files --others --exclude-standard)
