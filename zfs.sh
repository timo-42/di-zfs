#!/bin/sh
ZFS_ROOT=/tmp/zfs
ARCH=amd64
VERSION=stretch
MIRROR=http://ftp.debian.org/debian/
PATH="$PATH:/usr/sbin"
ZFS_VERSION="0.6.5.9"

mkdir -p $ZFS_ROOT

# install base system
/usr/sbin/debootstrap --components main,contrib --arch $ARCH $VERSION $ZFS_ROOT $MIRROR

# binding stuff
for dir in /dev /dev/pts /proc /sys /run; do mount --bind $dir $ZFS_ROOT/$dir; done 

cat <<EOF >>$ZFS_ROOT/zfs_install.sh
#!/bin/sh
apt-get update
apt-get -y install spl spl-dkms
apt-get -y install zfsutils-linux

#dkms build   -m spl -v $ZFS_VERSION -k $(uname -r)
#dkms install -m spl -v $ZFS_VERSION -k $(uname -r)
#dkms build   -m zfs -v $ZFS_VERSION -k $(uname -r)
#dkms install -m zfs -v $ZFS_VERSION -k $(uname -r)

exit
EOF

# run script which builds zfs kernel module inside chroot
/bin/chmod +x $ZFS_ROOT/zfs_install.sh
/usr/sbin/chroot $ZFS_ROOT /zfs_install.sh

# copy modules from chroot to installer system
cp -r $ZFS_ROOT/lib/modules/$(uname -r)/updates /lib/modules/$(uname -r)
# rebuild kernel module dependency graph
depmod -a
# load zfs kernel module
modprobe zfs

# copy zpool,zfs and their dynamic linked libraries
cp $ZFS_ROOT/sbin/zpool /sbin/
cp $ZFS_ROOT/sbin/zfs   /sbin/

for lib in libnvpair.so.1 libuutil.so.1 libzpool.so.2 libzfs.so.2 libzfs_core.so.1
do
	if [ ! -e /lib/$lib ]
	then
		cp $ZFS_ROOT/lib/$lib /lib
	fi
done

for lib in libblkid.so.1 libuuid.so.1 libz.so.1 libpthread.so.0 librt.so.1 libm.so.6 libdl.so.2
do
	if [ ! -e /lib/x86_64-linux-gnu/$lib ]
	then
		cp $ZFS_ROOT/lib/x86_64-linux-gnu/$lib /lib
	fi
done

# unbinding chroot
for dir in /dev/pts /dev /proc /sys /run; do echo "umount " "$ZFS_ROOT/$dir"; umount "$ZFS_ROOT/$dir"; done
# delete tmp zfs building linux
rm -rf $ZFS_ROOT
