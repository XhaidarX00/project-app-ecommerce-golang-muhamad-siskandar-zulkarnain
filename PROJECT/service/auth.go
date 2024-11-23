package service

import (
	"net/http"
	"project/model"

	"go.uber.org/zap"
)

func (s *AllService) RegisterService(user *model.User) error {
	err := s.Repo.RegisterRepo(user)
	if err != nil {
		s.Logger.Error("Error RegisterService :", zap.Error(err))
		return err
	}
	return nil
}

func (s *AllService) LoginService(user *model.User) error {
	err := s.Repo.LoginRepo(user)
	if err != nil {
		s.Logger.Error("Error AllService :", zap.Error(err))
		return err
	}
	return nil
}

func (s *AllService) TokenCheck(token string) error {
	err := s.Repo.TokenCheckRepo(token)
	if err != nil {
		s.Logger.Error("Error :", zap.String("AllService", "Token Tidak Ditemukan"))
		return err
	}

	return nil
}

// Fungsi untuk membersihkan token yang sudah kadaluarsa
func (s *AllService) CleanExpiredTokens(w http.ResponseWriter) error {
	err := s.Repo.CleanExpiredTokensRepo()
	if err != nil {
		s.Logger.Error("Error :", zap.String("AllService", "Token Tidak Ditemukan"))
		return err
	}

	return nil
}
