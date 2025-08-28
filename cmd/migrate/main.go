package main

import (
	"log"
	"os"

	"github.com/ambiyansyah-risyal/golang-base/internal/config"
	_ "github.com/go-sql-driver/mysql"
	_ "github.com/lib/pq"
	"github.com/pressly/goose/v3"
)

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	dbDSN := cfg.GetDSN()
	db, err := goose.OpenDBWithDriver(cfg.DBDriver, dbDSN)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	if len(os.Args) < 2 {
		log.Fatalf("Usage: %s <command>", os.Args[0])
	}

	if err := goose.Run(os.Args[1], db, "migrations"); err != nil {
		log.Fatalf("goose run failed: %v", err)
	}
}
