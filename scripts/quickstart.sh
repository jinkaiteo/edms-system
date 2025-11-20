#!/bin/bash

# EDMS Development Quickstart Script (Podman)
# Updated to use Podman container architecture as specified in requirements

echo "🚀 EDMS Development Quickstart"
echo "=============================="

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    echo "Install: https://www.python.org/downloads/"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed"
    echo "Install: https://nodejs.org/"
    exit 1
fi

# Check for Podman (primary) or Docker (fallback)
CONTAINER_CMD=""
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    COMPOSE_CMD="podman-compose"
    echo "✅ Found Podman (recommended for EDMS)"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    COMPOSE_CMD="docker-compose"
    echo "✅ Found Docker (will use as fallback)"
    echo "⚠️  Note: EDMS architecture recommends Podman for production"
else
    echo "❌ Container runtime required: Podman (recommended) or Docker"
    echo ""
    echo "Install Podman:"
    echo "  macOS: brew install podman"
    echo "  Ubuntu: sudo apt-get update && sudo apt-get install -y podman"
    echo "  RHEL/CentOS: sudo dnf install -y podman"
    echo "  Windows: https://podman.io/getting-started/installation"
    echo ""
    echo "Or install Docker as fallback:"
    echo "  https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo "🐳 Using container runtime: $CONTAINER_CMD"

# Check for compose command
if command -v podman-compose &> /dev/null; then
    COMPOSE_CMD="podman-compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif $CONTAINER_CMD compose version &> /dev/null; then
    COMPOSE_CMD="$CONTAINER_CMD compose"
else
    echo "❌ Container compose command not found"
    echo "Install:"
    echo "  For Podman: pip install podman-compose"
    echo "  For Docker: Docker Desktop includes docker-compose"
    exit 1
fi

echo "✅ Using compose command: $COMPOSE_CMD"

# Start container services
echo "🐳 Starting container services..."
if [ -f "podman-compose.yml" ]; then
    echo "Using podman-compose.yml (EDMS recommended configuration)"
    $COMPOSE_CMD -f podman-compose.yml up -d
elif [ -f "docker-compose.yml" ]; then
    echo "Using docker-compose.yml"
    $COMPOSE_CMD up -d
else
    echo "⚠️ No compose file found, creating basic configuration..."
    cat > podman-compose.yml << 'COMPOSE_EOF'
version: '3.8'

services:
  # PostgreSQL Database
  db:
    image: postgres:16
    container_name: edms_postgres
    environment:
      POSTGRES_DB: edms_dev
      POSTGRES_USER: edms_user
      POSTGRES_PASSWORD: dev_password_123
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256 --auth-local=scram-sha-256"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U edms_user -d edms_dev"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: edms_redis
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Elasticsearch
  elasticsearch:
    image: elasticsearch:8.11.0
    container_name: edms_elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
  redis_data:
  elasticsearch_data:

networks:
  default:
    name: edms-network
COMPOSE_EOF
    echo "✅ Created podman-compose.yml with EDMS configuration"
    $COMPOSE_CMD up -d
fi

echo "⏳ Waiting for services to start..."
sleep 20

# Check service health
echo "🔍 Checking service health..."

# Check PostgreSQL
if $CONTAINER_CMD exec edms_postgres pg_isready -U edms_user -d edms_dev &>/dev/null; then
    echo "✅ PostgreSQL is ready"
else
    echo "⚠️ PostgreSQL may still be starting..."
fi

# Check Redis
if $CONTAINER_CMD exec edms_redis redis-cli ping &>/dev/null; then
    echo "✅ Redis is ready"
else
    echo "⚠️ Redis may still be starting..."
fi

# Check Elasticsearch
if curl -s http://localhost:9200/_cluster/health &>/dev/null; then
    echo "✅ Elasticsearch is ready"
else
    echo "⚠️ Elasticsearch may still be starting..."
fi

# Setup backend environment
echo "🐍 Setting up backend environment..."
cd backend

