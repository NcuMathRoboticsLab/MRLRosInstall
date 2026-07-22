#!/bin/bash

echo ""
echo "[Note] OS version  >>> Ubuntu 24.04 (Noble Numbat)"
echo "[Note] Target ROS version >>> ROS 2 Jazzy Jalisco"
echo "[Note] Colcon workspace   >>> $HOME/colcon_ws"
echo ""
echo "PRESS [ENTER] TO CONTINUE THE INSTALLATION"
echo "IF YOU WANT TO CANCEL, PRESS [CTRL] + [C]"
read

echo "[1/8] Set the target ROS version and name of colcon workspace..."
ros_version=${ros_version:="jazzy"}
colcon_workspace=${colcon_workspace:="colcon_ws"}

echo "[2/8] Set Locale..."
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo "[3/8] Setup ROS 2 Sources..."
sudo apt install -y build-essential curl git lsb-release software-properties-common && sudo add-apt-repository universe
ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

echo "[4/8] Install ROS 2 packages"
sudo apt update && sudo apt install -y ros-$ros_version-desktop \
  ros-$ros_version-joy ros-$ros_version-teleop-twist-joy \
  ros-$ros_version-teleop-twist-keyboard ros-$ros_version-laser-proc \
  ros-$ros_version-urdf ros-$ros_version-xacro ros-$ros_version-rqt* \
  ros-$ros_version-compressed-image-transport ros-$ros_version-rviz2 \
  ros-$ros_version-navigation2 ros-$ros_version-slam-toolbox \
  ros-$ros_version-interactive-markers ros-$ros_version-dynamixel-sdk \
  ros-$ros_version-cartographer ros-$ros_version-cartographer-ros \
  ros-$ros_version-nav2-bringup ros-$ros_version-ros-gz \
  ros-$ros_version-turtlesim python3-rosdep python3-vcstool \
  python3-argcomplete python3-colcon-common-extensions

echo "[5/8] Make the colcon workspace & Clone repos..."
source /opt/ros/$ros_version/setup.bash
mkdir -p "$HOME/$colcon_workspace/src" && cd "$HOME/$colcon_workspace/src" || exit
git clone -b jazzy https://github.com/NcuMathRoboticsLab/mrlrobot_sample_code.git
mkdir -p $HOME/$colcon_workspace/src/turtlebot3 && cd $HOME/$colcon_workspace/src/turtlebot3 || exit
git clone -b jazzy https://github.com/ROBOTIS-GIT/DynamixelSDK.git
git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git
git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git
git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

echo "[6/8] Install ROS dependencies"
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update
cd $HOME/$colcon_workspace
rosdep install -y --from-paths src --ignore-src --rosdistro $ros_version

echo "[7/8] Build colcon workspace..."
colcon build --symlink-install

echo "[8/8] Configure environment variables and aliases..."
TARGET_SHELL="bash"
TARGET_SHELL_RC="$HOME/.bashrc"

if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    TARGET_SHELL_RC="$HOME/.zshrc"
fi

{
    echo ""
    echo "alias cw='cd ~/$colcon_workspace'"
    echo "alias cs='cd ~/$colcon_workspace/src'"
    echo "alias cb='cd ~/$colcon_workspace && colcon build --symlink-install && source $TARGET_SHELL_RC'"
    echo ""
    echo "source /opt/ros/$ros_version/setup.$TARGET_SHELL"
    echo "[ -f ~/$colcon_workspace/install/setup.$TARGET_SHELL ] && source ~/$colcon_workspace/install/setup.$TARGET_SHELL"
    echo ""
    echo "export ROS_DOMAIN_ID=30 # 0~101"
    echo "export ROS_LOCALHOST_ONLY=0"
} >> "$TARGET_SHELL_RC"

echo "[Complete!!!] ROS 2 Jazzy environment installed."
echo "Please restart the terminal or run source $TARGET_SHELL_RC"

exec bash
exit 0
