package repository

import (
	"database/sql"

	"go.uber.org/zap"
)

type AllRepository struct {
	DB     *sql.DB
	Logger *zap.Logger
}

func NewRepository(db *sql.DB, Log *zap.Logger) AllRepository {
	return AllRepository{
		DB:     db,
		Logger: Log,
	}
}

// func (Repository *Repository) Create(book *model.) error {
// 	// write sql
// 	return nil
// }

// func (Repository *Repository) GetAll() ([]*model., error) {
// 	return nil, nil
// }

// func (Repository *Repository) GetByID(id int) (*model., error) {
// 	return nil, nil
// }

// func (Repository *Repository) Update(id int, book model.) error {
// 	return nil
// }

// func (Repository *Repository) Delete(id int) error {
// 	return nil
// }
