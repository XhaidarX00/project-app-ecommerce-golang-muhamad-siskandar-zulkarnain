package handler

import (
	"encoding/json"
	"net/http"
	"project/helper"
	"project/model"
	"project/repository"
	"strconv"

	"go.uber.org/zap"
)

func (h *Handler) GetDetailHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		productID, err := strconv.Atoi(r.URL.Query().Get("product_id"))
		if err != nil {
			h.Log.Error("Error GetDetailHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusBadRequest, "Parameter product_id tidak valid")
			return
		}

		var data model.DetailProduct
		data.ProductID = productID
		err = h.Service.GetDetailService(&data)
		if err != nil {
			h.Log.Error("Error GetDetailHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "Gagal mendapatkan data checkout")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "Sukses mendapatkan data checkout", data)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) GetListCartHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		UserID, err := strconv.Atoi(r.URL.Query().Get("user_id"))
		if err != nil {
			h.Log.Error("Error GetDetailHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusBadRequest, "Parameter product_id tidak valid")
			return
		}

		var data model.ResponseListCart
		err = h.Service.GetListCartService(UserID, &data)
		if err != nil {
			h.Log.Error("Error GetListCart", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "Gagal mendapatkan list cart")
			return
		}

		if data.Data == nil {
			h.Log.Error("Error GetListCart", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "Gagal mendapatkan list cart")
			return
		}
		helper.ListCartToJson(w, http.StatusOK, "succes get data list cart", data.TotalPriceAllItems, data.TotalCartPrice, data.Shipping, data.Data)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) UpdateListCartHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		CartItems, err := strconv.Atoi(r.URL.Query().Get("cart_item_id"))
		if err != nil {
			h.Log.Error("Error GetDetailHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusBadRequest, "Parameter cart_item_id tidak valid")
			return
		}

		ProductID, _ := strconv.Atoi(r.URL.Query().Get("product_id"))
		Quantity, err := strconv.Atoi(r.URL.Query().Get("quantity"))
		var params = repository.Params{
			ID:        CartItems,
			ProductID: ProductID,
			Quantity:  Quantity,
		}

		var data model.ListCart
		err = h.Service.UpdateListCartService(params, &data)
		if err != nil {
			h.Log.Error("Error GetListCart", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "failed update cart item")
			return
		}
		helper.SuccessResponse(w, http.StatusOK, "succes update cart item", data)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) DeleteListCartHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodDelete {
		CartItemsID, err := strconv.Atoi(r.URL.Query().Get("cart_item_id"))
		if err != nil {
			h.Log.Error("Error Delete item list Cart", zap.Error(err))
			helper.BadResponse(w, http.StatusBadRequest, "Cart Item Id tidak valid")
			return
		}

		err = h.Service.DeleteListCartService(CartItemsID)
		if err != nil {
			h.Log.Error("Error Delete item list Cart", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "failed delete item")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "succes delete items", nil)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) GetListAddressHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		user_id, err := strconv.Atoi(r.URL.Query().Get("user_id"))
		if err != nil {
			h.Log.Error("Error GetListAddress", zap.Error(err))
			helper.BadResponse(w, http.StatusBadRequest, "Get List Address tidak valid")
			return
		}

		var data []model.CustomerAddress
		err = h.Service.GetListAddressService(user_id, &data)
		if err != nil {
			h.Log.Error("Error GetListAddress", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "Data tidak ditemukan")
			return
		}

		if len(data) == 0 {
			h.Log.Error("Error GetListAddress", zap.String("Message", "Data tidak ditemukan"))
			helper.BadResponse(w, http.StatusInternalServerError, "Data tidak ditemukan")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "succes get address customers", data)
	} else {
		helper.MethodNotAllowed(w)
	}
}

func (h *Handler) AddOrderHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		var data model.AddOrders
		if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
			helper.BadResponse(w, http.StatusBadRequest, err.Error())
			return
		}

		msg, err := helper.ValidateInput(data)
		if err != nil {
			h.Log.Error("Error AddOrderHandler", zap.Error(err))
			h.Log.Error("Error AddOrderHandler", zap.String("Message: ", msg))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		err = h.Service.AddOrdersService(&data)
		if err != nil {
			h.Log.Error("Error AddOrderHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusInternalServerError, "gagal tambah orders")
			return
		}

		helper.SuccessResponse(w, http.StatusCreated, "succes add order", data)
	} else {
		helper.MethodNotAllowed(w)
	}
}
