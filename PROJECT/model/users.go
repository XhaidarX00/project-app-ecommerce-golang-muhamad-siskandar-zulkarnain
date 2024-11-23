package model

import "time"

type User struct {
	ID          int       `json:"id"`
	Name        string    `json:"name"`
	Email       string    `json:"email,omitempty" validate:"omitempty,email"`
	PhoneNumber string    `json:"phone_number,omitempty" validate:"omitempty,numeric"`
	Password    string    `json:"password" validate:"required,min=6"`
	Token       string    `json:"token"`
	CreatedAt   time.Time `json:"created_at"`
	UpdateAt    time.Time `json:"update_at"`
}
