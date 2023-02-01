ARG RELEASE=stream9
FROM quay.io/centos/centos:$RELEASE

ENV NAME=autosd-cross-developer-toolbox
MAINTAINER "Stephen Smoogen <ssmoogen@redhat.com>"

LABEL com.github.containers.toolbox="true" \
      org.centos.component="$NAME" \
      name="$NAME" \
      version="$RELEASE" \
      usage="This image is meant to allow cross compiler using CentOS Stream 9"\
      summary="Container image for autosd cross development" \
      maintainer="$MAINTAINER"

# Install the Red Hat certificate authority and the packages needed for
# development on CentOS Stream and RHEL

COPY build_container.sh /root/
RUN /root/build_container.sh

# Use this to mount your home 
VOLUME /home
# Use this to mount an image built of cs9
VOLUME /opt/cs9_aarch64
