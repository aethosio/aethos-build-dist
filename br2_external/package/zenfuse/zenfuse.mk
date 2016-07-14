ZENFUSE_SITE_METHOD = local
ZENFUSE_SITE = /root/dev/zen-fuse

ZENFUSE_DEPENDENCIES = libfuse host-pkgconf zmqpp zeromq

$(eval $(cmake-package))
