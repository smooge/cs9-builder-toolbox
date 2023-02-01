#!/bin/bash
#
# This script will try to build a container with appropriate CentOS
# Stream 9 packages. You should have the koji and centpkg installed or
# a configuration for koji which stream will point to accordingly.

podman build -t cs9_autosd_devel ${BUILD_DIR}
