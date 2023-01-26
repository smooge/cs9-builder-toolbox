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
ADD  x86_pkgs /root/x86_pkgs
COPY build_container.sh /root/
RUN /root/build_container.sh

VOLUME /opt/home
VOLUME /opt/cs9_aarch64
