# Electronic Document Management System (EDMS)

A 21 CFR Part 11 compliant Electronic Document Management System built with Django and React.

## 🚀 Features

- **21 CFR Part 11 Compliance**: Electronic signatures, audit trails, and data integrity
- **Document Lifecycle Management**: Review, approval, and workflow automation
- **Advanced Search**: Elasticsearch-powered document discovery
- **Role-Based Access Control**: Secure user and permission management
- **Multi-Factor Authentication**: Enhanced security with Azure AD integration
- **Encrypted Storage**: Secure file storage with integrity verification

## 🏗️ Architecture

- **Backend**: Django REST Framework with PostgreSQL
- **Frontend**: React with TypeScript and Tailwind CSS
- **Workflow Engine**: Django-River for document workflows
- **Search**: Elasticsearch for document indexing
- **Cache**: Redis for performance optimization
- **Storage**: Encrypted file system with backup

## 📚 Documentation

- [Development Setup](docs/development-setup.md)
- [API Documentation](docs/api-documentation.md)
- [Database Schema](docs/database-schema.md)
- [Configuration Guide](docs/configuration-guide.md)
- [Testing Guide](docs/testing-guide.md)
- [Deployment Guide](docs/deployment-guide.md)

## 🚦 Quick Start

### Prerequisites

- Python 3.11+
- Node.js 18+
- PostgreSQL 16+
- Redis 7+
- Elasticsearch 8+

### Development Setup

```bash
# Clone the repository
git clone https://github.com/your-org/edms-system.git
cd edms-system

# Run setup script
bash scripts/infrastructure-setup.sh

# Start development environment
bash scripts/start-development.sh --init
```

### Docker Setup

```bash
# Start all services with Docker Compose
podman-compose up -d

# Initialize database
bash scripts/initialize-database.sh

# Create test users
bash scripts/create-test-users.sh
```

## 🏭 Production Deployment

See [Deployment Guide](docs/deployment-guide.md) for:
- Kubernetes deployment manifests
- CI/CD pipeline configuration
- Production hardening checklist
- Monitoring and backup setup

## 🧪 Testing

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm test

# E2E tests
npx playwright test
```

## 📋 Project Status

![CI/CD](https://github.com/your-org/edms-system/workflows/CI/badge.svg)
![Coverage](https://codecov.io/gh/your-org/edms-system/branch/main/graph/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

- ✅ Architecture and design complete
- ✅ Development documentation ready
- 🏗️ Core backend development in progress
- ⏳ Frontend development starting
- ⏳ Testing framework implementation
- ⏳ Deployment pipeline setup

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and development process.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🛡️ Security

For security concerns, please review our [Security Policy](SECURITY.md).

## 📞 Support

- **Documentation**: [Project Wiki](https://github.com/your-org/edms-system/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-org/edms-system/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/edms-system/discussions)

## 🐳 Container Architecture

This project uses **Podman** as the recommended container runtime for 21 CFR Part 11 compliance and production deployment.

### Quick Start with Podman

```bash
# Install Podman (recommended)
# macOS: brew install podman
# Ubuntu: sudo apt-get install -y podman
# RHEL/CentOS: sudo dnf install -y podman

# Install podman-compose
pip install podman-compose

# Start development environment
bash scripts/quickstart.sh
```

### Container Services

- **PostgreSQL 16**: Primary database with audit capabilities
- **Redis 7**: Cache and session store  
- **Elasticsearch 8**: Document search and indexing
- **Django**: Web application (when ready)
- **Celery**: Background task processing

### Development Commands

```bash
# Start core services (DB, Redis, Elasticsearch)
podman-compose up -d

# Start all services including Django and Celery
podman-compose --profile full up -d

# View service status
podman-compose ps

# View logs
podman-compose logs

# Stop all services
podman-compose down
```

### Docker Fallback

Docker can be used as a fallback, but Podman is recommended for production compliance:

```bash
# If using Docker instead of Podman
docker-compose up -d
```
