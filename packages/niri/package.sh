#!/usr/bin/env bash
# Last updated: WEDNESDAY, 11 NOVEMBER 2026 11:13 P.M. (UTC)
# Niri Stable | Ubuntu 26.04 LTS
# Source: Third-party Dux Labs PPA (recommended by Niri)
# Docs: Official https://niri-wm.github.io/niri/Getting-Started.html | Dux Labs https://duxlabs.dev/docs/repo

# === Configuration ===
NIRI_CONFIG="$HOME/.config/niri"
NIRI_SOURCE="$SCRIPT_DIR/config/niri"
NIRI_REPO="ppa:duxlabs/dux-repo"
NIRI_REPO_URI="https://ppa.launchpadcontent.net/duxlabs/dux-repo/ubuntu"

# === Utility functions ===
check_installation() {
  [[ "$(dpkg-query -W -f='${db:Status-Status}' niri 2>/dev/null)" == "installed" ]]
}

check_repository() {
  grep -Rqs "$NIRI_REPO_URI" /etc/apt/sources.list.d/ 2>/dev/null
}

check_config() {
  [[ -L "$NIRI_CONFIG" ]] &&
    [[ "$(readlink -f "$NIRI_CONFIG")" == "$(readlink -f "$NIRI_SOURCE")" ]]
}

# === Repository functions ===
install_repository() {
  if check_repository; then
    info_label "Niri repository already configured"
  else
    info_label "Adding Dux Labs repository..."

    sudo add-apt-repository -y "$NIRI_REPO" || {
      error_label "Failed to add Dux Labs repository"
      return 1
    }
  fi

  sudo apt update || {
    error_label "Failed to update package lists"
    return 1
  }
}

uninstall_repository() {
  if check_repository; then
    info_label "Removing Dux Labs repository..."

    sudo add-apt-repository --remove -y "$NIRI_REPO" || {
      error_label "Failed to remove Dux Labs repository"
      return 1
    }

    sudo apt update || {
      error_label "Failed to update package lists"
      return 1
    }

    success_label "Dux Labs repository removed"
  else
    info_label "Niri repository not found. Skipping"
  fi
}

# === Configuration functions ===
install_config() {
  [[ -d "$NIRI_SOURCE" ]] || {
    error_label "Niri configuration source not found"
    return 1
  }

  if check_config; then
    info_label "Niri configuration already linked. Skipping"
    return 0
  fi

  mkdir -p "$(dirname "$NIRI_CONFIG")" || return 1

  if [[ -e "$NIRI_CONFIG" || -L "$NIRI_CONFIG" ]]; then
    local backup="${NIRI_CONFIG}.backup.$(date +%Y%m%d-%H%M%S)"

    mv -- "$NIRI_CONFIG" "$backup" || return 1
    info_label "Previous configuration backed up to $backup"
  fi

  ln -s "$NIRI_SOURCE" "$NIRI_CONFIG" || return 1

  success_label "Niri configuration linked"
}

uninstall_config() {
  if check_config; then
    rm -- "$NIRI_CONFIG" || return 1
    success_label "Niri configuration link removed"
  else
    info_label "Managed Niri configuration link not found. Skipping"
  fi
}

config() {
  install_config
}

# === Core functions ===
install() {
  install_repository || return 1

  if check_installation; then
    info_label "Niri is already installed. Skipping"
  else
    info_label "Installing Niri..."

    sudo apt install -y niri || {
      error_label "Niri installation failed"
      return 1
    }

    success_label "Niri installed"
    info_label "Log out and select Niri from your display manager"
  fi

  install_config
}

uninstall() {
  if check_installation; then
    info_label "Removing Niri..."

    sudo apt remove -y niri || {
      error_label "Niri removal failed"
      return 1
    }
    success_label "Niri package removed"
  else
    info_label "Niri is not installed. Skipping package removal"
  fi

  uninstall_config || return 1
  uninstall_repository || return 1

  success_label "Niri uninstallation completed. Reboot to apply the changes"
}

status() {
  echo "${BOLD}Niri Status:${RESET}"

  check_installation && success_label "Installed" ||
    info_label "Not installed"

  check_repository && success_label "Repository configured" ||
    info_label "Repository not configured"

  check_config && success_label "Configuration linked" ||
    info_label "Configuration not linked"
}
