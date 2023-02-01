#!/bin/bash

##
## Flow of build script.
## Determine Environment we are building in
ARCH=$(arch)
BUILD_DIR=/root/x86_pkgs

## Setup core variables
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
vim-enhanced
emacs-nox
"

EPEL_PKGS="
centpkg
createrepo_c
koji
"

## Define functions
function x86_downloads(){
    # Get needed gcc for current published CentOS Stream 9
    GPKG=$( koji -p stream -q list-tagged --latest c9s-candidate gcc | awk '{print $1}' )
    if [[ $? -ne 0 ]]; then
	echo "Something went wrong with determining gcc. Exiting."
	exit 4
    else
	echo "GCC is ${GPKG}"
    fi
    BPKG=$( koji -p stream -q list-tagged --latest c9s-candidate binutils | awk '{print $1}' )
    if [[ $? -ne 0 ]]; then
	echo "Something went wrong with determining binutils. Exiting."
	exit 5
    else
	echo "binutils is ${GPKG}"
    fi
    
    # download gcc from koji
    koji -p stream download-build  --arch=x86_64 --arch=noarch ${GPKG}
    if [[ $? -ne 0 ]]; then
	echo "Something went wrong with download gcc. Exiting."
	exit 6
    fi
    # download binutils from koji
    koji -p stream download-build --arch=x86_64 --arch=noarch ${BPKG}
    if [[ $? -ne 0 ]]; then
	echo "Something went wrong with download gcc. Exiting."
	exit 6
    fi

    # Set up a repository to make it easier to manage
    /usr/bin/createrepo -v .
}

## Upgrade cs9 image to latest items
dnf --assumeyes upgrade
## Enable crb
dnf --assumeyes install dnf-plugins-core 
dnf --assumeyes config-manager --set-enabled crb 
## Install EPEL-9
dnf --assumeyes install epel-release
## Install centpkg and koji from EPEL-9
dnf --assumeyes install ${BASE_PKGS}
dnf --assumeyes install ${EPEL_PKGS}
if [[ $? -ne 0 ]]; then
    echo "Something went wrong with downloading epel packages. Exiting."
    exit 1
fi

# OK time to start working in the container and fixing things
if [[ ${ARCH} == "x86_64" ]]; then
    ## Make cache directory
    if [[ ! -d ${BUILD_DIR} ]]; then
	mkdir -vp ${BUILD_DIR}
    fi
    pushd ${BUILD_DIR}
    x86_downloads
    dnf --assumeyes --nogpgcheck --repofrompath local,${BUILD_DIR} update
    dnf --assumeyes --nogpgcheck --repofrompath local,${BUILD_DIR} install cross*aarch64*
    popd
fi

dnf --assumeyes clean all
