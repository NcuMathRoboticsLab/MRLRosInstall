#!/bin/bash

echo ""
echo "[Note] OS version  >>> Ubuntu 24.04 (Noble Numbat)"
echo "[Note] Target ROS  >>> ROS 2 Jazzy Jalisco (ros-base / No-GUI)"
echo "[Note] Target Bot  >>> TurtleBot3 (Default: burger)"
echo "[Note] Workspace   >>> $HOME/colcon_ws"
echo ""
echo "PRESS [ENTER] TO CONTINUE THE INSTALLATION"
echo "IF YOU WANT TO CANCEL, PRESS [CTRL] + [C]"
read -r

echo "[1/8] Set the target ROS version and name of colcon workspace..."
ros_version=${ros_version:="jazzy"}
colcon_workspace=${colcon_workspace:="colcon_ws"}
tb3_model=${tb3_model:="burger"}

echo "[2/8] Set Locale..."
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo "[3/8] Setup ROS 2 Sources..."
sudo rm -rf /var/lib/apt/lists/* && sudo apt update && sudo apt install -y curl gnupg2 lsb-release git build-essential
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null'

echo "[4/8] Install ROS 2 Headless packages..."
sudo apt update && sudo apt install -y \
  ros-$ros_version-ros-base \
  ros-$ros_version-joy \
  ros-$ros_version-teleop-twist-joy \
  ros-$ros_version-teleop-twist-keyboard \
  ros-$ros_version-laser-proc \
  ros-$ros_version-urdf \
  ros-$ros_version-xacro \
  ros-$ros_version-compressed-image-transport \
  ros-$ros_version-dynamixel-sdk \
  python3-rosdep \
  python3-vcstool \
  python3-argcomplete \
  python3-colcon-common-extensions

echo "[5/8] Make the colcon workspace & Clone TurtleBot3 repos..."
source /opt/ros/$ros_version/setup.bash
mkdir -p "$HOME/$colcon_workspace/src" && cd "$HOME/$colcon_workspace/src" || exit
git clone -b jazzy https://github.com/ROBOTIS-GIT/DynamixelSDK.git
git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git

echo "[6/8] Install ROS dependencies via rosdep..."
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update
cd "$HOME/$colcon_workspace" || exit
rosdep install -y --from-paths src --ignore-src --rosdistro "$ros_version"

echo "[7/8] Build colcon workspace..."
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "[8/8] Configure environment variables and aliases..."
TARGET_SHELL="bash"
TARGET_SHELL_RC="$HOME/.bashrc"
{
    echo "alias eb='vim ~/.bashrc'"
    echo "alias nb='nano ~/.bashrc'"
    echo "alias sb='source ~/.bashrc'"
    echo ""
    echo "alias cw='cd ~/$colcon_workspace'"
    echo "alias cs='cd ~/$colcon_workspace/src'"
    echo "alias cb='cd ~/$colcon_workspace && colcon build --symlink-install && source ~/.bashrc'"
    echo ""
    echo "source /opt/ros/$ros_version/setup.bash"
    echo "[ -f ~/$colcon_workspace/install/setup.bash ] && source ~/$colcon_workspace/install/setup.bash"
    echo ""
    echo "export ROS_DOMAIN_ID=30 # 0~101"
    echo "export ROS_LOCALHOST_ONLY=0"
    echo "export TURTLEBOT3_MODEL=$tb3_model # burger, waffle, waffle_pi"
} >> "$HOME/.bashrc"

echo ""
echo "[Complete!] ROS 2 Jazzy (Headless) installed."
echo "Please restart your SSH session or run: source $HOME/.bashrc"

exit 0
