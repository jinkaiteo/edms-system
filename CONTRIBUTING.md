# Contributing to EDMS

Thank you for your interest in contributing to the Electronic Document Management System!

## Development Process

1. **Fork** the repository
2. **Create** a feature branch from `develop`
3. **Make** your changes with proper tests
4. **Submit** a pull request

## Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature development branches
- `hotfix/*` - Critical production fixes
- `release/*` - Release preparation branches

## Code Standards

### Backend (Python/Django)

- Follow PEP 8 style guidelines
- Use type hints for all functions
- Maintain test coverage above 85%
- Document all public APIs

### Frontend (React/TypeScript)

- Use TypeScript for all components
- Follow React hooks best practices
- Implement proper error boundaries
- Use Tailwind CSS for styling

## Commit Message Format

```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

## Pull Request Process

1. **Update** documentation for any new features
2. **Add** tests for new functionality
3. **Ensure** all tests pass
4. **Request** review from maintainers

## Security Guidelines

- Never commit secrets or credentials
- Follow OWASP security guidelines
- Report security vulnerabilities privately
