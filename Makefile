SHELL := /bin/bash

# Rez variables, setting these to sensible values if we are not building from rez
REZ_BUILD_PROJECT_VERSION ?= NOT_SET
REZ_BUILD_INSTALL_PATH ?= /usr/local
REZ_BUILD_SOURCE_PATH ?= $(shell dirname $(lastword $(abspath $(MAKEFILE_LIST))))
BUILD_ROOT := $(REZ_BUILD_SOURCE_PATH)/build
REZ_BUILD_PATH ?= $(BUILD_ROOT)

# Source
VERSION ?= $(REZ_BUILD_PROJECT_VERSION)
ARCHIVE_URL := https://download.sourceforge.net/libpng/libpng-$(VERSION).tar.gz
LOCAL_ARCHIVE := $(BUILD_ROOT)/libpng.$(VERSION).tar.gz

# Build time locations
SOURCE_DIR := $(BUILD_ROOT)/libpng-$(VERSION)/
BUILD_TYPE = Release
BUILD_DIR = ${REZ_BUILD_PATH}/BUILD/$(BUILD_TYPE)

# Installation prefix
PREFIX ?= ${REZ_BUILD_INSTALL_PATH}

# CMake Arguments
CMAKE_ARGS := -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_SKIP_RPATH=ON

.PHONY: build install test clean
.DEFAULT_GOAL := build

clean:
	rm -rf $(BUILD_ROOT)

$(BUILD_DIR): # Prepare build directories
	mkdir -p $(BUILD_ROOT)
	mkdir -p $(BUILD_DIR)

$(LOCAL_ARCHIVE): | $(BUILD_DIR)
	cd $(BUILD_ROOT) && wget -O $(LOCAL_ARCHIVE) $(ARCHIVE_URL)

$(SOURCE_DIR): $(LOCAL_ARCHIVE)
	cd $(BUILD_ROOT) && tar -xvzf $<
	
build: $(SOURCE_DIR) # Checkout the correct tag and build
	# Warn about building master if no tag is provided
ifeq "$(VERSION)" "NOT_SET"
	$(warn "No version was specified, provide one with: VERSION=1.6.37")
else
	cd $(BUILD_DIR) && cmake $(CMAKE_ARGS) $(SOURCE_DIR) && make
endif


install: build
	mkdir -p $(PREFIX)
	cd $(BUILD_DIR) && make install

test: build # Run the tests in the build
	$(MAKE) -C $(BUILD_DIR) test
