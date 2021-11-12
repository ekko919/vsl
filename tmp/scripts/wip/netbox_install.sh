#!/bin/bash

# This bash script is used to install the Netbox application, and should be run with 
# root privileges.
#
# ===== RTC CONFIGURATION ======
#
echo -e "Checking RTC Time Configuration... \n"
rtc='RTC Time'
timedatectl | grep "Warning"
	if [ $? == 0 ]
	then
		echo -e "$rtc error corrected... \n"
		timedatectl set-local-rtc 0
	else
		echo -e "$rtc is configured correctly \n"
	fi
#
# ===== UTC CHECK ======
#
echo -e "Checking Time Zone Configuration... \n"
utc='UTC Time'
timedatectl | grep -o 'Time zone: UTC'
	if [ $? == 0 ]
	then
		echo ""
		PS3='Choose your time zone: '
		zones=("Eastern" "Central" "Mountain" "Pacific" "Skip")
		lcl=("/etc/localtime")
		select ytz in "${zones[@]}"; do
    		case $ytz in
        		"Eastern")
            		echo -e "Setting your system to $ytz timezone ... \n"
            			if test -e "$lcl"; 
            			then 
            				rm --interactive=never /etc/localtime
						fi
	    			ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
	    			break
        			;;
       			 "Central")
           			echo -e "Setting your system to $ytz timezone ... \n"
	    			    if test -e "$lcl"; 
            			then 
            				rm --interactive=never /etc/localtime
						fi
						ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime
	    			break
           			;;
        		"Mountain")
            		echo -e "Setting your system to $ytz timezone ... \n"
	    			    if test -e "$lcl"; 
            			then 
            				rm --interactive=never /etc/localtime
						fi
						ln -s /usr/share/zoneinfo/America/Denver /etc/localtime
	    			break
	    			;;
	    		"Pacific")
            		echo -e "Setting your system to $ytz timezone ... \n"
	    			    if test -e "$lcl"; 
            			then 
            				rm --interactive=never /etc/localtime
						fi
						ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
	    			break
            		;;
				"Skip")
	    			echo -e " Skipping timezone configuration. \n This may have negative affects \n on your database services. \n"
	    			break
	    			;;
        		*) echo "invalid option $REPLY";;
    		esac
		done
	else
		echo -e "Your time zone is NOT set for $utc ... \n"
	fi
#
	timedatectl
#
# ====== ROOT DOWNLOADS ======
#
	downloads=/root/downloads
	if  [ -d "$downloads" ];
	then
		cd /root/downloads
    	echo -e " Begin Install Prep... \n"
	else
		mkdir /root/downloads
		cd /root/downloads
    	echo -e " Begin Install Prep... \n"
	fi
#
# ====== SELINUX PROCESS ======
#
echo -e " Checking SELinux Status... \n"
	if [ $(getenforce) = 'Disabled' ];
	then
		echo -e " SELinux is already Disabled \n" 
	else
		echo " Disabling SELinux & Rebooting "
		sudo sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		sudo sed -i -e 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
		reboot
	fi
#
# ======= EPEL REPO ========
#
echo -e " Checking EPEL Repository References \n"
	epel=/etc/yum.repos.d/epel.repo
	if  [ -f "$epel" ]; 
	then
    	echo -e " EPEL Repo exists... \n"
	else
		yum install -y epel-release
	fi
#
# ======= PostgreSQL SERVICE ========
#
packages=("postgresql-server")
name=("Postgres Server")
for pkg in ${packages[@]}; do
echo -e "Checking for $name now ... \n"
rpm -aqi $pkg | grep "Install Date" > /dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "$name is already installed. \n"
	else
		echo -e "Installing $name now... \n"
		yum install -y $pkg
	fi
done
#
sleep 3s
postgresql-setup initdb
#
sleep 3s
systemctl start postgresql
#
sleep 3s
systemctl enable postgresql
#
# ===== NEW POSTGRES CONFIGURATION ======
#
echo -e "Checking for 'Default' configuration backup ... \n"
ls /var/lib/pgsql/data | grep "pg_hba.conf.org" > /dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "Backup already exists. \n"
	else
		echo -e "Backuping up now... \n"
		mv /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.org
	fi

