# --- SETTINGS ---
HISTFILE=$HOME/.zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS
eval "$(starship init zsh)"

# --- ROS2 MODULE (Optional) ---
if [[ -f "$HOME/.zsh/.zsh_ros2" ]]; then
  source "$HOME/.zsh/.zsh_ros2"
fi

# --- ALIASES & PLUGINS ---
alias ..="cd .."
alias ...="cd ../.."
alias update="sudo apt update && sudo apt upgrade -y"

source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
