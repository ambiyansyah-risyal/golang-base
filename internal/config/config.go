package config

import (
	"os"
	"strconv"
	"time"
)

// Config holds all configuration for the application
type Config struct {
	Environment     string
	DatabaseURL     string
	JWTSecret       string
	AllowedOrigins  string
	RateLimit       int
	RateLimitWindow time.Duration
	SessionTimeout  time.Duration
	BCryptCost      int
}

// Load reads configuration from environment variables with sensible defaults
func Load() *Config {
	return &Config{
		Environment:     getEnv("APP_ENV", "development"),
		DatabaseURL:     getEnv("DATABASE_URL", "postgres://user:password@localhost:5432/golang_base?sslmode=disable"),
		JWTSecret:       getEnv("JWT_SECRET", "your-super-secret-jwt-key-change-this-in-production"),
		AllowedOrigins:  getEnv("ALLOWED_ORIGINS", "*"),
		RateLimit:       getEnvInt("RATE_LIMIT", 100),
		RateLimitWindow: getEnvDuration("RATE_LIMIT_WINDOW", "1m"),
		SessionTimeout:  getEnvDuration("SESSION_TIMEOUT", "24h"),
		BCryptCost:      getEnvInt("BCRYPT_COST", 12),
	}
}

// getEnv gets an environment variable or returns a default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// getEnvInt gets an environment variable as int or returns a default value
func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}

// getEnvDuration gets an environment variable as duration or returns a default value
func getEnvDuration(key string, defaultValue string) time.Duration {
	value := getEnv(key, defaultValue)
	duration, err := time.ParseDuration(value)
	if err != nil {
		duration, _ = time.ParseDuration(defaultValue)
	}
	return duration
}
