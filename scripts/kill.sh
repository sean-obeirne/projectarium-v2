#!/bin/bash
# Kill all instances of the Projectarium API server

echo "🔪 Killing Projectarium API processes..."

# Find and kill by pattern
pkill -f "cmd/api/main.go"

# Kill anything on port 8888
if lsof -ti:8888 > /dev/null 2>&1; then
    echo "Killing process on port 8888..."
    lsof -ti:8888 | xargs kill
fi

echo "✅ Done!"