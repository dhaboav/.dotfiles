#!/usr/bin/env bash
# Last updated: TUESDAY, 10 NOVEMBER 2026 04:19 P.M. (UTC)

# === Text styles ===
RESET=$'\033[0m'
BOLD=$'\033[1m'
BOLD_UNDERLINE=$'\033[1;4m'

# === Colors ===
YELLOW=$'\033[33m'
RED=$'\033[31m'
GREEN=$'\033[32m'
BOLD_RED=$'\033[1;31m'

# === Utility functions ===
info_label() {
  echo "${YELLOW}info:${RESET} $1"
}

success_label() {
  echo "${GREEN}success:${RESET} $1"
}

error_label() {
  echo "${RED}error:${RESET} $1" >&2
}
