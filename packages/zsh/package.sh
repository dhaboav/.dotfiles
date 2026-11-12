#!/usr/bin/env bash
# Last updated: THURSDAY, 12 NOVEMBER 2026 00:25 A.M. (UTC)

#  === Configuration ===
PLUGINS=(
  "zsh-users/zsh-history-substring-search"
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
)
PLUGIN_DIR="$HOME/.zsh"

ZSHRC="$HOME/.zshrc"
ZSHRC_SOURCE="$SCRIPT_DIR/config/zsh/.zshrc"

ZSH_INIT="$HOME/.zsh/init.zsh"
ZSH_INIT_SOURCE="$SCRIPT_DIR/config/zsh/init.zsh"

#  === Utility functions ===
check_installation() {
  command -v zsh >/dev/null 2>&1
}

check_default_shell() {
  local zsh_path

  zsh_path="$(command -v zsh)" || return 1

  [[ "$(getent passwd "$(id -un)" | cut -d: -f7)" == "$zsh_path" ]]
}

check_plugins() {
  local repo

  for repo in "${PLUGINS[@]}"; do
    [[ -d "$PLUGIN_DIR/${repo##*/}" ]] || return 1
  done
}

install_plugins() {
  local repo name

  mkdir -p "$PLUGIN_DIR" || return 1

  for repo in "${PLUGINS[@]}"; do
    name="${repo##*/}"

    if [[ -d "$PLUGIN_DIR/$name" ]]; then
      info_label "$name is already installed. Skipping"
      continue
    fi

    info_label "Installing $name..."

    if git clone --quiet "https://github.com/$repo" "$PLUGIN_DIR/$name"; then
      success_label "$name installed"
    else
      error_label "Failed to install $name"
      return 1
    fi
  done
}

uninstall_plugins() {
  local repo name

  for repo in "${PLUGINS[@]}"; do
    name="${repo##*/}"

    if [[ -d "$PLUGIN_DIR/$name" ]]; then
      rm -rf -- "$PLUGIN_DIR/$name" &&
        success_label "$name removed" ||
        return 1
    fi
  done
}

check_config() {
  [[ -f "$ZSHRC" ]] &&
    cmp -s "$ZSHRC_SOURCE" "$ZSHRC" &&
    [[ -L "$ZSH_INIT" ]] &&
    [[ "$(readlink -f "$ZSH_INIT")" == "$(readlink -f "$ZSH_INIT_SOURCE")" ]]
}

install_config() {
  local backup

  [[ -f "$ZSHRC_SOURCE" ]] || {
    error_label ".zshrc source file not found"
    return 1
  }

  [[ -f "$ZSH_INIT_SOURCE" ]] || {
    error_label "init.zsh source file not found"
    return 1
  }

  mkdir -p "$HOME/.zsh" || return 1

  # Configure .zshrc
  if [[ -f "$ZSHRC" ]] && cmp -s "$ZSHRC_SOURCE" "$ZSHRC"; then
    info_label ".zshrc is already configured. Skipping"
  else
    if [[ -e "$ZSHRC" || -L "$ZSHRC" ]]; then
      backup="$ZSHRC.backup.$(date +%Y%m%d-%H%M%S)"
      mv -- "$ZSHRC" "$backup" || return 1
      info_label "Existing .zshrc backed up to $(basename "$backup")"
    fi

    cp -- "$ZSHRC_SOURCE" "$ZSHRC" || return 1
    success_label ".zshrc copied successfully"
  fi

  # Configure init.zsh
  if [[ -L "$ZSH_INIT" ]] &&
    [[ "$(readlink -f "$ZSH_INIT")" == "$(readlink -f "$ZSH_INIT_SOURCE")" ]]; then
    info_label "init.zsh is already linked. Skipping"
  else
    if [[ -e "$ZSH_INIT" || -L "$ZSH_INIT" ]]; then
      backup="$ZSH_INIT.backup.$(date +%Y%m%d-%H%M%S)"
      mv -- "$ZSH_INIT" "$backup" || return 1
      info_label "Existing init.zsh backed up to $(basename "$backup")"
    fi

    ln -s "$ZSH_INIT_SOURCE" "$ZSH_INIT" || return 1
    success_label "init.zsh linked successfully"
  fi
}

uninstall_config() {
  if [[ -f "$ZSHRC" ]] && cmp -s "$ZSHRC_SOURCE" "$ZSHRC"; then
    rm -- "$ZSHRC" || return 1
    success_label ".zshrc removed"
  else
    info_label "Managed .zshrc not found. Skipping"
  fi

  if [[ -L "$ZSH_INIT" ]] &&
    [[ "$(readlink -f "$ZSH_INIT")" == "$(readlink -f "$ZSH_INIT_SOURCE")" ]]; then
    rm -- "$ZSH_INIT" || return 1
    success_label "init.zsh link removed"
  else
    info_label "Managed init.zsh link not found. Skipping"
  fi
}

#  === Core functions ===
install() {
  echo "${BOLD}Installing ZSH...${RESET}"

  if check_installation; then
    info_label "ZSH is already installed"
  else
    sudo apt update && sudo apt install -y zsh || {
      error_label "ZSH installation failed"
      return 1
    }

    success_label "ZSH installed successfully"
  fi

  if check_default_shell; then
    info_label "ZSH is already the default shell"
  else
    chsh -s "$(command -v zsh)" || {
      error_label "Failed to set ZSH as default shell"
      return 1
    }

    success_label "ZSH set as default shell"
    info_label "Log out and back in for changes to take effect"
  fi

  install_plugins || return 1
  install_config || return 1

  success_label "ZSH setup completed"
}

uninstall() {
  echo "${BOLD}Uninstalling ZSH...${RESET}"

  if check_default_shell; then
    chsh -s "$(command -v bash)" || {
      error_label "Failed to reset default shell. Keeping ZSH installed"
      return 1
    }

    info_label "Default shell changed to Bash"
  fi

  if check_installation; then
    sudo apt remove -y zsh || {
      error_label "ZSH removal failed"
      return 1
    }

    success_label "ZSH removed."
  else
    info_label "ZSH is not installed"
  fi

  uninstall_plugins || return 1
  uninstall_config || return 1

  success_label "ZSH uninstallation completed"
}

status() {
  echo "${BOLD}ZSH Status:${RESET}"

  check_installation && success_label "Installed" ||
    info_label "Not installed"

  check_default_shell && success_label "Default shell" ||
    info_label "Not the default shell"

  check_plugins && success_label "All plugins installed" ||
    info_label "Some plugins are missing"

  check_config && success_label "Configuration linked" ||
    info_label "Configuration not linked"
}
