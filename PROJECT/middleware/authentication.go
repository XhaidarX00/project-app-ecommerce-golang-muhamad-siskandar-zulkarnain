package middleware

import (
	"net/http"
	"project/helper"

	"go.uber.org/zap"
)

func (m *Middleware) TokenMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// cookie, err := r.Cookie("Token")
		token := r.Header.Get("token")
		// if err != nil {
		// 	helper.BadResponse(w, http.StatusBadRequest, "Silahkan Login Terlebih Dahulu!")
		// 	return
		// }

		// token := cookie.Value

		if err := m.Svc.TokenCheck(token); err != nil {
			m.Log.Error("Error Token Midleware", zap.Error(err))
			helper.BadResponse(w, http.StatusUnauthorized, "Gagal login, pengguna tidak ditemukan")
			return
		}

		// Lanjutkan ke handler berikutnya jika token valid
		next.ServeHTTP(w, r)
	})
}
