#!/usr/bin/env bash

#Install ChromiumOS touchpad driver for linux chroot (crouton) on Acer C720P (Peppy) Chromebook. 
#This makes the touchpad behave and respond like it does in ChromeOS.
#See: https://github.com/hugegreenbug/xf86-input-cmt/issues/6
#I posted a note about this script in: https://groups.google.com/forum/#!topic/crouton-central/claM9XZxsz0
#and https://github.com/dnschneid/crouton/wiki/Acer-C720-C720P#touchpad

#After creating/installing this driver, look at:
#https://github.com/hugegreenbug/xf86-input-cmt#notes

############################################################
# Build and install X11 ChromiumOS touchpad driver for linux
############################################################

pushd .

# First install jsoncpp, xutils-dev and xserver-xorg-dev
# which are dependencies of libgestures and the X11 ChromiumOS
# touchpad driver.
sudo apt-get update
echo
echo "*** Install libjsoncpp-dev xutils-dev libtool xserver-xorg-dev xinput"
sudo apt-get install -y libjsoncpp-dev xutils-dev libtool xserver-xorg-dev xinput
## Note: libgtest-dev is also required for libgesture tests
sudo apt-get install -y libgtest-dev

# Next, build and install libgestures which is a dependency for X11 ChromiumOS
# touchpad driver
if [ ! -d ~/src/libgestures ]; then
  echo
  echo "*** Getting src for ChromiumOS libgestures modified to compile for Linux"
  mkdir ~/src
  cd ~/src
  git clone https://github.com/hugegreenbug/libgestures.git
  echo
  echo "*** Building ChromiumOS libgestures for linux"
  cd ~/src/libgestures
  ./apply_patches.sh
  make
  echo
  echo "*** Now installing ChromiumOS libgestures for linux"
  sudo make install
fi

# Next, build and install libevdevc which is another dependency for X11
# ChromiumOS touchpad driver
if [ ! -d ~/src/libevdevc ]; then
  echo
  echo "*** Getting src for ChromiumOS libevdevc"
  mkdir ~/src
  cd ~/src
  git clone https://github.com/hugegreenbug/libevdevc.git
  echo
  echo "*** Building ChromiumOS libevdevc for linux"
  cd ~/src/libevdevc
  make
  echo
  echo "*** Now installing ChromiumOS libevdevc for linux"
  sudo make install
fi

# Finally, build and install X11 ChromiumOS touchpad driver
if [ ! -d ~/src/xf86-input-cmt ]; then
  echo
  echo "*** Getting src for X11 ChromiumOS touchpad driver ported to Linux"
  mkdir ~/src
  cd ~/src
  git clone https://github.com/hugegreenbug/xf86-input-cmt.git
  echo
  echo "*** Building X11 ChromiumOS touchpad driver"
  cd ~/src/xf86-input-cmt
  ./apply_patches.sh
  sh ./autogen.sh
  ./configure --prefix=/usr
  make
  sudo make install
  echo "*** Rename old configuration file for synaptics trackpad driver"
  if [ -e /usr/share/X11/xorg.conf.d/50-synaptics.conf  ]; then
    sudo mv /usr/share/X11/xorg.conf.d/50-synaptics.conf /usr/share/X11/xorg.conf.d/50-synaptics.conf.old
  fi
  echo "*** Copy configuration files for mouse, touchscreen and touchpad"
  if [ ! -e /usr/share/X11/xorg.conf.d/20-mouse.conf ]; then
    sudo cp ~/src/xf86-input-cmt/xorg-conf/20-mouse.conf /usr/share/X11/xorg.conf.d
  fi
  #if [ ! -e /usr/share/X11/xorg.conf.d/20-touchscreen.conf ]; then
  # sudo cp ~/src/xf86-input-cmt/xorg-conf/20-touchscreen.conf /usr/share/X11/xorg.conf.d
  #fi
  if [ ! -e /usr/share/X11/xorg.conf.d/40-touchpad-cmt.conf ]; then
    sudo cp ~/src/xf86-input-cmt/xorg-conf/40-touchpad-cmt.conf /usr/share/X11/xorg.conf.d
  fi
  if [ ! -e /usr/share/X11/xorg.conf.d/50-touchpad-cmt-peppy.conf ]; then
    sudo cp ~/src/xf86-input-cmt/xorg-conf/50-touchpad-cmt-peppy.conf /usr/share/X11/xorg.conf.d
  fi
fi

# echo "*** Now removing src for libgestures"
# rm -rf ~/src/libgestures
# echo "*** Now removing src for libevdevc"
# rm -rf ~/src/libevdevc
# echo "*** Now removing src for xf86-input-cmt"
# rm -rf ~/src/xf86-input-cmt

popd
