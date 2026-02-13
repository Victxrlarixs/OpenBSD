# OpenBSD VMM (How to) 

## Setup

/etc/rc.conf.local
```
apmd_flags="-A"
dhcpd_flags=vether0
vmd_flags=
ntpd_flags="-s"
```

/etc/hostname.vether0
```
inet 192.168.30.1 255.255.255.0 NONE
```

/etc/dhcpd.conf
```
# Network:        192.168.11.0/255.255.255.0
# Domain name:    vmm.home.ctors.net
# Name servers:   192.168.11.1
# Default router: 192.168.11.1
# Addresses:      192.168.30.100 - 192.168.30.200

shared-network VMM-HOME-CTORS-NET {
    subnet 192.168.30.0 netmask 255.255.255.0 {
        range 192.168.30.100 192.168.30.200;

        option subnet-mask 255.255.255.0;
        option broadcast-address 192.168.30.255;
        option routers 192.168.30.1;
        option domain-name-servers 192.168.11.1;

        filename "auto_install";
        next-server pxe.home.ctors.net;

#        host vm1 {
#            hardware ethernet 00:20:91:00:00:01;
#            fixed-address vm1.vmm.home.ctors.net;
#        }
    }
}
```

/etc/sysctl.conf
```
net.inet.ip.forwarding=1
```

/etc/pf.conf
```
set skip on lo

block return    # block stateless traffic
pass            # establish keep-state

# By default, do not permit remote connections to X11
block return in on ! lo0 proto tcp to port 6000:6010

ext_if="em0"
int_if="{ vether0 tap0 }"
set block-policy drop
set loginterface egress
match in all scrub (no-df random-id max-mss 1440)
match out on egress inet from !(egress:network) to any nat-to (egress:0)
pass out quick inet
pass in on $int_if inet
pass in on egress inet proto tcp from any to (egress) port 22
```

/etc/vm.conf
```
switch "local" {
    add vether0
    add tap0
}

vm "vm1.vm" {
    memory 512M
    kernel "/bsd.rd"
    disk "/vmm/vm1.img"
    interface {
        switch "local"
        lladdr 00:20:91:00:00:01
    }
}
```

## Commands

```
vmmctl status

vmctl console 1
cu /dev/ttyp0

vmctl create /vmm/vm1.img -s 500M
vmctl start -c -b /bsd.rd -m 512M -i 1 -d /vmm/vm1.img
```

@author: https://gist.github.com/tvlooy/fd6bc5a77bc03f4d419f395dfcf4f038