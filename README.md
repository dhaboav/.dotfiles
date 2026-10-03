# dotfiles

Automated Linux (Ubuntu distro) setup scripts and configurations.

## 🛠 Directory Overview

`config/` Contains files mapped to the system `~/.config/` directory.

`home/` Contains files mapped to the system `~/` directory (e.g., .zshrc).

`scripts/` Automation scripts to configure environment.

`config.sh`: Centralized environment variables and shared configurations.

## 🚀 Getting Started

- Prerequisites

  Ensure scripts have execution permissions before running them:
  ```bash
  chmod +x scripts/*.sh
  ```

- Installation

  To perform a full terminal and environment setup, run the master installation script:
  ```bash
  ./scripts/install_zsh.sh
  ```
  > Note: You may need to log out and log back in for changes (such as the default shell) to take effect.

## 📋 Available Scripts

| Script | Description |
|--------|-------------|
| `install_font.sh`   | Installs required fonts (e.g., JetBrainsMono Nerd Font).    |
| `install_ros2.sh`   | Installs ROS 2 and initializes your development workspace.  |
| `install_zsh.sh`    | Sets up Zsh, Starship, and links core configurations.       |
| `setup_plugins.sh`  | Automatically clones and manages your Zsh plugins.          |  
| `uninstall_ros2.sh` | Uninstalls ROS 2 packages and dependencies.                 |
