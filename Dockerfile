FROM golang:1.21-alpine AS build
WORKDIR /src
COPY . .
RUN go mod tidy
RUN go build -o /app/bin/server ./cmd/server

FROM alpine:3.18
COPY --from=build /app/bin/server /app/bin/server
EXPOSE 8080
ENTRYPOINT ["/app/bin/server"]
