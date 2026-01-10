# bootstrap-env-yugachang

A personal comprehensive bootstrapping script to set up dev environment across different machines (Linux, macOS, WSL) and containers.

## 🚀 Features

This project provides a "One-Click" setup to transform a fresh OS into a fully capable development machine. It handles the installation of core utilities, configuration of shell environments, and setup of essential development tools with sensible defaults.

### ✅ Supported Tools

| Category | Tool | Description |
| :--- | :--- | :--- |
| **Shell** | **Zsh** | Configured with [Oh My Zsh](https://ohmyz.sh/), [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme, Autosuggestions, Syntax Highlighting, FZF, and Z. |
| **Editor** | **Vim** | Enhanced with [Vim-Plug](https://github.com/junegunn/vim-plug), NERDTree (File Explorer), Airline (Status Bar), GitGutter, and more. |
| **Multiplexer** | **Tmux** | Setup with [TPM](https://github.com/tmux-plugins/tpm), mouse support, intuitive keybindings, and auto-session save/restore. |
| **Python** | **uv** | Blazing fast Python package installer and resolver. |
| **Container** | **Docker** | Automated installation (skips if Docker Desktop/WSL is detected). |
| **System** | **Core Utils** | Installs `git`, `curl`, `fzf`, `ripgrep`, `fd`, and `GNU Stow` for dotfiles management. |

## 🛠 Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yugachang/bootstrap-env-yugachang.git ~/bootstrap-env-yugachang
    cd ~/bootstrap-env-yugachang
    ```

2.  **Run the installer**:
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

3.  **Restart your terminal** to apply changes.

## ⚙️ Configuration

You can customize the installation behavior by editing `setup.conf`. Each module generally supports three modes:

-   `SKIP` (0): Do not install or configure this tool.
-   `SAFE` (1): **Recommended**. Only installs if missing. Checks for updates if already present. Links configs without overwriting existing files (unless they are symlinks).
-   `FORCE` (2): Force reinstall software, overwrite existing configuration files, and force reinstall plugins. Use with caution.

Example `setup.conf`:
```bash
CONFIG[system_packages]="SAFE"
CONFIG[zsh]="FORCE"  # Force re-link zsh configs and reinstall OMZ/plugins
CONFIG[vim]="SAFE"
```

## 📂 Directory Structure

```
.
├── install.sh      # Main entry point script
├── setup.conf      # Configuration for installation modes
├── zsh/            # Zsh configurations (.zshrc, .p10k.zsh)
├── vim/            # Vim configurations (.vimrc)
├── tmux/           # Tmux configurations (.tmux.conf)
└── ...
```

## 🔧 How to Add a New Tool

To add support for a new tool (e.g., `git` config or `neovim`), follow these steps:

1.  **Create a Configuration Directory**:
    Create a folder for the tool (e.g., `git/`) and place your config files inside (e.g., `git/.gitconfig`).
    ```bash
    mkdir git
    touch git/.gitconfig
    ```

2.  **Update `setup.conf`**:
    Add a new configuration entry for the tool.
    ```bash
    CONFIG[git]="SAFE"
    ```

3.  **Update `install.sh`**:
    Add a new function to handle the installation and linking logic.

    ```bash
    install_git() {
        local mode=$1
        if [ "$mode" == "SKIP" ]; then return; fi
        echo "🔧 [Git] Setting up Git..."

        # 1. Install software (if needed)
        if ! cmd_exists git; then
            # Logic to install git via apt/brew
            sudo apt-get install -y git
        fi

        # 2. Link configuration
        # This will stow the contents of the 'git' directory to $HOME
        run_stow "git" "$mode"
    }
    ```

4.  **Register the Function**:
    Add your new function to the main execution area at the bottom of `install.sh`.

    ```bash
    # ...
    S_GIT=${CONFIG[git]:-$SAFE}
    # ...
    install_git "$S_GIT"
    ```
