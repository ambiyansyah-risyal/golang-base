package handlers

import (
	"github.com/gofiber/fiber/v2"
)

type WebHandler struct{}

func NewWebHandler() *WebHandler {
	return &WebHandler{}
}

// Index serves the homepage
func (h *WebHandler) Index(c *fiber.Ctx) error {
	return c.Render("index", fiber.Map{
		"Title": "Welcome to GoFiber App",
	})
}

// Login serves the login page
func (h *WebHandler) Login(c *fiber.Ctx) error {
	return c.Render("auth/login", fiber.Map{
		"Title": "Login",
	})
}

// Register serves the registration page
func (h *WebHandler) Register(c *fiber.Ctx) error {
	return c.Render("auth/register", fiber.Map{
		"Title": "Register",
	})
}

// Dashboard serves the user dashboard
func (h *WebHandler) Dashboard(c *fiber.Ctx) error {
	return c.Render("dashboard", fiber.Map{
		"Title": "Dashboard",
	})
}
