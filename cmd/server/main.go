package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"time"

	"github.com/ambiyansyah-risyal/golang-base/internal/server"
)

func main() {
	srv := server.New()
	go func() {
		if err := srv.Start(":8080"); err != nil {
			log.Fatal(err)
		}
	}()

	// graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal(err)
	}
}
