#!/usr/bin/env bash
# Last updated: WEDNESDAY, 11 NOVEMBER 2026 05:09 A.M. (UTC)

# === Package Metadata ===
PACKAGE_NAME="fastfetch"
PACKAGE_DESCRIPTION="Fastfetch with configuration"

# === Configuration ===
FASTFETCH_CONFIG="$HOME/.config/fastfetch/config.jsonc"
FASTFETCH_SOURCE="$SCRIPT_DIR/config/fastfetch/config.jsonc"

# === Utility functions ===
check_installation() {
  command -v fastfetch >/dev/null 2>&1
}

check_config() {
  [[ -L "$FASTFETCH_CONFIG" ]] &&
    [[ "$(readlink -f "$FASTFETCH_CONFIG")" == "$(readlink -f "$FASTFETCH_SOURCE")" ]]
}

# === Configuration functions ===
install_config() {
  [[ -f "$FASTFETCH_SOURCE" ]] || {
    error_label "Fastfetch configuration source not found"
    return 1
  }

  if check_config; then
    info_label "Fastfetch configuration is already linked. Skipping"
    return 0
  fi

  mkdir -p "$(dirname "$FASTFETCH_CONFIG")" || return 1

  if [[ -e "$FASTFETCH_CONFIG" || -L "$FASTFETCH_CONFIG" ]]; then
    if [[ -L "$FASTFETCH_CONFIG" ]]; then
      rm -- "$FASTFETCH_CONFIG" || return 1
    else
      local backup="$FASTFETCH_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
      mv -- "$FASTFETCH_CONFIG" "$backup" || return 1
      info_label "Existing configuration backed up"
    fi
  fi

  ln -s "$FASTFETCH_SOURCE" "$FASTFETCH_CONFIG" || return 1
  success_label "Fastfetch configuration linked"
}

uninstall_config() {
  if [[ -d "$HOME/.config/fastfetch" ]]; then
    rm -rf -- "$HOME/.config/fastfetch" || return 1
    success_label "Fastfetch configuration directory removed"
  else
    info_label "Fastfetch configuration directory not found. Skipping"
  fi
}

# === Core functions ===
install() {
  echo "${BOLD}Installing Fastfetch...${RESET}"

  if check_installation; then
    info_label "Fastfetch is already installed"
  else
    sudo apt update && sudo apt install -y fastfetch || {
      error_label "Fastfetch installation failed"
      return 1
    }

    success_label "Fastfetch installed successfully"
  fi

  install_config || return 1

  success_label "Fastfetch setup completed"
}

uninstall() {
  echo "${BOLD}Uninstalling Fastfetch...${RESET}"

  if check_installation; then
    sudo apt remove -y fastfetch || {
      error_label "Fastfetch removal failed"
      return 1
    }
    success_label "Fastfetch removed"
  else
    info_label "Fastfetch is not installed"
  fi

  uninstall_config || return 1

  success_label "Fastfetch uninstallation completed"
}

status() {
  echo "${BOLD}Fastfetch Status:${RESET}"

  check_installation && success_label "Installed" ||
    info_label "Not installed"

  check_config && success_label "Configuration linked" ||
    info_label "Configuration not linked"
}
