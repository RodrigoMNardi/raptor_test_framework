#!/usr/bin/env bash
sudo apt update
sudo apt-get install \
   git autoconf automake libtool make libreadline-dev texinfo \
   pkg-config libpam0g-dev libjson-c-dev bison flex python3-pytest \
   libc-ares-dev python3-dev libsystemd-dev python-ipaddress python3-sphinx \
   install-info build-essential libsystemd-dev libsnmp-dev perl

wget https://ci1.netdef.org/artifact/LIBYANG-YANGRELEASE/shared/build-10/Debian-AMD64-Packages/libyang0.16_0.16.105-1_amd64.deb
sudo dpkg -i libyang0.16_0.16.105-1_amd64.deb

wget https://ci1.netdef.org/artifact/LIBYANG-YANGRELEASE/shared/build-10/Debian-AMD64-Packages/libyang-dev_0.16.105-1_amd64.deb
sudo dpkg -i libyang-dev_0.16.105-1_amd64.deb

sudo apt-get -f install

sudo apt-get install protobuf-c-compiler libprotobuf-c-dev
sudo apt-get install libzmq5 libzmq3-dev

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 \
                         --slave /usr/bin/g++ g++ /usr/bin/g++-7
sudo update-alternatives --config gcc

echo "====== GCC VERSION (Expected > 7.0) ======"
gcc --version
echo "====== G++ VERSION (Expected > 7.0) ======"
g++ --version
