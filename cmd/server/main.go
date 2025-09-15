package main

import (
    "context"
    "log"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/gofiber/fiber/v2"
    "go.uber.org/zap"

    "github.com/ambiyansyah-risyal/golang-base/internal/app/http/router"
    "github.com/ambiyansyah-risyal/golang-base/internal/config"
    appcache "github.com/ambiyansyah-risyal/golang-base/internal/platform/cache"
    appdb "github.com/ambiyansyah-risyal/golang-base/internal/platform/db"
)

func main() {
    // Config
    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("config: %v", err)
    }

    // Logger
    logger, _ := zap.NewProduction()
    defer logger.Sync()
    sugar := logger.Sugar()

    // Infra
    gdb, err := appdb.NewPostgres(cfg)
    if err != nil {
        sugar.Fatalf("db connect: %v", err)
    }
    sqlDB, _ := gdb.DB()

    rdb := appcache.NewRedis(cfg)
    if err := appcache.Ping(context.Background(), rdb); err != nil {
        sugar.Fatalf("redis connect: %v", err)
    }

    // Fiber app
    app := fiber.New()
    router.Register(app)

    // Graceful shutdown
    go func() {
        if err := app.Listen(cfg.Addr()); err != nil {
            sugar.Fatalf("listen: %v", err)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    ctx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
    defer cancel()
    _ = ctx // Fiber v2 uses duration directly below
    _ = app.ShutdownWithTimeout(cfg.ShutdownTimeout)
    if sqlDB != nil {
        _ = sqlDB.Close()
    }
    _ = rdb.Close()
    sugar.Infow("server stopped", "env", cfg.AppEnv, "time", time.Now())
}
