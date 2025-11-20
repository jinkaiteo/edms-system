#!/bin/bash

# EDMS Development Quickstart Script

echo "🚀 EDMS Development Quickstart"
echo "=============================="

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required but not installed"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Start Docker services
echo "🐳 Starting Docker services..."
if [ -f "docker-compose.yml" ]; then
    docker-compose up -d
    echo "⏳ Waiting for services to start..."
    sleep 15
    echo "✅ Docker services started"
else
    echo "⚠️ docker-compose.yml not found, skipping Docker setup"
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
    
    if [ -f "requirements/base.txt" ]; then
        echo "Installing Python dependencies..."
        pip install --upgrade pip
        pip install -r requirements/base.txt
        echo "✅ Python dependencies installed"
    else
        echo "⚠️ requirements/base.txt not found"
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
else
    echo "⚠️ package.json not found"
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
        echo "⚠️ No .env.example found"
    fi
else
    echo "✅ Environment configuration exists"
fi

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. Review documentation: docs/README.md"
echo "3. Check development tasks: DEVELOPMENT_TASKS.md"
echo ""
echo "🚀 To start development:"
echo "Backend:  cd backend && source venv/bin/activate && python manage.py runserver"
echo "Frontend: cd frontend && npm start"
echo "Services: docker-compose up -d"
echo ""
echo "📚 Documentation: docs/README.md"
