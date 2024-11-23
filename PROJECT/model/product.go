package model

import (
	"time"
)

type Product struct {
	ProductID       int       `json:"product_id" validate:"required,gt=0"`
	Name            string    `json:"name" validate:"required,min=3,max=100"`
	Description     string    `json:"description" validate:"required,min=10,max=500"`
	Price           float64   `json:"price,omitempty" validate:"required_with=PriceDiscount,gt=0"`
	PriceDiscount   float64   `json:"price_discount,omitempty" validate:"omitempty,ltfield=Price"`
	NominalDiscount float64   `json:"nominal_discount,omitempty" validate:"omitempty,gte=0"`
	Stock           int       `json:"stock,omitempty" validate:"omitempty,gte=0"`
	CategoryID      *int      `json:"category_id,omitempty" validate:"omitempty,gt=0"`
	PhotoURL        string    `json:"photo_url,omitempty" validate:"omitempty,url"`
	CreatedAt       time.Time `json:"created_at,omitempty" validate:"omitempty"`
	UpdatedAt       time.Time `json:"updated_at,omitempty" validate:"omitempty"`
	PathPage        string    `json:"path_page,omitempty" validate:"omitempty,url"`
}
