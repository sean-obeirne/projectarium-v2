# Projectarium v2

A portable project kanban board display, hosted on a dedicated device and accessible from anywhere!

Multi-device project and todo tracker with PostgreSQL backend and Go REST API.

## Quick Start

### First Time Setup

1. **Install Development Tools**
   ```bash
   make install-tools    # Installs golangci-lint, air
   make install-hooks    # Sets up git pre-commit hooks
   ```

2. **Setup Database**
   ```bash
   make db-setup
   ```

3. **Run the API**
   ```bash
   make dev              # Run with hot reload (recommended)
   # OR
   make run              # Run without hot reload
   ```

The API will be available at `http://localhost:8080`

### Development Workflow

```bash
make dev              # Start development server with hot reload
make check            # Run all checks (fmt, vet, lint, test)
make build            # Build production binary
make clean            # Clean build artifacts
```

### Available Make Commands

```bash
make help             # Show all available commands
make build            # Build the application
make run              # Run the application
make dev              # Run with air (hot reload)
make test             # Run tests
make fmt              # Format code
make vet              # Run go vet
make lint             # Run golangci-lint
make check            # Run all checks (runs automatically on commit)
make clean            # Clean build artifacts
make install-hooks    # Install git pre-commit hooks
make install-tools    # Install development tools
make db-setup         # Setup database
```

### Pre-Commit Hooks

The git pre-commit hook automatically runs on every commit:
- `go mod tidy` - Clean up dependencies
- `go fmt` - Format code
- `go vet` - Check for common errors
- `go test` - Run tests
- `golangci-lint` - Run comprehensive linter

If any check fails, the commit is blocked until you fix the issues.

## API Endpoints

### Projects
- `GET /api/projects` - Get all projects
- `GET /api/projects/{id}` - Get project by ID
- `POST /api/projects` - Create new project
- `PUT /api/projects/{id}` - Update project
- `DELETE /api/projects/{id}` - Delete project

### Todos
- `GET /api/todos` - Get all todos
- `GET /api/todos/{id}` - Get todo by ID
- `POST /api/todos` - Create new todo
- `PUT /api/todos/{id}` - Update todo
- `DELETE /api/todos/{id}` - Soft-delete todo

### Health Check
- `GET /health` - Server health check

## Configuration

Copy `.env.example` to `.env` and adjust values as needed. The application will use sensible defaults if no `.env` file is present.

## Project Structure

See `notes.txt` for detailed project structure documentation.

## Database

See `README_DATABASE.md` for database setup and management details.
