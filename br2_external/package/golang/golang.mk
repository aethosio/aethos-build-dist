################################################################################
#
# golang
#
################################################################################

GOLANG_VERSION = 1.6.2
GOLANG_SITE = https://storage.googleapis.com/golang
GOLANG_SOURCE = go$(GOLANG_VERSION).src.tar.gz

GOLANG_LICENSE = BSD-3c
GOLANG_LICENSE_FILES = LICENSE

ifeq ($(BR2_arm),y)
GOLANG_GOARCH = arm
ifeq ($(BR2_ARM_CPU_ARMV5),y)
GOLANG_GOARM = 5
else ifeq ($(BR2_ARM_CPU_ARMV6),y)
GOLANG_GOARM = 6
else ifeq ($(BR2_ARM_CPU_ARMV7A),y)
GOLANG_GOARM = 7
endif
else ifeq ($(BR2_aarch64),y)
GOLANG_GOARCH = arm64
else ifeq ($(BR2_i386),y)
GOLANG_GOARCH = 386
else ifeq ($(BR2_x86_64),y)
GOLANG_GOARCH = amd64
else ifeq ($(BR2_powerpc64),y)
GOLANG_GOARCH = ppc64
else ifeq ($(BR2_powerpc64le),y)
GOLANG_GOARCH = ppc64le
endif

GOLANG_ENV = \
	GOROOT_BOOTSTRAP=$(HOST_GO_ROOT) \
	GOROOT="$(@D)" \
	GOBIN="$(@D)/bin/linux_$(GOLANG_GOARCH)" \
	GOARCH=$(GOLANG_GOARCH) \
	$(if $(GOLANG_GOARM),GOARM=$(GOLANG_GOARM)) \
	CC_FOR_TARGET="$(TARGET_CC)" \
	LD_FOR_TARGET="$(TARGET_LD)" \
	CXX_FOR_TARGET="$(TARGET_CXX)" \
	GOOS=linux \
	GO_NO_HOST=1 \
	CGO_ENABLED=$(HOST_GO_CGO_ENABLED) \
	CC=$(HOSTCC_NOCCACHE)

#GOLANG_ENV += GOROOT_FINAL="/usr/lib/go"

GOLANG_DEPENDENCIES = host-go

# Compile with golang cross-capable compiler
# (Does't HOST_GO_ROOT already have a cross compiler?)
# GOLANG = $(HOST_DIR)/usr/bin/go
# GOLANGFMT = $(HOST_DIR)/usr/bin/gofmt

# Environment variables required for the cross compiler.
# GO requires, on minimum, GOOS= and GOARCH= to be set to cross compile.
# This line also adds additional information to allow Go to compile cgo files.
# GOLANG_CROSS_ENV = $(GOLANG_ENV) \
# 	CGO_ENABLED=1 \
# 	CGO_NO_EMULATION=1 \
# 	CGO_CFLAGS='-I$(STAGING_DIR)/usr/include/ -I$(TARGET_DIR)/usr/include -I$(LINUX_HEADERS_DIR)/fs/' \
# 	LDFLAGS="-extld '$(TARGET_CC_NOCCACHE)'" \
# 	CC="$(TARGET_CC_NOCCACHE)" \
# 	LD="$(TARGET_LD)"
#
# # Full line to cross compile with go including env vars.
# GOLANG_CROSS = $(GOLANG_CROSS_ENV) $(GOLANG)

define GOLANG_BUILD_CMDS
	cd $(@D)/src/ && $(GOLANG_ENV) ./make.bash --no-banner
endef

HOST_GO_ENV = \
	GOROOT_BOOTSTRAP=$(HOST_GO_ROOT) \
	GOROOT="$(@D)" \
	GOBIN="$(HOST_GO_ROOT)/bin" \
	GOARCH=$(GOLANG_GOARCH) \
	$(if $(GOLANG_GOARM),GOARM=$(GOLANG_GOARM)) \
	CC_FOR_TARGET="$(TARGET_CC)" \
	LD_FOR_TARGET="$(TARGET_LD)" \
	CXX_FOR_TARGET="$(TARGET_CXX)" \
	GOOS=linux \
	GO_NO_HOST=1 \
	CGO_ENABLED=$(HOST_GO_CGO_ENABLED) \
	CC=$(HOSTCC_NOCCACHE) \
	GOPATH=$(HOST_DIR)/go-work \
	INSTALL=$(INSTALL) \
	GO15VENDOREXPERIMENT=1 \
	HOST_DIR=$(HOST_DIR)

TARGET_GO_PATH = ${TARGET_DIR}/root/go-work

TARGET_GO_ENV = \
	GOROOT_BOOTSTRAP=$(HOST_GO_ROOT) \
	GOROOT="$(@D)" \
	GOBIN=$(TARGET_DIR)/usr/bin/ \
	GOARCH=$(GOLANG_GOARCH) \
	$(if $(GOLANG_GOARM),GOARM=$(GOLANG_GOARM)) \
	CC_FOR_TARGET="$(TARGET_CC)" \
	LD_FOR_TARGET="$(TARGET_LD)" \
	CXX_FOR_TARGET="$(TARGET_CXX)" \
	GOOS=linux \
	GO_NO_HOST=1 \
	CGO_ENABLED=$(HOST_GO_CGO_ENABLED) \
	CC=$(HOSTCC_NOCCACHE) \
	GOPATH=$(TARGET_GO_PATH) \
	INSTALL=$(INSTALL)

# We must install both the src/ and pkg/ subdirs because they
# contain the go "runtime".
#(not used) cp -a $(@D)/include $(TARGET_DIR)/usr/lib/go/
define GOLANG_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/linux_$(GOLANG_GOARCH)/go $(TARGET_DIR)/usr/bin/go
	$(INSTALL) -D -m 0755 $(@D)/bin/linux_$(GOLANG_GOARCH)/gofmt $(TARGET_DIR)/usr/bin/gofmt
	mkdir -p $(TARGET_DIR)/usr/lib/go/
	cp -a $(@D)/src $(TARGET_DIR)/usr/lib/go/
	cp -a $(@D)/pkg $(TARGET_DIR)/usr/lib/go/

	# Set up
	echo $(HOST_GO_ENV) > /root/HOST_GO_ENV
	echo $(TARGET_GO_ENV) > /root/TARGET_GO_ENV
endef

# define HOST_GOLANG_BUILD_CMDS
# 	cd $(@D)/src/ ; \
# 		$(GOLANG_ENV) GOROOT_FINAL="$(HOST_DIR)/usr/lib/go" GO_NO_TARGET=1 \
# 			./make.bash --no-banner
# endef
#
# # We must install both the src/ and include/ subdirs because they
# # contain the go "runtime"
# define HOST_GOLANG_INSTALL_CMDS
# 	$(INSTALL) -D -m 0755 $(@D)/bin/host/go $(HOST_DIR)/usr/bin/go
# 	$(INSTALL) -D -m 0755 $(@D)/bin/host/gofmt $(HOST_DIR)/usr/bin/gofmt
# 	mkdir -p $(HOST_DIR)/usr/lib/go/
# 	cp -a $(@D)/src $(HOST_DIR)/usr/lib/go/
# 	cp -a $(@D)/include $(HOST_DIR)/usr/lib/go/
# 	cp -a $(@D)/pkg $(HOST_DIR)/usr/lib/go/
# endef

$(eval $(generic-package))
# $(eval $(host-generic-package))
