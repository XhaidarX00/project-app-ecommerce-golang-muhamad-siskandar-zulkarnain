package model

type RecomentIDs struct {
	ProductIDs []int `json:"product_ids" validate:"required,min=1,dive,gt=0"`
}

type RecomentProduct struct {
	ProductID   int    `json:"product_id" validate:"required,gt=0"`
	Name        string `json:"name" validate:"required,min=3,max=100"`
	Description string `json:"description" validate:"required,max=500"`
	PhotoURL    string `json:"photo_url" validate:"required,url"`
	PathPage    string `json:"path_page,omitempty" validate:"omitempty,url"`
}
