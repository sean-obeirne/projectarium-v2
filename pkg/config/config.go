package config

import (
	"fmt"
	"os"
)

type Config struct {
	DatabaseURL string
	Port        string
}

func Load() *Config {
	dbUser := getEnv("DB_USER", os.Getenv("USER"))
	dbPassword := getEnv("DB_PASSWORD", "")
	dbName := getEnv("DB_NAME", "projectarium")
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")

	var dbURL string
	if dbPassword != "" {
		dbURL = fmt.Sprintf("postgresql://%s:%s@%s:%s/%s?sslmode=disable", dbUser, dbPassword, dbHost, dbPort, dbName)
	} else {
		dbURL = fmt.Sprintf("postgresql://%s@%s:%s/%s?sslmode=disable", dbUser, dbHost, dbPort, dbName)
	}

	return &Config{
		DatabaseURL: dbURL,
		Port:        getEnv("PORT", "8888"),
	}
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
