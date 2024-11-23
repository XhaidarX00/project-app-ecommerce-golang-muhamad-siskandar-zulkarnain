package util

import (
	"fmt"

	"github.com/spf13/viper"
)

type Configuration struct {
	AppName   string
	Port      string
	Debug     bool
	DB        DatabaseConfig
	DirUpload string
}

type DatabaseConfig struct {
	Name     string
	Username string
	Password string
	Host     string
}

func ReadConfiguration() (Configuration, error) {
	// Mengatur viper untuk membaca file .env
	viper.SetConfigName(".env") // Nama file (tanpa ekstensi)
	viper.SetConfigType("env")  // Tipe file
	viper.AddConfigPath(".")    // Direktori tempat file berada

	// Membaca file .env
	if err := viper.ReadInConfig(); err != nil {
		return Configuration{}, fmt.Errorf("failed to read configuration file: %w", err)
	}

	// Membaca variabel environment (prioritas lebih tinggi jika ada)
	viper.AutomaticEnv()

	// Mengembalikan konfigurasi yang terbaca
	return Configuration{
		AppName:   viper.GetString("APP_NAME"),
		Port:      viper.GetString("PORT"),
		Debug:     viper.GetBool("DEBUG"),
		DirUpload: viper.GetString("DIR_UPLOAD"),
		DB: DatabaseConfig{
			Name:     viper.GetString("DATABASE_NAME"),
			Username: viper.GetString("DATABASE_USERNAME"),
			Password: viper.GetString("DATABASE_PASSWORD"),
			Host:     viper.GetString("DATABASE_HOST"),
		},
	}, nil
}
