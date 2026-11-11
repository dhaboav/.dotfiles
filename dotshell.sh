#!/usr/bin/env bash

VERSION="1.0.0"

#  === Directories ===
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/packages"
source "$SCRIPT_DIR/lib/utils.sh" || exit 1

#  === Utility functions ===
read_metadata() {
  local file="$1"
  local key value

  PACKAGE_NAME=""
  PACKAGE_DESCRIPTION=""

  while IFS='=' read -r key value || [[ -n "$key" ]]; do
    value="${value%$'\r'}"

    case "$key" in
    PACKAGE_NAME)
      PACKAGE_NAME="$value"
      ;;
    PACKAGE_DESCRIPTION)
      PACKAGE_DESCRIPTION="$value"
      ;;
    esac
  done <"$file"
}

run_package() {
  local action="$1"
  local package="$2"
  local file name package_file

  for file in "$PACKAGE_DIR"/*/metadata; do
    [[ -f "$file" ]] || continue

    read_metadata "$file"
    name="${PACKAGE_NAME:-}"

    if [[ "${name,,}" == "${package,,}" ]]; then
      package_file="${file%/metadata}/package.sh"

      [[ -f "$package_file" ]] || {
        show_error "Package script for '$package' not found"
        return 1
      }

      (
        source "$package_file" || {
          show_error "Failed to load package '$package'"
          exit 1
        }

        if ! declare -F "$action" >/dev/null; then
          show_error "Package '$name' does not support '$action'"
          exit 1
        fi

        "$action"
      )

      return $?
    fi
  done

  show_error "Package '$package' not found"
  echo ""
  show_packages
  return 1
}

#  === Core functions ===
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
  ${BOLD}-L, --list${RESET}     Print available packages

EOF
}

show_error() {
  cat >&2 <<EOF
${BOLD_RED}error:${RESET} $1

${BOLD_UNDERLINE}Usage:${RESET} <COMMAND> [PACKAGE]

For more information, try '${BOLD}--help${RESET}'.
EOF
}

show_packages() {
  local file package name description

  echo "${BOLD_UNDERLINE}Packages:${RESET}"

  for file in "$PACKAGE_DIR"/*/metadata; do
    [[ -f "$file" ]] || continue

    package="${file%/metadata}"
    package="${package##*/}"

    read_metadata "$file"

    name="${PACKAGE_NAME:-$package}"
    description="${PACKAGE_DESCRIPTION:-No description available.}"

    printf "  ${BOLD}%-13s${RESET} %s\n" "$name" "$description"
  done
}

#  === Main entry point ===
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
