# vsl

# Initial Setup

To get up and running you will need the following installed:

1. [Virtual Box](https://www.virtualbox.org/)
2. [Virtual Box Guest Addtions](https://download.virtualbox.org/virtualbox/6.1.32/Oracle_VM_VirtualBox_Extension_Pack-6.1.32.vbox-extpack)
3. [Vagrant](https://www.vagrantup.com/downloads)

To install `Virtual Box Guest Addtions` (_after_ installing Virtual Box):

Visit https://www.virtualbox.org/wiki/Downloads.
Under the heading **VirtualBox 6.1.32 Oracle VM VirtualBox Extension Pack**, find the download link [All supported platforms](https://download.virtualbox.org/virtualbox/6.1.32/Oracle_VM_VirtualBox_Extension_Pack-6.1.32.vbox-extpack).
Once downloaded, double click the file to install.

## Configuration

These steps may work with other operating systems, but have only been tested with MacOS.

**NOTE: on MacOS, don't forget to go to `System Preferences > Privacy > Accessibility` and give Virtual Box permission.**

Create the config file `/etc/vbox/networks.conf` and add the following entry:

```
Remote Host-Only Network IP Restriction(s)
* 0.0.0.0/0 ::/0
```

Run Virtual Box, and go to `File > Host Network Manager`.
Click the icon to create a new adapter. Leave the default name of `vboxnet0`.
Disable DHCP Server on this adapter.
Click the icon to go to `Properties`.
At the bottom, choose _Configure Adapater Manually_.
Change the `IPv4 Address` to `172.16.100.1`.
Leave the subnet mask at `255.255.255.0`.
Hit _Apply_.
**Note: you may have to do this process and hit _Apply_ a couple times for this to "stick", because of a bug in Virtual Box GUI.**

<br/>

### Accessing Services on VMs from Host: Port Forwarding

_coming soon..._

Preferences > Network > Config > Port Forwarding
