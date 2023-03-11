# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
#
#############################################
#           VAGRANT GUEST SCRIPTS           #
#############################################
$disable_ipv6 = <<-SCRIPT
echo Disable IPv6 Listener
cp /media/tmp/sysctl.conf /etc/sysctl.conf
awk 'NR==18 {$0="AddressFamily inet"} 1' /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp
mv /etc/ssh/sshd_config.tmp /etc/ssh/sshd_config
SCRIPT

###############################
$dnsmasq_conf = <<-SCRIPT
echo Provisioning DNSMASQ file
rm /etc/dnsmasq.conf
cp /media/tmp/dnsmasq.conf /etc/dnsmasq.conf
SCRIPT

###############################
$java_adj = <<-'SCRIPT'
echo Update Java Environment Memory
awk 'NR==9 {$0="JAVA_ARGS=\"-Xms512m -Xmx512m -Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger\""} 1' /etc/sysconfig/puppetserver > /etc/sysconfig/puppetserver.tmp
mv /etc/sysconfig/puppetserver.tmp /etc/sysconfig/puppetserver
SCRIPT

###############################
$ntp_conf = <<-SCRIPT
echo Provisioning NTP file
rm /etc/ntp.conf
cp /media/tmp/ntp.conf /etc/ntp.conf
SCRIPT

##############################
$puppet_conf = <<-'SCRIPT'
echo Provisioning puppet.conf
rm /etc/puppetlabs/puppet/puppet.conf
touch /etc/puppetlabs/puppet/puppet.conf

puppet config set certname $HOSTNAME'.lab.test' --section master
puppet config set environment production --section master
puppet config set runinterval 1m --section master

puppet config set server 'otto-svr.lab.test' --section agent

awk '/\[/{print "#"}1' /etc/puppetlabs/puppet/puppet.conf > /etc/puppetlabs/puppet/puppet.tmp
awk 'NR==2 {$0="[master]"} 1' /etc/puppetlabs/puppet/puppet.tmp > /etc/puppetlabs/puppet/puppet.tmp1
mv /etc/puppetlabs/puppet/puppet.tmp1 /etc/puppetlabs/puppet/puppet.conf
SCRIPT

###############################
$puppet_env = <<-SCRIPT
echo Setting Puppet Enviroment
rm /etc/puppetlabs
mkdir /etc/puppetlabs
SCRIPT

###############################
$puppet_hosts = <<-SCRIPT
echo Provisioning HOSTS file
rm /etc/hosts
cp /media/tmp/ag-hosts /etc/hosts
SCRIPT

##############################
$puppet_path = <<-SCRIPT
echo Setting Puppet PATH
export PATH=/opt/puppetlabs/bin:$PATH
SCRIPT

###############################
$puppet_suse = <<-SCRIPT
echo Installing Puppet Repo
mkdir /root/downloads
cd /root/downloads
wget https://yum.puppet.com/puppet6-release-sles-15.noarch.rpm
zypper --no-gpg-checks in -y puppet6-release-sles-15.noarch.rpm
SCRIPT

##############################
$puppet_svr_conf = <<-'SCRIPT'
echo Provisioning puppet.conf
cp /media/tmp/puppet-svr.conf /etc/puppetlabs/puppet/puppet.conf
SCRIPT


##############################
$puppet_svr_hosts = <<-SCRIPT
echo Provisioning HOSTS file
rm /etc/hosts
cp /media/tmp/svr-hosts /etc/hosts
SCRIPT

###############################
$resolv_conf = <<-SCRIPT
echo Provisioning RESOLVER file
rm /etc/resolv.conf
cp /media/tmp/resolv.conf /etc/resolv.conf
SCRIPT

#############################################
#     VAGRANT HOST MANAGER CONFIGURATION    #
#############################################

