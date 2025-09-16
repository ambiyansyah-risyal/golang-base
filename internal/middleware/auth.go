package middleware

import (
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

// JWTAuth creates JWT authentication middleware
func JWTAuth(secret string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Get token from Authorization header
		tokenString := c.Get("Authorization")
		if tokenString == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Authorization header required",
			})
		}

		// Remove "Bearer " prefix
		if strings.HasPrefix(tokenString, "Bearer ") {
			tokenString = tokenString[7:]
		}

		// Parse and validate token
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			// Validate signing method
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fiber.NewError(fiber.StatusUnauthorized, "Invalid token signing method")
			}
			return []byte(secret), nil
		})

		if err != nil || !token.Valid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Invalid token",
			})
		}

		// Extract claims
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Invalid token claims",
			})
		}

		// Store user info in context
		c.Locals("user_id", claims["user_id"])
		c.Locals("user_email", claims["email"])
		c.Locals("user_role", claims["role"])

		return c.Next()
	}
}

// RequireRole creates role-based authorization middleware
func RequireRole(requiredRole string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		role := c.Locals("user_role")
		if role == nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Authentication required",
			})
		}

		userRole, ok := role.(string)
		if !ok || userRole != requiredRole {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"error": "Insufficient permissions",
			})
		}

		return c.Next()
	}
}

// WebAuth creates web authentication middleware for HTML pages
func WebAuth() fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Check for JWT token in cookie
		tokenString := c.Cookies("auth_token")
		if tokenString == "" {
			// Redirect to login page
			return c.Redirect("/login")
		}

		// For web auth, we could validate the token here
		// For now, just continue if token exists
		return c.Next()
	}
}
