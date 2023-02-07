# CentOS Stream 9 Developer Pod

The end goal of this project is to create CentOS Stream 9 containers
with a working cross-architecture development environment. These can
then be used on another operating system directly to build, test, and
publish software which should be compatible with the CentOS Automobile
Software Development (CentOS AUTOSD).

## Build instructions

In order to build this container, you will need a working CentOS Stream
9 aarch64 and x86_64 environment. These systems will need to have the
packages `centpkg` and `podman` installed. You will then be able to
build the requisite container images.

``` bash
$ sudo dnf install centpkg podman
$ git clone <<this project>>
$ podman build -t cs9-$(arch) CS9-builder-toolbox
```

For setup and creation of the images, I am pushing these to
quay.io. These instructions should be similar for the repository you are
going to use. On the aarch64 system I then did:

``` bash
$ podman push localhost/cs9_autosd_devel \
  quay.io/smooge_fedora/cs9_autosd_development:aarch64
```

On the x86_64 system, 

``` bash
$ podman push 
  localhost/cs9_autosd_devel \
  quay.io/smooge_fedora/cs9_autosd_development:x86_64
```

On either system, you can then connect the images together with a
manifest:

``` bash
$ podman manifest create \
  quay.io/smooge_fedora/cs9_autosd_development:latest \
  quay.io/smooge_fedora/cs9_autosd_development:x86_64 \
  quay.io/smooge_fedora/cs9_autosd_development:aarch64
$ podman manifest push \
  smooge_fedora/cs9_autosd_development:latest \
  quay.io/smooge_fedora/cs9_autosd_development:latest
```

At this point, it is time to get the two containers to work together. On
the aarch64 system, I created a temporary container and then exported
its contents to a tar file as follows:

``` bash
$ podman create --name cs9_aarch64_20220201 localhost/cs9_autosd_devel:latest bash
$ podman export -o cs9_aarch64.tar cs9_aarch64_20220201
```

On the x86_64 system I am planning to do cross compilation, I then use
podman to pull down the x86_64 container and copy over the tar file. I
then create a volume and import the aarch64 tar ball into it.

``` bash
$ podman volume create cs9_aarch64
$ podman volume import cs9_aarch64 ~/cs9_aarch64.tar
```

We can now create a running container connecting up a temporary home
directory for file storage with /home and the aarch64 volume as /opt/cs

``` bash
$ podman run -v cs9_aarch64:/opt/cs9_aarch64 \
  -v temp_cs:/home:Z -ti --rm \
  localhost/cs9_autosd_devel:latest bash
[root@5802be112c87 /]# ls
afs  bin  boot  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
[root@5802be112c87 /]# cd home/
[root@5802be112c87 home]# ls
RPM-QA_0  RPM-QA_1  RPM-QA_2  RPM-QA_3  a.out  hello  hello.c  hello_old
[root@5802be112c87 home]# cat hello.c
#include <stdio.h>

int main(){
printf("Hello World!\n");
return(0);
}
[root@5802be112c87 home]# export CC="/usr/bin/aarch64-redhat-linux-gcc --sysroot=/opt/cs9_aarch64/"
[root@5802be112c87 home]# make hello
/usr/bin/aarch64-redhat-linux-gcc --sysroot=/opt/cs9_aarch64/     hello.c   -o hello
[root@5802be112c87 home]# file hello
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=4f156d64629d8f8c960ea416466067be19a4ce87, for GNU/Linux 3.7.0, not stripped

```

At this po9int we have a minimal build set with a linked set. We can
copy this over to a running aarch64 system and get:

``` bash
$ uname -a
Linux ip-172-31-8-184.us-east-2.compute.internal 5.14.0-239.el9.aarch64 #1 SMP PREEMPT_DYNAMIC Thu Jan 19 14:22:16 UTC 2023 aarch64 aarch64 aarch64 GNU/Linux
$ ./hello 
Hello World!
$ file hello 
hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, BuildID[sha1]=4f156d64629d8f8c960ea416466067be19a4ce87, for GNU/Linux 3.7.0, not stripped

```
