ZENSPACES_SITE_METHOD = local
ZENSPACES_SITE = /root/dev/zen-spaces

ZENSPACES_DEPENDENCIES = leveldb host-pkgconf
# Additional dependencies? snappy

$(eval $(cmake-package))
