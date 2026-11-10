#!/bin/bash
# LAST UPDATE: WEDNESDAY, 15 JULY 2026 06:43 A.M. (UTC)

set -e

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/../config.sh"

echo "[Master] Starting full terminal setup..."

if ! command -v zsh &> /dev/null; then
  echo "[Master] Installing zsh..."
  sudo apt update && sudo apt install zsh -y
fi

if [[ "$SHELL" != *"zsh" ]]; then
  echo "[Master] Setting zsh as default shell..."
  chsh -s $(which zsh)
fi

# Fonts and Starship
echo "[Master] Installing Fonts and Starship..."
sudo apt install starship
mkdir -p ~/.config
ln -sf "$(realpath "$SCRIPT_DIR/../config/starship.toml")" ~/.config/starship.toml

source "$SCRIPT_DIR/setup_plugins.sh"
ln -sf "$(realpath "$SCRIPT_DIR/../home/.zshrc")" ~/.zshrc

echo "[Master] Setup complete."
echo "IMPORTANT: Please log out and log back in for the shell change to take effect!"
