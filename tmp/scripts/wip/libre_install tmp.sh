#!/bin/bash

# This bash script is used to install the LibreNMS application, and should be run with 
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
# ====== SELINUX PROCESS ======
#
#echo -e " Checking SELinux Status... \n"
#	if [ $(getenforce) = 'Disabled' ];
#	then
#		echo -e " SELinux is already Disabled \n" 
#	else
#		echo " Disabling SELinux & Rebooting "
#		sudo sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
#		sudo sed -i -e 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
#		reboot
#	fi
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
echo -e " Checking REMI Repository References \n"
	remi=/etc/yum.repos.d/remi.repo
	if  [ -f "$remi" ];
	then
		echo -e " REMI Repo exists... \n"
	else
		echo -e " Installing REMI Repo... \n"
		yum install -y wget
		wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
		yum install -y remi-release-7.rpm
		echo -e " REMI Repo installed successfully...\n"
	fi
yum-config-manager --enable remi-php73
#
# ======= MARIA DB REPO ========
#
echo -e " Creating MariaDB Repo... \n"
cat <<- EOF > /etc/yum.repos.d/MariaDB.repo
# MariaDB 10.3 CentOS repository list - created 2021-06-17 14:57 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
echo -e " MariaDB Repo installed successfully...\n"
#
# ======= REQUIRED PACKAGES ========
#
packages=( "bash-completion" "composer" "cronie" "fping" "git" "ImageMagick" "jwhois" "mtr" "MySQL-python" \
			"nmap" "python3" "python3-pip" "python3-redis" "python-memcached" \
			"unzip" "yum-utils")
for pkg in ${packages[@]}; do
echo -e "Checking for $pkg now ... \n"
rpm -aqi $pkg | grep "Install Date" > /dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "$pkg is already installed. \n"
	else
		echo -e "Installing $pkg now... \n"
		yum install -y $pkg
	fi
done
#
# ======= APACHE SERVICE ========
#
packages=("httpd" "httpd-devel")
for pkg in ${packages[@]}; do
echo -e "Checking for $pkg now ... \n"
rpm -aqi $pkg | grep "Install Date" > /dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "$pkg is already installed. \n"
	else
		echo -e "Installing $pkg now... \n"
		yum install -y $pkg
	fi
done
#
# ======= PHP INSTALL ========
#
packages=("php" "php-cli" "php-common" "php-curl" "php-devel" "php-fpm" "php-gd" "php-intl" "php-ldap" "php-mbstring" \
			"php-memcached" "php-mysqlnd" "php-pear" "php-process" "php-snmp" "php-xml" "php-zip")
for pkg in ${packages[@]}; do
echo -e "Checking for $pkg now ... \n"
rpm -aqi $pkg | grep "Install Date" > /dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "$pkg is already installed. \n"
	else
		echo -e "Installing $pkg now... \n"
		yum install -y $pkg
	fi
done
#
# ======= MARIA DB ========
#
packages=("mariadb" "mariadb-server" "mariadb-devel")
for pkg in ${packages[@]}; do
echo -e "Checking for $pkg now ... \n"
rpm -aqi $pkg | grep "Install Date" > /dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "$pkg is already installed. \n"
	else
		echo -e "Installing $pkg now... \n"
		yum install -y $pkg
	fi
done
#
# ======= SNMP / RRD TOOL ========
#
packages=("net-snmp" "net-snmp-utils" "net-snmp-libs" "net-snmp-devel" "rrdtool")
for pkg in ${packages[@]}; do
echo -e "Checking for $pkg now ... \n"
rpm -aqi $pkg | grep "Install Date" > /dev/null 2>&1
	if [ $? == 0 ]
	then
		echo -e "$pkg is already installed. \n"
	else
		echo -e "Installing $pkg now... \n"
		yum install -y $pkg
	fi
done
#
# ======= CREATE LIBRENMS USER ========
#
useradd librenms -d /opt/librenms -M -r
usermod -a -G librenms apache
#
# ======= DOWNLOAD LIBRENMS ========
#
cd /opt
git clone https://github.com/librenms/librenms.git
#
# ======= SET LIBRENMS PERMISSIONS ========
#
chown -R librenms:librenms /opt/librenms
chmod 770 /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
chgrp apache /var/lib/php/session/
#
# ======= INSTALL PHP DEPENDENCIES ========
#
su - librenms -c '/opt/librenms/scripts/composer_wrapper.php install --no-dev'
#
# ======= START SUPPORTING SERVICES ========
#
systemctl enable --now "httpd" "mariadb" "snmpd"
systemctl status "httpd" "mariadb" "snmpd"
#
# ======= MYSQL SECURITY ========
#
echo -e "\n" "no\n" "yes\n" "yes\n" "yes\n" "yes\n" | mysql_secure_installation
#
# ======= IMPORT TIMEZONE ========
#
echo -e "Importing Date/Timezone Template \n"
object=("Time_Zone_Info")
for tz in ${object[@]}; do
echo -e "Checking for $tz now ... \n"
mysql -u root  mysql < /usr/share/mysql/mysql_test_data_timezone.sql 2>&1 > /dev/null | grep -o "ERROR" > /dev/null
	if [ $? == 0 ]
	then
		echo -e "$tz already exists. \n"
	else
		echo -e "Imported $tz now... \n"
	fi
