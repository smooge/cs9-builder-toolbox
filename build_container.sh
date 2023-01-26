#!/bin/bash

ARCH=$( arch )

BASE_PKGS="
bash
binutils
bzip2
cmake
cpio 
dwz 
elfutils 
elfutils-devel
file 
gcc 
gcc-c++ 
gdb 
git-core 
glibc-devel 
kernel-devel 
libstdc++-devel 
libxcrypt-devel 
libzstd-devel 
meson
rpm-build 
unzip 
util-linux 
xz 
xz-devel 
zip 
zlib-devel 
"

# OK time to start working in the container and fixing things
dnf --assumeyes upgrade
dnf --assumeyes install dnf-plugins-core 
dnf --assumeyes config-manager --set-enabled crb 
dnf --assumeyes install ${BASE_PKGS}
# we only need to install the cross architecture stuff on x86_64
if [[ ${ARCH} == "x86_64" ]]; then
    cd /root/x86_pkgs/
    dnf --assumeyes localinstall ./cross*aarch64*rpm
else
    echo ${ARCH}
fi
dnf --assumeyes clean all
