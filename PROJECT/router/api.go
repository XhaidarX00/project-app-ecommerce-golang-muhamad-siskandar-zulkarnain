package router

import (
	"database/sql"
	"project/database"
	"project/handler"
	"project/middleware"
	"project/repository"
	"project/service"
	"project/util"

	"github.com/go-chi/chi/v5"
	"go.uber.org/zap"
)

func InitRouter() (*chi.Mux, *sql.DB, *zap.Logger, error) {
	r := chi.NewRouter()

	logger := util.InitLog()

	config, err := util.ReadConfiguration()
	if err != nil {
		return nil, nil, logger, err
	}

	db, err := database.InitDB(config)
	if err != nil {
		return nil, nil, logger, err
	}

	repo := repository.NewRepository(db, logger)
	service := service.NewService(repo, logger)
	Handle := handler.NewHandler(service, logger)
	Middleware := middleware.NewMiddleware(logger, service)

	Routes(r, &Handle, &Middleware)
	return r, db, logger, nil
}

func Routes(r *chi.Mux, h *handler.Handler, m *middleware.Middleware) {
	r.With(m.MinddlewareLogger).Route("/", func(r chi.Router) {
		r.Post("/login", h.LoginHandler)
		r.Post("/register", h.RegisterHandler)
		r.Get("/banner", h.BannerHandler)
		r.Get("/categories", h.GetCategoryHandler)
		r.Get("/best-selling", h.GetBestSellingHandler)
		r.Get("/promo-weekly", h.GetPromoWeeklyHandler)
		r.Get("/list-product", h.GetAllProductHandler)
		r.Get("/list-recomment", h.GetRecomentProductHandler)
		r.Get("/page-products", h.GetAllPageProductHandler)

		r.With(m.TokenMiddleware).Route("/api", func(r chi.Router) {
			r.Get("/product-detail", h.GetDetailHandler)
			r.Get("/list-cart", h.GetListCartHandler)
			r.Get("/customer-address", h.GetListAddressHandler)
			r.Post("/add-order", h.AddOrderHandler)
			r.Post("/add-to-cart", h.AddToCartHandler)
			r.Post("/update-cart-items", h.UpdateListCartHandler)
			r.Delete("/delete-cart-items", h.DeleteListCartHandler)
		})
	})
}
