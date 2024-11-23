package main

import (
	"net/http"
	"project/router"
)

func main() {
	r, db, log, err := router.InitRouter()
	if err != nil {
		log.Panic(err.Error())

	}

	defer log.Sync()
	defer db.Close()

	log.Info("server started on http://localhost:8080")
	http.ListenAndServe(":8080", r)
}
