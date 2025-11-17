-- Migration: Remove UNIQUE constraint from todo.description
-- This allows multiple todos to have the same description text

-- Drop the unique constraint on the description column
ALTER TABLE todo DROP CONSTRAINT IF EXISTS todo_description_key;
