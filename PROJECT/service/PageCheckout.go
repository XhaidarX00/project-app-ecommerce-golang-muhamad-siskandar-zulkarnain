package service

import (
	"project/model"
	"project/repository"
)

func (s *AllService) GetDetailService(data *model.DetailProduct) error {
	return s.Repo.GetDetailRepo(data)

}

func (s *AllService) GetListCartService(user_id int, data *model.ResponseListCart) error {
	return s.Repo.GetListCartRepo(user_id, data)
}

func (s *AllService) UpdateListCartService(params repository.Params, data *model.ListCart) error {
	return s.Repo.UpdateListCartRepo(params, data)
}

func (s *AllService) DeleteListCartService(cart_id int) error {
	return s.Repo.DeleteListCartRepo(cart_id)
}

func (s *AllService) GetListAddressService(userID int, data *[]model.CustomerAddress) error {
	return s.Repo.GetListAddressRepo(userID, data)
}

func (s *AllService) AddOrdersService(data *model.AddOrders) error {
	return s.Repo.AddOrdersRepo(data)
}
