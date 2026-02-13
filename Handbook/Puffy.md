# Personal Handbook v6.5

```
           _.-|-/\-._
         \-'          '-.
        /    /\    /\    \/          _____                 ____   _____ _____
      \/  <    .  >  ./.  \/        / ___ \               |  _ \ / ____|  __ \
  _   /  <         > /___\ |.      / /  / /___  ___  ____ | |_) | (___ | |  | |
.< \ /  <     /\    > ( #) |#)    / /  / / __ \/ _ \/ __ \|  _ < \___ \| |  | |
  | |    <       /\   -.   __\   / /__/ / /_/ /  __/ / / /| |_) |____) | |__| |
   \   <  <   V      > )./_._(\  \_____/ .___/\___/_/ /_/ |____/|_____/|_____/
  .)/\   <  <  .-     /  \_'_) )-..   /_/
      \  <   ./  /  > >       /._./
      /\   <  '-' >    >    /
        '-._ < v    >   _.-'
          / '-.______.-' \
                 \/
```

**Basic Guide, solve problems, reminders and others**

---

## Content

- 00.0 – Basic installation (After create install media)
- 01.0 – Installation with xfce4
- 02.0 – Networking using DHCP
- 03.0 – Firmware
- 04.0 – Wireless connection
- 05.0 – Enable and configure doas
- 06.0 – Packages
- 07.0 – Minimal Web Server (Httpd or Apache2)
- 08.0 – Simple firewalling with packet filter

---

## Notes

- `*` = Information  
- `<<text>>` = Topic Information  
- `<text>` = Commits  
- `text` = Commands  

---

## 00.0 – Basic Installation (After create install media)

Select (I)nstall option after boot.

---

## 01.0 – Installation with xfce4

**Root login**
```sh
su -
password
```

**Add your regular user to wheel group**
```sh
usermod -G wheel username
```

**Install nano text editor**
```sh
pkg_add nano
```

### Desktop Environment

**Install Xfce, slim, xscreensaver**
```sh
pkg_add xfce xfce-extras slim slim-themes xscreensaver
```

**Edit root .xinitrc**
```sh
nano .xinitrc
# add:
exec startxfce4
```

**Edit user .xinitrc**
```sh
nano /home/youruser/.xinitrc
# add:
exec startxfce4
```

**Edit rc.local**
```sh
nano /etc/rc.local
# add:
 /usr/local/bin/slim -d
```

**Edit rc.conf.local**
```sh
nano /etc/rc.conf.local
# add:
pkg_scripts="dbus_daemon avahi_daemon"
dbus_enable=YES
```

**Install basic applications**
```sh
pkg_add <package>
```

**Reboot**
```sh
reboot
```

---

## 02.0 – Networking using DHCP

**Show interfaces**
```sh
ifconfig
```

**Enable interface**
```sh
ifconfig <interface> up
```

**Set DHCP**
```sh
dhclient <interface>
```

**Persist DHCP**
```sh
echo "dhcp" >> /etc/hostname.<interface>
```

**Example (athn0)**
```sh
ifconfig athn0 up
dhclient athn0
```

---

## 03.0 – Firmware (non-free)

```sh
fw_update -a
```

> Installs all available firmware automatically.

---

## 04.0 – Wireless connection

```sh
ifconfig
ifconfig <interface> up
ifconfig <interface> nwid <SSID> wpakey <WPA_PASSWORD>
```

**Example**
```sh
ifconfig athn0
ifconfig athn0 nwid SSID wpakey 4lf4num3r1c0
```

**Permanent config**
```conf
# /etc/hostname.<interface>
nwid MIRED
wpakey 4lf3num3r1c0
dhcp
```

---

## 05.0 – Enable and configure doas

```conf
# /etc/doas.conf
permit persist setenv { PKG_CACHE PKG_PATH } <username> cmd pkg_add
permit setenv { -ENV PS1=$DOAS_PS1 SSH_AUTH_SOCK } :wheel
permit nopass <username> as root cmd /usr/sbin/procmap
permit nopass keepenv root as root
```

```sh
usermod -G wheel youruser
```

---

## 06.0 – Packages

```sh
export PKG_PATH="http://openbsd.c3sl.ufpr.br/pub/OpenBSD/6.5/packages/amd64/"
doas pkg_add <packagename>
doas pkg_delete <packagename>
doas pkg_info
```

---

## 07.0 – Minimal Web Server (HTTPD / Apache2)

### Apache
```sh
doas pkg_add apache-httpd
doas rcctl start apache2
```

### MariaDB
```sh
doas pkg_add mariadb-server
mysql_install_db
mysql_secure_installation
doas rcctl start mysqld
```

### PHP
```sh
doas pkg_add php php-mysql
ln -sf /var/www/conf/modules.sample/php-5.2.conf /var/www/conf/modules/php.conf
ln -sf /etc/php-5.2.sample/mysql.ini /etc/php-5.2/mysql.ini
```

```sh
doas pkg_add phpMyAdmin  # optional
```

```php
<?php phpinfo(); ?>
```

---

## 08.0 – Simple firewalling with packet filter

```conf
# /etc/pf.conf
pass out quick on athn0 proto tcp to port 22
pass out quick on athn0 proto udp to port 53
pass out quick on athn0 proto tcp to port 80
pass out quick on athn0 proto tcp to port 443
block out all
block in all
```

```sh
doas pfctl -f /etc/pf.conf
```

---