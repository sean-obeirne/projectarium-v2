.PHONY: help build run test clean fmt vet lint install-hooks install-tools db-setup docker-up docker-down docker-logs docker-reset service-install service-start service-stop service-status

# Default target
help:
	@echo "Available targets:"
	@echo "  make build          - Build the application"
	@echo "  make run            - Run the application"
	@echo "  make dev            - Run with air (hot reload)"
	@echo "  make test           - Run tests"
	@echo "  make fmt            - Format code"
	@echo "  make vet            - Run go vet"
	@echo "  make lint           - Run golangci-lint"
	@echo "  make check          - Run all checks (fmt, vet, lint, test)"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make install-hooks  - Install git pre-commit hooks"
	@echo "  make install-tools  - Install development tools"
	@echo "  make db-setup       - Setup database"
	@echo ""
	@echo "Docker commands:"
	@echo "  make docker-up      - Start API and database in Docker"
	@echo "  make docker-down    - Stop Docker containers"
	@echo "  make docker-logs    - View Docker logs"
	@echo "  make docker-reset   - Wipe database and restart"
	@echo ""
	@echo "Systemd service commands:"
	@echo "  make service-install - Install systemd service"
	@echo "  make service-start   - Start the service"
	@echo "  make service-stop    - Stop the service"
	@echo "  make service-status  - Check service status"

# Build the application
build:
	@echo "🏗️  Building..."
	go build -o bin/projectarium ./cmd/api

# Run the application
run:
	@echo "🚀 Running..."
	go run ./cmd/api

# Run with air (hot reload)
dev:
	@echo "🔥 Starting with hot reload..."
	air

# Run tests
test:
	@echo "🧪 Running tests..."
	go test ./... -v

# Format code
fmt:
	@echo "📝 Formatting code..."
	go fmt ./...

# Run go vet
vet:
	@echo "🔍 Running go vet..."
	go vet ./...

# Run golangci-lint
lint:
	@echo "🔒 Running golangci-lint..."
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run; \
	else \
		echo "⚠️  golangci-lint not installed. Run: make install-tools"; \
	fi

# Run all checks
check:
	@echo "🔧 Running go mod tidy..."
	@go mod tidy
	@echo "📝 Formatting code..."
	@go fmt ./...
	@echo "🔍 Running go vet..."
	@go vet ./...
	@echo "🧪 Running tests..."
	@go test ./... -short
	@if command -v golangci-lint > /dev/null; then \
		echo "🔒 Running golangci-lint..."; \
		golangci-lint run; \
	else \
		echo "⚠️  golangci-lint not installed, skipping..."; \
	fi
	@echo "✅ All checks passed!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	rm -rf bin/
	rm -rf tmp/
	rm -f build-errors.log

# Install git hooks
install-hooks:
	@echo "🪝 Installing git hooks..."
	@mkdir -p scripts/hooks
	@echo '#!/bin/sh' > scripts/hooks/pre-commit
	@echo 'make check' >> scripts/hooks/pre-commit
	@chmod +x scripts/hooks/pre-commit
	@ln -sf ../../scripts/hooks/pre-commit .git/hooks/pre-commit
	@echo "✅ Git hooks installed!"

# Install development tools
install-tools:
	@echo "📦 Installing development tools..."
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/air-verse/air@latest
	@echo "✅ Tools installed!"

# Setup database
db-setup:
	@echo "🗄️  Setting up database..."
	cd scripts && ./setup_database.sh

# Docker commands
docker-up:
	@echo "🐳 Starting Docker containers..."
	docker compose up -d
	@echo "✅ API running on http://localhost:8888"

docker-down:
	@echo "🛑 Stopping Docker containers..."
	docker compose down

docker-logs:
	@echo "📋 Showing Docker logs..."
	docker compose logs -f api

docker-reset:
	@echo "⚠️  Wiping database and restarting..."
	docker compose down -v
	docker compose up -d
	@echo "✅ Reset complete!"

# Systemd service commands
service-install:
	@echo "🔧 Installing systemd service..."
	@mkdir -p ~/.config/systemd/user
	@cp projectarium.service ~/.config/systemd/user/
	@systemctl --user daemon-reload
	@systemctl --user enable projectarium
	@echo "✅ Service installed! Use 'make service-start' to start it."
	@echo "💡 Run 'loginctl enable-linger $$USER' to start on boot."

service-start:
	@echo "▶️  Starting service..."
	@systemctl --user start projectarium
	@echo "✅ Service started!"

service-stop:
	@echo "⏸️  Stopping service..."
	@systemctl --user stop projectarium
	@echo "✅ Service stopped!"

service-status:
	@systemctl --user status projectarium
