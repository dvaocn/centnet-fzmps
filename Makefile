# https://sohlich.github.io/post/go_makefile/


TOP_PATH=.
BUILD_PATH=$(TOP_PATH)/output
SCRIPTS_PATH=$(TOP_PATH)/scripts
OUTPUT_PATH=$(TOP_PATH)/output

BUILT_ID_TAG := main.BuiltID=$(shell git symbolic-ref --short HEAD 2>/dev/null) +$(shell git rev-parse --short HEAD)
BUILT_HOST_TAG := main.BuiltHost=$(shell whoami)@$(shell hostname)
BUILT_TIME_TAG := main.BuiltTime=$(shell date)
BUILT_GOVER_TAG := main.GoVersion=$(shell go version)

GOBUILD_FLAGS := -ldflags "-X \"$(BUILT_ID_TAG)\" -X \"$(BUILT_TIME_TAG)\" -X \"$(BUILT_HOST_TAG)\" -X \"$(BUILT_GOVER_TAG)\""
GOBUILD_FLAGS =

.PHONY : all build darwin linux32 linux64 win32 win64 test clean fmt install docker

ifeq ($(shell uname), Linux)
all: linux
else ifeq ($(shell uname), Darwin)
all: darwin
else
endif

full: linux darwin

# development environment
dev: darwin

darwin :
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64  go build $(GOBUILD_FLAGS)  -o $(BUILD_PATH)/bin/centnet-fzmps main.go

# Cross compilation
linux :
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64  go build $(GOBUILD_FLAGS)  -o $(BUILD_PATH)/bin/centnet-fzmps main.go

test:
	go test -v ./...

clean:
	rm -rf $(OUTPUT_PATH)

run:
	go build -o $(BINARY_NAME) -v ./...
	./$(BINARY_MAXOSX)

fmt:
	go fmt ./...

# deps:

install:
	install -d $(OUTPUT_PATH)/bin
	install -d $(OUTPUT_PATH)/conf
	install -d $(OUTPUT_PATH)/scripts
	install -m 0755 $(SCRIPTS_PATH)/start.sh $(OUTPUT_PATH)/
	install -m 0755 $(SCRIPTS_PATH)/stop.sh $(OUTPUT_PATH)/
	install config.toml $(OUTPUT_PATH)/conf/

docker:
