package models

type Todo struct {
	ID          int    `json:"id"`
	Description string `json:"description"`
	Priority    string `json:"priority"`
	Deleted     bool   `json:"deleted"`
	ProjectID   *int   `json:"project_id"`
}
