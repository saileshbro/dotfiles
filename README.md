# Dotfiles

A comprehensive collection of my dotfiles and system configuration files, organized using GNU Stow and following XDG Base Directory specification standards. This setup provides a clean, maintainable way to manage configuration files across multiple machines.

## 🚀 Features

- **XDG Compliant**: All configuration files follow XDG Base Directory specification
- **GNU Stow Management**: Easy symlink management with `make` commands
- **Cross-Platform**: Works on macOS, Linux, and other Unix-like systems
- **Git Tracked**: All configuration files are version controlled
- **Modular Structure**: Organized by application and purpose
- **CLI Tool Compatible**: Aliases for tools that need specific file locations

## 📁 Directory Structure

```
dotfiles/
├── .config/                    # XDG configuration directory
│   ├── zsh/                   # Zsh configuration
│   │   ├── .zshenv           # Zsh environment variables
│   │   ├── .zshrc            # Zsh configuration
│   │   ├── .zprofile         # Zsh profile
│   │   ├── .alias            # Custom aliases
│   │   └── ...               # Other zsh files
│   ├── nvim/                 # Neovim configuration
│   ├── git/                  # Git configuration
│   ├── tmux/                 # Tmux configuration
│   └── ...                   # Other application configs
├── .cache/                   # XDG cache directory
│   └── .gitkeep
├── .cursor/                  # Cursor IDE directory
│   └── .gitkeep
├── .local/                   # XDG local data directory
│   └── .gitkeep
├── .run/                     # XDG runtime directory
│   └── .gitkeep
├── .hushlogin               # Prevent login message
├── .vscode/                 # VS Code configuration
├── Makefile                 # Management commands
└── README.md               # This file
```

## 🛠️ Installation

### Prerequisites

- **Git**: For cloning the repository
- **GNU Stow**: For symlink management
- **Zsh**: Shell configuration (optional but recommended)

### Quick Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/saileshbro/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install GNU Stow** (if not already installed):
   ```bash
   # macOS
   brew install stow

   # Ubuntu/Debian
   sudo apt install stow

   # Arch Linux
   sudo pacman -S stow
   ```

3. **Run the setup**:
   ```bash
   make setup
   ```

### Advanced Setup

For CLI tools that need specific file locations in your home directory:

```bash
# Setup with aliases for CLI tools
make setup-with-aliases
```

## 📋 Available Commands

The Makefile provides several commands for managing your dotfiles:

### Basic Commands

- **`make setup`** - Symlink all dotfiles (XDG compliant)
- **`make setup-with-aliases`** - Symlink dotfiles + create CLI tool aliases
- **`make delete`** - Remove all symlinks
- **`make clean`** - Full cleanup (remove symlinks and aliases)

### Alias Management

- **`make setup-aliases`** - Create symlinks for CLI tools that need specific locations
- **`make clean-aliases`** - Remove all CLI tool aliases

### Individual Commands

- **`make all`** - Just symlink dotfiles (same as `make setup`)
- **`make help`** - Show available commands (if implemented)

## 🔧 Configuration Details

### XDG Base Directory Compliance

This dotfiles setup follows the XDG Base Directory specification:

- **`$XDG_CONFIG_HOME`** → `~/.config/` (configuration files)
- **`$XDG_CACHE_HOME`** → `~/.cache/` (cache files)
- **`$XDG_DATA_HOME`** → `~/.local/share/` (data files)
- **`$XDG_STATE_HOME`** → `~/.local/state/` (state files)
- **`$XDG_RUNTIME_DIR`** → `~/.run/` (runtime files)

### Zsh Configuration

The zsh configuration includes:

- **Environment Variables**: XDG paths, development tools, Android SDK
- **History Management**: Proper XDG-compliant history location
- **Path Management**: Development tools, package managers, custom binaries
- **Aliases**: Custom commands and shortcuts
- **Plugins**: Oh My Zsh, syntax highlighting, autosuggestions
- **Starship**: Modern shell prompt

### Supported Applications

- **Shell**: Zsh with Oh My Zsh
- **Editor**: Neovim, VS Code, Cursor
- **Version Control**: Git
- **Terminal**: Tmux
- **Development**: Android SDK, Flutter, Node.js, Python, Ruby
- **Package Managers**: Homebrew, npm, yarn, pnpm, cargo

## 🔄 Maintenance

### Updating Dotfiles

1. **Make changes** to configuration files in the dotfiles directory
2. **Test changes** by running `make setup` to update symlinks
3. **Commit changes** to git:
   ```bash
   git add .
   git commit -m "Update configuration"
   git push
   ```

### Adding New Applications

1. **Create configuration** in the appropriate XDG directory
2. **Add to .gitignore** if needed (for sensitive files)
3. **Update this README** with new application details
4. **Test** with `make setup`

### Troubleshooting

- **Broken symlinks**: Run `make clean` then `make setup`
- **Missing aliases**: Run `make setup-aliases`
- **XDG issues**: Check that environment variables are properly set
- **Permission issues**: Ensure proper file permissions

## 🚨 Important Notes

### Security

- **Never commit sensitive data** like API keys, passwords, or tokens
- **Use .gitignore** for files containing personal information
- **Review changes** before committing

### Backup

- **Always backup** your existing configuration before setup
- **Test on a separate machine** before applying to your main system
- **Keep your original files** in a separate backup location

### Compatibility

- **macOS**: Fully tested and supported
- **Linux**: Should work with most distributions
- **Windows**: Not directly supported (use WSL2 for best experience)

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **GNU Stow** for symlink management
- **XDG Base Directory** specification for organization standards
- **Oh My Zsh** for zsh framework
- **Starship** for shell prompt
- **Community** for inspiration and feedback

---

**Happy configuring!** 🎉

For questions or issues, please open an issue on GitHub or contact me directly.