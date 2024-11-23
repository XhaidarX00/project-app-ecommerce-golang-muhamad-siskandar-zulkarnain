package model

type Category struct {
	CategoryID  int    `json:"category_id" validate:"required,gt=0"`
	Name        string `json:"name" validate:"required,min=3,max=100"`
	Description string `json:"description,omitempty" validate:"omitempty,min=5,max=255"`
}