done
#
# ======= LIBRENMS DB CREATION ========
#
usr=("librenms")
db=("librenms")
echo -e "Checking for LibreNMS DB \n"
mysql -uroot -e "show databases;" | grep -o "$db"
	if [ $? == 0 ]
	then
		echo -e "LibreNMS DB is already present. \n"
	else
		echo -e "CreatingDB \n"
		mysql -uroot -e  "create database librenms;"
	fi
echo -e "Checking for existing LibreNMS User \n"
mysql -uroot -D mysql -e "select user from user;" | grep -o "$usr"
	if [ $? == 0 ]
	then
		echo -e "LibreNMS User is already installed. \n"
	else
		echo -e "Creating LibreNMS User \n"
		mysql -uroot -e  "create user librenms@localhost identified by 'password';"
		echo -e "Granting Privileges to LibreNMS User \n"
		mysql -uroot -e  "grant all privileges on librenms.* to librenms@localhost identified by 'password';"
		mysql -uroot -e  "flush privileges;" 
	fi
#
# ===== SETTING TIMEZONE PERMISSIONS ======
#
echo -e "Setting Timezone Permissions \n"
mysql -uroot -e  "grant select on mysql.time_zone_name to librenms@localhost;"
mysql -uroot -e  "flush privileges;"
#
# ===== OPTIMIZE MARIA DB ======
#
echo -e "Optimizing the Maria DB... \n"
cat << 'cnf' >> /etc/my.cnf
#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see
#
# This is read by the standalone daemon and embedded servers
[server]

# This is only for the mysqld standalone daemon
[mysqld]
innodb_file_per_table=1
lower_case_table_names=0


# This is only for embedded server
[embedded]

cnf

systemctl restart mariadb
#
# ===== CONFIGURE PHP-FPM ======
#
sed -i -e 's|;date.timezone = |date.timezone = Etc/UTC|g' /etc/php.ini
sed -i -e 's|listen = 127.0.0.1:9000|listen = /run/php-fpm/php-fpm.sock|g' /etc/php-fpm.d/www.conf
sed -i -e 's|;listen.owner = nobody|listen.owner = apache|g' /etc/php-fpm.d/www.conf
sed -i -e 's|;listen.group = nobody|listen.group = apache|g' /etc/php-fpm.d/www.conf
sed -i -e 's|;listen.mode = 0660|listen.mode = 0660|g' /etc/php-fpm.d/www.conf
systemctl enable php-fpm
systemctl restart php-fpm
#
# ===== CONFIGURE APACHE ======
#
echo -e "Configuring Apache... \n"
rm -f /etc/httpd/conf.d/welcome.conf
cat << 'EOF' > /etc/httpd/conf.d/librenms.conf
#
<VirtualHost *:80>
  DocumentRoot /opt/librenms/html/
  ServerName  librenms.example.com

  AllowEncodedSlashes NoDecode
  <Directory "/opt/librenms/html/">
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
  </Directory>
</VirtualHost>
EOF
sed -i -e 's|ServerName  librenms.example.com|ServerName  librenms.lab.local|g' /etc/httpd/conf.d/librenms.conf
systemctl restart httpd
echo -e "Apache Configuration Complete... \n"
#
# ===== CONFIGURE SELINUX ======
#
yum install policycoreutils-python -y
#
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/logs(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/logs(/.*)?'
restorecon -RFvv /opt/librenms/logs/
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/rrd(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/rrd(/.*)?'
restorecon -RFvv /opt/librenms/rrd/
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/storage(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/storage(/.*)?'
restorecon -RFvv /opt/librenms/storage/
semanage fcontext -a -t httpd_sys_content_t '/opt/librenms/bootstrap/cache(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/opt/librenms/bootstrap/cache(/.*)?'
restorecon -RFvv /opt/librenms/bootstrap/cache/
setsebool -P httpd_can_sendmail=1
setsebool -P httpd_execmem 1
#
# ===== ALLOW FPING ======
#
echo -e "FPing Module Setup Initializing... \n"
touch http_fping.tt 
cat << 'EOF' > http_fping.tt
#
module http_fping 1.0;

require {
type httpd_t;
class capability net_raw;
class rawip_socket { getopt create setopt write read };
}

#============= httpd_t ==============
allow httpd_t self:capability net_raw;
allow httpd_t self:rawip_socket { getopt create setopt write read };
EOF
#
checkmodule -M -m -o http_fping.mod http_fping.tt
semodule_package -o http_fping.pp -m http_fping.mod
semodule -i http_fping.pp
echo -e "FPing Module Setup Complete... \n"
#
# ===== FIREWALL ACCESS (RESERVED) ======
#
# --- [Reserved Space for Firewall Intelligence] ---
#
# ===== CONFIGURE SNMPD ======
#
echo -e "Configure SNMP... \n"
cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf
#
# --- [Reserved Space for Community String Intelligence] ---
#
curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
chmod +x /usr/bin/distro
systemctl restart snmpd
echo -e "SNMP Complete... \n"
#
# ===== CRON JOB / LOG ROTATE ======
#
echo -e "Adding Cron Job... \n"
cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms
echo -e "Setting Up Log Rotate... \n"
cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms
#
