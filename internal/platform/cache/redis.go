package cache

import (
    "context"
    "time"

    "github.com/redis/go-redis/v9"
    "github.com/ambiyansyah-risyal/golang-base/internal/config"
)

func NewRedis(cfg config.Config) *redis.Client {
    return redis.NewClient(&redis.Options{
        Addr:     cfg.RedisAddr,
        Password: cfg.RedisPassword,
        DB:       cfg.RedisDB,
    })
}

func Ping(ctx context.Context, rdb *redis.Client) error {
    ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
    defer cancel()
    return rdb.Ping(ctx).Err()
}

