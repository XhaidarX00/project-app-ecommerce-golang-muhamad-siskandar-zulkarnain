package service

import "project/model"

func (s *AllService) GetAllPageProductService(name string, category, limit, page int, data *[]model.AllProduct) (int, int, error) {
	return s.Repo.GetAllPageProductRepo(name, category, limit, page, data)
}

func (s *AllService) AddToCartService(ATC *model.AddToCart) error {
	return s.Repo.AddToCartRepo(ATC)
}
