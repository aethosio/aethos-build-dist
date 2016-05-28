# aethos-build-dist
AethOS distribution builder

This is a collection of shell scripts used for building an AethOS distribution CD / sdcard image.

## Conventions

In `code` blocks, you'll notice the first line sometimes contains a line like one of these:

```
root@ubuntu:~#
trichards@ubuntu:~/dev$
root@build:/#
```

The first line means that you use a `root` shell on the `host` machine.  The second line means you use a `user` / less privileged shell on the `host` machine.  The third line means you should use a `root` shell attached to the `build` container.

Alternatively, you can use a `user` shell and prefix the commands with `sudo` or `sudo lxc-attach -n build --`.

For example, if the build instructions say do this:
```
root@build:/#
abd build
```
you can do this instead:
```
trichards@ubuntu:~/dev$
sudo lxc-attach -n build -- /root/abd/abd build
```

The commands are equivalent and you don't have to worry about remaining in a root shell all the time, which can be dangerous.

## Build AethOS

These steps will walk you through building an AethOS LiveCD / distribution CD / sdcard using custom BuildRoot scripts.

Assuming you have an Ubuntu installation, the following instructions will help you create your own AethOS distribution CD's and sdcard images.

### Create the build container

Since we use LXC containers within AethOS anyway, it only makes sense to create a container for our build "machine".  This will allow us to install a whole lot of software required for building, then discard it all without messing with our main machine.

```
root@ubuntu:~#
apt install lxc btrfs-tools
```

As a precursor, if you haven't already done so, you should (highly recommended, but not required) create a special partition for your containers formatted using btrfs and mount it at `/var/lib/lxc/`.

Create the partition; here I'm creating it on `/dev/sdb`, which is another drive altogether.  Hopefully you have a spare partition somewhere, or maybe, like me, you're actually running Ubuntu on a virtual machine, which will make it easier for you to add a new virtual hard drive.

```
root@ubuntu:~#
cfdisk /dev/sdb
```

```
root@ubuntu:~#
mkfs.btrfs /dev/sdb1
mount /dev/sdb1 /var/lib/lxc
```

We'll create a container with Ubuntu Xenial 64 bit OS installed. The `-n build` names the container "build"; it's important that you use this container name because other scripts will use this (specifically the lxc-aethos LXC template)

```
root@ubuntu:~#
lxc-create -B btrfs -t download -n build -- -d ubuntu -r xenial -a amd64
```

Alternatively, if you're doing this on an NVidia TK1, use this command for the appropriate architecture.

```
root@ubuntu:~#
lxc-create -B btrfs -t download -n build -- -d ubuntu -r xenial -a armhf
```

You can verify that the brtfs file system was used.
```
root@ubuntu:~#
btrfs sub list /var/lib/lxc/
```

Somewhere, whether it's in your home/dev folder (which is what I do), or somewhere in your root folder, check out this repository using git.

```
trichards@ubuntu:~/dev$
git clone git@github.com:aethosio/aethos-build-dist.git
```
or
```
trichards@ubuntu:~/dev$
git clone https://github.com/aethosio/aethos-build-dist.git
```

Create the environment variable where you checked out the project.

```
root@ubuntu:~#
export ABD_ROOT=/home/trichards/dev/aethos-build-dist
```

Mount it inside the `build` container you just created.

```
root@ubuntu:~#
echo "lxc.mount.entry=$ABD_ROOT root/abd none bind,create=dir" >> /var/lib/lxc/build/config
```

This gives you an example of how you can use your main machine to develop software and use that software inside a container without having to install all of the software necessary for building the software inside of your main machine.  This separation allows you to use software on your main machine that's not compatible with your target machine.

Start the container and attach to it (or, at least start it and you can control it using `lxc-attach -n build -- <command>`).
```
root@ubuntu:~#
lxc-start -n build
lxc-attach -n build
```

Update your build container with software required for the rest of this install.
```
root@build:~#
apt update
apt upgrade
apt install make gcc libncurses5-dev libelf-dev bc busybox grub mkisofs
```

Additional packages:

```
root@build:~#
apt install sed binutils build-essential g++ bash patch gzip bzip2 perl tar cpio python unzip rsync wget cvs git mercurial rsync subversion gcc-multilib
```

### Building AethOS

Now that you've attached to your build container and you've mapped `abd` (AethOS Build Distribution), you can use `abd` to help you build AethOS.

First, add `abd` to your path.
```
root@build:/#
cd /root
export PATH=$PATH:/root/abd
abd -h
```

This `abd` command is a shell script that helps you build AethOS.  When you use the `-h` argument, it will give you a list of command line arguments and commands.

