# AI Coding Assistant Rules

This file contains rules and guidelines for AI coding assistants (Cursor, GitHub Copilot, etc.) to follow when helping with code generation, refactoring, and development tasks.

## General Principles

### Code Quality
- Write clean, readable, and maintainable code
- Follow established coding standards and best practices
- Use meaningful variable and function names
- Add appropriate comments for complex logic
- Prefer explicit over implicit code

### Error Handling
- Always include proper error handling
- Use try-catch blocks where appropriate
- Validate inputs and handle edge cases
- Provide meaningful error messages

### Performance
- Consider performance implications of code changes
- Use efficient algorithms and data structures
- Avoid unnecessary computations or memory allocations
- Optimize for readability first, then performance

### Security
- Never hardcode sensitive information (API keys, passwords, tokens)
- Use environment variables for configuration
- Validate and sanitize user inputs
- Follow security best practices for the technology stack

## Language-Specific Guidelines

### JavaScript/TypeScript
- Use TypeScript when possible for better type safety
- Prefer `const` and `let` over `var`
- Use arrow functions for short, simple functions
- Use async/await over promises when possible
- Follow ESLint and Prettier configurations

### Python
- Follow PEP 8 style guidelines
- Use type hints when possible
- Prefer list/dict comprehensions over loops when readable
- Use virtual environments for dependency management
- Follow the principle "Explicit is better than implicit"

### React/Next.js
- Use functional components with hooks
- Prefer composition over inheritance
- Use proper key props for list items
- Implement proper cleanup in useEffect
- Follow React best practices for state management

### Flutter/Dart
- Follow Dart style guide
- Use proper widget composition
- Implement proper state management (Provider, Riverpod, Bloc)
- Use const constructors when possible
- Follow Material Design guidelines

## File Organization

### Structure
- Keep related files together
- Use consistent naming conventions
- Separate concerns (components, utilities, types)
- Follow the project's existing structure

### Imports
- Use absolute imports when possible
- Group imports logically (external, internal, relative)
- Remove unused imports
- Use consistent import ordering

## Documentation

### Code Comments
- Write comments for complex business logic
- Explain "why" not "what" in comments
- Keep comments up to date with code changes
- Use JSDoc/TSDoc for function documentation

### README Files
- Keep README files updated
- Include setup and installation instructions
- Document API changes and breaking changes
- Provide examples for complex features

## Testing

### Test Coverage
- Write tests for new features
- Include unit tests for utility functions
- Add integration tests for critical paths
- Test edge cases and error conditions

### Test Quality
- Write clear, descriptive test names
- Use proper test structure (Arrange, Act, Assert)
- Mock external dependencies appropriately
- Keep tests independent and isolated

## Git and Version Control

### Commit Messages
- Use conventional commit format
- Write clear, descriptive commit messages
- Keep commits focused and atomic
- Reference issues and pull requests

### Branch Management
- Use descriptive branch names
- Keep branches up to date with main
- Clean up merged branches
- Use pull requests for code review

## IDE and Tooling

### Code Formatting
- Use consistent formatting across the project
- Configure auto-formatting on save
- Use linters and formatters (ESLint, Prettier, Black, etc.)
- Follow project-specific formatting rules

### Development Environment
- Use consistent development tools
- Configure proper file watchers
- Use appropriate debugging tools
- Set up proper build processes

## Communication

### Code Reviews
- Provide constructive feedback
- Focus on code quality and maintainability
- Suggest improvements rather than just pointing out problems
- Be respectful and professional

### Documentation
- Document architectural decisions
- Keep documentation current
- Use clear, concise language
- Include diagrams for complex systems

## Best Practices

### Refactoring
- Refactor in small, incremental steps
- Maintain functionality during refactoring
- Test thoroughly after refactoring
- Document significant changes

### Dependencies
- Keep dependencies up to date
- Remove unused dependencies
- Use specific version ranges
- Audit dependencies for security vulnerabilities

### Configuration
- Use configuration files for environment-specific settings
- Provide sensible defaults
- Document configuration options
- Use environment variables for sensitive data

## Project-Specific Rules

### This Dotfiles Project
- Follow XDG Base Directory specification
- Use GNU Stow for symlink management
- Keep configuration files organized by application
- Maintain cross-platform compatibility
- Document setup and installation procedures

---

*This file serves as the single source of truth for AI coding assistant behavior across all development environments and tools.*
