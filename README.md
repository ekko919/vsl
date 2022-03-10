# vsl

# Setup

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

#### First..

Create the config file `/etc/vbox/networks.conf` and add the following entry:

```
Remote Host-Only Network IP Restriction(s)
* 0.0.0.0/0 ::/0
```

#### Next..

1. Run Virtual Box, and go to `File > Host Network Manager`.
2. Click the icon to create a new adapter. Leave the default name of `vboxnet0`.
3. Disable DHCP Server on this adapter.
4. Click the icon to go to `Properties`.
5. At the bottom, choose _Configure Adapater Manually_.
6. Change the `IPv4 Address` to `172.16.100.1`.
7. Leave the subnet mask at `255.255.255.0`.
8. Hit _Apply_.

**Note: you may have to do this process and hit _Apply_ a couple times for this to "stick", because of a bug in Virtual Box GUI.**

<br/>

## Clone and Run

After the above configuration steps are completed, you should be ready to run the `vsl` environment.

#### Imporant note about cloning:

`vsl` should be cloned into the following directory structure on your machine. It is important to use this exact structure, where `~` is your home directory:

`~/My Documents/VM_Share/Projects`

`vsl` should be cloned into `Projects` directory shown above. After `vsl` is cloned, the end result should look like this:

`~/My Documents/VM_Share/Projects/vsl`

<br/>

##### You should now be ready to run vagrant commands in the `vsl` environment

<br/>

# Accessing Services on VMs from Host: Port Forwarding

_coming soon..._

Preferences > Network > Config > Port Forwarding
