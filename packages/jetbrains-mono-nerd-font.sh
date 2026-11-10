#!/usr/bin/env bash
# LAST UPDATE: TUESDAY, 10 NOVEMBER 2026

TARGET_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/jetbrains-mono-nerd"
SOURCE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

check_dep() {
  command -v wget >/dev/null 2>&1 &&
    command -v unzip >/dev/null 2>&1 &&
    command -v fc-cache >/dev/null 2>&1 &&
    command -v fc-scan >/dev/null 2>&1
}

install_dep() {
  printf 'Installing dependencies...\n'
  sudo apt install -y wget unzip fontconfig
}

check() {
  [[ -d "$TARGET_DIR" ]] || return 1

  find "$TARGET_DIR" -type f -name '*.ttf' \
    -exec fc-scan --format '%{family}\n' {} + 2>/dev/null |
    grep -Fqi 'JetBrainsMono Nerd Font Mono'
}

install() {
  local tmp_dir archive stage_dir

  printf 'Installing JetBrainsMono Nerd Font Mono...\n'

  if check; then
    printf 'Font is already installed.\n'
    return 0
  fi

  tmp_dir=$(mktemp -d) || return 1
  archive="$tmp_dir/fonts.zip"
  stage_dir="$tmp_dir/fonts"

  mkdir -p "$stage_dir" || {
    rm -rf -- "$tmp_dir"
    return 1
  }

  # Download and validate
  wget -q --show-progress "$SOURCE_URL" -O "$archive" &&
    unzip -tq "$archive" || {
    rm -rf -- "$tmp_dir"
    return 1
  }

  # Extract Mono fonts
  unzip -q -j "$archive" \
    '*JetBrainsMonoNerdFontMono-*.ttf' \
    -d "$stage_dir" || {
    rm -rf -- "$tmp_dir"
    return 1
  }

  # Check extracted files
  if ! find "$stage_dir" -type f -name '*.ttf' -print -quit | grep -q .; then
    printf 'No Mono font files found.\n' >&2
    rm -rf -- "$tmp_dir"
    return 1
  fi

  # Install fonts
  mkdir -p "$TARGET_DIR" &&
    cp -f "$stage_dir"/*.ttf "$TARGET_DIR/" || {
    rm -rf -- "$tmp_dir"
    return 1
  }

  # Refresh and verify
  fc-cache -f "$TARGET_DIR" || {
    rm -rf -- "$tmp_dir"
    return 1
  }

  rm -rf -- "$tmp_dir"

  if ! check; then
    printf 'Font installation verification failed.\n' >&2
    return 1
  fi

  printf 'JetBrainsMono Nerd Font Mono installed successfully.\n'
}

uninstall() {
  printf 'Uninstalling JetBrainsMono Nerd Font Mono...\n'

  if [[ ! -d "$TARGET_DIR" ]]; then
    printf 'Font is not installed.\n'
    return 0
  fi

  rm -rf -- "$TARGET_DIR" || return 1
  fc-cache -f || return 1

  printf 'Font uninstalled successfully.\n'
}

status() {
  if check; then
    printf 'JetBrains Font is installed.\n'
  else
    printf 'JetBrains Font is not installed.\n'
  fi
}
