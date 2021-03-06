PREFIX ?= /usr/local
UNAME := $(shell uname)
ARCH := $(shell uname -m)
EYE3_BASE_DIR := $(shell pwd)
ifeq ($(UNAME), Darwin)
CFLAGS = -Wall -O2 -Wl
EXTRAS = -pagezero_size 10000 -image_base 100000000
else
CFLAGS = -Wall -O2 -Wl,-E
EXTRAS = -lrt
endif
GITTAG := $(shell git tag -l --contains HEAD)
GITBRANCH := $(shell git symbolic-ref --short HEAD)
GITSHA := $(shell git rev-parse --short HEAD)
ifeq ($(GITTAG), )
EYE3_VERSION := $(GITSHA)-dirty
else
EYE3_VERSION := $(GITTAG)
endif
LUAJIT_INCLUDE := tools/luajit/include/luajit-2.1
LUAJIT_ARCHIVE := tools/luajit/lib/libluajit-5.1.a
LUAJIT := tools/luajit/bin/luajit
TOOLS := $(realpath tools)
## this has to be expanded dynamically since luajit
## needs to be built first
LUAJIT_BIN = $(realpath $(LUAJIT))
LIBLUV := deps/luv/build/libluv.a
LIBLUV_INCLUDE := deps/luv/src
LIBUV_INCLUDE := deps/luv/deps/libuv/include
ARCHIVES := $(LUAJIT_ARCHIVE) $(LIBLUV) deps/luv/build/libuv.a
OBJECTS := main.o lib.o vendor.o

.PHONY: all clean clean-deps rebuild release test

all: eye3

eye3: $(LIBLUV) $(OBJECTS)
	@echo "BUILDING EYE3"
	$(CC) $(CFLAGS) -fPIC -o eye3 app.c $(OBJECTS) $(ARCHIVES) -I $(LIBUV_INCLUDE) -I $(LIBLUV_INCLUDE) -I $(LUAJIT_INCLUDE) -lm -ldl -lpthread $(EXTRAS)

rebuild: clean all

test: eye3
	./eye3 -f spec/support/run_busted.lua

lint: eye3
	./eye3 -f spec/support/run_linter.moon lib/*
	./eye3 -f spec/support/run_linter.moon spec/*

install: all
	cp eye3 $(PREFIX)/bin

lib/version.moon:
	@echo "VERSION TAGGING: $(EYE3_VERSION)"
	@echo "'$(EYE3_VERSION)'" > lib/version.moon

$(LIBLUV):
	@echo "BUILDING LIBLUV"
	git submodule update --init deps/luv
	$(MAKE) -C deps/luv reset
	$(MAKE) -C deps/luv BUILD_MODULE=OFF WITH_SHARED_LUAJIT=OFF

$(LUAJIT):
	@echo "BUILDING LUAJIT"
	git submodule update --init deps/luajit
	$(MAKE) -C deps/luajit XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT PREFIX=$(TOOLS)/luajit
	$(MAKE) -C deps/luajit install PREFIX=$(TOOLS)/luajit
	ln -sf $(TOOLS)/luajit/bin/luajit-2.1.0-beta2 $(TOOLS)/luajit/bin/luajit

main.lua: $(LUAJIT)
	@echo "BUILDING main.lua"
	EYE3_BASE_DIR=$(EYE3_BASE_DIR) $(LUAJIT_BIN) ./tools/compile_moon.lua main.moon > main.lua

lib.lua: lib/version.moon $(LUAJIT)
	@echo "BUILDING lib.lua"
	cd lib && \
		EYE3_BASE_DIR=$(EYE3_BASE_DIR) $(LUAJIT_BIN) ../tools/pack.lua . > ../lib.lua

vendor.lua: $(LUAJIT)
	@echo "BUILDING vendor.lua"
	cd vendor && \
		EYE3_BASE_DIR=$(EYE3_BASE_DIR) $(LUAJIT_BIN) ../tools/pack.lua . > ../vendor.lua

%.o: %.lua
	@echo "BUILDING luajit bytecode from $*.lua"
	$(LUAJIT_BIN) -b $*.lua $*.o

clean-deps:
	rm -rf tools/luajit
	cd deps/luajit && \
		$(MAKE) clean
	cd deps/luv && \
		$(MAKE) clean

clean:
	rm -f $(OBJECTS)
	rm -f main.lua vendor.lua lib.lua
	rm -f eye3 eye3-*.gz lib/version.moon

tools/github-release:
	cd /tmp && \
		if [ "$(UNAME)" = "Darwin" ]; then wget https://github.com/aktau/github-release/releases/download/v0.5.3/darwin-amd64-github-release.tar.bz2 -O /tmp/github-release.tar.bz2 && tar jxf github-release.tar.bz2 && mv bin/darwin/amd64/github-release $(TOOLS)/github-release && chmod +x $(TOOLS)/github-release; fi && \
	if [ "$(UNAME)" = "Linux" ]; then wget https://github.com/aktau/github-release/releases/download/v0.5.3/linux-amd64-github-release.tar.bz2 -O /tmp/github-release.tar.bz2 && tar jxf github-release.tar.bz2 && mv bin/linux/amd64/github-release $(TOOLS)/github-release && chmod +x $(TOOLS)/github-release; fi
	rm -rf /tmp/bin /tmp/*gitub-release*

release-create: tools/github-release
	@if [ "$(GITTAG)" = "" ]; then echo "You've not checked out a git tag" && exit 1; fi
	$(TOOLS)/github-release release \
		--tag $(GITTAG) \
		--name "Release $(GITTAG)" \
		--description "Release $(GITTAG)"

prerelease-create: tools/github-release
	@if [ "$(GITTAG)" = "" ]; then echo "You've not checked out a git tag" && exit 1; fi
	$(TOOLS)/github-release release \
		--tag $(GITTAG) \
		--name "Release $(GITTAG)" \
		--description "Release $(GITTAG)" \
		--pre-release

release-upload: tools/github-release rebuild
	@if [ "$(GITTAG)" = "" ]; then echo "You've not checked out a git tag" && exit 1; fi
	gzip -c eye3 > eye3-$(GITTAG)-$(UNAME)-$(ARCH).gz
	$(TOOLS)/github-release upload \
		--tag $(GITTAG) \
		--name "eye3-$(GITTAG)-$(UNAME)-$(ARCH).gz" \
		--file "eye3-$(GITTAG)-$(UNAME)-$(ARCH).gz"
	rm -f eye3-$(GITTAG)-$(UNAME)-$(ARCH).gz
