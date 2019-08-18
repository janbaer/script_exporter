FROM golang:1.12-alpine as build

MAINTAINER  Jan Baer <info@janbaer.de>

RUN apk add --no-cache gcc musl-dev ca-certificates git

RUN mkdir /src

WORKDIR /src

# Copy only go.mod and go.sum and than download the dependencies so that they will be cached
COPY ./go.mod ./go.sum ./
RUN go mod download

COPY script_exporter.go .

RUN go build -o script-exporter script_exporter.go

# ------------------------------------
FROM        alpine:latest

MAINTAINER  Jan Baer <info@janbaer.de>

COPY --from=build /src/script-exporter /bin/script-exporter
COPY script-exporter.yml /etc/script-exporter/config.yml

EXPOSE      9172
ENTRYPOINT  [ "/bin/script-exporter" ]
CMD ["-config.file=/etc/script-exporter/config.yml"]
