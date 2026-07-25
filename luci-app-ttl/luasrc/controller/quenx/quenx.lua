module("luci.controller.quenx.quenx", package.seeall)

function index()
    entry({"admin", "network", "quenx"}, call("render_page"), _("Fix TTL"), 100).leaf = true
end

function get_current_ttl()
    local output = luci.sys.exec("nft list chain inet fw4 mangle_postrouting_ttl67 2>/dev/null")
    if output and output:match("ip ttl set (%d+)") then
        return tonumber(output:match("ip ttl set (%d+)"))
    end
    return nil
end

function is_ttl_enabled()
    local output = luci.sys.exec("nft list chain inet fw4 mangle_postrouting_ttl67 2>/dev/null")
    return output and output:match("ip ttl set") ~= nil
end

function set_ttl(new_ttl)
    local ttl_file = "/etc/nftables.d/ttl67.nft"
    local ttl_rule = string.format([[
chain mangle_postrouting_ttl67 {
    type filter hook postrouting priority 300; policy accept;
    counter ip ttl set %d
}
chain mangle_prerouting_ttl67 {
    type filter hook prerouting priority 300; policy accept;
    counter ip ttl set %d
}
]], new_ttl, new_ttl)

    local f = io.open(ttl_file, "w")
    if f then
        f:write(ttl_rule)
        f:close()
    end

    luci.sys.call("/etc/init.d/firewall restart")
end

function disable_ttl()
    local ttl_file = "/etc/nftables.d/ttl67.nft"
    luci.sys.call("nft delete chain inet fw4 mangle_postrouting_ttl67 2>/dev/null")
    luci.sys.call("nft delete chain inet fw4 mangle_prerouting_ttl67 2>/dev/null")
    local f = io.open(ttl_file, "w")
    if f then f:write("") f:close() end
    luci.sys.call("/etc/init.d/firewall restart")
end

function enable_ttl(ttl_value)
    ttl_value = ttl_value or 65
    set_ttl(ttl_value)
end

function render_page()
    local http = require "luci.http"
    local sys = require "luci.sys"
    local tpl = require "luci.template"
    local current_ttl = get_current_ttl()
    local ttl_enabled = is_ttl_enabled()
    local action = http.formvalue("action")
    local ttl_value = http.formvalue("ttl_value")
    
    if action == "set_ttl" and ttl_value then
        ttl_value = tonumber(ttl_value)
        if ttl_value and ttl_value >= 1 and ttl_value <= 255 then
            set_ttl(ttl_value)
            current_ttl = ttl_value
            ttl_enabled = true
        end
    elseif action == "disable_ttl" then
        disable_ttl()
        current_ttl = nil
        ttl_enabled = false
    elseif action == "enable_ttl" then
        local enable_ttl_value = tonumber(ttl_value) or current_ttl or 65
        enable_ttl(enable_ttl_value)
        current_ttl = enable_ttl_value
        ttl_enabled = true
    end

    tpl.render("quenx/page", {
        current_ttl = current_ttl or "N/A",
        ttl_value = ttl_value or current_ttl or 65,
        ttl_enabled = ttl_enabled
    })
end
