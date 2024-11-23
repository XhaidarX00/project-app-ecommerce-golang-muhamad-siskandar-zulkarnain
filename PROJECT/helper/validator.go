package helper

import (
	"fmt"

	"github.com/go-playground/validator/v10"
)

var validate *validator.Validate

// validator inline message
func ValidateInput(data interface{}) (string, error) {
	// Create new validation and check the struct
	validate = validator.New()
	err := validate.Struct(data)

	if err != nil {
		// Handle invalid validation errors
		if _, ok := err.(*validator.InvalidValidationError); ok {
			fmt.Println(err)
			return "", nil
		}

		// Collect validation errors
		var errors []string
		for _, e := range err.(validator.ValidationErrors) {
			var message string
			if e.Tag() == "email" {
				message = "Please input correct email format"
			} else {
				message = fmt.Sprintf("%s must %s", e.Field(), e.Tag())
			}
			errors = append(errors, message)
		}
		return fmt.Sprint(errors), err
	}

	return "", nil
}

type FieldError struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}

// validator object struct message
func ValidateUser(data any) ([]FieldError, error) {
	// Initialize the validator
	validate = validator.New()

	// Validate the data struct
	err := validate.Struct(data)
	if err == nil {
		return nil, nil // No error, validation passed
	}

	// Initialize the error response
	var errors []FieldError

	// Process validation errors
	for _, err := range err.(validator.ValidationErrors) {
		var message string

		// Customize messages based on tag
		switch err.Tag() {
		case "required":
			message = fmt.Sprintf("%s is required", err.Field())
		case "email":
			message = "Please enter a valid email format"
		case "gte":
			message = fmt.Sprintf("%s must be a non-negative number", err.Field())
		case "min":
			message = fmt.Sprintf("%s must be at least %s characters long", err.Field(), err.Param())
		case "eqfield":
			message = fmt.Sprintf("%s must match %s", err.Field(), err.Param())
		default:
			message = fmt.Sprintf("%s is invalid", err.Field())
		}

		// Append each field error to the slice
		errors = append(errors, FieldError{
			Field:   err.Field(),
			Message: message,
		})
	}

	return errors, nil
}

// validator object struct message with generic
func ValidateInputGeneric[T any](data T) ([]FieldError, error) {
	// Initialize the validator if not already done
	if validate == nil {
		validate = validator.New()
	}

	// Validate the struct
	err := validate.Struct(data)
	if err == nil {
		return nil, nil // No errors, validation passed
	}

	// Initialize the error response
	var errors []FieldError

	// Process validation errors
	for _, err := range err.(validator.ValidationErrors) {
		var message string

		// Customize messages based on tag
		switch err.Tag() {
		case "required":
			message = fmt.Sprintf("%s is required", err.Field())
		case "email":
			message = "Please enter a valid email format"
		case "gte":
			message = fmt.Sprintf("%s must be a non-negative number", err.Field())
		case "min":
			message = fmt.Sprintf("%s must be at least %s characters long", err.Field(), err.Param())
		case "eqfield":
			message = fmt.Sprintf("%s must match %s", err.Field(), err.Param())
		default:
			message = fmt.Sprintf("%s is invalid", err.Field())
		}

		// Append each field error to the slice
		errors = append(errors, FieldError{
			Field:   err.Field(),
			Message: message,
		})
	}

	return errors, nil
}
