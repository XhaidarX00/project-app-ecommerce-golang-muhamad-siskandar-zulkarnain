package handler

import (
	"encoding/json"
	"net/http"
	"project/helper"
	"project/model"
	"strconv"

	"go.uber.org/zap"
)

func (h *Handler) GetAllPageProductHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		page, err := strconv.Atoi(r.URL.Query().Get("page"))
		if err != nil {
			h.Log.Error("Error GetAllProductHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		limit, err := strconv.Atoi(r.URL.Query().Get("limit"))
		if err != nil {
			h.Log.Error("Error GetAllProductHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		category, _ := strconv.Atoi(r.URL.Query().Get("category"))
		name := r.URL.Query().Get("name")

		var allProduct []model.AllProduct
		totalPage, totalItems, err := h.Service.GetAllPageProductService(name, category, limit, page, &allProduct)
		if err != nil {
			helper.BadResponse(w, http.StatusNotFound, "data tidak ditemukan")
			return
		}

		helper.PageResponse(w, "succes get data allProduct", limit, page, totalItems, totalPage, allProduct)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) AddToCartHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		var data model.AddToCart
		if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
			helper.BadResponse(w, http.StatusBadRequest, err.Error())
			return
		}

		msg, err := helper.ValidateInput(data)
		if err != nil {
			h.Log.Error("Error AddToCartHandler", zap.Error(err))
			h.Log.Error("Error AddToCartHandler", zap.String("Message: ", msg))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		err = h.Service.AddToCartService(&data)
		if err != nil {
			h.Log.Error("Error AddToCartHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "gagal tambah keranjang")
			return
		}

		helper.SuccessResponse(w, http.StatusCreated, "succes add cart", data)
	} else {
		helper.MethodNotAllowed(w)
	}
}
