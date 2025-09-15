package db

import (
    "time"

    "github.com/ambiyansyah-risyal/golang-base/internal/config"
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
)

func NewPostgres(cfg config.Config) (*gorm.DB, error) {
    gcfg := &gorm.Config{
        Logger: logger.Default.LogMode(logger.Warn),
    }
    db, err := gorm.Open(postgres.Open(cfg.PostgresDSN()), gcfg)
    if err != nil {
        return nil, err
    }
    // Set connection pool (optional)
    sqlDB, err := db.DB()
    if err != nil {
        return nil, err
    }
    sqlDB.SetMaxIdleConns(10)
    sqlDB.SetMaxOpenConns(25)
    sqlDB.SetConnMaxLifetime(30 * time.Minute)
    return db, nil
}

