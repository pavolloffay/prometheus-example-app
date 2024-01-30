VERSION:=$(shell cat VERSION)

LDFLAGS="-X main.appVersion=$(VERSION)"

all:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags=$(LDFLAGS) -o prometheus-example-app --installsuffix cgo main.go
	docker build -t pavolloffay/prometheus-example-app:$(VERSION) .

docker-push:
	docker push  pavolloffay/prometheus-example-app:$(VERSION)

k8s-install-prom:
	kubectl apply -f manifests/monitoring.coreos.com_podmonitors.yaml
	kubectl apply -f manifests/monitoring.coreos.com_servicemonitors.yaml
	kubectl apply -f manifests/prometheus.yaml

k8s-port-forward-app-metrics:
	kubectl port-forward svc/prometheus-example-app 9090:web

k8s-port-forward-collector-metrics:
	kubectl port-forward svc/otel-collector 3030:prometheus
