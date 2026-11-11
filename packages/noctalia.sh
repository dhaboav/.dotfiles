#!/usr/bin/env bash
# Last updated: WEDNESDAY, 11 NOVEMBER 2026 11:30 A.M. (UTC)
# Noctalia v5.4.1 | Ubuntu 26.04 LTS
# Docs: https://docs.noctalia.dev/noctalia/v5.4.1/getting-started/installation/?section=debian#debian

# === Package Metadata ===
PACKAGE_NAME="noctalia"
PACKAGE_DESCRIPTION="Noctalia v5.4.1 with configuration"

# === Configuration ===
NOCTALIA_CONFIG="$HOME/.config/noctalia"
NOCTALIA_SOURCE="$SCRIPT_DIR/config/noctalia"
NOCTALIA_REPO_FILE="/etc/apt/sources.list.d/noctalia-resolute.sources"
NOCTALIA_REPO_URL="https://pkg.noctalia.dev/deb/noctalia-resolute.sources"
NOCTALIA_KEYRING_URL="https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb"

# === Utility functions ===
check_installation() {
  [[ "$(dpkg-query -W -f='${db:Status-Status}' noctalia 2>/dev/null)" == "installed" ]]
}

check_repository() {
  [[ -f "$NOCTALIA_REPO_FILE" ]]
}

check_keyring() {
  [[ "$(dpkg-query -W -f='${db:Status-Status}' nickh-archive-keyring 2>/dev/null)" == "installed" ]]
}

check_config() {
  [[ -L "$NOCTALIA_CONFIG" ]] &&
    [[ "$(readlink -f "$NOCTALIA_CONFIG")" == "$(readlink -f "$NOCTALIA_SOURCE")" ]]
}

# === Repository functions ===
install_repository() {
  local temp_dir

  temp_dir="$(mktemp -d)" || return 1

  info_label "Downloading Noctalia keyring..."

  if ! wget -q -O "$temp_dir/nickh-archive-keyring.deb" "$NOCTALIA_KEYRING_URL"; then
    error_label "Failed to download Noctalia keyring"
    rm -rf -- "$temp_dir"
    return 1
  fi

  sudo dpkg -i "$temp_dir/nickh-archive-keyring.deb" || {
    error_label "Failed to install Noctalia keyring"
    rm -rf -- "$temp_dir"
    return 1
  }

  rm -rf -- "$temp_dir"

  info_label "Adding Noctalia repository..."

  sudo wget -q -O "$NOCTALIA_REPO_FILE" "$NOCTALIA_REPO_URL" || {
    error_label "Failed to add Noctalia repository"
    return 1
  }

  sudo apt update || {
    error_label "Failed to update package lists"
    return 1
  }
}

uninstall_repository() {
  if check_repository; then
    sudo rm -f -- "$NOCTALIA_REPO_FILE" || return 1
    success_label "Noctalia repository removed"
  else
    info_label "Noctalia repository not found. Skipping"
  fi

  sudo apt update || return 1

  if check_keyring; then
    sudo apt purge -y nickh-archive-keyring || return 1
    success_label "Noctalia keyring removed"
  fi
}

# === Configuration functions ===
install_config() {
  [[ -d "$NOCTALIA_SOURCE" ]] || {
    error_label "Noctalia configuration source not found"
    return 1
  }

  if check_config; then
    info_label "Noctalia configuration already linked. Skipping"
    return 0
  fi

  mkdir -p "$(dirname "$NOCTALIA_CONFIG")" || return 1

  if [[ -e "$NOCTALIA_CONFIG" || -L "$NOCTALIA_CONFIG" ]]; then
    local backup="${NOCTALIA_CONFIG}.backup.$(date +%Y%m%d-%H%M%S)"

    mv -- "$NOCTALIA_CONFIG" "$backup" || return 1
    info_label "Previous configuration backed up to $backup"
  fi

  ln -s "$NOCTALIA_SOURCE" "$NOCTALIA_CONFIG" || return 1

  success_label "Noctalia configuration linked"
}

uninstall_config() {
  if check_config; then
    rm -- "$NOCTALIA_CONFIG" || return 1
    success_label "Noctalia configuration link removed"
  else
    info_label "Managed Noctalia configuration link not found. Skipping"
  fi
}

config() {
  install_config
}

# === Core functions ===
install() {
  if ! check_installation; then
    install_repository || return 1

    info_label "Installing Noctalia..."

    sudo apt install -y noctalia || return 1

    success_label "Noctalia installed."
    info_label "Log out and back in to see the changes"
  else
    info_label "Noctalia is already installed. Skipping"
  fi

  install_config
}

uninstall() {
  if check_installation; then
    info_label "Removing Noctalia..."

    # Stop Noctalia processes
    pkill -x noctalia 2>/dev/null || true

    sudo apt purge -y noctalia || return 1
    success_label "Noctalia package removed."

    # Remove state and cache
    rm -rf -- "$HOME/.local/state/noctalia" "$HOME/.cache/noctalia" || return 1

    success_label "Noctalia state and cache removed."
  else
    info_label "Noctalia is not installed. Skipping package cleanup."
  fi

  uninstall_config || return 1
  uninstall_repository
}

status() {
  echo "${BOLD}Noctalia Status:${RESET}"

  check_installation && success_label "Installed" ||
    info_label "Not installed"

  check_repository && success_label "Repository configured" ||
    info_label "Repository not configured"

  check_keyring && success_label "Keyring installed" ||
    info_label "Keyring not installed"

  check_config && success_label "Configuration linked" ||
    info_label "Configuration not linked"
}
