# === SETTINGS ===
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS

# === STARSHIP ===
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# === ALIASES ===
alias ..="cd .."
alias ...="cd ../.."
alias reload="source ~/.zshrc"
alias update="sudo apt update && sudo apt upgrade -y"

# === ZSH PLUGINS ===
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
