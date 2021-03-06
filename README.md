# aethos-build-dist

AethOS distribution builder

This is a collection of shell scripts used for building an AethOS distribution CD / sdcard image.

## Conventions

In `code` blocks, you'll notice the first line sometimes contains a line like one of these:

* `root@ubuntu:~#` - use a `root` shell on the `host` machine.
* `trichards@ubuntu:~/dev$` - a `user` / less privileged shell on the `host` machine.  
* `root@build:/#` - use a `root` shell attached to the `build` container.  Alternatively, you can use a `user` shell and prefix the commands with `sudo` or `sudo lxc-attach -n build --`.

For example, if the build instructions say do this:

```bash
root@build:/#
abd build
```

you can do this instead:

```bash
trichards@ubuntu:~/dev$
sudo lxc-attach -n build -- /root/abd/abd build
```

The commands are equivalent and you don't have to worry about remaining in a root shell all the time, which can be dangerous.

## Installation

Prerequisites are Ubuntu, LXC and unionfs and the contents of this repository.

```bash
root@ubuntu:~#
apt install git lxc unionfs-fuse
```

As a precursor, if you haven't already done so, you should (highly recommended, but not required) create a partition for your containers and mount it at `/var/lib/lxc/`.

You might want to add the `aethos-build-dist` to your path so that you can execute the included shell scripts; if not then you'll have to modify these instructions to include that path for `apm`, `abd`, and `config_aethos_lxc.sh`.

Somewhere, whether it's in your home/dev folder (which is what I do), or somewhere in your root folder, check out this repository using git.

```bash
trichards@ubuntu:~/dev$
git clone git@github.com:aethosio/aethos-build-dist.git
```

or

```bash
trichards@ubuntu:~/dev$
git clone https://github.com/aethosio/aethos-build-dist.git
```

Create the environment variable where you checked out the project.

```bash
root@ubuntu:~#
export ABD_ROOT=/home/trichards/dev/aethos-build-dist
```

Next, copy or set up a symbolic link for `lxc-aethos` (see `config_aethos_lxc.sh`).

## Build AethOS

These steps will walk you through building an AethOS LiveCD / distribution CD / sdcard using custom BuildRoot scripts.

Assuming you have an Ubuntu installation, the following instructions will help you create your own AethOS distribution CD's and sdcard images.

### Create the buildroot container

Since we use LXC containers within AethOS anyway, it only makes sense to create a container for our build "machine".  This will allow us to install a whole lot of software required for building, then discard it all without messing with our main machine.

```bash
trichards@ubuntu:~#
apm create buildroot
```

This gives you an example of how you can use your main machine to develop software and use that software inside a container without having to install all of the software necessary for building the software inside of your main machine.  This separation allows you to use software on your main machine that's not compatible with your target machine.

Start the container and attach to it (or, at least start it and you can control it using `lxc-attach -n build -- <command>`).

***Note: You must be root and you must manually mount and unmount the file systems.  Until a workaround is found, this is true of all APM LXC containers that use unionfs-fuse.***

```bash
root@ubuntu:~#
/var/lib/lxc/buildroot/mount-buildroot.sh
lxc-start -n buildroot
lxc-attach -n buildroot
```

On non-ARM host platforms, install grub.

```bash
root@buildroot:~#
apt install grub2-common
```

### Building AethOS

Now that you've attached to your build container and you've mapped `abd` (AethOS Build Distribution), you can use `abd` to help you build AethOS.

First, add `abd` to your path.

```bash
root@buildroot:/#
cd /root
export PATH=$PATH:/root/abd
abd -h
```

This `abd` command is a shell script that helps you build AethOS.  When you use the `-h` argument, it will give you a list of command line arguments and commands.

