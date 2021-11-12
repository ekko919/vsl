#!/bin/bash

# This bash script is used to install the Cacti application, and should be run with 
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
# ======= REMI REPO ========
#
