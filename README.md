# di-zfs

simple zfs installer for the debian install iso. Simple do sh zfs.sh after network is setup and debootstrap and chroot is installed.

## how does it work?

build a temporary debian system with debootstrap
chroot into it
apt install zfsutils-linux
copy the binaries to the real installer and load the zfs kernel module
