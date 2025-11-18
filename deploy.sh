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

    # Install CLI locally
    echo "🔧 Installing projectarium CLI..."
    mkdir -p ~/bin
    cp projectarium ~/bin/projectarium
    chmod +x ~/bin/projectarium
    
    # Add ~/bin to PATH if not already there
    if not string match -q "*$HOME/bin*" $PATH
        echo "⚙️  Adding ~/bin to PATH..."
        
        # Add to fish config
        if test -f ~/.config/fish/config.fish
            if not grep -q "set -gx PATH \$HOME/bin \$PATH" ~/.config/fish/config.fish
                echo 'set -gx PATH $HOME/bin $PATH' >> ~/.config/fish/config.fish
            end
        else
            mkdir -p ~/.config/fish
            echo 'set -gx PATH $HOME/bin $PATH' >> ~/.config/fish/config.fish
        end
        
        # Add to current session
        set -gx PATH $HOME/bin $PATH
        echo "✅ Added ~/bin to PATH"
    else
        echo "✅ ~/bin already in PATH"
    end
    
    echo ""
    echo "✅ Local deployment complete!"
    echo "✅ CLI installed to ~/bin/projectarium"
    echo ""
    echo "The API is now running on http://localhost:8888"
    echo ""
    echo "Commands:"
    echo "  projectarium status   # Check status"
    echo "  projectarium logs     # View logs"
    echo "  projectarium down     # Stop service"
    echo "  projectarium reset    # Wipe database and restart"
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
ssh $REMOTE 'bash -c "
    # Check for Docker
    if ! command -v docker &> /dev/null; then
        echo \"❌ Docker not found. Installing...\"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker \$USER
        rm get-docker.sh
        echo \"✅ Docker installed! You may need to log out and back in for group changes to take effect.\"
    else
        echo \"✅ Docker found\"
    fi
    
    # Check for Docker Compose (bundled with newer Docker versions)
    if ! docker compose version &> /dev/null; then
        echo \"⚠️  Docker Compose plugin not found. Installing...\"
        
        # Try to install compose plugin
        DOCKER_CONFIG=\${DOCKER_CONFIG:-\$HOME/.docker}
        mkdir -p \$DOCKER_CONFIG/cli-plugins
        curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \\
            -o \$DOCKER_CONFIG/cli-plugins/docker-compose
        chmod +x \$DOCKER_CONFIG/cli-plugins/docker-compose
        
        if docker compose version &> /dev/null; then
            echo \"✅ Docker Compose installed\"
        else
            echo \"❌ Failed to install Docker Compose. Please install manually:\"
            echo \"   https://docs.docker.com/compose/install/\"
            exit 1
        fi
    else
        echo \"✅ Docker Compose found\"
    fi
    
    # Ensure ~/bin exists and is in PATH
    mkdir -p ~/bin
    
    # Add to PATH only if not already there
    if [[ \":\$PATH:\" != *\":\$HOME/bin:\"* ]]; then
        # Check if already in bashrc to avoid duplicates
        if ! grep -q 'export PATH=\"\$HOME/bin:\$PATH\"' ~/.bashrc 2>/dev/null; then
            echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc
        fi
        
        # Check if already in fish config to avoid duplicates  
        if ! grep -q 'set -gx PATH \$HOME/bin \$PATH' ~/.config/fish/config.fish 2>/dev/null; then
            mkdir -p ~/.config/fish
            echo 'set -gx PATH \$HOME/bin \$PATH' >> ~/.config/fish/config.fish
        fi
        
        echo \"✅ Added ~/bin to PATH (restart shell to apply)\"
    else
        echo \"✅ ~/bin already in PATH\"
    fi
"'

if test $status -ne 0
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

# Copy projectarium CLI
echo "🔧 Installing projectarium CLI on remote..."
scp projectarium $REMOTE:~/bin/projectarium
ssh $REMOTE "chmod +x ~/bin/projectarium"

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
echo "✅ CLI installed to ~/bin/projectarium"
echo ""
echo "⚠️  You may need to restart your shell or run:"
echo "    source ~/.bashrc  # or"
echo "    exec fish"
echo ""
echo "Remote commands:"
echo "  ssh $REMOTE 'projectarium status'  # Check status"
echo "  ssh $REMOTE 'projectarium logs'    # View logs"
echo "  ssh $REMOTE 'projectarium down'    # Stop service"
echo "  ssh $REMOTE 'projectarium restart' # Restart service"
echo ""
echo "To configure TUI:"
echo "  pj-tui config set "(string replace -r '^.*@' '' $REMOTE)
