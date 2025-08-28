package main

import (
	"log"
	"net/http"

	"github.com/yourusername/golang-base/internal/handlers"
	"github.com/yourusername/golang-base/pkg/version"
)

func main() {
	log.Printf("starting app version=%s", version.Version)
	http.HandleFunc("/", handlers.HelloHandler)
	addr := ":8080"
	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
