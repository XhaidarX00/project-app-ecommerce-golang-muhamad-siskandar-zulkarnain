package model

type PromoWeekly struct {
	ProductID   int    `json:"product_id" validate:"required,gt=0"`
	Description string `json:"description" validate:"required,min=10,max=500"`
	PhotoURL    string `json:"photo_url" validate:"required,url"`
	Category    string `json:"category" validate:"required,min=3,max=100"`
	PathPage    string `json:"path_page,omitempty" validate:"omitempty,url"`
}
