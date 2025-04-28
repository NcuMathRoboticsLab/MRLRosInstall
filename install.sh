#!/bin/bash

echo ""
echo "[Note] OS version  >>> Ubuntu 24.04 (Noble Numbat)"
echo "[Note] Target ROS version >>> ROS 2 Jazzy Jalisco"
echo "[Note] Colcon workspace   >>> $HOME/colcon_ws"
echo ""
echo "PRESS [ENTER] TO CONTINUE THE INSTALLATION"
echo "IF YOU WANT TO CANCEL, PRESS [CTRL] + [C]"
read

echo "[Set the target ROS version and name of colcon workspace]"
ros_version=${ros_version:="jazzy"}
colcon_workspace=${colcon_workspace:="colcon_ws"}

echo "[Set Locale]"
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo "[Setup Sources]"
sudo rm -rf /var/lib/apt/lists/* && sudo apt update && sudo apt install -y curl gnupg2 lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null'

echo "[Install ROS 2 packages]"
sudo apt update && sudo apt install -y ros-$ros_version-desktop \
  ros-$ros_version-joy ros-$ros_version-teleop-twist-joy \
  ros-$ros_version-teleop-twist-keyboard ros-$ros_version-laser-proc \
  ros-$ros_version-urdf ros-$ros_version-xacro ros-$ros_version-rqt* \
  ros-$ros_version-compressed-image-transport ros-$ros_version-rviz2 \
  ros-$ros_version-navigation2 ros-$ros_version-slam-toolbox \
  ros-$ros_version-interactive-markers ros-$ros_version-dynamixel-sdk \
  ros-$ros_version-cartographer ros-$ros_version-cartographer-ros \
  ros-$ros_version-nav2-bringup ros-$ros_version-ros-gz \
  ros-$ros_version-turtlesim

echo "[Environment setup]"
source /opt/ros/$ros_version/setup.sh
sudo apt install -y python3-argcomplete python3-colcon-common-extensions python3-vcstool python3-rosdep git

# echo "[Install dependencies]"
# sudo rosdep init && rosdep update
# cd $HOME/$colcon_workspace
# rosdep install -y --from-paths src --ignore-src --rosdistro $ros_version

echo "[Make the colcon workspace and test colcon build]"
mkdir -p $HOME/$colcon_workspace/src
cd $HOME/$colcon_workspace/src
cd $HOME/$colcon_workspace
colcon build --symlink-install

echo "[Set the ROS evironment]"
sh -c "echo \"\" >> ~/.bashrc"
sh -c "echo \"alias eb='vim ~/.bashrc'\" >> ~/.bashrc"
sh -c "echo \"alias nb='nano ~/.bashrc'\" >> ~/.bashrc"
sh -c "echo \"alias sb='source ~/.bashrc'\" >> ~/.bashrc"
sh -c "echo \"alias gs='git status'\" >> ~/.bashrc"
sh -c "echo \"alias gp='git pull'\" >> ~/.bashrc"

sh -c "echo \"\" >> ~/.bashrc"
sh -c "echo \"alias cw='cd ~/$colcon_workspace'\" >> ~/.bashrc"
sh -c "echo \"alias cs='cd ~/$colcon_workspace/src'\" >> ~/.bashrc"
sh -c "echo \"alias cb='cd ~/$colcon_workspace && colcon build --symlink-install && source ~/.bashrc'\" >> ~/.bashrc"

sh -c "echo \"\" >> ~/.bashrc"
sh -c "echo \"source /opt/ros/$ros_version/setup.bash\" >> ~/.bashrc"
sh -c "echo \"source ~/$colcon_workspace/install/setup.bash\" >> ~/.bashrc"

sh -c "echo \"export ROS_DOMAIN_ID=30 # 0~101\" >> ~/.bashrc"

source ~/.bashrc

echo "[Complete!!!]"

exec bash
exit 0
