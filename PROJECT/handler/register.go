package handler

import (
	"encoding/json"
	"net/http"
	"project/helper"
	"project/model"

	"go.uber.org/zap"
)

func (h *Handler) RegisterHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		var user model.User

		err := json.NewDecoder(r.Body).Decode(&user)
		if err != nil {
			h.Log.Error("Error RegisterHandler", zap.Error(err))
			helper.BadResponse(w, http.StatusBadRequest, "register failed invalid input")
			return
		}

		msg, err := helper.ValidateInput(user)
		if err != nil {
			h.Log.Error("Error RegisterHandler", zap.Error(err))
			h.Log.Error("Error RegisterHandler", zap.String("Message: ", msg))
			helper.BadResponse(w, http.StatusUnprocessableEntity, "inputan tidak valid")
			return
		}

		err = h.Service.RegisterService(&user)
		if err != nil {
			if err.Error() == "username or email already exists" {
				helper.BadResponse(w, http.StatusConflict, "username or email already exists")
			} else {
				helper.BadResponse(w, http.StatusUnauthorized, err.Error())
			}
			return
		}

		helper.SuccessResponse(w, http.StatusCreated, "succes register", user)

	} else {
		helper.MethodNotAllowed(w)
	}
}
