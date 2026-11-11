#!/usr/bin/env bash

VERSION="0.0.4"

# Directories
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/packages"
source "$SCRIPT_DIR/lib/utils.sh"

show_version() {
  echo "dotshell ${VERSION}"
}

show_help() {
  cat <<EOF
A simple and modular dotfiles manager for the command line.

${BOLD_UNDERLINE}Usage:${RESET} <COMMAND> [PACKAGE]

${BOLD_UNDERLINE}Commands:${RESET}
  ${BOLD}install${RESET}    Install a package
  ${BOLD}uninstall${RESET}  Remove a package
  ${BOLD}status${RESET}     Show package status
  
${BOLD_UNDERLINE}Options:${RESET}
  ${BOLD}-h, --help${RESET}     Print help
  ${BOLD}-v, --version${RESET}  Print version
  ${BOLD}-L, --list${RESET}         Print available packages

EOF
}

show_packages() {
  local file package name description

  echo "${BOLD_UNDERLINE}Packages:${RESET}"

  for file in "$PACKAGE_DIR"/*.sh; do
    [[ -f "$file" ]] || continue

    package="${file##*/}"
    package="${package%.sh}"

    PACKAGE_NAME=""
    PACKAGE_DESCRIPTION=""

    source "$file"

    name="${PACKAGE_NAME:-$package}"
    description="${PACKAGE_DESCRIPTION:-No description available.}"

    # Please change the spacing as needed to fit your terminal width
    printf "  ${BOLD}%-13s${RESET} %s\n" "$name" "$description"
  done
}

show_error() {
  cat >&2 <<EOF
${BOLD_RED}error:${RESET} $1

${BOLD_UNDERLINE}Usage:${RESET} <COMMAND> [PACKAGE]

For more information, try '${BOLD}--help${RESET}'.
EOF
}

# Execute package
run_package() {
  local action="$1"
  local package="$2"
  local package_file

  for file in "$PACKAGE_DIR"/*.sh; do
    [[ -f "$file" ]] || continue

    PACKAGE_NAME=""
    source "$file" || continue

    if [[ "${PACKAGE_NAME,,}" == "${package,,}" ]]; then
      package_file="$file"
      break
    fi
  done

  if [[ -z "$package_file" ]]; then
    show_error "Package '$package' not found"
    echo ""
    show_packages
    return 1
  fi

  # Load the selected package
  source "$package_file" || {
    show_error "Failed to load package '$package'"
    return 1
  }

  # Check requested function
  if ! declare -F "$action" >/dev/null; then
    show_error "Package '$PACKAGE_NAME' does not support '$action'"
    return 1
  fi

  # Execute package action
  "$action"
}

# Main entry point
case "${1:-}" in
--help | -h)
  show_help
  ;;

--version | -v)
  show_version
  ;;

--list | -L)
  show_packages
  ;;

install | uninstall | status)
  if [[ -z "${2:-}" ]]; then
    show_error "Missing package name"
    exit 1
  fi

  if [[ -n "${3:-}" ]]; then
    show_error "Unexpected argument '${3}' found"
    exit 1
  fi

  run_package "$1" "$2" || exit 1
  ;;

*)
  show_error "Unexpected argument '${1:-}' found"
  exit 1
  ;;
esac
