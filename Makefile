# SPDX-FileCopyrightText: 2020-present Open Networking Foundation <info@opennetworking.org>
#
# SPDX-License-Identifier: Apache-2.0

export CGO_ENABLED=0
export GO111MODULE=on

.PHONY: build

DOCKER_TAG                      ?= latest
DOCKER_REPOSITORY               ?= onosproject/
DOCKER_REGISTRY                 ?= ""
DOCKER_IMAGENAME_API         	:= ${DOCKER_REGISTRY}${DOCKER_REPOSITORY}aether-roc-api:${DOCKER_TAG}
DOCKER_IMAGENAME_WS         	:= ${DOCKER_REGISTRY}${DOCKER_REPOSITORY}aether-roc-websocket:${DOCKER_TAG}

ONOS_BUILD_VERSION := v0.6.9
OAPI_CODEGEN_VERSION := v1.7.0

build: # @HELP build the Go binaries and run all validations (default)
build:
	CGO_ENABLED=1 go build -o build/_output/aether-roc-api ./cmd/aether-roc-api
	CGO_ENABLED=1 go build -o build/_output/aether-roc-websocket ./cmd/aether-roc-websocket

build-tools:=$(shell if [ ! -d "./build/build-tools" ]; then cd build && git clone https://github.com/onosproject/build-tools.git; fi)
include ./build/build-tools/make/onf-common.mk

test: # @HELP run the unit tests and source code validation
test: build deps linters license openapi-linters
	CGO_ENABLED=1 go test -race github.com/onosproject/aether-roc-api/pkg/...
	CGO_ENABLED=1 go test -race github.com/onosproject/aether-roc-api/cmd/...

jenkins-test:  # @HELP run the unit tests and source code validation producing a junit style report for Jenkins
jenkins-test: deps license linters jenkins-tools # openapi-linters
	CGO_ENABLED=1 TEST_PACKAGES=github.com/onosproject/aether-roc-api/... ./build/build-tools/build/jenkins/make-unit

oapi-codegen:
	oapi-codegen || ( cd .. && go get github.com/deepmap/oapi-codegen/cmd/oapi-codegen@${OAPI_CODEGEN_VERSION})

openapi-spec-validator: # @HELP install openapi-spec-validator
	openapi-spec-validator -h || python -m pip install openapi-spec-validator==0.3.1

openapi-linters: # @HELP lints the Open API specifications
openapi-linters: openapi-spec-validator
	openapi-spec-validator api/aether-top-level-openapi3.yaml
	openapi-spec-validator api/aether-2.1.0-openapi3.yaml
	openapi-spec-validator api/aether-2.0.0-openapi3.yaml
	openapi-spec-validator api/aether-4.0.0-openapi3.yaml
	openapi-spec-validator api/aether-app-gtwy-openapi3.yaml

oapi-codegen-aether-2.1.0: # @HELP generate openapi types from aether-2.1.0-openapi3.yaml
oapi-codegen-aether-2.1.0: oapi-codegen
	mkdir -p pkg/aether_2_1_0/types pkg/aether_2_1_0/server
	oapi-codegen -generate types -package types -o pkg/aether_2_1_0/types/aether-2.1.0-types.go api/aether-2.1.0-openapi3.yaml
	oapi-codegen -generate spec -package server -o pkg/aether_2_1_0/server/aether-2.1.0-spec.go api/aether-2.1.0-openapi3.yaml
	# Note the import-mapping prefix below will be ignored and the the items sorted alphabetically
	oapi-codegen \
		-generate types,server \
		-import-mapping imp1:"github.com/onosproject/aether-roc-api/pkg/aether_2_1_0/types",imp2:"github.com/onosproject/aether-models/models/aether-2.1.x/api" \
		-package server \
		-templates pkg/codegen/templates \
		-o pkg/aether_2_1_0/server/aether-2.1.0-impl.go \
		api/aether-2.1.0-openapi3.yaml
	sed -i "s/enterpriseId EnterpriseId/enterpriseId externalRef1.EnterpriseId/g" pkg/aether_2_1_0/server/aether-2.1.0-impl.go
	oapi-codegen \
		-generate server \
		-import-mapping externalRef0:"github.com/onosproject/aether-roc-api/pkg/aether_2_1_0/types" \
		-package server \
		-templates pkg/codegen/modified \
		-o pkg/aether_2_1_0/server/aether-2.1.0-server.go \
		api/aether-2.1.0-openapi3.yaml
	sed -i "s/enterpriseId EnterpriseId/enterpriseId externalRef0.EnterpriseId/g" pkg/aether_2_1_0/server/aether-2.1.0-server.go
	oapi-codegen \
		-generate types \
		-import-mapping externalRef0:"github.com/onosproject/aether-models/models/aether-2.1.x/api" \
		-package server \
		-templates pkg/codegen/convert-oapi-gnmi \
		-o pkg/aether_2_1_0/server/aether-2.1.0-convert-oapi-gnmi.go \
		api/aether-2.1.0-openapi3.yaml
	sed -i "s/ > !//g" pkg/aether_2_1_0/server/aether-2.1.0-convert-oapi-gnmi.go
	oapi-codegen \
		-generate types \
		-import-mapping externalRef0:"github.com/onosproject/aether-models/models/aether-2.1.x/api" \
		-package server \
		-templates pkg/codegen/convert-gnmi-oapi \
		-o pkg/aether_2_1_0/server/aether-2.1.0-convert-gnmi-oapi.go \
		api/aether-2.1.0-openapi3.yaml
	sed -i "s/ > !//g" pkg/aether_2_1_0/server/aether-2.1.0-convert-gnmi-oapi.go
	for f in pkg/aether_2_1_0/**/aether-2.1.0*.go; do sed -i '1i// Code generated by oapi-codegen. DO NOT EDIT.' $$f; done

oapi-codegen-aether-2.0.0: # @HELP generate openapi types from aether-2.0.0-openapi3.yaml
oapi-codegen-aether-2.0.0: oapi-codegen
	mkdir -p pkg/aether_2_0_0/types pkg/aether_2_0_0/server
	oapi-codegen -generate types -package types -o pkg/aether_2_0_0/types/aether-2.0.0-types.go api/aether-2.0.0-openapi3.yaml
	oapi-codegen -generate spec -package server -o pkg/aether_2_0_0/server/aether-2.0.0-spec.go api/aether-2.0.0-openapi3.yaml
	oapi-codegen \
		-generate types,server \
		-import-mapping imp1:"github.com/onosproject/aether-roc-api/pkg/aether_2_0_0/types",imp2:"github.com/onosproject/aether-models/models/aether-2.0.x/api" \
		-package server \
		-templates pkg/codegenv200/templates \
		-o pkg/aether_2_0_0/server/aether-2.0.0-impl.go \
		api/aether-2.0.0-openapi3.yaml
	sed -i "s/target Target/target externalRef1.Target/g" pkg/aether_2_0_0/server/aether-2.0.0-impl.go
	oapi-codegen \
		-generate server \
		-import-mapping externalRef0:"github.com/onosproject/aether-roc-api/pkg/aether_2_0_0/types" \
		-package server \
		-templates pkg/codegenv200/modified \
		-o pkg/aether_2_0_0/server/aether-2.0.0-server.go \
		api/aether-2.0.0-openapi3.yaml
	sed -i "s/target Target/target externalRef0.Target/g" pkg/aether_2_0_0/server/aether-2.0.0-server.go
	oapi-codegen \
		-generate types \
		-import-mapping externalRef0:"github.com/onosproject/aether-models/models/aether-2.0.x/api" \
		-package server \
		-templates pkg/codegenv200/convert-oapi-gnmi \
		-o pkg/aether_2_0_0/server/aether-2.0.0-convert-oapi-gnmi.go \
		api/aether-2.0.0-openapi3.yaml
	sed -i "s/ > !//g" pkg/aether_2_0_0/server/aether-2.0.0-convert-oapi-gnmi.go
	oapi-codegen \
		-generate types \
		-import-mapping externalRef0:"github.com/onosproject/aether-models/models/aether-2.0.x/api" \
		-package server \
		-templates pkg/codegenv200/convert-gnmi-oapi \
		-o pkg/aether_2_0_0/server/aether-2.0.0-convert-gnmi-oapi.go \
		api/aether-2.0.0-openapi3.yaml
	sed -i "s/ > !//g" pkg/aether_2_0_0/server/aether-2.0.0-convert-gnmi-oapi.go
	for f in pkg/aether_2_0_0/**/aether-2.0.0*.go; do sed -i '1i// Code generated by oapi-codegen. DO NOT EDIT.' $$f; done

oapi-codegen-aether-app-gtwy: # @HELP generate openapi types from aether-app-gtwy-openapi3.yaml
oapi-codegen-aether-app-gtwy: oapi-codegen
	mkdir -p pkg/app_gtwy/types pkg/app_gtwy/server
	oapi-codegen -generate types -package types -o pkg/app_gtwy/types/aether-app-gtwy-types.go api/aether-app-gtwy-openapi3.yaml
	oapi-codegen -generate spec -package server -o pkg/app_gtwy/server/aether-app-gtwy-spec.go api/aether-app-gtwy-openapi3.yaml
	oapi-codegen \
		-generate server \
		-import-mapping externalRef0:"github.com/onosproject/aether-roc-api/pkg/aether_2_0_0/types" \
		-package server \
		-templates pkg/codegen/modified \
		-o pkg/app_gtwy/server/aether-app-gtwy-server.go \
		api/aether-app-gtwy-openapi3.yaml
	sed -i "s/target Target/target externalRef0.Target/g" pkg/app_gtwy/server/aether-app-gtwy-server.go

aether-top-level: # @HELP generate openapi types from aether-top-level-openapi3.yaml
aether-top-level: oapi-codegen
	oapi-codegen -generate types -package types \
	-import-mapping \
	./aether-2.0.0-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/aether_2_0_0/types,\
	./aether-2.1.0-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/aether_2_1_0/types,\
	./aether-4.0.0-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/aether_4_0_0/types,\
	./aether-app-gtwy-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/app_gtwy/types \
	-o pkg/toplevel/types/toplevel-types.go api/aether-top-level-openapi3.yaml

	oapi-codegen -generate spec -package server \
	-import-mapping \
	./aether-2.0.0-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/aether_2_0_0/types,\
	./aether-2.1.0-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/aether_2_1_0/types,\
	./aether-4.0.0-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/aether_4_0_0/types,\
	./aether-app-gtwy-openapi3.yaml:github.com/onosproject/aether-roc-api/pkg/app_gtwy/types \
	-o pkg/toplevel/server/toplevel-spec.go api/aether-top-level-openapi3.yaml

aether-roc-api-docker: # @HELP build aether-roc-api Docker image
	@go mod vendor
	docker build . -f build/aether-roc-api/Dockerfile \
		-t ${DOCKER_IMAGENAME_API}
	@rm -rf vendor

aether-roc-websocket-docker: # @HELP build aether-roc-websocket Docker image
	@go mod vendor
	docker build . -f build/aether-roc-websocket/Dockerfile \
		-t ${DOCKER_IMAGENAME_WS}
	@rm -rf vendor

images: # @HELP build all Docker images
images: build aether-roc-api-docker aether-roc-websocket-docker

kind: # @HELP build Docker images and add them to the currently configured kind cluster
kind: images
	$(eval CLUSTER_NAME := $(shell kind get clusters))
	@if [ "$(CLUSTER_NAME)" = '' ]; then echo "no kind cluster found" && exit 1; fi
	kind load --name=$(CLUSTER_NAME) docker-image ${DOCKER_IMAGENAME_API}
	kind load --name=$(CLUSTER_NAME) docker-image ${DOCKER_IMAGENAME_WS}

all: build images

publish: # @HELP publish version on github and dockerhub
	./build/build-tools/publish-version ${VERSION} onosproject/aether-roc-api onosproject/aether-roc-websocket

jenkins-publish: # @HELP Jenkins calls this to publish artifacts
	./build/bin/push-images
	./build/build-tools/release-merge-commit

generated: # @HELP create generated artifacts
generated: oapi-codegen-aether-2.1.0 oapi-codegen-aether-2.0.0 oapi-codegen-aether-app-gtwy

clean:: # @HELP remove all the build artifacts
	rm -rf ./build/_output ./vendor ./cmd/aether-roc-api/aether-roc-api ./cmd/aether-roc-websocket/aether-roc-websocket
	go clean -testcache github.com/onosproject/aether-roc-api/...

clean-generated: # @HELP remove generated artifacts
	rm -f pkg/aether_2_1_0/**/aether-2.1.0*.go
	rm -f pkg/aether_2_0_0/**/aether-2.0.0*.go
	rm -f pkg/app_gtwy/**/aether-app-gtwy*.go
