This is a nifty little device for under £100 suitable for a home router.

I am using one running OpenBSD 6.x for my AAISP PPPoE connection (avoiding the supplied VMG1312-B10A which has a number of issues).

## Installation

I bought a [SanDisk 16GB USB stick](https://www.amazon.co.uk/gp/product/B07MDXBT87) as there were reports the supplied USB stick isn't particularly reliable, plus it's nice to keep it separate in case of backup or selling the device in the future.

Download the OpenBSD `miniroot68.img` file system and `dd(1)` it, for example on macOS (assuming `/dev/disk2`):

```console
$ diskutil unmountDisk /dev/disk2
$ dd if=miniroot68.img of=/dev/rdisk2 bs=1m
```

Install the system according to the excellent INSTALL.octeon file, this is a log of my current install which I will eventually move to an unattended file.

Connect over serial:

```console
$ cu -s 115200 -l /dev/cu.usbserial
```

Boot the USB stick:

```console
Octeon ubnt_e100# fatload usb 0 $loadaddr bsd.rd
Octeon ubnt_e100# bootoctlinux
```

Install answers.  Brief notes:

* Single file system, it's not going to compile stuff and this is much simpler.
* It's my router, so no default gateway, and sets via local NFS rather than HTTP.
* Don't install X11.

```
Terminal type? [vt220]
System hostname? (short form, e.g. 'foo') router

Which network interface do you wish to configure? (or 'done') [cnmac0]
IPv4 address for cnmac0? (or 'dhcp' or 'none') [dhcp] 192.168.1.5
Netmask for cnmac0? [255.255.255.0]
IPv6 address for cnmac0? (or 'autoconf' or 'none') [none]
Which network interface do you wish to configure? (or 'done') [done]
Default IPv4 route? (IPv4 address or none) none
DNS domain name? (e.g. 'example.com') [my.domain] home.perkin.org.uk
DNS nameservers? (IP address list or 'none') [none] 192.168.1.5

Start sshd(8) by default? [yes]
Setup a user? (enter a lower-case loginname, or 'no') [no] jperkin
Full name for user jperkin? [jperkin] Jonathan Perkin
Allow root ssh login? (yes, no, prohibit-password) [no] 

Which disk is the root disk? ('?' for details) [sd0]
Use (W)hole disk or (E)dit the MBR? [whole]
Use (A)uto layout, (E)dit auto layout, or create (C)ustom layout? [a] c

sd0> p
OpenBSD area: 65600-31260672; size: 31195072; free: 0
#                size           offset  fstype [fsize bsize   cpg]
  a:         30152640            65600  4.2BSD   2048 16384 12960
  b:          1042432         30218240    swap
  c:         31260672                0  unused
  i:            65536               64   MSDOS

sd0> m a
offset: [65600]
size: [30152640]
FS type: [4.2BSD]
mount point: [none] /

sd0> p
OpenBSD area: 65600-31260672; size: 31195072; free: 0
#                size           offset  fstype [fsize bsize   cpg]
  a:         30152640            65600  4.2BSD   2048 16384 12960 # /
  b:          1042432         30218240    swap
  c:         31260672                0  unused
  i:            65536               64   MSDOS

sd0> q
No label changes.
/dev/rsd0a: 14723.0MB in 30152640 sectors of 512 bytes
73 cylinder groups of 202.50MB, 12960 blocks, 25920 inodes each
/dev/sd0a (0f721dabcb6ec9fa.a) on /mnt type ffs (rw, asynchronous, local)

Location of sets? (disk http nfs or 'done') [http] nfs
Server IP address or hostname? 192.168.1.10
Filesystem on server to mount? /nfs/archive
Use TCP transport? (requires TCP-capable NFS server) [no] yes
Pathname to the sets? (or 'done') [6.x/octeon] OS/OpenBSD/6.x

Set name(s)? (or 'abort' or 'done') [done] -x*
Set name(s)? (or 'abort' or 'done') [done]
Location of sets? (disk http nfs or 'done') [done]

What timezone are you in? ('?' for list) [Canada/Mountain] Europe/London

Exit to (S)hell, (H)alt or (R)eboot? [reboot]
```

### Bootloader

After installation configure U-boot with the following:

```
ubnt_e100# setenv old_bootcmd "${bootcmd}"
ubnt_e100# setenv bootcmd 'usb reset; fatload usb 0 ${loadaddr} boot; bootoctlinux rootdev=sd0 numcores=2'
ubnt_e100# setenv bootdelay 5
ubnt_e100# saveenv
ubnt_e100# reset
```

## Configuration

Post-install configuration of the device is as follows.

### Disable default daemons

I explicitly don't want to configure IPv6 on my local network (AAISP are probably the best ISP for providing IPv6 but I still don't want to use it until all the niggles have been fixed, plus it's one less thing to worry about).

I also have no need for a sound server on this device.

```console
$ rcctl stop slaacd sndiod
$ rcctl disable slaacd sndiod
```

### PPPoE

This is hooked up via the `cnmac2` interface to a HG612 modem.  Configuration is trivial:

```console
$ echo "net.inet.ip.forwarding=1" >/etc/sysctl.conf

$ echo "up" >/etc/hostname.cnmac2

$ vi /etc/hostname.pppoe0
```

```
inet 0.0.0.0 255.255.255.255 NONE \
        mtu 1492 \
        pppoedev cnmac2 \
        authproto chap \
        authname 'myusername' \
        authkey 'mypassword' \
        peerproto chap \
        peerflag callin \
        up
dest 0.0.0.1
!/sbin/route add default -ifp pppoe 0.0.0.1
```

### NTP

Run a local NTP service, and use AAISP's time servers.

```console
$ vi /etc/ntpd.conf
```

```
listen on 192.168.1.5
servers time.aa.net.uk

# comment out the defaults
#servers pool.ntp.org
#server time.cloudflare.com
#sensor *
```

ntpd(8) no longer supports the `-s` flag to immediately set the time, and the EdgeRouter Lite has no battery backed clock, so in order to get the time to be correct after boot we need to add an rdate(8) to `/etc/rc.local`.

This isn't ideal, and I don't know why they removed `-s`, but this will have to do for now - I can't wait days for the time to be correct after every reboot.

```console
$ vi /etc/rc.local
```

```bash
#/bin/sh

# Set time on boot to help NTP sync quickly.
rdate time.aa.net.uk
```

### PF

XXX I'll paste my config when I have some time to explain it.  It performs NAT, and some queuing and filtering for kids.

### Unbound

I run a few different unbound(8) instances:

* The main one uses an adblock list
* An unfiltered one is for when we can't use an adblocker (e.g. All4)
* A couple of different ones for kids (school time, leisure time).

Each has their own config file and port, and then PF is used to redirect clients DNS.  Individual rc.d(8) instances are set up for each, for example:

```console
$ ln -s /etc/rc.d/unbound /etc/rc.d/unbound_unfiltered
$ touch /var/unbound/query-unfiltered.log
$ chown _unbound:_unbound /var/unbound/query-unfiltered.log
$ rcctl enable unbound_unfiltered
$ rcctl set unbound_unfiltered flags "-c /var/unbound/etc/unbound-unfiltered.conf"
$ rcctl start unbound_unfiltered
unbound_unfiltered(ok)
$ pgrep -fl unbound
17682 unbound -c /var/unbound/etc/unbound-unfiltered.conf
```

### DHCP

Just a bog-standard DHCP instance, probably not worth documenting.

```console
$ vi /etc/dhcpd.conf
$ rcctl enable dhcpd
```

### Grafana

I generate some grafana stats:

* PF stats via `pfctl -vs queue` piped to awk.
* DSL stats via `netstat -bi -I pppoe0`.
* AAISP quota via `curl -sL https://quota.aa.net.uk`.
* HG612 modem stats via an expect(1) script running `xdslcmd info --stats` piped to awk.


@author: https://gist.github.com/jperkin/6e10825120973e8a61df1aada89a0b38