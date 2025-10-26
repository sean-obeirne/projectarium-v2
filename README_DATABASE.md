# Projectarium PostgreSQL Database Setup

This directory contains the PostgreSQL database setup for Projectarium, designed to be accessed from multiple devices (phone, laptop, etc.) via REST API calls.

## Files

- `schema.sql` - Database schema definition
- `seed_data.sql` - Sample/initial data
- `setup_database.sh` - Automated setup script
- `postgresql.conf.sample` - Sample PostgreSQL configuration for remote access

## Quick Setup

1. **Install PostgreSQL** (if not already installed):
   ```bash
   # Debian/Ubuntu
   sudo apt install postgresql postgresql-contrib
   
   # Fedora
   sudo dnf install postgresql-server postgresql-contrib
   
   # Arch Linux
   sudo pacman -S postgresql
   ```

2. **Run the setup script**:
   ```bash
   chmod +x setup_database.sh
   ./setup_database.sh
   ```

## Database Credentials

- **Database Name**: `projectarium`
- **User**: `projectarium_user`
- **Password**: `projectarium_pass`
- **Host**: `localhost` (or your machine's IP for remote access)
- **Port**: `5432` (default PostgreSQL port)

**Connection String**:
```
postgresql://projectarium_user:projectarium_pass@localhost:5432/projectarium
```

## Schema Overview

### Tables

#### `projects`
- `id` - Auto-incrementing primary key
- `name` - Unique project name
- `description` - Project description (max 29 characters)
- `path` - File system path to project
- `file` - Main file for the project
- `priority` - Priority level (default: 0)
- `status` - Project status (Active, Abandoned, Backlog, Done, etc.)
- `language` - Programming language(s) used

#### `todo`
- `id` - Auto-incrementing primary key
- `description` - Unique todo description
- `priority` - Priority level
- `deleted` - Soft delete flag (default: false)
- `project_id` - Foreign key to projects table

### Indexes
- `idx_projects_status` - For filtering by status
- `idx_projects_priority` - For sorting by priority
- `idx_todo_project_id` - For joining todos with projects
- `idx_todo_deleted` - For filtering out deleted todos

## Enabling Remote Access

To access the database from other devices on your network:

1. **Edit PostgreSQL configuration**:
   ```bash
   sudo nano /etc/postgresql/*/main/postgresql.conf
   ```
   Change:
   ```
   listen_addresses = 'localhost'
   ```
   To:
   ```
   listen_addresses = '*'
   ```

2. **Edit client authentication**:
   ```bash
   sudo nano /etc/postgresql/*/main/pg_hba.conf
   ```
   Add this line:
   ```
   host    projectarium    projectarium_user    0.0.0.0/0    md5
   ```

3. **Restart PostgreSQL**:
   ```bash
   sudo systemctl restart postgresql
   ```

4. **Configure firewall** (if needed):
   ```bash
   sudo ufw allow 5432/tcp
   ```

## Manual Database Operations

### Connect to database:
```bash
psql -U projectarium_user -d projectarium -h localhost
```

### Run schema manually:
```bash
psql -U projectarium_user -d projectarium -h localhost -f schema.sql
```

### Run seed data manually:
```bash
psql -U projectarium_user -d projectarium -h localhost -f seed_data.sql
```

### Backup database:
```bash
pg_dump -U projectarium_user -d projectarium -h localhost > backup.sql
```

### Restore database:
```bash
psql -U projectarium_user -d projectarium -h localhost < backup.sql
```

## Example Queries

### Get all active projects:
```sql
SELECT * FROM projects WHERE status = 'Active' ORDER BY priority DESC, name;
```

### Get all todos for a specific project:
```sql
SELECT t.* FROM todo t
JOIN projects p ON t.project_id = p.id
WHERE p.name = 'projectarium' AND t.deleted = FALSE;
```

### Get project count by status:
```sql
SELECT status, COUNT(*) as count
FROM projects
GROUP BY status
ORDER BY count DESC;
```

## Security Notes

- **Change the default password** in production!
- For remote access, consider using SSL/TLS connections
- Implement proper firewall rules to restrict access to trusted IPs only
- Use environment variables for connection credentials in your applications
- Consider setting up a VPN if accessing from outside your local network

## Next Steps

Once the database is set up, you can:
1. Build a REST API backend (Node.js, Python Flask/FastAPI, Go, etc.)
2. Implement authentication and authorization
3. Create mobile and web frontends that consume the API
4. Set up database backups and monitoring
