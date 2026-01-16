# Dotfiles Management with GNU Stow
# This Makefile handles symlinking dotfiles and managing aliases

.PHONY: all delete setup-aliases clean-aliases setup setup-with-aliases clean

# Main target: complete fresh machine setup
all: setup-aliases
	@echo "Setting up dotfiles with GNU Stow..."
	@echo "Note: .cache, .local, and .run remain as real directories (not symlinked)"
	stow --verbose --target=$$HOME --restow .
	@echo "Fresh machine setup complete!"

# Remove all symlinks (created by stow)
delete:
	@echo "Removing stow-managed symlinks..."
	stow --verbose --target=$$HOME --delete .
	@echo "Symlinks removed. Note: .cache, .local, and .run directories are not removed."

# Setup symlinks and XDG directories for CLI tools
setup-aliases:
	@echo "Setting up symlinks and XDG directories..."
	@echo "Creating symlinks for zsh configuration files..."
	ln -sf $$HOME/.config/zsh/.zshenv $$HOME/.zshenv
	ln -sf $$HOME/.config/zsh/.zshrc $$HOME/.zshrc
	ln -sf $$HOME/.config/zsh/.zprofile $$HOME/.zprofile
	ln -sf $$HOME/.config/zsh/.zlogin $$HOME/.zlogin
	@echo "Creating symlink for cursor configuration..."
	ln -sf $$HOME/.config/cursor $$HOME/.cursor
	@echo "Creating XDG directories (these remain as real directories, not symlinks)..."
	mkdir -p $$HOME/.cache $$HOME/.local $$HOME/.run
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

# Check current symlink status
status:
	@echo "=== Current Symlink Status ==="
	@echo "Checking symlinks in home directory..."
	@for dir in .config .vscode .antigravity .github .hushlogin; do \
		if [ -L "$$HOME/$$dir" ]; then \
			echo "✓ $$dir -> $$(readlink -f $$HOME/$$dir)"; \
		elif [ -e "$$HOME/$$dir" ]; then \
			echo "✗ $$dir exists but is NOT a symlink"; \
		else \
			echo "○ $$dir does not exist"; \
		fi; \
	done
	@echo ""
	@echo "=== XDG Directories (should be real directories, not symlinks) ==="
	@for dir in .cache .local .run; do \
		if [ -d "$$HOME/$$dir" ]; then \
			if [ -L "$$HOME/$$dir" ]; then \
				echo "⚠ $$dir is a symlink (should be a real directory)"; \
			else \
				echo "✓ $$dir is a real directory"; \
			fi; \
		else \
			echo "○ $$dir does not exist"; \
		fi; \
	done
