package config

import (
	"os"
	"testing"
)

func TestLoadConfigAndGetDSNPostgres(t *testing.T) {
	// Preserve envs
	old := map[string]string{}
	keys := []string{"DB_DRIVER", "DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME", "DB_SSLMODE"}
	for _, k := range keys {
		old[k] = os.Getenv(k)
	}
	defer func() {
		for k, v := range old {
			os.Setenv(k, v)
		}
	}()

	os.Setenv("DB_DRIVER", "postgres")
	os.Setenv("DB_HOST", "localhost")
	os.Setenv("DB_PORT", "5432")
	os.Setenv("DB_USER", "user")
	os.Setenv("DB_PASSWORD", "pass")
	os.Setenv("DB_NAME", "db")
	os.Setenv("DB_SSLMODE", "disable")

	cfg, err := LoadConfig()
	if err != nil {
		t.Fatalf("LoadConfig failed: %v", err)
	}

	got := cfg.GetDSN()
	want := "host=localhost port=5432 user=user password=pass dbname=db sslmode=disable"
	if got != want {
		t.Fatalf("unexpected postgres DSN\n got: %s\nwant: %s", got, want)
	}
}

func TestGetDSNMySQL(t *testing.T) {
	// set minimal vars for mysql
	os.Setenv("DB_DRIVER", "mysql")
	os.Setenv("DB_HOST", "127.0.0.1")
	os.Setenv("DB_PORT", "3306")
	os.Setenv("DB_USER", "u")
	os.Setenv("DB_PASSWORD", "p")
	os.Setenv("DB_NAME", "mydb")

	cfg, err := LoadConfig()
	if err != nil {
		t.Fatalf("LoadConfig failed: %v", err)
	}

	got := cfg.GetDSN()
	want := "u:p@tcp(127.0.0.1:3306)/mydb?parseTime=true"
	if got != want {
		t.Fatalf("unexpected mysql DSN\n got: %s\nwant: %s", got, want)
	}
}

func TestLoadConfigMissingDriver(t *testing.T) {
	// unset DB_DRIVER
	old := os.Getenv("DB_DRIVER")
	defer os.Setenv("DB_DRIVER", old)
	os.Unsetenv("DB_DRIVER")

	_, err := LoadConfig()
	if err == nil {
		t.Fatalf("expected error when DB_DRIVER is not set")
	}
}

func TestGetDSDUnknownDriver(t *testing.T) {
	os.Setenv("DB_DRIVER", "unknown")
	os.Setenv("DB_HOST", "x")
	os.Setenv("DB_PORT", "y")
	os.Setenv("DB_USER", "u")
	os.Setenv("DB_PASSWORD", "p")
	os.Setenv("DB_NAME", "n")

	cfg, err := LoadConfig()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got := cfg.GetDSN(); got != "" {
		t.Fatalf("expected empty DSN for unknown driver, got: %s", got)
	}
}
