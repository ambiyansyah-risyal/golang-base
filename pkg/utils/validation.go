package utils

import (
	"strings"

	"github.com/go-playground/validator/v10"
)

// FormatValidationErrors formats validation errors into a readable string
func FormatValidationErrors(err error) string {
	var errors []string

	if validationErrors, ok := err.(validator.ValidationErrors); ok {
		for _, e := range validationErrors {
			switch e.Tag() {
			case "required":
				errors = append(errors, e.Field()+" is required")
			case "email":
				errors = append(errors, e.Field()+" must be a valid email")
			case "min":
				errors = append(errors, e.Field()+" must be at least "+e.Param()+" characters")
			case "max":
				errors = append(errors, e.Field()+" must be at most "+e.Param()+" characters")
			default:
				errors = append(errors, e.Field()+" is invalid")
			}
		}
	}

	return strings.Join(errors, ", ")
}

// Contains checks if a slice contains a specific value
func Contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

// RemoveIndex removes an element at a specific index from a slice
func RemoveIndex(slice []string, index int) []string {
	if index < 0 || index >= len(slice) {
		return slice
	}
	return append(slice[:index], slice[index+1:]...)
}
