# Dotfiles

This is a collection of my dotfiles. I use these to configure my system to my liking. I use these on my Mac system, but they should work on any system that uses bash and zsh.

## Installation

Clone the repository to your `$HOME` directory.

```bash
git clone https://github.com/saileshbro/dotfiles.git
```

Install GNU Stow if you don't have it already.

```bash
brew install stow
```

After installing stow, you can use it to symlink the dotfiles to your home directory.

```bash
cd dotfiles
stow .
```

Done! You should now have all the dotfiles symlinked to your home directory.
