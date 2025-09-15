package config

import (
    "fmt"
    "time"

    env "github.com/caarlos0/env/v11"
)

type Config struct {
    AppEnv   string `env:"APP_ENV,notEmpty" envDefault:"development"`
    AppPort  string `env:"APP_PORT,notEmpty" envDefault:"8080"`

    DBHost     string `env:"DB_HOST" envDefault:"localhost"`
    DBPort     int    `env:"DB_PORT" envDefault:"5432"`
    DBUser     string `env:"DB_USER" envDefault:"postgres"`
    DBPassword string `env:"DB_PASSWORD" envDefault:"postgres"`
    DBName     string `env:"DB_NAME" envDefault:"appdb"`
    DBSSLMode  string `env:"DB_SSLMODE" envDefault:"disable"`

    RedisAddr     string `env:"REDIS_ADDR" envDefault:"localhost:6379"`
    RedisPassword string `env:"REDIS_PASSWORD"`
    RedisDB       int    `env:"REDIS_DB" envDefault:"0"`

    // Optional timeouts
    ShutdownTimeout time.Duration `env:"SHUTDOWN_TIMEOUT" envDefault:"10s"`
}

func Load() (Config, error) {
    var cfg Config
    if err := env.Parse(&cfg); err != nil {
        return cfg, err
    }
    return cfg, nil
}

func (c Config) Addr() string { return ":" + c.AppPort }

func (c Config) PostgresDSN() string {
    return fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=%s",
        c.DBUser, c.DBPassword, c.DBHost, c.DBPort, c.DBName, c.DBSSLMode,
    )
}

