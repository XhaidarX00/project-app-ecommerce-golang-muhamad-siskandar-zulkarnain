package database

import (
	"database/sql"
	"fmt"
	"log"
	"project/util"
	"time"

	_ "github.com/lib/pq" // Driver PostgreSQL
)

func InitDB(config util.Configuration) (*sql.DB, error) {
	connStr := fmt.Sprintf(
		"user=%s dbname=%s sslmode=disable password=%s host=%s",
		config.DB.Username, config.DB.Name, config.DB.Password, config.DB.Host,
	)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("failed to open database connection: %w", err)
	}

	// Ping database untuk memverifikasi koneksi
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)
	db.SetConnMaxLifetime(30 * time.Minute)
	db.SetConnMaxIdleTime(5 * time.Minute)

	log.Println("Database connection successfully established")
	return db, nil
}
