package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/sean-obeirne/projectarium-v2/internal/database"
	"github.com/sean-obeirne/projectarium-v2/internal/handlers"
	"github.com/sean-obeirne/projectarium-v2/internal/middleware"
	"github.com/sean-obeirne/projectarium-v2/pkg/config"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize database connection
	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Initialize handlers
	h := handlers.New(db)

	// Setup routes
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "OK")
	})

	// Project routes
	mux.HandleFunc("GET /api/projects", h.GetProjects)
	mux.HandleFunc("GET /api/projects/{id}", h.GetProject)
	mux.HandleFunc("POST /api/projects", h.CreateProject)
	mux.HandleFunc("PUT /api/projects/{id}", h.UpdateProject)
	mux.HandleFunc("DELETE /api/projects/{id}", h.DeleteProject)
	mux.HandleFunc("PATCH /api/projects/{id}/status", h.UpdateProjectStatus)
	mux.HandleFunc("PATCH /api/projects/{id}/priority", h.UpdateProjectPriority)

	// Todo routes
	mux.HandleFunc("GET /api/todos", h.GetTodos)
	mux.HandleFunc("GET /api/todos/{id}", h.GetTodo)
	mux.HandleFunc("POST /api/todos", h.CreateTodo)
	mux.HandleFunc("PUT /api/todos/{id}", h.UpdateTodo)
	mux.HandleFunc("DELETE /api/todos/{id}", h.DeleteTodo)

	// Apply middleware
	handler := middleware.Logger(middleware.CORS(mux))

	// Start server
	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Server starting on %s", addr)
	if err := http.ListenAndServe(addr, handler); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
