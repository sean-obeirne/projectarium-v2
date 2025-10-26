#!/bin/bash
# Kill all instances of the Projectarium API server

echo "🔪 Killing Projectarium API processes..."

# Find and kill by pattern
pkill -f "cmd/api/main.go"

# Kill anything on port 8080
if lsof -ti:8080 > /dev/null 2>&1; then
    echo "Killing process on port 8080..."
    lsof -ti:8080 | xargs kill
fi

echo "✅ Done!"