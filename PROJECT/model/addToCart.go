package model

type AddToCart struct {
	UserID    int `json:"user_id" validate:"required,gt=0"`
	CartID    int `json:"cart_id"`
	ProductID int `json:"product_id" validate:"required,gt=0"`
	Quantity  int `json:"quantity" validate:"required,gt=0"`
}
