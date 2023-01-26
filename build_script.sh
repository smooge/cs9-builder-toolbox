#!/bin/bash
#
# This script will try to build a container with appropriate CentOS
# Stream 9 packages. You should have the koji and centpkg installed or
# a configuration for koji which stream will point to accordingly.

ARCH=$(arch)
BUILD_DIR=/home/ssmoogen/CS9-builder-toolbox/

function x86_downloads(){
    if [[ ! -f /usr/bin/koji ]]; then
	echo "Please install koji for this to work. dnf install centpkg"
	exit 2
    fi

    if [[ ! -f /etc/koji.conf.d/stream.conf ]]; then
	echo "Please set up centos stream 9 koji environment."
	echo "dnf install centpkg. Exiting"
	exit 2
    fi

    if [[ ! -f /usr/bin/createrepo ]]; then
	echo "Please install createrepo for this to work."
	exit 2
    fi

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
    createrepo -v .
}


if [[ ! -d ${BUILD_DIR}/x86_pkgs ]]; then
    mkdir -vp ${BUILD_DIR}/x86_pkgs
fi

if [[ ${ARCH} == "x86_64" ]]; then
    pushd ${BUILD_DIR}/x86_pkgs
    x86_downloads
    popd
fi

podman build -t temp1 ${BUILD_DIR}
