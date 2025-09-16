package main

import (
	"log"
	"os"

	"golang-base/internal/config"
	"golang-base/internal/database"
	"golang-base/internal/routes"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/helmet"
	"github.com/gofiber/fiber/v2/middleware/limiter"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/template/html/v2"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("Warning: .env file not found")
	}

	// Load configuration
	cfg := config.Load()

	// Initialize database
	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Run migrations
	if err := database.Migrate(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Initialize HTML template engine
	engine := html.New("./web/templates", ".html")
	engine.Reload(cfg.Environment == "development")

	// Create Fiber app with template engine
	app := fiber.New(fiber.Config{
		Views:       engine,
		ViewsLayout: "layouts/main",
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}

			// Send custom error page in production
			if cfg.Environment == "production" {
				return c.Status(code).Render("error", fiber.Map{
					"Title": "Error",
					"Code":  code,
				})
			}

			// Send error details in development
			return c.Status(code).JSON(fiber.Map{
				"error": err.Error(),
				"code":  code,
			})
		},
	})

	// Security middleware
	app.Use(helmet.New())

	// CORS middleware
	app.Use(cors.New(cors.Config{
		AllowOrigins: cfg.AllowedOrigins,
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
		AllowMethods: "GET, POST, HEAD, PUT, DELETE, PATCH, OPTIONS",
	}))

	// Rate limiting
	app.Use(limiter.New(limiter.Config{
		Max:        cfg.RateLimit,
		Expiration: cfg.RateLimitWindow,
	}))

	// Logger middleware
	app.Use(logger.New(logger.Config{
		Format: "[${ip}]:${port} ${status} - ${method} ${path}\n",
	}))

	// Recover middleware
	app.Use(recover.New())

	// Static files
	app.Static("/static", "./web/static")

	// Setup routes
	routes.Setup(app, db, cfg)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(app.Listen(":" + port))
}
