#!/bin/bash
set -e # Stop on error

# --- Variables and Settings ---
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DOTFILES_DIR/setup.conf"

SKIP="SKIP"
SAFE="SAFE"
FORCE="FORCE"

# --- Helper Functions ---
cmd_exists() { command -v "$1" &> /dev/null; }

# --- Replace original run_stow ---
run_stow() {
    local app=$1
    local mode=$2
    local target_dir="$HOME"
    local source_dir="$DOTFILES_DIR/$app"

    echo "   🔗 [Config] Linking $app config to $target_dir..."

    # 1. FORCE mode: Try to remove old links first
    if [ "$mode" == "FORCE" ]; then
        stow -D --target="$target_dir" "$app" 2>/dev/null || true
    fi

    # 2. Manually resolve conflicts (do not rely on stow --list)
    # Directly check source directory for files (.zshrc, .p10k.zsh, etc.)
    if [ -d "$source_dir" ]; then
        # Find all files in directory (including hidden ones)
        for filename in $(ls -A "$source_dir"); do
            local target_file="$target_dir/$filename"
            
            # Check: if target exists and is not a symlink (physical file conflict)
            if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
                echo "      🚨 Conflict detected: $target_file"
                echo "      📦 Backing up to $target_file.bak"
                mv "$target_file" "$target_file.bak"
            fi
        done
    else
        echo "      ⚠️  Source directory $source_dir not found!"
        return
    fi

    # 3. Execute Stow (verbose for debugging)
    stow -v --restow --target="$target_dir" "$app"
}

# --- 1. System and Basics ---
install_system_packages() {
    local mode=$1
    echo "📦 [System] Checking base packages..."
    if [ "$mode" == "SAFE" ] && cmd_exists git && cmd_exists stow; then
        echo "   ✅ Already installed."
        return
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! cmd_exists brew; then
             /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install stow vim tmux git curl zsh fzf ripgrep fd
    elif [ -f /etc/lsb-release ]; then
        sudo apt-get update
        sudo apt-get install -y zsh vim tmux git curl stow build-essential fzf ripgrep fd-find
    fi
}

# --- 2. Zsh Suite (Shell + OMZ + P10k + Plugins + Config) ---
install_zsh() {
    local mode=$1
    if [ "$mode" == "SKIP" ]; then return; fi
    echo "🚀 [Zsh] Setting up Zsh environment ($mode)..."

    # A. Install Zsh
    if ! cmd_exists zsh; then
        # Assume system_packages ran, or try installing again
        echo "   ⬇️  Installing Zsh binary..."
        # (Skip repeated apt/brew install logic, rely on install_system_packages)
    fi

    # B. Install Oh-My-Zsh
    local omz_dir="$HOME/.oh-my-zsh"
    if [ -d "$omz_dir" ] && [ "$mode" == "FORCE" ]; then rm -rf "$omz_dir"; fi
    if [ ! -d "$omz_dir" ]; then
        echo "   ⚡ Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # C. Install Plugins (P10k, Autosuggestions, Syntax-Highlighting)
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Helper: Clone Plugin
    clone_plugin() {
        local repo=$1
        local dest=$2
        if [ -d "$dest" ]; then
            if [ "$mode" == "FORCE" ]; then rm -rf "$dest"; git clone --depth=1 "$repo" "$dest";
            else git -C "$dest" pull --rebase --quiet; fi # Auto update in SAFE mode
        else
            git clone --depth=1 "$repo" "$dest"
        fi
    }

    echo "   🎨 Installing Themes & Plugins..."
    clone_plugin "https://github.com/romkatv/powerlevel10k.git" "$zsh_custom/themes/powerlevel10k"
    clone_plugin "https://github.com/zsh-users/zsh-autosuggestions" "$zsh_custom/plugins/zsh-autosuggestions"
    clone_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$zsh_custom/plugins/zsh-syntax-highlighting"
    
    # D. Config files (Stow)
    cd "$DOTFILES_DIR"
    run_stow "zsh" "$mode"
}

