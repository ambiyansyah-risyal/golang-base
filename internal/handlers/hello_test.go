package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHelloHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "/", nil)
	w := httptest.NewRecorder()

	HelloHandler(w, req)

	resp := w.Result()
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected status 200, got %d", resp.StatusCode)
	}

	var h helloResp
	if err := json.NewDecoder(resp.Body).Decode(&h); err != nil {
		t.Fatalf("decode error: %v", err)
	}

	if h.Message != "Hello, world" {
		t.Fatalf("unexpected message: %q", h.Message)
	}
}
