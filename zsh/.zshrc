# If P10k cache config exists, read it first
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

# --- 1. Theme Settings ---
# Set to Powerlevel10k (install.sh will auto download this theme)
ZSH_THEME="powerlevel10k/powerlevel10k"

# --- 2. Plugins Settings ---
# These plugins donwload logic are written in install.sh, here is for enabling them
# git: Show git status shortcuts
# docker: docker command completion
# z: Rapid directory jump
# fzf: Fuzzy search
# sudo: Double press ESC to auto add sudo
# zsh-autosuggestions: Grey text history suggestions
# zsh-syntax-highlighting: Command highlighting (green correct/red wrong)
plugins=(git docker z sudo fzf zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# --- 3. User Custom Settings ---

# Python uv setting
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Change default editor to vim
export EDITOR='vim'

# --- 4. FZF Settings (Search Optimization) ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='find . -type f' 
# If you installed fd or ripgrep, can use faster search command:
# export FZF_DEFAULT_COMMAND='fd --type f'

# --- 5. Load P10k Config ---
# (After running zsh for the first time, p10k configure will generate this file, remember to add to git)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh