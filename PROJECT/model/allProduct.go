package model

type AllProduct struct {
	ProductID     int     `json:"product_id" validate:"required,gt=0"`
	Name          string  `json:"name" validate:"required,min=3,max=100"`
	Description   string  `json:"description" validate:"required,min=10,max=500"`
	Price         float64 `json:"price" validate:"required,gt=0"`
	Discount      float64 `json:"discount" validate:"gte=0,lte=100"`
	DiscountPrice float64 `json:"discount_price" validate:"gte=0,ltefield=Price"`
	Rating        float64 `json:"rating" validate:"gte=0,lte=5"`
	PhotoURL      string  `json:"photo_url,omitempty" validate:"omitempty,url"`
	CountRating   int     `json:"count_rating" validate:"gte=0"`
	Status        string  `json:"status" validate:"required,oneof=active inactive discontinued"`
}
