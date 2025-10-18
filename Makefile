# Dotfiles Management with GNU Stow
# This Makefile handles symlinking dotfiles and managing aliases

.PHONY: all delete setup-aliases setup-ai-rules clean-ai-rules clean-aliases setup setup-with-aliases clean

# Main target: complete fresh machine setup
all: setup-aliases setup-ai-rules
	stow --verbose --target=$$HOME --restow .
	@echo "Fresh machine setup complete!"

# Remove all symlinks
delete:
	stow --verbose --target=$$HOME --delete .

# Setup symlinks and XDG directories for CLI tools
setup-aliases:
	@echo "Setting up symlinks and XDG directories..."
	@echo "Creating symlinks for zsh configuration files..."
	ln -sf $$HOME/.config/zsh/.zshenv $$HOME/.zshenv
	ln -sf $$HOME/.config/zsh/.zshrc $$HOME/.zshrc
	ln -sf $$HOME/.config/zsh/.zprofile $$HOME/.zprofile
	ln -sf $$HOME/.config/zsh/.zlogin $$HOME/.zlogin
	@echo "Creating XDG directories..."
	mkdir -p $$HOME/.cache $$HOME/.cursor $$HOME/.local $$HOME/.run
	@echo "Setup complete!"

# Setup AI coding assistant rules
setup-ai-rules:
	@echo "Setting up AI coding assistant rules..."
	@echo "Creating symlinks for AI rules..."
	ln -sf ../../RULES.md .cursor/rules/rule.mdc
	ln -sf ../RULES.md .github/copilot-instructions.md
	@echo "AI rules setup complete!"

# Clean up AI rules symlinks
clean-ai-rules:
	@echo "Cleaning up AI rules symlinks..."
	rm -f .cursor/rules/rule.mdc
	rm -f .github/copilot-instructions.md
	@echo "AI rules cleanup complete!"

# Clean up symlinks and XDG directories
clean-aliases:
	@echo "Cleaning up symlinks and XDG directories..."
	@echo "Cleanup complete!"

# Full setup: symlink dotfiles only (no aliases by default)
setup: all
	@echo "Full setup complete!"

# Full setup with aliases: symlink dotfiles and create aliases
setup-with-aliases: all setup-aliases
	@echo "Full setup with aliases complete!"

# Full cleanup: remove symlinks and aliases
clean: delete clean-aliases clean-ai-rules
	@echo "Full cleanup complete!"
