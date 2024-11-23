package model

import "time"

type PhotoDetailProduct struct {
	ID          int    `json:"id" validate:"required,gt=0"`
	PhotoURL    string `json:"photo_url" validate:"required,url"`
	Description string `json:"description" validate:"required,min=3,max=255"`
}

type DetailProduct struct {
	ProductID   int                    `json:"product_id" validate:"required,gt=0"`
	ProductName string                 `json:"product_name" validate:"required,min=3,max=100"`
	Detail      []DetailProductAtribut `json:"detail_product" validate:"required,dive"`
}

type DetailProductAtribut struct {
	Size       string  `json:"size,omitempty" validate:"omitempty,alpha"`
	Type       string  `json:"type,omitempty" validate:"omitempty,alpha"`
	ColorName  string  `json:"color_name,omitempty" validate:"omitempty,alpha"`
	ImageURL   string  `json:"image_url,omitempty" validate:"omitempty,url"`
	Price      float64 `json:"price" validate:"required,gt=0"`
	SizeStock  int     `json:"size_stock" validate:"required,gte=0"`
	ColorStock int     `json:"color_stock" validate:"required,gte=0"`
}

type ListCart struct {
	ID           int     `json:"id" validate:"required,gt=0"`
	UserID       int     `json:"user_id" validate:"required,gt=0"`
	ProductID    int     `json:"product_id" validate:"required,gt=0"`
	ProductName  string  `json:"product_name" validate:"required,min=3,max=100"`
	Price        float64 `json:"discount" validate:"required,gt=0"`
	Quantity     int     `json:"quantity" validate:"required,gt=0"`
	PhotoURL     string  `json:"photo_url" validate:"required,url"`
	ShippingCost float64 `json:"shipping_cost" validate:"required,gte=0"`
	Total        float64 `json:"total" validate:"required,gt=0"`
}

type ResponseListCart struct {
	Status             int        `json:"status" validate:"required"`
	Message            string     `json:"message" validate:"required,min=3,max=255"`
	Shipping           float64    `json:"shipping" validate:"required,gte=0"`
	TotalPriceAllItems float64    `json:"subtotal" validate:"required,gte=0"`
	TotalCartPrice     float64    `json:"total" validate:"required,gte=0"`
	Data               []ListCart `json:"data" validate:"required,dive"`
}

type CustomerAddress struct {
	AddressID     int       `json:"address_id" validate:"required,gt=0"`
	UserID        int       `json:"user_id" validate:"required,gt=0"`
	RecipientName string    `json:"recipient_name" validate:"required,min=3,max=100"`
	PhoneNumber   string    `json:"phone_number" validate:"required,e164"`
	AddressLine   string    `json:"address_line" validate:"required,min=5,max=255"`
	City          string    `json:"city" validate:"required,min=2,max=50"`
	Province      string    `json:"province" validate:"required,min=2,max=50"`
	PostalCode    string    `json:"postal_code" validate:"required,numeric,len=5"`
	Latitude      float64   `json:"latitude" validate:"required"`
	Longitude     float64   `json:"longitude" validate:"required"`
	IsDefault     bool      `json:"is_default"`
	CreatedAt     time.Time `json:"created_at" validate:"required"`
}

type AddOrders struct {
	OrderID    int `json:"order_id" validate:"required,gt=0"`
	UserID     int `json:"user_id" validate:"required,gt=0"`
	TotalPrice int `json:"total_price" validate:"required,gt=0"`
	Status     int `json:"status" validate:"required,gte=0"`
	PaymentID  int `json:"payment_id" validate:"required,gt=0"`
}
