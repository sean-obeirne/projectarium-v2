package repository

import (
	"database/sql"

	"github.com/sean-obeirne/projectarium-v2/internal/models"
)

type TodoRepository struct {
	db *sql.DB
}

func NewTodoRepository(db *sql.DB) *TodoRepository {
	return &TodoRepository{db: db}
}

func (r *TodoRepository) GetAll() ([]models.Todo, error) {
	rows, err := r.db.Query(`
		SELECT id, description, priority, deleted, project_id
		FROM todo
		WHERE deleted = FALSE
		ORDER BY id
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var todos []models.Todo
	for rows.Next() {
		var t models.Todo
		err := rows.Scan(&t.ID, &t.Description, &t.Priority, &t.Deleted, &t.ProjectID)
		if err != nil {
			return nil, err
		}
		todos = append(todos, t)
	}
	return todos, rows.Err()
}

func (r *TodoRepository) GetByID(id int) (*models.Todo, error) {
	var t models.Todo
	err := r.db.QueryRow(`
		SELECT id, description, priority, deleted, project_id
		FROM todo
		WHERE id = $1
	`, id).Scan(&t.ID, &t.Description, &t.Priority, &t.Deleted, &t.ProjectID)
	if err != nil {
		return nil, err
	}
	return &t, nil
}

func (r *TodoRepository) Create(t *models.Todo) error {
	return r.db.QueryRow(`
		INSERT INTO todo (description, priority, deleted, project_id)
		VALUES ($1, $2, $3, $4)
		RETURNING id
	`, t.Description, t.Priority, t.Deleted, t.ProjectID).Scan(&t.ID)
}

func (r *TodoRepository) Update(t *models.Todo) error {
	_, err := r.db.Exec(`
		UPDATE todo
		SET description = $1, priority = $2, deleted = $3, project_id = $4
		WHERE id = $5
	`, t.Description, t.Priority, t.Deleted, t.ProjectID, t.ID)
	return err
}

func (r *TodoRepository) Delete(id int) error {
	_, err := r.db.Exec("UPDATE todo SET deleted = TRUE WHERE id = $1", id)
	return err
}
