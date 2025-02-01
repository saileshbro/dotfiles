# 💤 LazyVim

## Prerequisites

- **Lua**: Lua is required to configure NeoVim.
- **NeoVim**: Ensure you have latest NeoVim installed
  Check out here: [NeoVim](https://neovim.io)
- **Git**: Required for cloning the repository.
- **Node.js**: Needed for certain plugins (if applicable).

## Installation

- **Backup your existing configuration**:

```
  mv ~/.config/nvim{,.bak}
  mv ~/.local/share/nvim{,.bak}
  mv ~/.local/state/nvim{,.bak}
  mv ~/.cache/nvim{,.bak}
```

- **Clone this repo**:

  ```
  git clone https://github.com/sumdahl/lazyvim ~/.config/nvim`

  ```

- **Remove the .git folder**

  ```
   rm -rf ~/.config/nvim/.git
  ```

- **Start the NeoVim**

```
  nvim
```