```
abd command

  Available commands:

  initfs      Creates the initfs in /root/initfs
  mkiso       Creates the iso of CD_root
  mkinstall   Create the installation script
  all         Executes all of the buid steps

  Experimental commands:

  build       Executes the buildroot make
  config

  Additional options:

  -h|--help   Displays this help
  -x|--x86_64  Set the architecture to x86_64
  -r|--rpi     Set the architecture to arm/Raspberry Pi
  -t|--tk1     Set the architecture to arm/NVidia TK1
  -f|--full    Set the size to be full
  -m|--min     Set the size to be min

```

### Full vs Min

Before proceeding, lets distinguish between a `full` build and a `min` build.

A `full` build builds everything required to run AethOS, whether it's an image you can use `dd` to create an sdcard image, or an ISO that you can use as a LiveCD, or even .tar files that can be used for creating an LXC container.

A `min` build builds everything required for an Installation medium, which is generally an ISO that also contains a tar file of the `full` build.  In order to create a `min` build, you must first also create a `full` build.  

With this in mind, normally you'll only create a `full` build.  You only need to create a `min` build if you're creating an installation CD/DVD ISO.

### Using ABD

The simplest command is just to do a build.  You can change your configuration, but it's not really recommended that you change anything at this point.

```
root@build~#
abd config
abd build
```

The first time you run this it will download `Buildroot` using git, and then it will do a full build.

`abd` defaults build to `full` and architecture to `x86_64`.

If you wanted to create a boot image for your Raspberry Pi or NVidia TK1 (**note that this has not been fully implemented yet**) you would use one of these commands:

```
root@build:~#
abd build --rpi
```
or
```
root@build:~#
abd build --tk1
```

If you wanted to change the configuration for the Raspberry Pi Linux kernel, you would do something like this:

```
root@build:~#
abd kconfig --rpi
```

## Test AethOS using LXC

If you don't have multiple machines, or if you want to be able to test using an existing machine without screwing it up, you can easily use LXC to test.

Create the environment variable where you checked out the ABD project; you did this earlier, but you might not be using that environment.

```
root@ubuntu:~#
export ABD_ROOT=/home/trichards/dev/aethos-build-dist
```

Create a symbolic link for the LXC template.

```
root@ubuntu:~#
ln -s $ABD_ROOT/lxc/templates/lxc-aethos /usr/share/lxc/templates/lxc-aethos
```

Create the LXC container.  I'm calling mine `nodennn` like `node000` as if I am creating a cluster with up to 1000 nodes, but you can call this container whatever you like.

```
root@ubuntu:~#
lxc-create -B btrfs -t aethos -n node000
```

Next, start the container in forground mode.
```
root@ubuntu:~#
lxc-start -F -n node000
```

And then you can attach to it in another console.
```
root@ubuntu:~#
lxc-attach -n node000
```

## Making an ISO

Once you have AethOS running in some containers, you'll probably want to build an ISO or sdcard image so that you can install AethOS on some of your other machines.

To make an ISO is as simple as doing an `abd build --min` for whatever architecture you're targeting, assuming you've already done a `full` build.

```
root@build:~#
abd build --min
```

This will create an ISO image on your container, but you can access it from your host machine at `/var/lib/lxc/build/rootfs/root/buildroot-x86_64-min-build/images/rootfs.iso9660`.

For me, since my host Linux machine is actually running as a Parallels VM, I can copy the ISO to my Mac.

```
cp /var/lib/lxc/boot/rootfs/root/buildroot-x86_64-min-build/images/rootfs.iso9660 /media/psf/Home/Downloads/buildroot.iso
```

From there I can burn the image or I can just use it to create a new Parallels VM.

## Making a sdcard image

When you do a `full` `rpi` build (or a `tk1` build), the sdcard image is already created.  You can access it from your host machine at `/var/lib/lxc/build/rootfs/root/buildroot-rpi-full-build/images/rootfs.ext2`.

This is an EXT4 file system that is bootable, so you can use `dd` to copy that image to an sdcard, plug the card into your Raspberry Pi or your NVidia Jetson TK1 and boot it up using AethOS.

**Please note that ABD does not fully support rpi and tk1 yet, but I'm committed to supporting these platforms.  I personally have 8 Raspberry Pis and 2 Jetson TK1 computers that need AethOS installed in order for me to complete my home installation of AethOS.**

For now, if you need to use Raspberry Pi or NVidia Jetson TK1 machines, just manually build AethOS on those machines within a container.  It wastes a lot of space since you have a full Ubuntu or Raspian too, but at least it works.

## Further Steps

TODO add information about configuring, using, etc, but that probably should go in a different .md or in a wiki.
