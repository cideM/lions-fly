FROM litestream/litestream AS litestream

FROM public.ecr.aws/docker/library/golang:1.18.4-alpine3.16 as go
WORKDIR /usr/src/app

# Required for go-sqlite3
RUN apk add --no-cache git make build-base
ENV CGO_ENABLED=1

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/root/.cache/go-build go mod download

COPY ./ ./
# https://github.com/golang/go/issues/51253
RUN git config --global --add safe.directory /usr/src/app
RUN git -c log.showsignature=false show
RUN --mount=type=cache,target=/root/.cache/go-build go build -tags json1 -o app

FROM alpine:3.16.1
WORKDIR /usr/src/app

COPY --from=litestream /usr/local/bin/litestream /usr/local/bin/litestream
COPY --from=go /usr/src/app/app /usr/local/bin/app
COPY ./entrypoint.sh ./

ENTRYPOINT ["./entrypoint.sh"]
