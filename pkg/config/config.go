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
	dbName := getEnv("DB_NAME", "projectarium")
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")

	return &Config{
		DatabaseURL: fmt.Sprintf("postgresql://%s@%s:%s/%s?sslmode=disable", dbUser, dbHost, dbPort, dbName),
		Port:        getEnv("PORT", "8080"),
	}
}

func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
