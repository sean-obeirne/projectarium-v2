package repository

import (
	"database/sql"

	"github.com/sean-obeirne/projectarium-v2/internal/models"
)

type ProjectRepository struct {
	db *sql.DB
}

func NewProjectRepository(db *sql.DB) *ProjectRepository {
	return &ProjectRepository{db: db}
}

func (r *ProjectRepository) GetAll() ([]models.Project, error) {
	rows, err := r.db.Query(`
		SELECT id, name, description, path, file, priority, status, language
		FROM projects
		ORDER BY priority DESC, name
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var projects []models.Project
	for rows.Next() {
		var p models.Project
		err := rows.Scan(&p.ID, &p.Name, &p.Description, &p.Path, &p.File, &p.Priority, &p.Status, &p.Language)
		if err != nil {
			return nil, err
		}
		projects = append(projects, p)
	}
	return projects, rows.Err()
}

func (r *ProjectRepository) GetByID(id int) (*models.Project, error) {
	var p models.Project
	err := r.db.QueryRow(`
		SELECT id, name, description, path, file, priority, status, language
		FROM projects
		WHERE id = $1
	`, id).Scan(&p.ID, &p.Name, &p.Description, &p.Path, &p.File, &p.Priority, &p.Status, &p.Language)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *ProjectRepository) Create(p *models.Project) error {
	return r.db.QueryRow(`
		INSERT INTO projects (name, description, path, file, priority, status, language)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id
	`, p.Name, p.Description, p.Path, p.File, p.Priority, p.Status, p.Language).Scan(&p.ID)
}

func (r *ProjectRepository) Update(p *models.Project) error {
	_, err := r.db.Exec(`
		UPDATE projects
		SET name = $1, description = $2, path = $3, file = $4, priority = $5, status = $6, language = $7
		WHERE id = $8
	`, p.Name, p.Description, p.Path, p.File, p.Priority, p.Status, p.Language, p.ID)
	return err
}

func (r *ProjectRepository) Delete(id int) error {
	_, err := r.db.Exec("DELETE FROM projects WHERE id = $1", id)
	return err
}