```bash
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

```bash
root@build~#
abd config
abd build
```

The first time you run this it will download `Buildroot` using git, and then it will do a full build.

`abd` defaults build to `full` and architecture to `x86_64`.

If you wanted to create a boot image for your Raspberry Pi or NVidia TK1 (**note that this has not been fully implemented yet**) you would use one of these commands:

```bash
root@buildroot:~#
abd build --rpi
```

or

```bash
root@buildroot:~#
abd build --tk1
```

If you wanted to change the configuration for the Raspberry Pi Linux kernel, you would do something like this:

```bash
root@buildroot:~#
abd kconfig --rpi
```

## Test AethOS using LXC

If you don't have multiple machines, or if you want to be able to test using an existing machine without screwing it up, you can easily use LXC to test.

### Configure LXC for AethOS

Create the environment variable where you checked out the ABD project; you did this earlier, but you might not be using that environment.

```bash
root@ubuntu:~#
export ABD_ROOT=/home/trichards/dev/aethos-build-dist
```

Create a symbolic link for the LXC template. (this is also in config-lxc.sh)

```bash
root@ubuntu:~#
ln -s $ABD_ROOT/lxc/templates/lxc-aethos /usr/share/lxc/templates/lxc-aethos
```

### Create the LXC container

This step shows you how to create an LXC container by copying the previously built AethOS root.  The advantage of this method is that you can have multiple versions of AethOS running at the same time that you're building a new version.

I'm calling mine `nodennn` like `node000` as if I am creating a cluster with up to 1000 nodes, but you can call this container whatever you like.

```bash
root@ubuntu:~#
lxc-create -B btrfs -t aethos -n node000
```

Next, start the container in foreground mode.

```bash
root@ubuntu:~#
lxc-start -F -n node000
```

And then you can attach to it in another console.

```bash
root@ubuntu:~#
lxc-attach -n node000
```

### Create LXC Container with OverlayFS

Alternatively, you can use less disk space if you use an `OverlayFS` with the ext2 file output from `abd`.

In addition to using less disk space, the host machine will cache the underlying root filesystem using the same cache for all containers, so you'll get some additional performance using less memory.

This disadvantage of this method is that you must shut down all running containers before building a new version of AethOS root, and all running versions will always be the same (most recently built) version of AethOS.

`lxc-create` will automatically use an `OverlayFS` mount if you first create an `aethos/rootfs` in `/var/lib/lxc` and then mount the `.ext2` root filesystem. (look at `copy_aethos.sh` for an example).

```bash
root@ubuntu:~#
mkdir -p /var/lib/lxc/aethos/rootfs
cp /var/lib/lxc/buildroot/rootfs/root/buildroot-x86_64-full-build/images/rootfs.ext2 /var/lib/lxc/aethos
mount /var/lib/lxc/aethos/rootfs.ext2 /var/lib/lxc/aethos/rootfs
```

Remember that this mount isn't permanent unless you add it to `fstab`, and remember that you must stop all of the `aethos` containers before copying / mounting a new version of the `rootfs.ext2` file.

When creating a new container using the `OverlayFS`, don't specify the `btrfs` file system:

```bash
root@ubuntu:~#
lxc-create -t aethos -n node000
```

## Making an ISO

Once you have AethOS running in some containers, you'll probably want to build an ISO or sdcard image so that you can install AethOS on some of your other machines.

To make an ISO is as simple as doing an `abd build --min` for whatever architecture you're targeting, assuming you've already done a `full` build.

```bash
root@buildroot:~#
abd build --min
```

This will create an ISO image on your container, but you can access it from your host machine at `/var/lib/lxc/buildroot/rootfs/root/buildroot-x86_64-min-build/images/rootfs.iso9660`.

For me, since my host Linux machine is actually running as a Parallels VM, I can copy the ISO to my Mac.

```bash
cp /var/lib/lxc/buildroot/rootfs/root/buildroot-x86_64-min-build/images/rootfs.iso9660 /media/psf/Home/Downloads/buildroot.iso
```

From there I can burn the image or I can just use it to create a new Parallels VM.

## Making a sdcard image

When you do a `full` `rpi` build (or a `tk1` build), the sdcard image is already created.  You can access it from your host machine at `/var/lib/lxc/buildroot/rootfs/root/buildroot-rpi-full-build/images/rootfs.ext2`.

This is an EXT4 file system that is bootable, so you can use `dd` to copy that image to an sdcard, plug the card into your Raspberry Pi or your NVidia Jetson TK1 and boot it up into AethOS.

## Further Steps

TODO add information about configuring, using, etc, but that probably should go in a different .md or in a wiki.
