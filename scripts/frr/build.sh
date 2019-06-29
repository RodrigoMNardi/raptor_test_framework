#!/usr/bin/env bash
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "====== Cloning FRR ======"
git clone https://github.com/frrouting/frr.git frr
cd frr

echo "====== Bootstrap ======"
./bootstrap.sh

echo "====== BUILDING FRR ======"
./configure \
    --prefix=/usr \
    --includedir=\${prefix}/include \
    --enable-exampledir=\${prefix}/share/doc/frr/examples \
    --bindir=\${prefix}/bin \
    --sbindir=\${prefix}/lib/frr \
    --libdir=\${prefix}/lib/frr \
    --libexecdir=\${prefix}/lib/frr \
    --localstatedir=/var/run/frr \
    --sysconfdir=/etc/frr \
    --with-moduledir=\${prefix}/lib/frr/modules \
    --with-libyang-pluginsdir=\${prefix}/lib/frr/libyang_plugins \
    --enable-configfile-mask=0640 \
    --enable-logfile-mask=0640 \
    --enable-snmp=agentx \
    --enable-multipath=64 \
    --enable-user=frr \
    --enable-group=frr \
    --enable-vty-group=frrvty \
    --with-pkg-git-version \
    --enable-grpc

echo "====== MAKE FRR ======"
make

echo "====== MAKE INSTALL FRR ======"
sudo make install
