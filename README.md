# di-zfs

simple zfs installer for the debian install iso. Simple do sh zfs.sh after network is setup and debootstrap and chroot is installed.

## how does it work?

1) build a temporary debian system with debootstrap

2) chroot into it

3) apt install zfsutils-linux

4) copy the binaries to the real installer and load the zfs kernel module
