#!/bin/sh

echo "🛠️ This script was designed to work on OpenWrt 22.03.5 (architecture mipsel_24kc)."
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

echo "🕓 Setting timezone to America/Sao_Paulo..."
uci set system.@system[0].timezone='America/Sao_Paulo'
uci set system.@system[0].zonename='America/Sao_Paulo'
uci commit system
/etc/init.d/system reload

echo "🌍 Adjusting timezone in /etc/config/system file..."
# Update only the 'zonename' option line
sed -i "s|^\(\s*option zonename\).*|\1 'America/Sao Paulo'|" /etc/config/system
# Update only the 'timezone' option line
sed -i "s|^\(\s*option timezone\).*|\1 '<-03>3'|" /etc/config/system

echo "✅ Timezone updated in the configuration file."
/etc/init.d/system reload || echo "ℹ️ Please reboot the system to apply the timezone."

echo "⏰ Synchronizing time with NTP..."
/etc/init.d/sysntpd enable
/etc/init.d/sysntpd restart
sleep 3

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

echo "⬇️ Installing base packages..."
opkg install ipset ipt2socks iptables iptables-legacy

echo "🔧 Installing extra modules for iptables (games/TPROXY)..."
opkg install iptables-mod-conntrack-extra
opkg install iptables-mod-iprange
opkg install iptables-mod-socket
opkg install iptables-mod-tproxy

echo "🌐 Installing full NAT and DNS..."
opkg install kmod-ipt-nat
opkg install dnsmasq-full

echo "🔗 Installing network modules for tunneling..."
opkg install kmod-tun

echo "🎮 Installing PassWall and LuCI interface..."
opkg install luci-app-passwall

rm -f /passwall-install.sh

echo "📥 Downloading xray-core to /tmp..."
wget -O /tmp/xray https://github.com/fleetvpngit/PASSWALL/raw/refs/heads/main/xray-core/xray
chmod +x /tmp/xray

echo "🧹 UPDATING PASSWALL CONFIGURATION FILE..."
rm -f /etc/config/passwall
wget -O /etc/config/passwall https://raw.githubusercontent.com/fleetvpngit/PASSWALL/refs/heads/main/config/passwall
chmod +x /etc/config/passwall

echo "🔁 Enabling autostart..."
/etc/init.d/passwall enable

echo "📦 Installing openssh-sftp-server..."
opkg install openssh-sftp-server

echo "✅ Installation completed successfully! Now go to LuCI → Services → PassWall to configure."
