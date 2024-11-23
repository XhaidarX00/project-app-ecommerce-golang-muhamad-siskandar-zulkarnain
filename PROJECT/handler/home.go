package handler

import (
	"net/http"
	"project/helper"
	"project/model"
	"strconv"

	"go.uber.org/zap"
)

func (h *Handler) BannerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		var product []model.Product
		err := h.Service.BannerService(&product)
		if err != nil {
			helper.BadResponse(w, http.StatusNotFound, "data tidak ditemukan")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "succes get data banner", product)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) GetCategoryHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		var categories []model.Category
		err := h.Service.GetCategoryService(&categories)
		if err != nil {
			helper.BadResponse(w, http.StatusNotFound, "data tidak ditemukan")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "succes get data categories", categories)

	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) GetBestSellingHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		page, err := strconv.Atoi(r.URL.Query().Get("page"))
		if err != nil {
			h.Log.Error("Error GetBestSellingHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		limit, err := strconv.Atoi(r.URL.Query().Get("limit"))
		if err != nil {
			h.Log.Error("Error GetBestSellingHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		var bestSelling []model.BestSelling
		totalPage, totalItems, err := h.Service.GetBestSellingProductService(limit, page, &bestSelling)
		if err != nil {
			helper.BadResponse(w, http.StatusNotFound, "data tidak ditemukan")
			return
		}

		helper.PageResponse(w, "succes get data bestSelling", limit, page, totalItems, totalPage, bestSelling)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) GetPromoWeeklyHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		var product []model.PromoWeekly
		err := h.Service.GetPromoWeeklyProductService(&product)
		if err != nil {
			helper.BadResponse(w, http.StatusNotFound, "data tidak ditemukan")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "succes get data banner", product)

	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) GetAllProductHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
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

		var allProduct []model.AllProduct
		totalPage, totalItems, err := h.Service.GetAllProductService(limit, page, &allProduct)
		if err != nil {
			helper.BadResponse(w, http.StatusNotFound, "data tidak ditemukan")
			return
		}

		helper.PageResponse(w, "succes get data allProduct", limit, page, totalItems, totalPage, allProduct)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) GetRecomentProductHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		var product []model.RecomentProduct
		err := h.Service.GetRecomentProductService(&product)
		if err != nil {
			helper.BadResponse(w, http.StatusNotFound, "data tidak ditemukan")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "succes get data recomment", product)

	} else {
		helper.MethodNotAllowed(w)
	}
}
