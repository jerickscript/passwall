# Installing PASSWALL + XRAY-CORE on OpenWrt 22.03.05

This script installs PASSWALL and XRAY-CORE on OpenWrt.

Due to insufficient storage, the Xray-Core installation is done in the router's temporary memory. This means the xray file must be placed again in the /tmp folder after every reboot.

---

## Compatible Environment Details

- **OpenWrt Version: 22.03.05
- **Router Model: Xiaomi MI 4A Gigabit
- **Required Storage Space: 8 MB+
- **Required RAM: 128 MB+

---

## Installation Command

Run the following command in your router's terminal to download and install the script:

```sh
cd / && wget -O passwall-install.sh https://raw.githubusercontent.com/jrks1996/passwall/refs/heads/main/passwall-install.sh && chmod +x passwall-install.sh && sh passwall-install.sh
