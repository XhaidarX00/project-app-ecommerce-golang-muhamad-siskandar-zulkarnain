package handler

import (
	"encoding/json"
	"net/http"
	"project/helper"
	"project/model"

	"go.uber.org/zap"
)

func (h *Handler) LoginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		var user model.User
		err := json.NewDecoder(r.Body).Decode(&user)
		if err != nil {
			helper.BadResponse(w, http.StatusBadRequest, err.Error())
			return
		}

		msg, err := helper.ValidateInput(user)
		if err != nil {
			h.Log.Error("Error LoginHandler", zap.Error(err))
			h.Log.Error("Error LoginHandler", zap.String("Message: ", msg))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		err = h.Service.LoginService(&user)
		if err != nil {
			helper.BadResponse(w, http.StatusUnauthorized, "email atau phone number tidak valid, atau password salah")
			return
		}

		helper.SuccessResponse(w, http.StatusOK, "Succes Login", user)

	} else {
		helper.MethodNotAllowed(w)
	}
}
