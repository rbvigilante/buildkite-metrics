
VERSION=$(shell git fetch --tags && git describe --tags --candidates=1 --dirty --always)
FLAGS=-X main.Version=$(VERSION)
BIN=build/buildkite-metrics-$(shell uname -s)-$(shell uname -m)-$(VERSION)
LAMBDA_ZIP=build/buildkite-metrics-$(VERSION)-lambda.zip
SRC=$(shell find . -name '*.go')

test:
	go test -v ./collector

build: $(BIN)

build-lambda: $(LAMBDA_ZIP)

clean:
	-rm -f build/

$(BIN): $(SRC)
	-mkdir -p build/
	go build -o $(BIN) -ldflags="$(FLAGS)" .

GODIR=/go/src/github.com/buildkite/buildkite-metrics

$(LAMBDA_ZIP): $(SRC)
	docker run --rm -v $(PWD):$(GODIR) -w $(GODIR) eawsy/aws-lambda-go
	-mkdir -p build/
	mv handler.zip $(LAMBDA_ZIP)
