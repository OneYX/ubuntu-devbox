#!/bin/sh

# replace sources with aliyun mirrors
sed -i -e 's/\(us\.\)\?archive.ubuntu.com\|security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# for install sogoupinyin
mkdir -p /etc/apt/sources.list.d
touch /etc/apt/sources.list.d/sogoupinyin.list
sh -c "echo 'deb http://archive.ubuntukylin.com:10006/ubuntukylin xenial main' >> /etc/apt/sources.list.d/sogoupinyin.list"

# change zoneinfo to Shanghai
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# add ppa to system's Software Sources
add-apt-repository -y ppa:webupd8team/java
add-apt-repository -y ppa:gnome3-team/gnome3
add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make

# update the system
apt-get update
apt-get upgrade

################################################################################
# Install the mandatory tools
################################################################################

export LANGUAGE='zh_CN.UTF-8'
export LANG='zh_CN.UTF-8'
export LC_ALL='zh_CN.UTF-8'
locale-gen zh_CN.UTF-8
dpkg-reconfigure locales

# install utilities
apt-get -y install vim git zip bzip2 fontconfig curl language-pack-en language-pack-zh-hans language-pack-zh-hans-base language-pack-gnome-zh-hans language-pack-gnome-zh-hans-base

# install sogoupinyin
apt-get -y --allow-unauthenticated install sogoupinyin

# install Java 8
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y install oracle-java8-installer

################################################################################
# Install the graphical environment
################################################################################

# force encoding
echo 'LANG=zh_CN.UTF-8' >> /etc/environment
echo 'LANGUAGE=zh_CN.UTF-8' >> /etc/environment
echo 'LC_ALL=zh_CN.UTF-8' >> /etc/environment
echo 'LC_CTYPE=zh_CN.UTF-8' >> /etc/environment

# run GUI as non-privileged user
echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config

# install Ubuntu desktop and VirtualBox guest tools
apt-get install -y gnome-shell ubuntu-gnome-desktop virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11

################################################################################
# Install the development tools
################################################################################

# install Ubuntu Make - see https://wiki.ubuntu.com/ubuntu-make
apt install -y ubuntu-make

# install Chromium Browser
apt-get install -y chromium-browser

# install MySQL Workbench
apt-get install -y mysql-workbench

# install Guake
apt-get install -y guake
cp /usr/share/applications/guake.desktop /etc/xdg/autostart/

# install zsh
apt-get install -y zsh

# install oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh
cp /home/vagrant/.oh-my-zsh/templates/zshrc.zsh-template /home/vagrant/.zshrc
chsh -s /bin/zsh vagrant
echo 'SHELL=/bin/zsh' >> /etc/environment

# change user to vagrant
chown -R vagrant:vagrant /home/vagrant/.zshrc /home/vagrant/.oh-my-zsh

# install Visual Studio Code
su -c 'umake ide visual-studio-code /home/vagrant/.local/share/umake/ide/visual-studio-code --accept-license' vagrant

# fix links (see https://github.com/ubuntu/ubuntu-make/issues/343)
sed -i -e 's/visual-studio-code\/code/visual-studio-code\/bin\/code/' /home/vagrant/.local/share/applications/visual-studio-code.desktop

# disable GPU (see https://code.visualstudio.com/docs/supporting/faq#_vs-code-main-window-is-blank)
sed -i -e 's/"$CLI" "$@"/"$CLI" "--disable-gpu" "$@"/' /home/vagrant/.local/share/umake/ide/visual-studio-code/bin/code

#install IDEA
su -c 'umake ide idea /home/vagrant/.local/share/umake/ide/idea-ultimate' vagrant

# increase Inotify limit (see https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit)
echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/60-inotify.conf
sysctl -p --system

# fix ownership of home
chown -R vagrant:vagrant /home/vagrant/

# clean the box
apt-get -y autoclean
apt-get -y clean
apt-get -y autoremove
dd if=/dev/zero of=/EMPTY bs=1M > /dev/null 2>&1
rm -f /EMPTY
