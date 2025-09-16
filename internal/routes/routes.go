package routes

import (
	"golang-base/internal/config"
	"golang-base/internal/handlers"
	"golang-base/internal/middleware"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// Setup configures all routes for the application
func Setup(app *fiber.App, db *gorm.DB, cfg *config.Config) {
	// Initialize handlers
	authHandler := handlers.NewAuthHandler(db, cfg)
	userHandler := handlers.NewUserHandler(db, cfg)
	webHandler := handlers.NewWebHandler()

	// API routes
	api := app.Group("/api/v1")

	// Public routes
	auth := api.Group("/auth")
	auth.Post("/register", authHandler.Register)
	auth.Post("/login", authHandler.Login)
	auth.Post("/refresh", authHandler.RefreshToken)

	// Protected routes
	protected := api.Group("/")
	protected.Use(middleware.JWTAuth(cfg.JWTSecret))

	// User routes
	users := protected.Group("/users")
	users.Get("/profile", userHandler.GetProfile)
	users.Put("/profile", userHandler.UpdateProfile)
	users.Delete("/profile", userHandler.DeleteProfile)

	// Admin routes
	admin := protected.Group("/admin")
	admin.Use(middleware.RequireRole("admin"))
	admin.Get("/users", userHandler.GetAllUsers)
	admin.Get("/users/:id", userHandler.GetUserByID)
	admin.Put("/users/:id", userHandler.UpdateUser)
	admin.Delete("/users/:id", userHandler.DeleteUser)

	// Web routes (serving HTML pages)
	app.Get("/", webHandler.Index)
	app.Get("/login", webHandler.Login)
	app.Get("/register", webHandler.Register)
	app.Get("/dashboard", middleware.WebAuth(), webHandler.Dashboard)

	// Health check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":  "ok",
			"message": "Server is running",
		})
	})
}
