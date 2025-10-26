# Projectarium v2

A portable project kanban board display, hosted on a dedicated device and accessible from anywhere!

Multi-device project and todo tracker with PostgreSQL backend and Go REST API.

## Quick Start

1. **Setup Database**
   ```bash
   cd scripts
   ./setup_database.sh
   ```

2. **Install Dependencies**
   ```bash
   go mod tidy
   ```

3. **Run the API**
   ```bash
   go run cmd/api/main.go
   ```

The API will be available at `http://localhost:8080`

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
