package service

import (
	"project/repository"

	"go.uber.org/zap"
)

type AllService struct {
	Repo   repository.AllRepository
	Logger *zap.Logger
}

func NewService(repo repository.AllRepository, Log *zap.Logger) AllService {
	return AllService{
		Repo:   repo,
		Logger: Log,
	}
}

// func (Service *Service) Create( *model.) error {
// 	return Service.Create()
// }

// func (Service *Service) GetAll() ([]*model., error) {
// 	return nil, nil
// }

// func (Service *Service) GetByID(id int) (*model., error) {
// 	return nil, nil
// }

// func (Service *Service) Update(id int, book model.) error {
// 	return nil
// }

// func (Service *Service) Delete(id int) error {
// 	return nil
// }
