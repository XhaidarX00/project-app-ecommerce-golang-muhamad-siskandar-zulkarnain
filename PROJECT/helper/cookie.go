package helper

import (
	"net/http"
	"time"
)

func SetCookie(w http.ResponseWriter, token string) {
	cookieDuration := 24 * time.Hour

	http.SetCookie(w, &http.Cookie{
		Name:     "Token",
		Value:    token,
		Path:     "/", // access to all route
		Expires:  time.Now().Add(cookieDuration),
		MaxAge:   int(cookieDuration.Seconds()), // MaxAge in seconds
		HttpOnly: true,                          // Prevents JavaScript access to the cookie
		Secure:   true,                          // Ensures cookie is sent only over HTTPS
		SameSite: http.SameSiteStrictMode,       // Prevents CSRF attacks
	})
}
