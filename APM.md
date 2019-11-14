# AethOS Package Manager

Primarily used with `AethOS Build Dist`, the `AethOS Package Manager` is used for building, creating, and deploying AethOS packages.

## Motivation

The primary motivation for building APM instead of using off the shelf software is simplicity.

AethOS requires multiple sandboxes spread out across a cluster of computers in support of a low number of users.  Containers are started and stopped as users require them (one or more containers for each application / service being used).

Ubuntu Snappy / Core is intended for use with a single user on a single machine with a bunch of containers.

Docker / Kubernetes is intended for use on multiple computers, and although multiple applications are supported, generally all of the applications are started and then scaled according to demand in support of a large number of users.

While we could have adopted any of these technologies, attempting to utilize one of these technologies and making them fit with our requirements exacerbates the level of complexity.

AethOS package manager is less than a thousand lines of fairly simple Bash shell scripts.
