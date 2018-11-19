
# Image URL to use all building/pushing image targets
IMG ?= gcr.io/sunilarora-sandbox/mysql-controller:1.0.1

all: test manager

# Run tests
test: generate fmt vet manifests
	# go test ./pkg/... ./cmd/... -coverprofile cover.out
	go test ./pkg/... ./cmd/... 

# Build manager binary
manager: generate fmt vet
	go build -o bin/manager github.com/droot/client-status-demo/cmd/manager

# Run against the configured Kubernetes cluster in ~/.kube/config
run: generate fmt vet
	go run ./cmd/manager/main.go

# Install CRDs into a cluster
install: manifests
	kubectl apply -f config/crds

# Deploy controller in the configured Kubernetes cluster in ~/.kube/config
# deploy: manifests
deploy: 
	kubectl apply -f config/crds
	kustomize build config/default | kubectl apply --as=admin --as-group=system:masters -f -

# Generate manifests e.g. CRD, RBAC etc.
manifests:
	go run vendor/sigs.k8s.io/controller-tools/cmd/controller-gen/main.go all

# Run go fmt against code
fmt:
	go fmt ./pkg/... ./cmd/...

# Run go vet against code
vet:
	go vet ./pkg/... ./cmd/...

# Generate code
generate:
	go generate ./pkg/... ./cmd/...

# Build the docker image
docker-build:
	docker build . -t ${IMG}
	@echo "updating kustomize image patch file for manager resource"
	sed -i'' -e 's@image: .*@image: '"${IMG}"'@' ./config/default/manager_image_patch.yaml

# Push the docker image
docker-push:
	docker push ${IMG}