# --- 3. Vim Suite (Editor + Plug + Config + Auto Install) ---
install_vim() {
    local mode=$1
    if [ "$mode" == "SKIP" ]; then return; fi
    echo "📝 [Vim] Setting up Vim environment ($mode)..."

    # A. Install Vim (Usually installed by system_packages, double check here)
    if ! cmd_exists vim; then echo "   ⚠️  Vim binary missing! Please install system_packages."; return; fi

    # B. Download Vim-Plug (Plugin Manager)
    local plug_file="$HOME/.vim/autoload/plug.vim"
    if [ ! -f "$plug_file" ] || [ "$mode" == "FORCE" ]; then
        echo "   🔌 Installing Vim-Plug..."
        curl -fLo "$plug_file" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    # C. Config files (Stow) - Must have .vimrc before installing Plugins
    cd "$DOTFILES_DIR"
    run_stow "vim" "$mode"

    # D. Auto install all Plugins (Headless Mode)
    echo "   📦 Installing/Updating Vim Plugins (Headless)..."
    # Key command: Open vim -> Run PlugInstall -> Run qa (Quit All)
    vim -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall" -c "qa"
    echo "   ✅ Vim Plugins installed."
}

# --- 4. Tmux Suite (Mux + TPM + Config + Auto Install) ---
install_tmux() {
    local mode=$1
    if [ "$mode" == "SKIP" ]; then return; fi
    echo "📺 [Tmux] Setting up Tmux environment ($mode)..."

    # A. Install Tmux
    if ! cmd_exists tmux; then echo "   ⚠️  Tmux binary missing!"; return; fi

    # B. Download TPM (Tmux Plugin Manager)
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [ -d "$tpm_dir" ] && [ "$mode" == "FORCE" ]; then rm -rf "$tpm_dir"; fi
    if [ ! -d "$tpm_dir" ]; then
        echo "   🔌 Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    # C. Config files (Stow)
    cd "$DOTFILES_DIR"
    run_stow "tmux" "$mode"

    # D. Auto install all Plugins (Headless Mode)
    echo "   📦 Installing Tmux Plugins (Headless)..."
    # TPM provides a script to install directly without opening tmux
    if [ -f "$tpm_dir/bin/install_plugins" ]; then
        "$tpm_dir/bin/install_plugins" >/dev/null 2>&1
    fi
    echo "   ✅ Tmux Plugins installed."
}

# --- 5. Other tools (Docker / uv) ---
install_docker() {
    local mode=$1
    if [ "$mode" == "SKIP" ]; then return; fi
    echo "🐳 [Docker] Checking Docker..."

    # WSL Check
    if grep -qEi "(Microsoft|WSL)" /proc/version && cmd_exists docker; then
        echo "   🪟 WSL + Docker Desktop detected. Skipping Linux installation."
        return
    fi

    if [ "$mode" == "SAFE" ] && cmd_exists docker; then
        echo "   ✅ Already installed."
        return
    fi

    # ... (Original install logic) ...
    if [ -f /etc/lsb-release ]; then
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER || true
    fi
}

install_uv() {
    local mode=$1
    if [ "$mode" == "SKIP" ]; then return; fi
    echo "🐍 [uv] Checking Python uv..."
    if [ "$mode" == "SAFE" ] && cmd_exists uv; then echo "   ✅ Already installed."; return; fi
    curl -LsSf https://astral.sh/uv/install.sh | sh
}


# --- Main Execution Area ---

# Read config strategy, default is SAFE
S_SYS=${CONFIG[system_packages]:-$SAFE}
S_ZSH=${CONFIG[zsh]:-$SAFE}
S_VIM=${CONFIG[vim]:-$SAFE}
S_TMUX=${CONFIG[tmux]:-$SAFE}
S_DOCKER=${CONFIG[docker]:-$SAFE}
S_UV=${CONFIG[python_uv]:-$SAFE}

echo "========================================"
echo "   Dotfiles Auto-Installer (Smart Mode)"
echo "========================================"

install_system_packages "$S_SYS"
install_uv "$S_UV"
install_docker "$S_DOCKER"
install_zsh "$S_ZSH"
install_vim "$S_VIM"
install_tmux "$S_TMUX"

echo "========================================"
echo "🎉 All Tasks Completed!"
echo "👉 Please restart your terminal."