#
echo -e "Loading New Configuration... \n"
cat << 'EOF' >> /var/lib/pgsql/data/pg_hba.conf
#
# PostgreSQL Client Authentication Configuration File
# ===================================================
#
# Refer to the "Client Authentication" section in the PostgreSQL
# documentation for a complete description of this file.  A short
# synopsis follows.
#
# This file controls: which hosts are allowed to connect, how clients
# are authenticated, which PostgreSQL user names they can use, which
# databases they can access.  Records take one of these forms:
#
# local      DATABASE  USER  METHOD  [OPTIONS]
# host       DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostssl    DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostnossl  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
#
# (The uppercase items must be replaced by actual values.)
#
# The first field is the connection type: "local" is a Unix-domain
# socket, "host" is either a plain or SSL-encrypted TCP/IP socket,
# "hostssl" is an SSL-encrypted TCP/IP socket, and "hostnossl" is a
# plain TCP/IP socket.
#
# DATABASE can be "all", "sameuser", "samerole", "replication", a
# database name, or a comma-separated list thereof. The "all"
# keyword does not match "replication". Access to replication
# must be enabled in a separate record (see example below).
#
# USER can be "all", a user name, a group name prefixed with "+", or a
# comma-separated list thereof.  In both the DATABASE and USER fields
# you can also write a file name prefixed with "@" to include names
# from a separate file.
#
# ADDRESS specifies the set of hosts the record matches.  It can be a
# host name, or it is made up of an IP address and a CIDR mask that is
# an integer (between 0 and 32 (IPv4) or 128 (IPv6) inclusive) that
# specifies the number of significant bits in the mask.  A host name
# that starts with a dot (.) matches a suffix of the actual host name.
# Alternatively, you can write an IP address and netmask in separate
# columns to specify the set of hosts.  Instead of a CIDR-address, you
# can write "samehost" to match any of the server's own IP addresses,
# or "samenet" to match any address in any subnet that the server is
# directly connected to.
#
# METHOD can be "trust", "reject", "md5", "password", "gss", "sspi",
# "krb5", "ident", "peer", "pam", "ldap", "radius" or "cert".  Note that
# "password" sends passwords in clear text; "md5" is preferred since
# it sends encrypted passwords.
#
# OPTIONS are a set of options for the authentication in the format
# NAME=VALUE.  The available options depend on the different
# authentication methods -- refer to the "Client Authentication"
# section in the documentation for a list of which options are
# available for which authentication methods.
#
# Database and user names containing spaces, commas, quotes and other
# special characters must be quoted.  Quoting one of the keywords
# "all", "sameuser", "samerole" or "replication" makes the name lose
# its special character, and just match a database or username with
# that name.
#
# This file is read on server startup and when the postmaster receives
# a SIGHUP signal.  If you edit the file on a running system, you have
# to SIGHUP the postmaster for the changes to take effect.  You can
# use "pg_ctl reload" to do that.

# Put your actual configuration here
# ----------------------------------
#
# If you want to allow non-local connections, you need to add more
# "host" records.  In that case you will also need to make PostgreSQL
# listen on a non-local interface via the listen_addresses
# configuration parameter, or via the -i or -h command line switches.



#	TYPE	DATABASE	USER		ADDRESS			METHOD

# Unix
	local	all		postgres				trust
	local	all		all					peer
# IPv4
	host	all		all		127.0.0.1/32		ident
# IPv6
	host	all		all		::1/128			ident
# Replication
#	local	replication	postgres				peer
#	host    replication	postgres	127.0.0.1/32		ident
#	host	replication	postgres	::1/128			ident
# Non-Standard
	local	all		root					peer


EOF
sleep 3s
systemctl restart postgresql
#
# ======= NETBOX USER/DB VERIFICATION ========
#
USR=("netbox")
PWD=("netbox")
DB=("netbox")
echo -e "Checking for Netbox Database \n"
psql -U postgres ${DB} --command="SELECT version();" >/dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "Netbox Database is already present... \n"
	else
		echo -e "Netbox Database Does NOT Exist... \n"
		#
		echo -e "Creating Netbox Database... \n"
		psql -U postgres --command="CREATE DATABASE ${DB};"
	fi
echo -e "Checking for Netbox User \n"
psql -U postgres -d netbox --command="\du" | grep netbox >/dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "Netbox User is already present... \n"
	else
		echo -e "Netbox User Does NOT Exist... \n"
		
		echo -e "Creating Netbox User... \n"
		psql -U postgres --command="CREATE USER ${USR} WITH PASSWORD '${PWD}';"
		psql -U postgres --command="GRANT ALL PRIVILEGES ON DATABASE ${DB} TO ${USR};"
	fi