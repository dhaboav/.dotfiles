#!/usr/bin/env bash

VERSION="0.0.1"

# Directories
DOTSHELL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$DOTSHELL_DIR/packages"

# Text styles
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  RESET=$'\033[0m'
  BOLD=$'\033[1m'
  BOLD_UNDERLINE=$'\033[1;4m'
  YELLOW=$'\033[33m'
  BOLD_RED=$'\033[1;31m'
else
  RESET=''
  BOLD=''
  BOLD_UNDERLINE=''
  YELLOW=''
  BOLD_RED=''
fi

# Version
show_version() {
  printf 'dotshell %s\n' "$VERSION"
}

# List available packages
list_packages() {
  local file
  local package
  local found=false

  printf '%sAvailable packages:%s\n' "$BOLD" "$RESET"

  for file in "$PACKAGE_DIR"/*.sh; do
    [[ -f "$file" ]] || continue

    package="${file##*/}"
    package="${package%.sh}"

    printf '  %s\n' "$package"
    found=true
  done

  if [[ "$found" == false ]]; then
    printf '  No packages available.\n'
  fi
}

# Help
show_help() {
  cat <<EOF
A simple and modular dotfiles manager for the command line.

${BOLD_UNDERLINE}Usage:${RESET}
  dotshell <COMMAND> [PACKAGE]

${BOLD_UNDERLINE}Commands:${RESET}
  ${BOLD}install${RESET}    Install a package
  ${BOLD}uninstall${RESET}  Remove a package
  ${BOLD}status${RESET}     Show package status
  ${BOLD}list${RESET}       List available packages
  ${BOLD}help${RESET}       Print this help message

${BOLD_UNDERLINE}Options:${RESET}
  ${BOLD}-h, --help${RESET}     Print help
  ${BOLD}-v, --version${RESET}  Print version

EOF

  list_packages
}

# Error
show_error() {
  printf '%serror:%s %s\n' "$BOLD_RED" "$RESET" "$1" >&2
  printf "For more information, try '%sdotshell --help%s'.\n" \
    "$BOLD" "$RESET" >&2
}

# Execute package
run_package() {
  local action="$1"
  local package="$2"
  local package_file

  # Validate package name
  if [[ ! "$package" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    show_error "Invalid package name '$package'."
    return 1
  fi

  # Locate package
  package_file="$PACKAGE_DIR/$package.sh"

  if [[ ! -f "$package_file" ]]; then
    show_error "Package '$package' not found."
    printf '\n'
    list_packages
    return 1
  fi

  # Load package
  source "$package_file" || {
    show_error "Failed to load package '$package'."
    return 1
  }

  # Check requested function
  if ! declare -F "$action" >/dev/null; then
    show_error "Package '$package' does not support '$action'."
    return 1
  fi

  # Execute package action
  "$action"
}

# Main entry point
case "${1:-}" in
  --help | -h | help)
    show_help
    ;;

  --version | -v)
    show_version
    ;;

  list)
    list_packages
    ;;

  install | uninstall | status)
    if [[ -z "${2:-}" ]]; then
      show_error "Missing package name."
      exit 1
    fi

    if [[ -n "${3:-}" ]]; then
      show_error "Unexpected argument '${3}'."
      exit 1
    fi

    run_package "$1" "$2" || exit 1
    ;;

  *)
    show_error "Unknown command '${1:-}'."
    exit 1
    ;;
esac
