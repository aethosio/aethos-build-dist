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
apt install lxc btrfs-tools
```

We'll create a container with Ubuntu Xenial 64 bit OS installed. The `-n build` names the container "build"; it's important that you use this container name because other scripts will use this (specifically the lxc-aethos LXC template)

```
lxc-create -B btrfs -t download -n build -- -d ubuntu -r xenial -a amd64
```

Alternatively, if you're doing this on an NVidia TK1, use this command for the appropriate architecture.

```
lxc-create -B btrfs -t download -n build -- -d ubuntu -r xenial -a armhf
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

Mount it inside the container.

```
root@ubuntu:~#
echo "lxc.mount.entry=$ABD_ROOT root/abd none bind,create=dir" >> /var/lib/lxc/boot/config
```

This gives you an example of how you can use your main machine to develop software and use that software inside a container without having to install all of the software necessary for building the software inside of your main machine.  This separation allows you to use software on your main machine that's not compatible with your target machine.

Start the container and attach to it (or, at least start it and you can control it using `lxc-attach -n build -- <command>`).
```
root@ubuntu:~#
lxc-start -n build
lxc-attach -n build
```

##

## Test AethOS using LXC

If you don't have multiple machines, or if you want to be able to test using an existing
