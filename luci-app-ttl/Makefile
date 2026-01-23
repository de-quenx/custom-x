include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-ttl
PKG_VERSION:=0.0.1
PKG_RELEASE:=23012026

LUCI_TITLE:=LuCI TTL
LUCI_DESCRIPTION:=TTL for LuCI
LUCI_DEPENDS:=+luci-base 
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,$(PKG_NAME)))