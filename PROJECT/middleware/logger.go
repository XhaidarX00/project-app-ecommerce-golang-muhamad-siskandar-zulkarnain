package middleware

import (
	"net/http"
	"project/service"
	"time"

	"go.uber.org/zap"
)

type Middleware struct {
	Svc service.AllService
	Log *zap.Logger
}

func NewMiddleware(log *zap.Logger, svc service.AllService) Middleware {
	return Middleware{
		Log: log,
		Svc: svc,
	}
}

func (middleware *Middleware) MinddlewareLogger(handler http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		handler.ServeHTTP(w, r)

		duration := time.Since(start)

		middleware.Log.Info("http request", zap.String("url", r.URL.String()), zap.Duration("duration", duration))
	})
}
