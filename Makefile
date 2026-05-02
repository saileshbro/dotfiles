# Dotfiles Management with GNU Stow
# This Makefile handles symlinking dotfiles and managing aliases

.PHONY: all delete setup-aliases clean-aliases setup setup-with-aliases clean install-fonts sync-themes setup-terminal install-vscode-theme

THEME_DIR := themes/tinacious-theme

# Main target: complete fresh machine setup
# install-vscode-theme is intentionally NOT part of `all` — run it manually
# after VS Code / Cursor / Antigravity are installed on the machine.
all: setup-aliases install-fonts sync-themes setup-terminal
	stow --verbose --target=$$HOME --restow .
	@echo "Fresh machine setup complete!"

# Build themes from the submodule and sync into dotfiles
sync-themes:
	@echo "Initialising theme submodule..."
	@git submodule update --init themes/tinacious-theme
	@echo "Building tinacious themes..."
	@cd $(THEME_DIR) && npm install --silent && npm run build
	@echo "Syncing Ghostty themes..."
	@mkdir -p .config/ghostty/themes
	@cp $(THEME_DIR)/dist/ghostty/tinacious-design-dark $(THEME_DIR)/dist/ghostty/tinacious-design-light .config/ghostty/themes/
	@cp $(THEME_DIR)/dist/ghostty/app-config .config/ghostty/app-config
	@echo "Syncing Warp themes..."
	@mkdir -p .config/warp/themes
	@cp $(THEME_DIR)/dist/warp/* .config/warp/themes/
	@echo "Syncing Terminal.app script..."
	@mkdir -p .config/terminal
	@cp $(THEME_DIR)/dist/terminal/setup-profile.applescript .config/terminal/setup-profile.applescript
	@echo "Themes synced."

# Symlink theme submodule as a local extension into VS Code, Cursor, and Antigravity.
# Also purges any conflicting marketplace installs from both the filesystem and
# each editor's extensions.json registry (stale entries break Cursor on restart).
install-vscode-theme:
	@echo "Installing Tinacious Design theme from submodule..."
	@mkdir -p $$HOME/.vscode/extensions $$HOME/.cursor/extensions $$HOME/.antigravity/extensions
	@code    --uninstall-extension tinaciousdesign.theme-tinaciousdesign 2>/dev/null; true
	@cursor  --uninstall-extension tinaciousdesign.theme-tinaciousdesign 2>/dev/null; true
	@cursor  --uninstall-extension hoyame.yungythem-theme-tinaciousdesign2 2>/dev/null; true
	@antigravity --uninstall-extension tinaciousdesign.theme-tinaciousdesign 2>/dev/null; true
	@ln -sfn $$HOME/dotfiles/$(THEME_DIR) $$HOME/.vscode/extensions/tinaciousdesign.theme-tinaciousdesign-local
	@ln -sfn $$HOME/dotfiles/$(THEME_DIR) $$HOME/.cursor/extensions/tinaciousdesign.theme-tinaciousdesign-local
	@ln -sfn $$HOME/dotfiles/$(THEME_DIR) $$HOME/.antigravity/extensions/tinaciousdesign.theme-tinaciousdesign-local
	@echo "Theme linked from submodule in VS Code, Cursor, and Antigravity."

# Create Terminal.app "Tinacious Design Dark" profile and set as default
setup-terminal:
	@echo "Setting up Terminal.app profile..."
	@osascript .config/terminal/setup-profile.applescript
	@defaults write com.apple.Terminal "Default Window Settings" -string "Tinacious Design Dark"
	@defaults write com.apple.Terminal "Startup Window Settings" -string "Tinacious Design Dark"
	@echo "Terminal profile set. Restart Terminal.app to apply."

# Install fonts to ~/Library/Fonts
install-fonts:
	@echo "Installing fonts..."
	@cp -f fonts/*.otf $$HOME/Library/Fonts/
	@echo "Fonts installed."

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
	@echo "Creating symlink for Warp configuration..."
	ln -sfn $$HOME/.config/warp $$HOME/.warp
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
