#!/bin/bash
# LAST UPDATE: SATURDAY, 03 OCTOBER 2026 01:35 P.M. (UTC)

set -e

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/../config.sh"

# --- ROS2 Version ---
ROS_VERSION="lyrical"
WS_PATH="$HOME/Desktop/ros2_ws"

echo "[1/4] Removing ROS2 packages, Gazebo integration, and extensions..."
sudo apt remove --purge "ros-${ROS_VERSION}-*" -y || true
sudo apt remove --purge "*ros-gz*" "python3-colcon-common-extensions" -y || true
sudo apt autoremove --purge -y

echo "[2/4] Cleaning up shell configurations..."
if [ -n "$ZSH_DIR" ] && [ -f "$ZSH_DIR/.zsh_ros2" ]; then
    rm -f "$ZSH_DIR/.zsh_ros2"
    echo "Removed $ZSH_DIR/.zsh_ros2"
fi

echo "[3/4] Removing ROS2 repository sources and keys..."
sudo dpkg -r ros2-apt-source || true
sudo rm -f /etc/apt/sources.list.d/ros2.list /etc/apt/sources.list.d/ros.list
sudo apt update

echo "[4/4] Verification..."
echo "ROS2 has been successfully uninstalled from system directories."
echo "Your workspace at ${WS_PATH} remains untouched and safe!"
