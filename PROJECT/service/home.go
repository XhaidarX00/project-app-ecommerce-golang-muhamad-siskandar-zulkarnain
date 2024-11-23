package service

import "project/model"

func (s *AllService) BannerService(data *[]model.Product) error {
	return s.Repo.BannerRepository(data)
}

func (s *AllService) GetCategoryService(data *[]model.Category) error {
	return s.Repo.GetCategoryRepo(data)
}

func (s *AllService) GetBestSellingProductService(limit int, page int, data *[]model.BestSelling) (int, int, error) {
	return s.Repo.GetBestSellingProductRepo(limit, page, data)
}

func (s *AllService) GetPromoWeeklyProductService(data *[]model.PromoWeekly) error {
	return s.Repo.GetPromoWeeklyProductRepo(data)
}

func (s *AllService) GetAllProductService(limit int, page int, data *[]model.AllProduct) (int, int, error) {
	return s.Repo.GetAllProductRepo(limit, page, data)
}

func (s *AllService) GetRecomentProductService(data *[]model.RecomentProduct) error {
	return s.Repo.GetRecomentProductRepo(data)
}
