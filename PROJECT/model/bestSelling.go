package model

type BestSelling struct {
	ID            int     `json:"id" validate:"required,gt=0"`
	Name          string  `json:"name" validate:"required,min=3,max=100"`
	Price         float64 `json:"price" validate:"required,gt=0"`
	PriceDiscount float64 `json:"price_discount" validate:"gte=0,ltefield=Price"`
	Rating        float32 `json:"rating" validate:"gte=0,lte=5"`
	CountRating   int     `json:"count_rating" validate:"gte=0"`
	TotalSold     int     `json:"-" validate:"gte=0"`
}
