-- PostgreSQL Schema for Projectarium
-- Create the 'projects' table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT CHECK(LENGTH(description) <= 29),
    path TEXT NOT NULL,
    file TEXT,
    priority INTEGER DEFAULT 0,
    status TEXT NOT NULL,
    language TEXT
);

-- Create the 'todo' table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS todo (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL UNIQUE,
    priority INTEGER DEFAULT 0,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    project_id INTEGER,
    FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
);

-- Create indexes for better query performance (if they don't exist)
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_priority ON projects(priority);
CREATE INDEX IF NOT EXISTS idx_todo_project_id ON todo(project_id);
CREATE INDEX IF NOT EXISTS idx_todo_deleted ON todo(deleted);
