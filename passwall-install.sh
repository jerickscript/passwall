#!/bin/sh

echo "🛠️ This script was designed to work on OpenWrt 22.03 (architecture mipsel_24kc)."
echo "- Installs PassWall and packages in OpenWrt internal storage"
echo "- Installs Xray-core in temporary memory (/tmp)"
echo

read -p "❓ Do you want to install PassWall and Xray? (Y/N): " response

# Convert response to lowercase
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

if [ "$response" != "y" ]; then
    echo "❌ Installation cancelled by the user."
    exit 0
fi


echo "📝 Disabling signature check in opkg.conf..."
sed -i 's/^option check_signature/#option check_signature/' /etc/opkg.conf

echo "➕ Adding PassWall repositories..."
cat <<EOF >> /etc/opkg/customfeeds.conf

# PassWall Repositories (mipsel_24kc for OpenWrt 22.03)
src/gz passwall_luci http://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-22.03/mipsel_24kc/passwall_luci
src/gz passwall_packages http://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-22.03/mipsel_24kc/passwall_packages
src/gz passwall2 http://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-22.03/mipsel_24kc/passwall2
EOF

echo "🔄 Updating package list..."
opkg update

echo "🧹 Removing default dnsmasq..."
opkg remove dnsmasq
opkg install dnsmasq-full

echo "⬇️ Installing base packages..."
opkg install ipset ipt2socks iptables iptables-legacy

echo "🔧 Installing extra modules for iptables (games/TPROXY)..."
opkg install iptables-mod-conntrack-extra
opkg install iptables-mod-iprange
opkg install iptables-mod-socket
opkg install iptables-mod-tproxy

echo "🌐 Installing full NAT and DNS..."
opkg install kmod-ipt-nat

echo "🔗 Installing network modules for tunneling..."
opkg install kmod-tun

echo "🎮 Installing PassWall and LuCI interface..."
opkg install luci-app-passwall

echo "📥 Downloading xray-core to /tmp..."
wget -O /tmp/xray https://github.com/jerickscript/passwall/raw/refs/heads/main/xray-core/xray
chmod +x /tmp/xray

echo "🧹 UPDATING PASSWALL CONFIGURATION FILE..."
rm -f /etc/config/passwall
wget -O /etc/config/passwall https://raw.githubusercontent.com/jerickscript/passwall/refs/heads/main/config/passwall
chmod +x /etc/config/passwall

echo "🔁 Enabling autostart..."
/etc/init.d/passwall enable

rm -f /passwall-install.sh

echo "✅ Installation completed successfully! Now go to LuCI → Services → PassWall to configure."
