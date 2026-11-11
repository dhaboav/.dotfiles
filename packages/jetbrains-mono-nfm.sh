#!/usr/bin/env bash
# Last updated: WEDNESDAY, 11 NOVEMBER 2026 04:05 A.M. (UTC)

#  === Package Metadata ===
PACKAGE_NAME="JetBrainsNFM"
PACKAGE_DESCRIPTION="JetBrainsMono NFM Font"

#  === Configuration ===
TARGET_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/jetbrains-mono-nerd"
SOURCE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"

#  === Utility functions ===
check_installation() {
  [[ -d "$TARGET_DIR" ]] || return 1

  find "$TARGET_DIR" -type f -name '*.ttf' \
    -exec fc-scan --format '%{family}\n' {} + 2>/dev/null |
    grep -Fqi 'JetBrainsMono Nerd Font Mono'
}

#  === Core functions ===
install() {
  local tmp_dir archive stage_dir

  echo "${BOLD}Installing JetBrainsMono NFM...${RESET}"

  if check_installation; then
    info_label "Font is already installed. Skipping."
    return 0
  fi

  tmp_dir=$(mktemp -d) || {
    error_label "Could not create temporary directory."
    return 1
  }

  archive="$tmp_dir/fonts.zip"
  stage_dir="$tmp_dir/fonts"

  mkdir -p "$stage_dir" || {
    error_label "Could not create staging directory."
    rm -rf -- "$tmp_dir"
    return 1
  }

  # Download
  info_label "Downloading font archive..."

  if ! wget -q --show-progress "$SOURCE_URL" -O "$archive"; then
    error_label "Font download failed."
    rm -rf -- "$tmp_dir"
    return 1
  fi

  success_label "Font archive downloaded."

  # Validate archive
  info_label "Validating archive..."

  if ! unzip -tq "$archive" >/dev/null 2>&1; then
    error_label "Downloaded archive is invalid."
    rm -rf -- "$tmp_dir"
    return 1
  else
    success_label "Archive validation passed."
  fi

  # Extract fonts
  info_label "Extracting font files..."

  if ! unzip -q -j "$archive" \
    '*JetBrainsMonoNerdFontMono-*.ttf' \
    -d "$stage_dir"; then
    error_label "Font extraction failed."
    rm -rf -- "$tmp_dir"
    return 1
  fi

  if ! find "$stage_dir" -type f -name '*.ttf' -print -quit | grep -q .; then
    error_label "No font files were found in the archive."
    rm -rf -- "$tmp_dir"
    return 1
  fi

  # Install
  info_label "Installing font files..."

  if ! mkdir -p "$TARGET_DIR" ||
    ! cp -f "$stage_dir"/*.ttf "$TARGET_DIR/"; then
    error_label "Could not copy font files into $TARGET_DIR."
    rm -rf -- "$tmp_dir"
    return 1
  fi

  # Refresh font cache
  info_label "Refreshing font cache..."

  if ! fc-cache -f "$TARGET_DIR"; then
    error_label "Failed to refresh font cache."
    rm -rf -- "$tmp_dir"
    return 1
  fi

  rm -rf -- "$tmp_dir"

  # Verify
  if ! check_installation; then
    error_label "Installation completed, but font verification failed."
    return 1
  fi

  success_label "Font installed successfully."
}

uninstall() {
  echo "${BOLD}Uninstalling JetBrainsMono NFM...${RESET}"

  if [[ ! -d "$TARGET_DIR" ]]; then
    info_label "Font is not installed. Nothing to remove."
    return 0
  fi

  rm -rf -- "$TARGET_DIR" || return 1
  fc-cache -f || return 1

  success_label "Font uninstalled successfully"
}

status() {
  if check_installation; then
    success_label "JetBrainsMono NFM is installed."
  else
    info_label "JetBrainsMono NFM is not installed."
  fi
}
