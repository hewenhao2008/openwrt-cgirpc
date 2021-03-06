##############################################
# OpenWrt Makefile for cgi-rpc program
#
#
# Most of the variables used here are defined in
# the include directives below. We just need to
# specify a basic description of the package,
# where to build our program, where to find
# the source files, and where to install the
# compiled program on the router.
#
# Be very careful of spacing in this file.
# Indents should be tabs, not spaces, and
# there should be no trailing whitespace in
# lines that are not commented.
#
##############################################

include $(TOPDIR)/rules.mk

# Name and release number of this package
PKG_NAME:=cgi-rpc
PKG_VERSION:=1.0.0
PKG_RELEASE:=1


# This specifies the directory where we're going to build the program. 
# The root build directory, $(BUILD_DIR), is by default the build_mipsel
# directory in your OpenWrt SDK directory
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)


include $(INCLUDE_DIR)/package.mk

 

# Specify package information for this program.
# The variables defined here should be self explanatory.
# If you are running Kamikaze, delete the DESCRIPTION
# variable below and uncomment the Kamikaze define
# directive for the description below
define Package/$(PKG_NAME)
        SECTION:=utils
        CATEGORY:=Utilities
        DEPENDS:=+uhttpd +jshn +netifd +minidlna +samba36-server +qos-scripts +blkid +iwinfo +xxd
        TITLE:=CGI RPC interface of router
endef


# Uncomment portion below for Kamikaze and delete DESCRIPTION variable above
define Package/$(PKG_NAME)/description
        Remote config interface of router over http protocol,
        transacted by CGI and formatted in JSON.
endef


define Package/$(PKG_NAME)/conffiles
/etc/config/cgirpc
/etc/config/clientlist
endef
 

# Specify what needs to be done to prepare for building the package.
# In our case, we need to copy the source files to the build directory.
# This is NOT the default.  The default uses the PKG_SOURCE_URL and the
# PKG_SOURCE which is not defined here to download the source from the web.
# In order to just build a simple program that we have just written, it is
# much easier to do it this way.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef


# We do not need to define Build/Configure or Build/Compile directives
# The defaults are appropriate for compiling a simple program such as this one
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	$(TARGET_CONFIGURE_OPTS) CFLAGS="$(TARGET_CFLAGS) -I$(LINUX_DIR)/include"
endef

# Specify where and how to install the program. Since we only have one file,
# the cgi-rpc executable, install it by copying it to the /bin directory on
# the router. The $(1) variable represents the root directory on the router running
# OpenWrt. The $(INSTALL_DIR) variable contains a command to prepare the install
# directory if it does not already exist.  Likewise $(INSTALL_BIN) contains the
# command to copy the binary file from its current location (in our case the build
# directory) to the install directory.
#define Package/cgi-rpc/install
#	$(INSTALL_DIR) $(1)/bin
#	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cgi-rpc $(1)/bin/
#endef
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/cgi-rpc
	$(CP) ./files/rpc-func $(1)/usr/lib/cgi-rpc
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) ./files/common-func/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/cgirpc.config $(1)/etc/config/cgirpc
	$(CP) ./files/clientlist.config $(1)/etc/config/clientlist
	$(CP) ./files/blocklist.config $(1)/etc/config/blocklist
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(CP) ./files/cgi-rpc $(1)/www/cgi-bin/cgi-rpc
	$(INSTALL_DIR) $(1)/etc/crontabs
	touch $(1)/etc/crontabs/root
	sed -i '/syncclientlist/d' $(1)/etc/crontabs/root
	cat ./files/cgirpc.cron >> $(1)/etc/crontabs/root
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
rm -rf $(1)/usr/lib/cgi-rpc
sed -i '/syncclientlist/d' $(1)/etc/crontabs/root
endef

# This line executes the necessary commands to compile our program.
# The above define directives specify all the information needed, but this
# line calls BuildPackage which in turn actually uses this information to
# build a package.
$(eval $(call BuildPackage,cgi-rpc))
