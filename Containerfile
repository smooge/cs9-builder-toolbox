ARG RELEASE=stream9
FROM quay.io/centos/centos:$RELEASE

ENV NAME=autosd-cross-developer-toolbox
MAINTAINER "Stephen Smoogen <ssmoogen@redhat.com>"

LABEL com.github.containers.toolbox="true" \
      com.gitlab.sgallagher.toolbox="true" \
      com.redhat.component="$NAME" \
      name="$NAME" \
      version="$RELEASE" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Container image for autosd cross development" \
      maintainer="$MAINTAINER"

# Install the Red Hat certificate authority and the packages needed for
# development on CentOS Stream and RHEL
RUN dnf --assumeyes upgrade \
 && dnf --assumeyes install dnf-plugins-core \
 && dnf --assumeyes config-manager --set-enabled crb \
# && dnf --assumeyes groupinstall --with-optional 'Development Tools' \
# && dnf --assumeyes install epel-release \
 && dnf --assumeyes install bash binutils bzip2 cmake cpio elfutils file dwz gcc gcc-c++ gdb git-core rpm-build unzip zip xz util-linux meson \
 && dnf --assumeyes install kernel-devel glibc-devel libstdc++-devel xz-devel zlib-devel libzstd-devel libxcrypt-devel elfutils-devel \
 && dnf --assumeyes install https://kojihub.stream.centos.org/kojifiles/packages/binutils/2.35.2/35.el9/x86_64/cross-binutils-aarch64-2.35.2-35.el9.x86_64.rpm https://kojihub.stream.centos.org/kojifiles/packages/gcc/11.3.1/4.3.el9/x86_64/cross-gcc-aarch64-11.3.1-4.3.el9.x86_64.rpm https://kojihub.stream.centos.org/kojifiles/packages/gcc/11.3.1/4.3.el9/x86_64/cross-gcc-c++-aarch64-11.3.1-4.3.el9.x86_64.rpm \
 && ( dnf --assumeyes --installroot /opt/cs9-aarch64 --forcearch=aarch64 --releasever=9 install kernel-devel glibc-devel libstdc++-devel xz-devel zlib-devel libzstd-devel libxcrypt-devel elfutils-devel || true ) \
 && dnf --assumeyes clean all

VOLUME /opt/home
