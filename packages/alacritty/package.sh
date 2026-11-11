#!/usr/bin/env bash
# Last updated: WEDNESDAY, 11 NOVEMBER 2026 01:22 P.M. (UTC)

# === Configuration ===
ALACRITTY_CONFIG="$HOME/.config/alacritty"
ALACRITTY_SOURCE="$SCRIPT_DIR/config/alacritty"

# === Utility functions ===
check_installation() {
  command -v alacritty >/dev/null 2>&1
}

check_config() {
  [[ -L "$ALACRITTY_CONFIG" ]] &&
    [[ "$(readlink -f "$ALACRITTY_CONFIG")" == "$(readlink -f "$ALACRITTY_SOURCE")" ]]
}

# === Configuration functions ===
install_config() {
  [[ -d "$ALACRITTY_SOURCE" ]] || {
    error_label "Alacritty configuration source not found"
    return 1
  }

  if check_config; then
    info_label "Alacritty configuration is already linked. Skipping"
    return 0
  fi

  mkdir -p "$(dirname "$ALACRITTY_CONFIG")" || return 1

  if [[ -e "$ALACRITTY_CONFIG" || -L "$ALACRITTY_CONFIG" ]]; then
    if [[ -L "$ALACRITTY_CONFIG" ]]; then
      rm -- "$ALACRITTY_CONFIG" || return 1
    else
      local backup="$ALACRITTY_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
      mv -- "$ALACRITTY_CONFIG" "$backup" || return 1
      info_label "Existing configuration backed up"
    fi
  fi

  ln -s "$ALACRITTY_SOURCE" "$ALACRITTY_CONFIG" || return 1
  success_label "Alacritty configuration linked"
}

uninstall_config() {
  if check_config; then
    rm -- "$ALACRITTY_CONFIG" || return 1
    success_label "Alacritty configuration removed"
  else
    info_label "Managed Alacritty configuration not found. Skipping"
  fi
}

# === Core functions ===
install() {
  echo "${BOLD}Installing Alacritty...${RESET}"

  if check_installation; then
    info_label "Alacritty is already installed. Skipping"
  else
    sudo apt update && sudo apt install -y alacritty || {
      error_label "Alacritty installation failed"
      return 1
    }
    success_label "Alacritty installed successfully"
  fi

  install_config || return 1

  success_label "Alacritty setup completed"
}

uninstall() {
  echo "${BOLD}Uninstalling Alacritty...${RESET}"

  if check_installation; then
    sudo apt remove -y alacritty || {
      error_label "Alacritty removal failed"
      return 1
    }

    success_label "Alacritty removed"
  else
    info_label "Alacritty is not installed"
  fi

  uninstall_config || return 1

  success_label "Alacritty uninstallation completed"
}

status() {
  echo "${BOLD}Alacritty Status:${RESET}"

  check_installation && success_label "Installed" ||
    info_label "Not installed"

  check_config && success_label "Configuration linked" ||
    info_label "Configuration not linked"
}
