package handlers

import (
	"encoding/json"
	"net/http"
)

type helloResp struct {
	Message string `json:"message"`
}

// HelloHandler returns a simple JSON greeting.
func HelloHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	resp := helloResp{Message: "Hello, world"}
	_ = json.NewEncoder(w).Encode(resp)
}
