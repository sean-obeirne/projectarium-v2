#!/bin/bash
# Setup script for Projectarium PostgreSQL database

DB_NAME="projectarium"
DB_USER="$USER"  # Use your current user

echo "Setting up PostgreSQL database for Projectarium..."

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "PostgreSQL is not installed. Please install it first:"
    echo "  sudo apt install postgresql postgresql-contrib  # For Debian/Ubuntu"
    echo "  sudo dnf install postgresql-server postgresql-contrib  # For Fedora"
    echo "  sudo pacman -S postgresql  # For Arch Linux"
    exit 1
fi

# Check if PostgreSQL is initialized
# if [ ! -d "/var/lib/postgres/data" ]; then
#     echo "PostgreSQL needs to be initialized..."
#     echo "Run: sudo -u postgres initdb -D /var/lib/postgres/data"
#     echo "Or on some systems: sudo postgresql-setup --initdb"
#     exit 1
# fi

# Start PostgreSQL service if not running
echo "Starting PostgreSQL service..."
sudo systemctl start postgresql 2>/dev/null || sudo systemctl start postgresql@* 2>/dev/null || true

# Wait a moment for service to start
sleep 2

# Create database and user as your current user
echo "Creating database '$DB_NAME' (if it doesn't exist)..."
createdb $DB_NAME 2>/dev/null || echo "Database already exists or creation failed, continuing..."

# Create schema and seed data
echo "Creating schema..."
psql -d $DB_NAME -f schema.sql

echo "Inserting sample data..."
psql -d $DB_NAME -f seed_data.sql

echo ""
echo "✓ Database setup complete!"
echo ""
echo "Database Information:"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Host: localhost"
echo "  Port: 5432"
echo ""
echo "Connection string:"
echo "  postgresql://$DB_USER@localhost:5432/$DB_NAME"
echo ""
echo "To connect manually:"
echo "  psql -d $DB_NAME"
echo "  or"
echo "  psql -U $DB_USER -d $DB_NAME"
echo ""
