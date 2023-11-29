#!/bin/bash

lsblk
# NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# loop0     7:0    0  63.5M  1 loop /snap/core20/2015
# loop1     7:1    0 111.9M  1 loop /snap/lxd/24322
# loop2     7:2    0  40.9M  1 loop /snap/snapd/20290
# sda       8:0    0    64G  0 disk
# ├─sda1    8:1    0  63.9G  0 part /
# ├─sda14   8:14   0     4M  0 part
# └─sda15   8:15   0   106M  0 part /boot/efi
# sdb       8:16   0   300G  0 disk
# └─sdb1    8:17   0   300G  0 part /mnt
# sdc       8:32   0     2T  0 disk
# sr0      11:0    1  1024M  0 rom

df -h
# /dev/root        62G  3.9G   58G   7% /
# tmpfs           7.8G     0  7.8G   0% /dev/shm
# tmpfs           3.2G  1.1M  3.2G   1% /run
# tmpfs           5.0M     0  5.0M   0% /run/lock
# /dev/sda15      105M  6.1M   99M   6% /boot/efi
# /dev/sdb1       295G   32K  280G   1% /mnt
# tmpfs           1.6G  4.0K  1.6G   1% /run/user/1000
# tmpfs           1.6G  4.0K  1.6G   1% /run/user/10129868

sudo parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs /dev/sdc1
sudo partprobe /dev/sdc1
# meta-data=/dev/sdc1              isize=512    agcount=4, agsize=134217600 blks
#          =                       sectsz=4096  attr=2, projid32bit=1
#          =                       crc=1        finobt=1, sparse=1, rmapbt=0
#          =                       reflink=1    bigtime=0 inobtcount=0
# data     =                       bsize=4096   blocks=536870400, imaxpct=5
#          =                       sunit=0      swidth=0 blks
# naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
# log      =internal log           bsize=4096   blocks=262143, version=2
#          =                       sectsz=4096  sunit=1 blks, lazy-count=1
# realtime =none                   extsz=4096   blocks=0, rtextents=0
# Discarding blocks...Done.

lsblk
# NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# loop0     7:0    0  63.5M  1 loop /snap/core20/2015
# loop1     7:1    0 111.9M  1 loop /snap/lxd/24322
# loop2     7:2    0  40.9M  1 loop /snap/snapd/20290
# sda       8:0    0    64G  0 disk
# ├─sda1    8:1    0  63.9G  0 part /
# ├─sda14   8:14   0     4M  0 part
# └─sda15   8:15   0   106M  0 part /boot/efi
# sdb       8:16   0   300G  0 disk
# └─sdb1    8:17   0   300G  0 part /mnt
# sdc       8:32   0     2T  0 disk
# └─sdc1    8:33   0     2T  0 part
# sr0      11:0    1  1024M  0 rom


sudo mkdir /data
sudo mount /dev/sdc1 /data

lsblk
# NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# loop0     7:0    0  63.5M  1 loop /snap/core20/2015
# loop1     7:1    0 111.9M  1 loop /snap/lxd/24322
# loop2     7:2    0  40.9M  1 loop /snap/snapd/20290
# sda       8:0    0    64G  0 disk
# ├─sda1    8:1    0  63.9G  0 part /
# ├─sda14   8:14   0     4M  0 part
# └─sda15   8:15   0   106M  0 part /boot/efi
# sdb       8:16   0   300G  0 disk
# └─sdb1    8:17   0   300G  0 part /mnt
# sdc       8:32   0     2T  0 disk
# └─sdc1    8:33   0     2T  0 part /data
# sr0      11:0    1  1024M  0 rom

sudo blkid  # to find UUID
# /dev/sdb1: UUID="90311fb0-21a9-4516-b78d-ac7b3df04ec1" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="d2d461a5-01"
# /dev/sda15: LABEL_FATBOOT="UEFI" LABEL="UEFI" UUID="3B41-D64C" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="47a2dfe7-09b5-43c1-b5cd-9ea7aa87fc8d"
# /dev/sda1: LABEL="cloudimg-rootfs" UUID="4f506c69-e474-4bc1-92ef-1000043212ae" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="e215c48d-aff1-4d38-88f8-bd35f90c9fb1"
# /dev/loop1: TYPE="squashfs"
# /dev/loop2: TYPE="squashfs"
# /dev/loop0: TYPE="squashfs"
# /dev/sdc1: UUID="1f0ca19c-a8e4-4c35-ba10-c8b4a963ceda" BLOCK_SIZE="4096" TYPE="xfs" PARTLABEL="xfspart" PARTUUID="443c13f4-ab08-4f05-a401-8713dbaadde5"
# /dev/sda14: PARTUUID="13c861cd-318f-46a5-b1cd-3e6cc3e57338"

sudo vim /ets/fstab # auto mount
# # CLOUD_IMG: This file was created/modified by the Cloud Image build process
# UUID=4f506c69-e474-4bc1-92ef-1000043212ae       /        ext4   discard,errors=remount-ro       0 1
# UUID=3B41-D64C  /boot/efi       vfat    umask=0077      0 1
# /dev/disk/cloud/azure_resource-part1    /mnt    auto    defaults,nofail,x-systemd.requires=cloud-init.service,_netdev,comment=cloudconfig       0       2
# -> NEWLY ADDED: UUID=1f0ca19c-a8e4-4c35-ba10-c8b4a963ceda   /data   xfs   defaults,nofail   1   2
