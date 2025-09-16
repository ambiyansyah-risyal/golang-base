package handlers

import (
	"strconv"

	"golang-base/internal/config"
	"golang-base/internal/models"
	"golang-base/pkg/utils"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

type UserHandler struct {
	db       *gorm.DB
	config   *config.Config
	validate *validator.Validate
}

func NewUserHandler(db *gorm.DB, cfg *config.Config) *UserHandler {
	return &UserHandler{
		db:       db,
		config:   cfg,
		validate: validator.New(),
	}
}

// GetProfile returns the current user's profile
func (h *UserHandler) GetProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id")
	if userID == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "User not authenticated",
		})
	}

	var user models.User
	if err := h.db.Where("id = ?", userID).First(&user).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "User not found",
		})
	}

	return c.JSON(fiber.Map{
		"user": user.ToResponse(),
	})
}

// UpdateProfile updates the current user's profile
func (h *UserHandler) UpdateProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id")
	if userID == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "User not authenticated",
		})
	}

	var req struct {
		FirstName string `json:"first_name" validate:"required"`
		LastName  string `json:"last_name" validate:"required"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if err := h.validate.Struct(req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": utils.FormatValidationErrors(err),
		})
	}

	var user models.User
	if err := h.db.Where("id = ?", userID).First(&user).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "User not found",
		})
	}

	user.FirstName = req.FirstName
	user.LastName = req.LastName

	if err := h.db.Save(&user).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update user",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Profile updated successfully",
		"user":    user.ToResponse(),
	})
}

// DeleteProfile deletes the current user's account
func (h *UserHandler) DeleteProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id")
	if userID == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "User not authenticated",
		})
	}

	if err := h.db.Delete(&models.User{}, userID).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to delete user",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Account deleted successfully",
	})
}

// GetAllUsers returns all users (admin only)
func (h *UserHandler) GetAllUsers(c *fiber.Ctx) error {
	var users []models.User

	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset := (page - 1) * limit

	if err := h.db.Offset(offset).Limit(limit).Find(&users).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch users",
		})
	}

	var userResponses []models.UserResponse
	for _, user := range users {
		userResponses = append(userResponses, user.ToResponse())
	}

	return c.JSON(fiber.Map{
		"users": userResponses,
		"page":  page,
		"limit": limit,
	})
}

// GetUserByID returns a specific user by ID (admin only)
func (h *UserHandler) GetUserByID(c *fiber.Ctx) error {
	userID := c.Params("id")

	var user models.User
	if err := h.db.Where("id = ?", userID).First(&user).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "User not found",
		})
	}

	return c.JSON(fiber.Map{
		"user": user.ToResponse(),
	})
}

// UpdateUser updates a specific user (admin only)
func (h *UserHandler) UpdateUser(c *fiber.Ctx) error {
	userID := c.Params("id")

	var req struct {
		FirstName string `json:"first_name" validate:"required"`
		LastName  string `json:"last_name" validate:"required"`
		Role      string `json:"role" validate:"required,oneof=user admin"`
		Active    *bool  `json:"active" validate:"required"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if err := h.validate.Struct(req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": utils.FormatValidationErrors(err),
		})
	}

	var user models.User
	if err := h.db.Where("id = ?", userID).First(&user).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "User not found",
		})
	}

	user.FirstName = req.FirstName
	user.LastName = req.LastName
	user.Role = req.Role
	user.Active = *req.Active

	if err := h.db.Save(&user).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update user",
		})
	}

	return c.JSON(fiber.Map{
		"message": "User updated successfully",
		"user":    user.ToResponse(),
	})
}

// DeleteUser deletes a specific user (admin only)
func (h *UserHandler) DeleteUser(c *fiber.Ctx) error {
	userID := c.Params("id")

	if err := h.db.Delete(&models.User{}, userID).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to delete user",
		})
	}

	return c.JSON(fiber.Map{
		"message": "User deleted successfully",
	})
}
