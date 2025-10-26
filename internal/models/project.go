package models

type Project struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Path        string `json:"path"`
	File        string `json:"file"`
	Priority    int    `json:"priority"`
	Status      string `json:"status"`
	Language    string `json:"language"`
}
