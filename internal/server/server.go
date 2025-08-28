package server

import (
	"context"
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Server wraps the Fiber app
type Server struct {
	app *fiber.App
}

// New creates a new Server with routes
func New() *Server {
	app := fiber.New()
	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"message": "hello from golang-base"})
	})

	// health check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.SendString("ok")
	})

	return &Server{app: app}
}

// Start launches the underlying Fiber app
func (s *Server) Start(addr string) error {
	return s.app.Listen(addr)
}

// Shutdown stops the server gracefully
func (s *Server) Shutdown(ctx context.Context) error {
	ch := make(chan error, 1)
	go func() {
		ch <- s.app.Shutdown()
	}()

	select {
	case err := <-ch:
		return err
	case <-ctx.Done():
		return fmt.Errorf("shutdown timeout after %s", 5*time.Second)
	}
}
