FROM golang:1.20-alpine AS build
WORKDIR /src
COPY . .
RUN go build -o /bin/app ./cmd/app

FROM alpine:3.18
COPY --from=build /bin/app /bin/app
EXPOSE 8080
ENTRYPOINT ["/bin/app"]
