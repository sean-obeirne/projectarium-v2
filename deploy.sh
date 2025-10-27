#!/usr/bin/env fish

# Projectarium Deployment Script
# Usage: ./deploy.sh <remote-host|local>

if test (count $argv) -lt 1
    echo "Usage: ./deploy.sh <user@remote-host|local>"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh local                # Deploy locally"
    echo "  ./deploy.sh user@192.168.1.100   # Deploy to remote server"
    exit 1
end

set TARGET $argv[1]

# Check if deploying locally
if test "$TARGET" = "local"
    echo "🏠 Deploying locally..."
    echo ""
    
    # Check Docker
    if not command -v docker &> /dev/null
        echo "❌ Docker not found. Please install Docker first:"
        echo "   https://docs.docker.com/get-docker/"
        exit 1
    end
    
    # Check Docker Compose
    if not docker compose version &> /dev/null
        echo "❌ Docker Compose not found. Please install it first:"
        echo "   https://docs.docker.com/compose/install/"
        exit 1
    end
    
    echo "✅ Docker found"
    echo "✅ Docker Compose found"
    echo ""
    
    # Setup .env if doesn't exist
    if not test -f .env
        echo "⚙️  Creating .env file..."
        cp .env.example .env
    end
    
    # Start containers
    echo "🐳 Starting Docker containers..."
    docker compose up -d
    
    echo ""
    echo "✅ Local deployment complete!"
    echo ""
    echo "The API is now running on http://localhost:8888"
    echo ""
    echo "Commands:"
    echo "  pj status   # Check status"
    echo "  pj logs     # View logs"
    echo "  pj down     # Stop service"
    echo "  pj reset    # Wipe database and restart"
    echo ""
    echo "To configure TUI:"
    echo "  pj-tui config local"
    
    exit 0
end

# Remote deployment
set REMOTE $TARGET
set REMOTE_DIR "~/projectarium"

echo "🚀 Deploying Projectarium to $REMOTE..."

# Check dependencies on remote
echo "🔍 Checking dependencies on remote..."
ssh $REMOTE 'bash -s' << 'EOF'
    # Check for Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker not found. Installing..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        echo "✅ Docker installed! You may need to log out and back in for group changes to take effect."
    else
        echo "✅ Docker found"
    fi
    
    # Check for Docker Compose (bundled with newer Docker versions)
    if ! docker compose version &> /dev/null; then
        echo "⚠️  Docker Compose plugin not found. Installing..."
        
        # Try to install compose plugin
        DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
        mkdir -p $DOCKER_CONFIG/cli-plugins
        curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
            -o $DOCKER_CONFIG/cli-plugins/docker-compose
        chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
        
        if docker compose version &> /dev/null; then
            echo "✅ Docker Compose installed"
        else
            echo "❌ Failed to install Docker Compose. Please install manually:"
            echo "   https://docs.docker.com/compose/install/"
            exit 1
        fi
    else
        echo "✅ Docker Compose found"
    fi
    
    # Ensure ~/bin exists and is in PATH
    mkdir -p ~/bin
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        echo 'set -gx PATH $HOME/bin $PATH' >> ~/.config/fish/config.fish 2>/dev/null || true
        echo "✅ Added ~/bin to PATH (restart shell to apply)"
    fi
EOF

if [ $status -ne 0 ]; then
    echo "❌ Dependency check failed. Please install missing dependencies and try again."
    exit 1
end

# Create remote directory
ssh $REMOTE "mkdir -p $REMOTE_DIR"

# Copy necessary files
echo "📦 Copying files..."
scp -r \
    docker-compose.yml \
    Dockerfile \
    .dockerignore \
    .env.example \
    go.mod \
    go.sum \
    cmd/ \
    internal/ \
    pkg/ \
    scripts/ \
    projectarium.service \
    $REMOTE:$REMOTE_DIR/

# Copy pj CLI
echo "🔧 Installing pj CLI on remote..."
scp pj $REMOTE:~/bin/pj
ssh $REMOTE "chmod +x ~/bin/pj"

# Setup .env
echo "⚙️  Setting up environment..."
ssh $REMOTE "cd $REMOTE_DIR && cp .env.example .env"

# Start the service
echo "🐳 Starting Docker containers..."
ssh $REMOTE "cd $REMOTE_DIR && docker compose up -d"

# Setup systemd service for auto-start
echo "⚙️  Setting up auto-start on boot..."
ssh $REMOTE "cd $REMOTE_DIR && mkdir -p ~/.config/systemd/user && cp projectarium.service ~/.config/systemd/user/ && systemctl --user daemon-reload && systemctl --user enable projectarium && loginctl enable-linger \$USER"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "The API is now running on $REMOTE:8888"
echo "✅ Auto-start on boot is enabled"
echo ""
echo "Remote commands:"
echo "  ssh $REMOTE 'pj status'  # Check status"
echo "  ssh $REMOTE 'pj logs'    # View logs"
echo "  ssh $REMOTE 'pj down'    # Stop service"
echo "  ssh $REMOTE 'pj restart' # Restart service"
echo ""
echo "To configure TUI:"
echo "  pj-tui config set "(string replace -r '^.*@' '' $REMOTE)
