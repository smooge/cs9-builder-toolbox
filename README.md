# CentOS Stream 9 Developer Pod

The end goal of this project is to create CentOS Stream 9 containers
with a working cross-architecture development environment. These can
then be used on another operating system directly to build, test, and
publish software which should be compatible with the CentOS Automobile
Software Development (CentOS AUTOSD).

## Build instructions

In order to build this container, you will need a working CentOS Stream
9 aarch64 and x86_64 environment. These systems will need to have the
packages `centpkg` and `podman` installed:

``` bash
$ sudo dnf install centpkg podman
$ git clone <<this project>>
$ podman build -t cs9-$(arch) CS9-builder-toolbox
```

