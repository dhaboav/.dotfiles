#!/usr/bin/env bash
# Last updated: THURSDAY, 12 NOVEMBER 2026 15:02 P.M. (UTC)

# ==================================================
# Input Parameters
# ==================================================
# Directory   : Path to the folder containing files to rename.
# Prefix      : Base name used for renamed files.
# Extensions  : Space-separated file extensions (e.g., jpg png jpeg). Case-sensitive.
# Dry run     : Enabled by default. Set to false to rename files immediately.
#
# WARNING: USE WITH CAUTION! INCORRECT USAGE MAY DAMAGE SYSTEM FILES.
# ==================================================

set -u
export LC_ALL=C

# === Configuration ===

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

DRY_RUN=true # Change this!

# === Helpers ===

error() {
  echo "${RED}Error: $1 ${RESET} " >&2
  exit 1
}

info() {
  echo "${CYAN}$1 ${RESET}"
}

progress() {
  local current=$1
  local total=$2
  local width=30
  local filled=$((current * width / total))
  local percent=$((current * 100 / total))
  local bar

  printf -v bar '%*s' "$filled" ''
  bar=${bar// /#}

  printf -v bar '%s%*s' "$bar" "$((width - filled))" ''
  bar=${bar// /-}

  printf '\r[%s] %3d%% (%d/%d)' \
    "$bar" "$percent" "$current" "$total"
}

# === Directory Validation ===

validate_directory() {
  [[ -d "$1" ]] || error "Directory does not exist."

  directory=$(realpath -e -- "$1") ||
    error "Cannot resolve directory."

  case "$directory" in
  / | /etc | /etc/* | /usr | /usr/* | /bin | /bin/* | \
    /sbin | /sbin/* | /boot | /boot/* | \
    /lib | /lib/* | /lib64 | /lib64/* | \
    /var | /var/* | /root | /root/* | \
    /proc | /proc/* | /sys | /sys/* | \
    /dev | /dev/* | /run | /run/* | \
    /opt | /opt/* | /snap | /snap/* | /home)
    error "Protected system directory."
    ;;
  esac

  [[ -w "$directory" && -x "$directory" ]] ||
    error "Insufficient directory permissions."
}

# === Input Validation ===

get_input() {
  read -r -p "Directory: " input_directory
  validate_directory "$input_directory"

  read -r -p "Prefix: " prefix

  [[ -n "$prefix" ]] || error "Prefix cannot be empty."
  [[ "$prefix" != */* ]] || error "Prefix cannot contain /."
  [[ "$prefix" != "." && "$prefix" != ".." ]] ||
    error "Invalid prefix."

  read -r -p "Extensions: " extensions
  [[ -n "$extensions" ]] || error "No extensions provided."

  extensions="${extensions//,/ }"
  read -r -a extensions_array <<<"$extensions"

  ((${#extensions_array[@]} > 0)) ||
    error "No valid extensions."

  for ext in "${extensions_array[@]}"; do
    [[ "$ext" =~ ^[a-zA-Z0-9_-]+$ ]] ||
      error "Invalid extension: $ext"
  done

  mapfile -t extensions_array < <(
    printf '%s\n' "${extensions_array[@]}" | sort -u
  )
}

# === File Collection ===

collect_files() {
  files=()

  for ext in "${extensions_array[@]}"; do
    for file in "$directory"/*."$ext"; do
      [[ -f "$file" ]] || continue
      files+=("$file")
    done
  done

  total=${#files[@]}

  ((total > 0)) || error "No matching files found."
}

# === Preview ===

preview_changes() {
  info "Preview:"

  for ((i = 0; i < total; i++)); do
    old_name=${files[i]##*/}
    ext=${old_name##*.}

    new_name=$(printf '%s_%03d.%s' \
      "$prefix" "$((i + 1))" "$ext")

    echo " ${old_name} -> ${new_name}"
  done
  info "Total files: ${total}"
}

# === Rename ===

rename_files() {
  local renamed=0
  local unchanged=0
  local current=0

  info "Renaming files..."

  for ((i = 0; i < total; i++)); do
    source=${files[i]}
    old_name=${source##*/}
    ext=${old_name##*.}

    new_name=$(printf '%s_%03d.%s' \
      "$prefix" "$((i + 1))" "$ext")

    destination="$directory/$new_name"

    if [[ "$source" == "$destination" ]]; then
      ((unchanged += 1))

    elif [[ -e "$destination" || -L "$destination" ]]; then
      ((unchanged += 1))

    elif [[ "$DRY_RUN" == true ]]; then
      ((renamed += 1))

    elif mv -n -- "$source" "$destination" &&
      [[ ! -e "$source" && ! -L "$source" ]]; then
      ((renamed += 1))

    else
      ((unchanged += 1))
    fi

    ((current += 1))
    progress "$current" "$total"
  done

  printf "\n\n"

  if [[ "$DRY_RUN" == true ]]; then
    echo "${YELLOW}Dry run complete.${RESET}"
    echo "Would rename: $renamed"
    echo "Unchanged: $unchanged"
  else
    echo "${GREEN}Renaming complete.${RESET}"
    echo "Renamed: $renamed"
    echo "Unchanged: $unchanged"
  fi
}

# === Main ===

main() {
  info "=== Bash Bulk Renamer ==="

  get_input
  collect_files
  preview_changes

  if [[ "$DRY_RUN" == true ]]; then
    read -r -p "Proceed with dry run? [Y/n]: " choice

    if [[ "$choice" =~ ^[Nn]$ ]]; then
      echo "Cancelled."
      exit 0
    fi

    rename_files

    read -r -p "Apply these changes for real? [y/N]: " choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
      DRY_RUN=false
      rename_files
    else
      echo "No files were changed."
    fi
  else
    read -r -p "Proceed with renaming? [y/N]: " choice

    if [[ "$choice" =~ ^[Yy]$ ]]; then
      rename_files
    else
      echo "Cancelled. No files were changed."
    fi
  fi
}

main "$@"
