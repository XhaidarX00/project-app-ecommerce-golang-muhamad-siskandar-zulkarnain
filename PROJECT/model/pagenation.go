package model

type PaginationResponse struct {
	StatusCode int         `json:"status_code" validate:"required,gt=0"`
	Message    string      `json:"message" validate:"required,min=3,max=255"`
	Page       int         `json:"page" validate:"required,gt=0"`
	Limit      int         `json:"limit" validate:"required,gt=0"`
	TotalItems int         `json:"total_items" validate:"required,gt=0"`
	TotalPages int         `json:"total_pages" validate:"required,gt=0"`
	Data       interface{} `json:"data" validate:"required"`
}
