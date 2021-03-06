.PHONY: all test docker publish-docker

VERSION?=$(shell git describe HEAD | sed s/^v//)
DATE?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
DOCKERNAME?=alde/eremetic
DOCKERTAG?=${DOCKERNAME}:${VERSION}
LDFLAGS=-X main.Version '${VERSION}' -X main.BuildDate '${DATE}'
TOOLS=${GOPATH}/bin/go-bindata \
      ${GOPATH}/bin/go-bindata-assetfs
SRC=$(shell find . -name '*.go')
STATIC=$(shell find static templates)

all: test

${TOOLS}:
	go get github.com/jteeuwen/go-bindata/...
	go get github.com/elazarl/go-bindata-assetfs/...

test: eremetic
	go test -v ./...

assets/assets.go: generate.go ${STATIC}
	go generate

eremetic: ${TOOLS} assets/assets.go
eremetic: ${SRC}
	go get -t ./...
	go build -ldflags "${LDFLAGS}" -o $@

docker/eremetic: ${TOOLS} assets/assets.go
docker/eremetic: ${SRC}
	go get -t ./...
	CGO_ENABLED=0 GOOS=linux go build -ldflags "${LDFLAGS}" -a -installsuffix cgo -o $@

docker: docker/eremetic docker/Dockerfile docker/marathon.sh
	docker build -t ${DOCKERTAG} docker

publish-docker: docker
	docker push ${DOCKERTAG}
	git describe HEAD --exact 2>/dev/null && \
		docker tag ${DOCKERTAG} ${DOCKERNAME}:latest && \
		docker push ${DOCKERNAME}:latest || true
