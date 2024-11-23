package handler

import (
	"project/service"

	"go.uber.org/zap"
)

type Handler struct {
	Service service.AllService
	Log     *zap.Logger
}

func NewHandler(service service.AllService, log *zap.Logger) Handler {
	return Handler{
		Service: service,
		Log:     log,
	}
}
