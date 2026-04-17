# Dotfiles Management with GNU Stow
# This Makefile handles symlinking dotfiles and managing aliases

.PHONY: all delete setup-aliases clean-aliases setup setup-with-aliases clean

# Main target: complete fresh machine setup
all: setup-aliases
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
	@echo "Creating symlink for git configuration..."
	ln -sf $$HOME/.config/git/config $$HOME/.gitconfig
	@echo "Creating symlinks for VS Code configuration..."
	mkdir -p $$HOME/Library/Application\ Support/Code/User
	ln -sf $$HOME/.config/vscode/settings.json $$HOME/Library/Application\ Support/Code/User/settings.json
	ln -sf $$HOME/.config/vscode/mcp.json $$HOME/Library/Application\ Support/Code/User/mcp.json
	ln -sf $$HOME/dotfiles/.config/claude $$HOME/.claude
	ln -sf $$HOME/dotfiles/.config/copilot $$HOME/.copilot
	@echo "Creating symlink for SSH configuration..."
	chmod 700 $$HOME/.config/ssh
	ln -sfn $$HOME/.config/ssh $$HOME/.ssh
	@echo "Creating XDG directories..."
	mkdir -p $$HOME/.cache $$HOME/.cursor $$HOME/.local $$HOME/.run
	@echo "Setup complete!"


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
clean: delete clean-aliases
	@echo "Full cleanup complete!"