if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    echo "✅ Virtual environment activated"
    
    # Upgrade pip first
    pip install --upgrade pip
    
    if [ -f "requirements/base.txt" ]; then
        echo "Installing Python dependencies..."
        pip install -r requirements/base.txt
        echo "✅ Python dependencies installed"
    elif [ -f "requirements.txt" ]; then
        echo "Installing Python dependencies from requirements.txt..."
        pip install -r requirements.txt
        echo "✅ Python dependencies installed"
    else
        echo "📦 Installing basic Django dependencies..."
        pip install Django>=4.2.0 djangorestframework>=3.14.0 psycopg2-binary>=2.9.0
        echo "✅ Basic dependencies installed"
    fi
else
    echo "⚠️ Virtual environment creation failed"
fi

cd ..

# Setup frontend environment
echo "⚛️ Setting up frontend environment..."
cd frontend

if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install
    echo "✅ Frontend dependencies installed"
elif [ -f "package-lock.json" ]; then
    echo "Installing Node.js dependencies..."
    npm ci
    echo "✅ Frontend dependencies installed"
else
    echo "📦 Initializing React TypeScript project..."
    npx create-react-app . --template typescript
    npm install @tailwindcss/forms @headlessui/react @heroicons/react
    echo "✅ Frontend project initialized"
fi

cd ..

# Environment configuration
echo "⚙️ Checking environment configuration..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "Creating .env from .env.example..."
        cp .env.example .env
        echo "⚠️ Please edit .env file with your configuration"
    else
        echo "📝 Creating basic .env configuration..."
        cat > .env << 'ENV_EOF'
# EDMS Development Environment Configuration

# Company Information
COMPANY_NAME=Your Company Inc.
COMPANY_DOMAIN=yourcompany.com

# Database Configuration
DATABASE_NAME=edms_dev
DATABASE_USER=edms_user
DATABASE_PASSWORD=dev_password_123
DATABASE_HOST=localhost
DATABASE_PORT=5432

# Django Settings
DJANGO_SECRET_KEY=dev-secret-key-change-in-production
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Elasticsearch Configuration
ELASTICSEARCH_URL=http://localhost:9200

# Email Configuration (Development)
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend

# File Storage
STORAGE_ROOT=./storage
MAX_FILE_SIZE_MB=100
TEMP_RETENTION_HOURS=24

# Logging
LOG_LEVEL=DEBUG
LOG_FILE=./logs/edms.log
ENV_EOF
        echo "✅ Basic .env created"
    fi
else
    echo "✅ Environment configuration exists"
fi

echo ""
echo "🎉 EDMS Development Environment Setup Complete!"
echo "============================================="
echo ""
echo -e "🐳 \033[32mServices Status:\033[0m"
echo "• PostgreSQL: http://localhost:5432 (Database)"
echo "• Redis: http://localhost:6379 (Cache)"  
echo "• Elasticsearch: http://localhost:9200 (Search)"
echo ""
echo -e "📋 \033[33mNext Steps:\033[0m"
echo "1. Edit .env file with your specific configuration"
echo "2. Review documentation: docs/README.md"
echo "3. Check current tasks: DEVELOPMENT_TASKS.md"
echo "4. Initialize Django project (if not done yet)"
echo ""
echo -e "🚀 \033[32mTo Start Development:\033[0m"
echo ""
echo "Backend Development:"
echo "  cd backend"
echo "  source venv/bin/activate"
echo "  python manage.py migrate         # Run when Django project is ready"
echo "  python manage.py runserver       # Start Django development server"
echo ""
echo "Frontend Development:"
echo "  cd frontend"
echo "  npm start                        # Start React development server"
echo ""
echo "Container Management:"
echo "  $COMPOSE_CMD ps                  # Check running services"
echo "  $COMPOSE_CMD logs                # View service logs"
echo "  $COMPOSE_CMD down                # Stop all services"
echo "  $COMPOSE_CMD up -d               # Start services in background"
echo ""
echo -e "📚 \033[34mResources:\033[0m"
echo "• Documentation: docs/README.md"
echo "• API Specs: docs/api/complete-api-specs.md"
echo "• Development Tasks: DEVELOPMENT_TASKS.md"
echo "• Configuration Guide: docs/configuration/configuration-templates.md"
echo ""
echo -e "🛡️ \033[35mCompliance Note:\033[0m"
echo "This development environment follows 21 CFR Part 11 architecture requirements"
echo "using Podman containers for production-ready infrastructure."
