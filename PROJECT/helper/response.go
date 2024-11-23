package helper

import (
	"encoding/json"
	"net/http"
	"project/model"
)

type Response struct {
	Status  int
	Message string
	Data    interface{}
}

func SuccessResponse(w http.ResponseWriter, code int, message string, data interface{}) {
	response := Response{
		Status:  code,
		Message: message,
		Data:    data,
	}

	w.WriteHeader(code)
	w.Header().Set("content-type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func BadResponse(w http.ResponseWriter, code int, message string) {
	response := Response{
		Status:  code,
		Message: message,
	}

	w.WriteHeader(code)
	w.Header().Set("content-type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func PageResponse(w http.ResponseWriter, text string, limit, page, totalItems, totalPages int, data interface{}) {
	response := model.PaginationResponse{
		StatusCode: http.StatusOK,
		Message:    text,
		Page:       page,
		Limit:      limit,
		TotalItems: totalItems,
		TotalPages: totalPages,
		Data:       data,
	}

	w.WriteHeader(http.StatusOK)
	w.Header().Set("content-type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func MethodNotAllowed(w http.ResponseWriter) {
	response := Response{
		Status:  http.StatusMethodNotAllowed,
		Message: "methode not allowed",
	}

	w.WriteHeader(http.StatusMethodNotAllowed)
	w.Header().Set("content-type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func ToJson(w http.ResponseWriter) {
	response := Response{
		Status:  http.StatusMethodNotAllowed,
		Message: "methode not allowed",
	}

	w.WriteHeader(http.StatusMethodNotAllowed)
	w.Header().Set("content-type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func ListCartToJson(w http.ResponseWriter, code int, message string, totalItems, totalcartprice, shipping float64, data []model.ListCart) {
	response := model.ResponseListCart{
		Status:             code,
		Message:            message,
		Shipping:           shipping,
		TotalPriceAllItems: totalItems,
		TotalCartPrice:     totalcartprice,
		Data:               data,
	}
	w.WriteHeader(code)
	w.Header().Set("content-type", "application/json")
	json.NewEncoder(w).Encode(response)
}