Vagrant.configure("2") do |config|
	config.vm.box_check_update = true
	config.vm.boot_timeout = 60

	#SSH Key Config
	config.ssh.forward_agent = false
	config.ssh.insert_key = false
	config.ssh.private_key_path = ["keys/.ssh/vagrant.key", "~/.vagrant.d/insecure_private_key"]
	config.vm.provision "file", source: "keys/.ssh/vagrant.pub", destination: "~/.ssh/authorized_keys"

	# Configure Vagrant-HostManager Plugin
	if Vagrant.has_plugin? "vagrant-hostmanager"
		config.hostmanager.enabled = false
		config.hostmanager.manage_host = true
		config.hostmanager.ignore_private_ip = false
		config.hostmanager.include_offline = true
	end

	# Configure vagrant-vbguest Plugin
	if Vagrant.has_plugin? "vagrant-vbguest"
		config.vbguest.iso_path = ["vbguest/VBoxGuestAdditions.iso"]
		config.vbguest.no_install  = false
		config.vbguest.auto_update = true
		config.vbguest.no_remote   = false
	end

#############################################
#      AUTOMATION SERVER CONFIGURATION      #
#############################################
  	
	config.vm.define "otto-svr" do |vm1|
  		vm1.vm.network :forwarded_port, guest: 22, host: 2211, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm1.vm.network :forwarded_port, guest: 80, host: 8011, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm1.vm.network :forwarded_port, guest: 443, host: 11443, host_ip: "0.0.0.0", id: "https", auto_correct: true
    	vm1.vm.hostname = "otto-svr.vsl.lab"
    	vm1.vm.box = "bento/centos-7.9"
    	vm1.vm.synced_folder ".", "/vagrant", disabled: true 
    	vm1.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
