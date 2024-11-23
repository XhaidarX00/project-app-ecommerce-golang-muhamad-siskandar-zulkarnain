package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"project/model"
	"time"

	"github.com/google/uuid"
	"go.uber.org/zap"
)

func (r *AllRepository) LoginRepo(user *model.User) error {
	if user.Email == "" {
		query := `SELECT u.user_id, u.name, u.phone_number, u.password, t.token 
			FROM users u
			JOIN tokens t ON t.user_id = u.user_id
			WHERE u.phone_number = $1 AND u.password = $2`

		err := r.DB.QueryRow(query, user.PhoneNumber, user.Password).Scan(&user.ID, &user.Name, &user.PhoneNumber, &user.Password, &user.Token)
		if err != nil {
			r.Logger.Error("Error LoginRepo", zap.Error(err))
			return err
		}

	} else if user.PhoneNumber == "" {
		query := `SELECT u.user_id, u.name, u.email, u.password, t.token 
			FROM users u
			JOIN tokens t ON t.user_id = u.user_id
			WHERE u.email = $1 AND u.password = $2`

		err := r.DB.QueryRow(query, user.Email, user.Password).Scan(&user.ID, &user.Name, &user.Email, &user.Password, &user.Token)
		if err != nil {
			r.Logger.Error("Error LoginRepo", zap.Error(err))
			return err
		}
	} else {
		return errors.New("email atau phone number tidak ditemukan")
	}

	return nil
}

func (r *AllRepository) RegisterRepo(user *model.User) error {
	if user.Email != "" {
		query := `INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING user_id`
		err := r.DB.QueryRow(query, user.Name, user.Email, user.Password).Scan(&user.ID)
		if err != nil {
			r.Logger.Error("Error RegisterRepo", zap.Error(err))
			return err
		}
	} else if user.PhoneNumber != "" {
		query := `INSERT INTO users (name, phone_number, password) VALUES ($1, $2, $3) RETURNING user_id`
		err := r.DB.QueryRow(query, user.Name, user.PhoneNumber, user.Password).Scan(&user.ID)
		if err != nil {
			r.Logger.Error("Error RegisterRepo", zap.Error(err))
			return err
		}
	} else {
		return errors.New("email atau phone number tidak ditemukan")
	}

	var err error
	user.Token, err = r.generateToken(user.ID)
	if err != nil {
		return err
	}

	return nil
}

func (r *AllRepository) generateToken(userID int) (string, error) {
	const tokenExpiryDuration = 30 * 24 * time.Hour
	if userID <= 0 {
		r.Logger.Error("Invalid userID for GenerateToken", zap.Int("userID", userID))
		return "", fmt.Errorf("invalid userID: %d", userID)
	}

	token := uuid.New().String()
	expiresAt := time.Now().Add(tokenExpiryDuration)

	query := "INSERT INTO tokens (user_id, token, expires_at) VALUES ($1, $2, $3)"
	_, err := r.DB.Exec(query, userID, token, expiresAt)
	if err != nil {
		r.Logger.Error("Error inserting token into database", zap.Error(err))
		return "", fmt.Errorf("failed to generate token: %w", err)
	}

	return token, nil
}

func (r *AllRepository) TokenCheckRepo(token string) error {
	if token == "" {
		return errors.New("token is required")
	}

	if r.DB == nil {
		r.Logger.Error("Database connection is nil")
		return errors.New("database connection is not initialized")
	}

	var expiresAt time.Time
	query := "SELECT expires_at FROM tokens WHERE token = $1"
	err := r.DB.QueryRow(query, token).Scan(&expiresAt)
	if err != nil {
		if err == sql.ErrNoRows {
			r.Logger.Warn("Token not found", zap.String("token", token))
			return errors.New("invalid token")
		}

		r.Logger.Error("Database error during token check", zap.Error(err))
		return errors.New("failed to verify token")
	}

	if time.Now().After(expiresAt) {
		r.Logger.Warn("Token has expired", zap.String("token", token))
		return errors.New("token has expired")
	}

	r.Logger.Info("Token is valid", zap.String("token", token))
	return nil
}

// Fungsi untuk membersihkan token yang sudah kadaluarsa
func (r *AllRepository) CleanExpiredTokensRepo() error {
	query := "DELETE FROM tokens WHERE expires_at < $1"
	_, err := r.DB.Exec(query, time.Now())
	if err != nil {
		r.Logger.Error("Error CleanExpiredTokenRepo", zap.Error(err))
		return fmt.Errorf("Failed to clean expired tokens: %v", err)
	}

	return nil
}

// func (r *AllRepository) GetUserByIDRepo(id int) (string, error) {
// 	var name string
// 	query := `SELECT u.name
// 	FROM users u
// 	JOIN orders o ON o.user_id = u.id
// 	WHERE o.customer_id = $1
// 	LIMIT 1
// `
// 	err := r.DB.QueryRow(query, id).Scan(&name)
// 	if err != nil {
// 		r.Logger.Error("Error GetCustomerByID", zap.Error(err))
// 		return "", err
// 	}
// 	return name, nil
// }
