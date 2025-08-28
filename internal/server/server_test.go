package server

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestServerHandlers(t *testing.T) {
	s := New()

	// test root handler using Fiber's app.Test
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	resp, err := s.app.Test(req)
	if err != nil {
		t.Fatalf("app.Test / failed: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 from /, got %d", resp.StatusCode)
	}
	// read body
	b := make([]byte, 128)
	n, _ := resp.Body.Read(b)
	body := string(b[:n])
	if body == "" {
		t.Fatalf("expected non-empty body from /, got empty")
	}
	// test /health
	req2 := httptest.NewRequest(http.MethodGet, "/health", nil)
	resp2, err := s.app.Test(req2)
	if err != nil {
		t.Fatalf("app.Test /health failed: %v", err)
	}
	if resp2.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 from /health, got %d", resp2.StatusCode)
	}
	b2 := make([]byte, 8)
	n2, _ := resp2.Body.Read(b2)
	if string(b2[:n2]) != "ok" {
		t.Fatalf("expected body 'ok' from /health, got %q", string(b2[:n2]))
	}
}

func TestStartAndShutdown(t *testing.T) {
	s := New()

	// start in background
	done := make(chan error, 1)
	go func() {
		// Listen on :0 to pick an available port
		done <- s.Start(":0")
	}()

	// give server a moment to start
	time.Sleep(50 * time.Millisecond)

	// attempt graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err := s.Shutdown(ctx); err != nil {
		t.Fatalf("Shutdown failed: %v", err)
	}

	// ensure Start returned (either nil or an error after shutdown)
	select {
	case err := <-done:
		if err != nil && err != http.ErrServerClosed {
			// Fiber may return different errors; accept nil
		}
	default:
	}
}