#      	vm1.vm.synced_folder "env/dev/puppetlabs/code/", "/etc/puppetlabs/code/", create: false
#      		owner = "root", group = "root"
    	vm1.vm.network "private_network",
    				    ip: "172.16.100.11",
						gateway: "172.16.100.254",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
    	vm1.vm.provider "virtualbox" do |vb|
      		vb.name = "CentOS_7.x (Otto SVR)"
      		vb.gui = false
      		vb.memory = "2048"
      		vb.cpus = 2
      		vb.customize ["modifyvm", :id,
                    	"--vram", 
                   	 	"128"
                	 	]
      		vb.customize ["storageattach", :id, 
                   		"--storagectl", "IDE Controller", 
                    	"--port", "0", "--device", "1", 
                    	"--type", "dvddrive", 
                    	"--medium", "emptydrive"
                	 	]
      		vb.customize ["modifyvm", :id,
                     	"--graphicscontroller", "vmsvga"
                	 	]
      		vb.customize ["modifyvm", :id,
                    	"--audio", "none"
                	 	]
          	vb.customize ["modifyvm", :id, 
                        "--cableconnected1", "on"
                     	]
      		vb.customize ["modifyvm", :id,
     		 		    "--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
    		end
    	vm1.vm.provision "shell", inline: $disable_ipv6
    	vm1.vm.provision "shell", inline: 'sysctl -p'
    	vm1.vm.provision "shell", inline: $puppet_svr_hosts
    	vm1.vm.provision "shell", inline: <<-SHELL
       		yum -y install http://yum.puppetlabs.com/puppet6-release-el-7.noarch.rpm
       		yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
       		yum -y install nano gcc make perl kernel-devel
       		yum -y install bind-utils ntp
       		yum -y install puppetserver
       		systemctl set-default multi-user.target
      		SHELL
    	vm1.vm.provision "shell", inline: $puppet_path
    	vm1.vm.provision "shell", inline: $java_adj
    	vm1.vm.provision "shell", inline: $puppet_svr_conf
    	vm1.vm.provision "shell", inline: $resolv_conf
    	vm1.vm.provision "shell", inline: $ntp_conf
    	vm1.vm.provision "shell", inline: <<-SHELL
			yum -y install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
       	vm1.vm.provision "shell", inline: <<-SHELL
       		echo 'setting TimeZone & NTP Services'
       		timedatectl set-timezone America/New_York
       		ntpdate us.pool.ntp.org
       		systemctl start ntpd
       		systemctl enable ntpd
       		echo ...
       		echo Done.
       		SHELL
    	vm1.vm.provision "shell", inline: <<-SHELL
       		echo starting Puppet Server
       		systemctl start puppetserver
       		echo enabling Puppet Server
       		systemctl enable puppetserver
       		echo Puppet Server started and enabled...
       		echo ...
       		echo Create Puppet Server Certificate
       		rm -rf /etc/puppetlabs/puppet/ssl/*
       		puppetserver ca setup --certname puppet-svr
       		echo Done.
       		SHELL
    	end

#############################################
#          PUPPET AGENT CENTOS 7.X          #
#############################################
    
	config.vm.define "centos-01" do |vm2|
		vm2.vm.network :forwarded_port, guest: 22, host: 2212, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm2.vm.network :forwarded_port, guest: 80, host: 8012, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm2.vm.network :forwarded_port, guest: 443, host: 12443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm2.vm.hostname = "centos-01.vsl.lab"
		vm2.vm.box = "bento/centos-8"
		vm2.vm.synced_folder ".", "/vagrant", disabled: true 
		vm2.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm2.vm.network "private_network",
						ip: "172.16.100.12",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm2.vm.provider "virtualbox" do |vb|
			vb.name = "CentOS_7.x (Client AG12)"
			vb.gui = false
			vb.memory = "4096"
			vb.cpus = 4
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "IDE Controller", 
						"--port", "0", "--device", "1", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm2.vm.provision "shell", inline: $puppet_hosts
		vm2.vm.provision "shell", inline: <<-SHELL
			yum -y install http://yum.puppetlabs.com/puppet6-release-el-7.noarch.rpm
			yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
			yum -y install nano gcc make perl kernel-devel
			yum -y install bind-utils
			yum -y install puppet
			systemctl set-default multi-user.target
			SHELL
		vm2.vm.provision "shell", inline: $puppet_path
		vm2.vm.provision "shell", inline: <<-SHELL
			yum -y install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm2.vm.provision "shell", inline: $resolv_conf
		vm2.vm.provision "shell", inline: $puppet_conf
		vm2.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			SHELL
		end

#############################################
#          PUPPET AGENT CENTOS 7.X          #
#############################################
    
	config.vm.define "centos-02" do |vm3|
		vm3.vm.network :forwarded_port, guest: 22, host: 2213, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm3.vm.network :forwarded_port, guest: 80, host: 8013, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm3.vm.network :forwarded_port, guest: 443, host: 13443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm3.vm.hostname = "centos-02.vsl.lab"
		vm3.vm.box = "bento/centos-7.9"
		vm3.vm.synced_folder ".", "/vagrant", disabled: true 
		vm3.vm.synced_folder "tmp", "/media/tmp", automount: true
			owner = "vagrant", group = "vboxsf"
		vm3.vm.network "private_network",
						ip: "172.16.100.13",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm3.vm.provider "virtualbox" do |vb|
			vb.name = "CentOS_7.x (Client AG13)"
			vb.gui = false
			vb.memory = "2048"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "IDE Controller", 
						"--port", "0", "--device", "1", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm3.vm.provision "shell", inline: $puppet_hosts
		vm3.vm.provision "shell", inline: <<-SHELL
			yum -y install http://yum.puppetlabs.com/puppet6-release-el-7.noarch.rpm
			yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
			yum -y install nano gcc make perl kernel-devel
			yum -y install bind-utils
			yum -y install puppet
			systemctl set-default multi-user.target
			SHELL
		vm3.vm.provision "shell", inline: $puppet_path
		vm3.vm.provision "shell", inline: <<-SHELL
			yum -y install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm3.vm.provision "shell", inline: $resolv_conf
		vm3.vm.provision "shell", inline: $puppet_conf
		vm3.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			SHELL
		end

#############################################
#        PUPPET AGENT ORACLE LINUX          #
#############################################
    
	config.vm.define "oracle-01" do |vm4|
		vm4.vm.network :forwarded_port, guest: 22, host: 2214, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm4.vm.network :forwarded_port, guest: 80, host: 8014, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm4.vm.network :forwarded_port, guest: 443, host: 14443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm4.vm.hostname = "oracle-01.vsl.lab"
		vm4.vm.box = "bento/oracle-7.8"
		vm4.vm.synced_folder ".", "/vagrant", disabled: true 
		vm4.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm4.vm.network "private_network",
						ip: "172.16.100.14",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm4.vm.provider "virtualbox" do |vb|
			vb.name = "Oracle Linux 7.x (Client AG14)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "IDE Controller", 
						"--port", "0", "--device", "1", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm4.vm.provision "shell", inline: $puppet_hosts
		vm4.vm.provision "shell", inline: <<-SHELL
			yum -y install http://yum.puppetlabs.com/puppet6-release-el-7.noarch.rpm
			yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
			yum -y install nano gcc make perl kernel-devel
			yum -y install bind-utils
			yum -y install puppet
			systemctl set-default multi-user.target
			SHELL
		vm4.vm.provision "shell", inline: $puppet_path
		vm4.vm.provision "shell", inline: <<-SHELL
			yum -y install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm4.vm.provision "shell", inline: $resolv_conf
		vm4.vm.provision "shell", inline: $puppet_conf
		vm4.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			systemctl set-default multi-user.target
			SHELL
		end

#############################################
#        PUPPET AGENT ORACLE LINUX          #
#############################################
    
	config.vm.define "oracle-02" do |vm5|
		vm5.vm.network :forwarded_port, guest: 22, host: 2215, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm5.vm.network :forwarded_port, guest: 80, host: 8015, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm5.vm.network :forwarded_port, guest: 443, host: 15443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm5.vm.hostname = "oracle-02.vsl.lab"
		vm5.vm.box = "bento/oracle-7.8"
		vm5.vm.synced_folder ".", "/vagrant", disabled: true 
		vm5.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm5.vm.network "private_network",
						ip: "172.16.100.15",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm5.vm.provider "virtualbox" do |vb|
			vb.name = "Oracle Linux 7.x (Client AG15)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "IDE Controller", 
						"--port", "0", "--device", "1", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm5.vm.provision "shell", inline: <<-SHELL
			yum check-update
			yum upgrade -y
			yum install -y kernel-uek-headers-$(uname -r)
			yum install -y kernel-uek-devel-$(uname -r) 
			SHELL
		vm5.vm.provision "shell", inline: $puppet_hosts
		vm5.vm.provision "shell", args: "y", inline: <<-SHELL
			yum -y install http://yum.puppetlabs.com/puppet6-release-el-7.noarch.rpm
			yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
			yum -y install nano gcc make perl kernel-devel
			yum -y install bind-utils
			yum -y install puppet
			systemctl set-default multi-user.target
			SHELL
		vm5.vm.provision "shell", inline: $puppet_path
		vm5.vm.provision "shell", inline: <<-SHELL
			yum -y install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm5.vm.provision "shell", inline: $resolv_conf
		vm5.vm.provision "shell", inline: $puppet_conf
		vm5.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			systemctl set-default multi-user.target
			SHELL
		end

#############################################
#          PUPPET AGENT UBUNTU 18.04        #
#############################################
    
	config.vm.define "ubuntu-01" do |vm6|
		vm6.vm.network :forwarded_port, guest: 22, host: 2216, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm6.vm.network :forwarded_port, guest: 80, host: 8016, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm6.vm.network :forwarded_port, guest: 443, host: 16443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm6.vm.hostname = "ubuntu-01.vsl.lab"
		vm6.vm.box = "bento/ubuntu-18.04"
#		vm6.vm.box = "ekko919/Ubuntu-18.x"
		vm6.vm.synced_folder ".", "/vagrant", disabled: true
		vm6.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm6.vm.network "private_network",
						ip: "172.16.100.16",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm6.vm.provider "virtualbox" do |vb|
			vb.name = "Ubuntu_18.x (Client AG16)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "IDE Controller", 
						"--port", "0", "--device", "1", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm6.vm.provision "shell", inline: <<-SHELL
			apt update
			apt install -y linux-headers-generic dkms
			SHELL
		vm6.vm.provision "shell", inline: $puppet_hosts
		vm6.vm.provision "shell", inline: <<-SHELL
			wget https://apt.puppetlabs.com/puppet6-release-stretch.deb
			dpkg -i puppet6-release-stretch.deb
			apt-get update
			apt-get install -y puppet-agent
			apt-get install nano gcc make perl linux-headers-$(uname -r) -y
			apt-get install bind9utils -y
			systemctl set-default multi-user.target
			SHELL
		vm6.vm.provision "shell", inline: $puppet_path
		vm6.vm.provision "shell", inline: <<-SHELL
			apt-get install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm6.vm.provision "shell", inline: $resolv_conf
		vm6.vm.provision "shell", inline: $puppet_conf
		vm6.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			SHELL
		end

#############################################
#          PUPPET AGENT UBUNTU 18.04        #
#############################################
    
	config.vm.define "ubuntu-02" do |vm7|
		vm7.vm.network :forwarded_port, guest: 22, host: 2217, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm7.vm.network :forwarded_port, guest: 80, host: 8017, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm7.vm.network :forwarded_port, guest: 443, host: 17443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm7.vm.hostname = "ubuntu-02.vsl.lab"
		vm7.vm.box = "bento/ubuntu-18.04"
		vm7.vm.synced_folder ".", "/vagrant", disabled: true
		vm7.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm7.vm.network "private_network",
						ip: "172.16.100.17",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm7.vm.provider "virtualbox" do |vb|
			vb.name = "Ubuntu_18.x (Client AG17)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "IDE Controller", 
						"--port", "0", "--device", "1", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]					 
			end
		vm7.vm.provision "shell", inline: <<-SHELL
			apt update
			apt install -y linux-headers-generic dkms
			SHELL
		vm7.vm.provision "shell", inline: $puppet_hosts
		vm7.vm.provision "shell", inline: <<-SHELL
			wget https://apt.puppetlabs.com/puppet6-release-stretch.deb
			dpkg -i puppet6-release-stretch.deb
			apt-get update
			apt-get install -y puppet-agent
			apt-get install nano gcc make perl linux-headers-$(uname -r) -y
			apt-get install bind9utils -y
			systemctl set-default multi-user.target
			SHELL
		vm7.vm.provision "shell", inline: $puppet_path
		vm7.vm.provision "shell", inline: <<-SHELL
			apt-get install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm7.vm.provision "shell", inline: $resolv_conf
		vm7.vm.provision "shell", inline: $puppet_conf
		vm7.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			SHELL
		end
	
#############################################
#          PUPPET AGENT openSUSE 15.x       #
#############################################

	config.vm.define "suse-01" do |vm8|
		vm8.vm.network :forwarded_port, guest: 22, host: 2218, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm8.vm.network :forwarded_port, guest: 80, host: 8018, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm8.vm.network :forwarded_port, guest: 443, host: 18443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm8.vm.hostname = "suse-01.vsl.lab"
		vm8.vm.box = "bento/opensuse-leap-15"
		vm8.vm.synced_folder ".", "/vagrant", disabled: true
		vm8.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm8.vm.network "private_network",
						ip: "172.16.100.18",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm8.vm.provider "virtualbox" do |vb|
			vb.name = "openSUSE_15.x (Client AG18)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "SATA Controller", 
						"--port", "1", "--device", "0", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm8.vm.provision "shell", inline: <<-SHELL
			zypper -n up
			zypper -n in kernel-default-devel kernel-devel
			SHELL
		vm8.vm.provision "shell", inline: $puppet_hosts
		vm8.vm.provision "shell", inline: <<-SHELL
			zypper in -y wget nano bind-utils
			SHELL
		vm8.vm.provision "shell", inline: $puppet_suse
		vm8.vm.provision "shell", inline: <<-SHELL
			zypper in -y dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm8.vm.provision "shell", inline: <<-SHELL
			zypper --no-gpg-checks in -y puppet-agent
			systemctl set-default multi-user.target
			SHELL
		vm8.vm.provision "shell", inline: $resolv_conf
		vm8.vm.provision "shell", inline: $puppet_conf
		vm8.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			SHELL
		end
		
#############################################
#          PUPPET AGENT openSUSE 15.x       #
#############################################

	config.vm.define "suse-02" do |vm9|
		vm9.vm.network :forwarded_port, guest: 22, host: 2219, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm9.vm.network :forwarded_port, guest: 80, host: 8019, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm9.vm.network :forwarded_port, guest: 443, host: 19443, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm9.vm.hostname = "suse-02.vsl.lab"
		vm9.vm.box = "opensuse/Leap-15.2.x86_64"
		vm9.vm.synced_folder ".", "/vagrant", disabled: true
		vm9.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm9.vm.network "private_network",
						ip: "172.16.100.19",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm9.vm.provider "virtualbox" do |vb|
			vb.name = "openSUSE_15.x (Client AG19)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "SATA Controller", 
						"--port", "1", "--device", "0", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm9.vm.provision "shell", inline: <<-SHELL
			zypper -n up
			zypper -n in kernel-default-devel kernel-devel
			SHELL
		vm9.vm.provision "shell", inline: $puppet_hosts
		vm9.vm.provision "shell", inline: <<-SHELL
			zypper -n in wget nano bind-utils
			SHELL
		vm9.vm.provision "shell", inline: $puppet_suse
		vm9.vm.provision "shell", inline: <<-SHELL
			zypper in -y dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm9.vm.provision "shell", inline: <<-SHELL
			zypper --no-gpg-checks in -y puppet-agent
			systemctl set-default multi-user.target
			SHELL
		vm9.vm.provision "shell", inline: $resolv_conf
		vm9.vm.provision "shell", inline: $puppet_conf
		vm9.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			SHELL
		end

#############################################
#          PUPPET AGENT PreVu 'APT'         #
#############################################
    
	config.vm.define "pvu-98" do |vm98|
		vm98.vm.network :forwarded_port, guest: 22, host: 2298, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm98.vm.network :forwarded_port, guest: 80, host: 8098, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm98.vm.network :forwarded_port, guest: 443, host: 9843, host_ip: "0.0.0.0", id: "https", auto_correct: true
		vm98.vm.hostname = "pvu-98.vsl.lab"
		vm98.vm.box = "local_ub2"
#		vm98.vm.box = "ekko919/Debian-11.x"
#		vm98.vm.box = "bento/debian-11.4"
		vm98.vm.synced_folder ".", "/vagrant", disabled: true
		vm98.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		vm98.vm.network "private_network",
						ip: "172.16.100.98",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm98.vm.provider "virtualbox" do |vb|
			vb.name = "PVU_98 (Client AG98)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"16"
						]
			vb.customize ["modifyvm", :id,
						"--nested-hw-virt", 
						"on"
						]
			vb.customize ["modifyvm", :id,
						"--uart1", 
						"0x3F8", "4"
						]
			vb.customize ["modifyvm", :id, 
						"--uartmode1", 
						"file", File::NULL
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "IDE Controller", 
						"--port", "0", "--device", "1", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]					 
			end
		vm98.vm.provision "shell", inline: <<-SHELL
			apt update
			apt install -y linux-headers-generic dkms wget
			SHELL
		vm98.vm.provision "shell", inline: $puppet_hosts
		vm98.vm.provision "shell", inline: <<-SHELL
			wget https://apt.puppetlabs.com/puppet6-release-stretch.deb
			dpkg -i puppet6-release-stretch.deb
			apt-get update
			apt-get install -y puppet-agent
			apt-get install nano gcc make perl linux-headers-$(uname -r) -y
			apt-get install bind9utils -y
			systemctl set-default multi-user.target
			SHELL
		vm98.vm.provision "shell", inline: $puppet_path
		vm98.vm.provision "shell", inline: <<-SHELL
			apt-get install -y dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm98.vm.provision "shell", inline: $resolv_conf
		vm98.vm.provision "shell", inline: $puppet_conf
		vm98.vm.provision "shell", inline: <<-SHELL
			echo starting Puppet Agent
			systemctl start puppet
			echo enabling Puppet Agent
			systemctl enable puppet
			echo Puppet Agent started and enabled...
			echo ...
			echo Done.
			SHELL
		end

#############################################
#          PUPPET AGENT PreVu 'YUM'         #
#############################################

	config.vm.define "pvu-99" do |vm99|
		vm99.vm.network :forwarded_port, guest: 22, host: 2299, host_ip: "0.0.0.0", id: "ssh", auto_correct: true
		vm99.vm.network :forwarded_port, guest: 80, host: 8099, host_ip: "0.0.0.0", id: "http", auto_correct: true
		vm99.vm.network :forwarded_port, guest: 443, host: 9943, host_ip: "0.0.0.0", id: "https", auto_correct: true		
		vm99.vm.hostname = "pvu-99.vsl.lab" 
		vm99.vm.box = "bento/oracle-8"
		vm99.vm.synced_folder ".", "/vagrant", disabled: true
		vm99.vm.synced_folder "tmp", "/media/tmp", create: true
			owner = "vagrant", group = "vboxsf"
		# Rocky Linux Guest Additions Failure to load...
		# Run as root: yum install elfutils-libelf-devel -y
		vm99.vm.network "private_network",
						ip: "172.16.100.99",
						name: "vboxnet1"                                  # macOS/Linux Naming Schema
#						name: "VirtualBox Host-Only Ethernet Adapter#2"   # Windows Network Naming Schema
		vm99.vm.provider "virtualbox" do |vb|
			vb.name = "PVU_99 (Client AG99)"
			vb.gui = false
			vb.memory = "1024"
			vb.cpus = 1
			vb.customize ["modifyvm", :id,
						"--vram", 
						"128"
						]
			vb.customize ["storageattach", :id, 
						"--storagectl", "SATA Controller", 
						"--port", "1", "--device", "0", 
						"--type", "dvddrive", 
						"--medium", "emptydrive"
						]
			vb.customize ["modifyvm", :id,
						"--graphicscontroller", "vmsvga"
						]
			vb.customize ["modifyvm", :id,
						"--audio", "none"
						]
			vb.customize ["modifyvm", :id, 
						"--cableconnected1", "on"
						]
			vb.customize ["modifyvm", :id,
						"--nictype2", "82540em",
						"--nic2", "natnetwork",
						"--nat-network2", "Puppet_Network",
						"--nicpromisc2", "allow-all"
						]
			end
		vm99.vm.provision "shell", inline: $puppet_hosts
		vm99.vm.provision "shell", inline: <<-SHELL
			yum install -y wget nano bind-utils
			SHELL
		vm99.vm.provision "shell", inline: $puppet_path
		vm99.vm.provision "shell", inline: <<-SHELL
			yum -y install dnsmasq > /dev/null 2>&1 && systemctl stop dnsmasq
			echo starting DNS MASQ Service
			systemctl stop systemd-resolved
			systemctl disable systemd-resolved
			systemctl mask systemd-resolved
			$dnsmasq_conf
			systemctl start dnsmasq
			systemctl enable dnsmasq
			echo ...
			echo Done.
			SHELL
		vm99.vm.provision "shell", inline: <<-SHELL
			systemctl set-default multi-user.target
			SHELL
		vm99.vm.provision "shell", inline: $resolv_conf
		end	
end

