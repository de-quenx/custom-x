include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-ttl
PKG_VERSION:=0.0.2
PKG_RELEASE:=25072026

LUCI_TITLE:=LuCI TTL
LUCI_DESCRIPTION:=TTL interface for LuCI with nftables support
LUCI_DEPENDS:=+luci-base
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    /etc/init.d/firewall restart
    rm -f /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    rm -f /etc/nftables.d/ttl67.nft
    /etc/init.d/firewall restart
    rm -f /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
