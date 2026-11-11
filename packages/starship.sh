#!/usr/bin/env bash
# Last updated: WEDNESDAY, 11 NOVEMBER 2026 05:09 A.M. (UTC)

# === Package Metadata ===
PACKAGE_NAME="starship"
PACKAGE_DESCRIPTION="Starship prompt with configuration"

# === Configuration ===
STARSHIP_CONFIG="$HOME/.config/starship.toml"
STARSHIP_SOURCE="$SCRIPT_DIR/config/starship/starship.toml"

# === Utility functions ===
check_installation() {
  command -v starship >/dev/null 2>&1
}

check_config() {
  [[ -L "$STARSHIP_CONFIG" ]] &&
    [[ "$(readlink -f "$STARSHIP_CONFIG")" == "$(readlink -f "$STARSHIP_SOURCE")" ]]
}

# === Configuration functions ===
install_config() {
  [[ -f "$STARSHIP_SOURCE" ]] || {
    error_label "Starship configuration source not found"
    return 1
  }

  if check_config; then
    info_label "Starship configuration is already linked. Skipping"
    return 0
  fi

  mkdir -p "$(dirname "$STARSHIP_CONFIG")" || return 1

  if [[ -e "$STARSHIP_CONFIG" || -L "$STARSHIP_CONFIG" ]]; then
    if [[ -L "$STARSHIP_CONFIG" ]]; then
      rm -- "$STARSHIP_CONFIG" || return 1
    else
      local backup="$STARSHIP_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
      mv -- "$STARSHIP_CONFIG" "$backup" || return 1
      info_label "Existing configuration backed up"
    fi
  fi

  ln -s "$STARSHIP_SOURCE" "$STARSHIP_CONFIG" || return 1
  success_label "Starship configuration linked"
}

uninstall_config() {
  if check_config; then
    rm -- "$STARSHIP_CONFIG" || return 1
    success_label "Starship configuration removed"
  else
    info_label "No managed Starship configuration found. Skipping"
  fi
}

# === Core functions ===
install() {
  echo "${BOLD}Installing Starship...${RESET}"

  if check_installation; then
    info_label "Starship is already installed"
  else
    sudo apt update && sudo apt install -y starship || {
      error_label "Starship installation failed"
      return 1
    }

    success_label "Starship installed successfully"
  fi

  install_config || return 1

  success_label "Starship setup completed. Reload your terminal to apply changes"
}

uninstall() {
  echo "${BOLD}Uninstalling Starship...${RESET}"

  if check_installation; then
    sudo apt remove -y starship || {
      error_label "Starship removal failed"
      return 1
    }

    success_label "Starship removed"
  else
    info_label "Starship is not installed"
  fi

  uninstall_config || return 1

  success_label "Starship uninstallation completed. Reload your terminal to apply changes"
}

status() {
  echo "${BOLD}Starship Status:${RESET}"

  check_installation && success_label "Installed" ||
    info_label "Not installed"

  check_config && success_label "Configuration linked" ||
    info_label "Configuration not linked"
}
