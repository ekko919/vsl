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
# ======= PHP INSTALL ========
#
packages=("php" "php-cli" "php-common" "php-devel" "php-gd" "php-intl" "php-ldap" "php-mbstring" "php-mysql" "php-pear" "php-snmp")
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
# ======= START SUPPORTING SERVICES ========
#
systemctl enable --now "httpd" "mariadb" "snmpd"
systemctl status "httpd" "mariadb" "snmpd"
#
#
# ======= MYSQL SECURITY ========
#
echo -e "\n" "no\n" "yes\n" "yes\n" "yes\n" "yes\n" | mysql_secure_installation
#
# ======= CACTI DB CREATION ========
#
usr=("cactiuser")
db=("cactidb")
echo -e "Checking for CactiDB \n"
mysql -uroot -e "show databases;" | grep -o "$db"
	if [ $? == 0 ]
	then
		echo -e "CactiDB is already present. \n"
	else
		echo -e "CreatingDB \n"
		mysql -uroot -e  "create database cactidb;"
	fi
echo -e "Checking for existing Cacti User \n"
mysql -uroot -D mysql -e "select user from user;" | grep -o "$usr"
	if [ $? == 0 ]
	then
		echo -e "Cacti User is already installed. \n"
	else
		echo -e "Creating Cacti User \n"
		mysql -uroot -e  "create user cactiuser@localhost identified by 'cactipwd';"
		echo -e "Granting Privileges to Cacti User \n"
		mysql -uroot -e  "grant all privileges on cactidb.* to cactiuser@localhost identified by 'cactipwd';"
		mysql -uroot -e  "flush privileges;" 
	fi
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
# ===== SETTING TIMEZONE PERMISSIONS ======
#
echo -e "Setting Timezone Permissions \n"
mysql -uroot -e  "grant select on mysql.time_zone_name to cactiuser@localhost;"
mysql -uroot -e  "flush privileges;" 
#
# ===== OPTIMIZE MARIA DB ======
#
echo -e "Optimizing the Maria DB... \n"
cat << 'cnf' >> /etc/my.cnf.d/server.cnf
#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see
#
# This is read by the standalone daemon and embedded servers
[server]

# This is only for the mysqld standalone daemon
[mysqld]
	collation_server = utf8_general_ci
	init-connect = 'SET NAMES utf8'
	character_set_server = utf8
	max_heap_table_size = 128M
	max_allowed_packet = 16777216
	tmp_table_size = 64M
	join_buffer_size = 64M
	innodb_file_per_table = ON
	innodb_buffer_pool_size = 512M
	innodb_doublewrite = OFF
	innodb_additional_mem_pool_size = 80M
	innodb_lock_wait_timeout = 50
	innodb_flush_log_at_trx_commit = 2

# This is only for embedded server
[embedded]

# This group is only read by MariaDB-5.5 servers.
# If you use the same .cnf file for MariaDB of different versions,
# use this group for options that older servers don't understand
[mysqld-5.5]

# These two groups are only read by MariaDB servers, not by MySQL.
# If you use the same .cnf file for MySQL and MariaDB,
# you can put MariaDB-only options here
[mariadb]

[mariadb-5.5]

cnf
#
# ===== PHP TIMEZONE ======
#
echo -e "Setting PHP Timezone Info. \n"
tzi=$(timedatectl | grep 'Time zone' | grep -Po '(?<=\:).*(?=\()')
var1=(";date.timezone =")
var2=("date.timezone =$tzi")
sed -i "s|${var1}|${var2}|g" /etc/php.ini
#
# ===== CACTI INSTALL CHECK ======
#
echo -e "Checking Existing Cacti Installation ... \n"
ck1="$(yum info cacti | grep -o 'installed' )"
ck2="$(ls /opt | grep -o cacti.d )"

	if [ "$ck1" == "installed" ] || [ "$ck2" == "cacti.d" ]
	then
		echo -e "Cacti appears to already be installed. \n"
		echo ""
		echo -e "Checking the type of installation ... \n"
				ls /opt | grep cacti.d > /dev/null
					if [ $ck1 == "installed" ]
					then
						echo -e "This appears to be a YUM install ... \n"
						yum info cacti | grep Version
						echo -e "Please use the CONVERSION script ... \n"
						echo -e "GOOD-BYE \n"
						exit
					else
						echo -e "This appears to be a scripted installation ... \n"
						ls /opt/cacti.d/
						echo ""
						echo -e	"Please use the UPDATE script instead. \n"
						echo -e "GOOD-BYE \n"
						exit
					fi
	else
		echo -e "Cacti does not appear to be installed ... \n"
	fi
#
# ===== CACTI VERSION INSTALL ======
#
wget -qO- https://files.cacti.net/cacti/linux/ | grep -wo '>cacti-1.2.*.tar' | sed '/.tar/,$ { s/.tar*//g; }' | sed 's/[>]//g'
echo ""
echo -e "Please enter the numeric values for the version of Cacti you wish to install ... \n"
read CACTIVERSION
cd /root/downloads
wget https://www.cacti.net/downloads/cacti-$CACTIVERSION.tar.gz
tar -xzvf cacti-$CACTIVERSION.tar.gz
mkdir -p /opt/cacti.d
mv cacti-$CACTIVERSION /opt/cacti.d
ln -s /opt/cacti.d/cacti-$CACTIVERSION/ /usr/share/cacti
#
# ===== CACTI DATABASE IMPORT ======
#
echo -e "Creating Cacti Database ... \n"
mysql -u root -p cactidb < /usr/share/cacti/cacti.sql
#
# ===== CACTI PHP CONFIG ======
#
echo -e "Configuring PHP settings ... \n"
cat << 'EOT' > /usr/share/cacti/include/config.php
<?php
/*
 +-------------------------------------------------------------------------+
 | Copyright (C) 2004-2020 The Cacti Group                                 |
 |                                                                         |
 | This program is free software; you can redistribute it and/or           |
 | modify it under the terms of the GNU General Public License             |
 | as published by the Free Software Foundation; either version 2          |
 | of the License, or (at your option) any later version.                  |
 |                                                                         |
 | This program is distributed in the hope that it will be useful,         |
 | but WITHOUT ANY WARRANTY; without even the implied warranty of          |
 | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           |
 | GNU General Public License for more details.                            |
 +-------------------------------------------------------------------------+
 | Cacti: The Complete RRDtool-based Graphing Solution                     |
 +-------------------------------------------------------------------------+
 | This code is designed, written, and maintained by the Cacti Group. See  |
 | about.php and/or the AUTHORS file for specific developer information.   |
 +-------------------------------------------------------------------------+
 | http://www.cacti.net/                                                   |
 +-------------------------------------------------------------------------+
*/

/*
 * Make sure these values reflect your actual database/host/user/password
 */

$database_type     = 'mysql';
$database_default  = 'cactidb';
$database_hostname = 'localhost';
$database_username = 'cactiuser';
$database_password = 'cactipwd';
$database_port     = '3306';
$database_retries  = 5;
$database_ssl      = false;
$database_ssl_key  = '';
$database_ssl_cert = '';
$database_ssl_ca   = '';

/*
 * When the cacti server is a remote poller, then these entries point to
 * the main cacti server. Otherwise, these variables have no use and
 * must remain commented out.
 */

#$rdatabase_type     = 'mysql';
#$rdatabase_default  = 'cacti';
#$rdatabase_hostname = 'localhost';
#$rdatabase_username = 'cactiuser';
#$rdatabase_password = 'cactiuser';
#$rdatabase_port     = '3306';
#$rdatabase_retries  = 5;
#$rdatabase_ssl      = false;
#$rdatabase_ssl_key  = '';
#$rdatabase_ssl_cert = '';
#$rdatabase_ssl_ca   = '';

/*
 * The poller_id of this system.  set to `1` for the main cacti web server.
 * Otherwise, you this value should be the poller_id for the remote poller.
 */

$poller_id = 1;

/*
 * Set the $url_path to point to the default URL of your cacti install.
 * For exmaple if your cacti install as at `https://serverip/cacti/` this
 * would be set to `/cacti/`.
 */

$url_path = '/cacti/';

/*
 * Default session name - session name must contain alpha characters
 */

$cacti_session_name = 'Cacti';

/*
 * Save sessions to a database for load balancing
 */

$cacti_db_session = false;

/*
 * Disable log rotation settings for packagers
 */

$disable_log_rotation = false;

/*
 * Optional parameters to define scripts and resource paths. These
 * variables become important when using remote poller installs when the
 * scripts and resource files are not in the main Cacti web server path.
 */

//$scripts_path = '/var/www/html/cacti/scripts';
//$resource_path = '/var/www/html/cacti/resource/';

/*
 * Optional parameter to define a data input whitelist command string. This
 * whitelist file will help protect cacti from unauthorized changes to Cacti
 * data input command string.
 */

//$input_whitelist = '/usr/local/etc/cacti/input_whitelist.json';

/*
 * Optional parameter to give explicit path to PHP
 */
//$php_path = '/bin/php';

/*
 * Optional parameter to disable the PHP SNMP extension. If not set, defaults
 * to class_exists('SNMP').
 */

//$php_snmp_support = false;

/*
 * Optional parameter to define the path of the csrf_secret.php path.  This
 * variable is for packagers who wish to specify an alternate location of 
 * the CRSF secret file.
 */

//$path_csrf_secret = '/usr/share/cacti/resource/csrf-secret.php';

/*
 * The following are optional variables for debugging low level system
 * functions that are generally only used by Cacti Developers to help
 * identify potential issues in commonly used functions
 *
 * To use them, uncomment and the equivalent field will be set in the
 * $config variable allowing for instant on but still allowing the
 * ability to fine turn and turn them off.
 */

/*
 * Debug the read_config_option program flow
 */
# define('DEBUG_READ_CONFIG_OPTION', true);

/*
 * Automatically suppress the DEBUG_READ_CONFIG_OPTION
 */
# define('DEBUG_READ_CONFIG_OPTION_DB_OPEN', true);

/*
 * Always write the SQL command to the cacti log file
 */
# define('DEBUG_SQL_CMD', true);

/*
 * Debug the flow of calls to the db_xxx functions that
 * are defined in lib/database.php
 */
# define('DEBUG_SQL_FLOW', true);

EOT
echo -e "Completed successfully. \n"
#
# ===== CACTI PERMISSIONS ======
#
echo -e "Setting up permissions ... \n"
cd /opt/cacti.d/cacti-$CACTIVERSION
adduser --groups apache cactiuser
	chown -R cactiuser.apache /opt/cacti.d/cacti-$CACTIVERSION
	chmod -R 775 rra/ log/ resource/ scripts/ cache/ 
	setfacl -d -m group:apache:rw /usr/share/cacti/rra 
	setfacl -d -m group:apache:rw /usr/share/cacti/log
echo -e "Completed successfully. \n"
#
# ===== CRON JOB ======
#
cat << 'cron' >> /etc/cron.d/cacti
*/1 * * * *     apache  /usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1
cron
#
# ===== CACTI APACHE CONFIG ======
#
echo -e "Configuring Apache settings ... \n"
cat << 'apache' >> /etc/httpd/conf.d/cacti.conf
#
# Cacti: An rrd based graphing tool
#

# For security reasons, the Cacti web interface is accessible only to
# localhost in the default configuration. If you want to allow other clients
# to access your Cacti installation, change the httpd ACLs below.
# For example:
# On httpd 2.4, change "Require host localhost" to "Require all granted".
# On httpd 2.2, change "Allow from localhost" to "Allow from all".

	Alias /cacti    /usr/share/cacti
	
	<Directory /usr/share/cacti/>
		<IfModule mod_authz_core.c>
			# httpd 2.4
			Require all granted
		</IfModule>
		<IfModule !mod_authz_core.c>
			# httpd 2.2
			Order deny,allow
			Deny from all
			Allow from all
		</IfModule>
	</Directory>

	<Directory /usr/share/cacti/install>
		# mod_security overrides.
		# Uncomment these if you use mod_security.
		# allow POST of application/x-www-form-urlencoded during install
		#SecRuleRemoveById 960010
		# permit the specification of the rrdtool paths during install
		#SecRuleRemoveById 900011
	</Directory>

# These sections marked "Require all denied" (or "Deny from all")
# should not be modified.
# These are in place in order to harden Cacti.
	<Directory /usr/share/cacti/log>
		<IfModule mod_authz_core.c>
			Require all denied
		</IfModule>
		<IfModule !mod_authz_core.c>
			Order deny,allow
			Deny from all
		</IfModule>
	</Directory>
	<Directory /usr/share/cacti/rra>
		<IfModule mod_authz_core.c>
			Require all denied
		</IfModule>
		<IfModule !mod_authz_core.c>
			Order deny,allow
			Deny from all
		</IfModule>
	</Directory>
apache
echo -e "Completed successfully. \n"
#
# ===== INSTALLING SPINE ======
#
echo -e "Installing SPINE ... \n"
cd /root/downloads
yum install -y autoconf automake libtool dos2unix help2man openssl-devel perl-devel rpm-devel gcc mysql-devel
wget https://www.cacti.net/downloads/spine/cacti-spine-$CACTIVERSION.tar.gz
tar -xzvf cacti-spine-$CACTIVERSION.tar.gz
mv cacti-spine-$CACTIVERSION /opt/cacti.d/
cd /opt/cacti.d/cacti-spine-$CACTIVERSION
	./bootstrap
	./configure
	make
	make install
cp /usr/local/spine/etc/spine.conf.dist /etc/spine.conf
#
cat << 'spine' >> /etc/cron.d/cacti
# +-------------------------------------------------------------------------+
# | Copyright (C) 2004-2019 The Cacti Group                                 |
# |                                                                         |
# | This program is free software; you can redistribute it and/or           |
# | modify it under the terms of the GNU Lesser General Public License      |
# | as published by the Free Software Foundation; either version 2.1        |
# | of the License, or (at your option) any later version.                  |
# |                                                                         |
# | This program is distributed in the hope that it will be useful,         |
# | but WITHOUT ANY WARRANTY; without even the implied warranty of          |
# | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           |
# | GNU General Public License for more details.                            |
# +-------------------------------------------------------------------------+
# | spine: a backend data gatherer for Cacti                                |
# +-------------------------------------------------------------------------+
# | This poller would not have been possible without:                       |
# |   - Larry Adams (current development and enhancements)                  |
# |   - Rivo Nurges (rrd support, mysql poller cache, misc functions)       |
# |   - RTG (core poller code, pthreads, snmp, autoconf examples)           |
# |   - Brady Alleman/Doug Warner (threading ideas, implimentation details) |
# +-------------------------------------------------------------------------+
# | Settings                                                                |
# +-------------------------------------------------------------------------+
# | DB_Host         'localhost' or socket file for UNIX/Linux               |
# |                 IP Address for Windows                                  |
# | DB_Database     Database name, typically 'cacti'                        |
# | DB_Port         The database port to use                                |
# | DB_User         The user to access the database, typically 'cactiuser'  |
# | DB_Pass         The password for the Cacti user                         |
# | SNMP_Clientaddr Bind SNMP to a specific address for sites that use      |
# |                 higher security levels                                  |
# +-------------------------------------------------------------------------+
# | Settings for Remote Polling                                             |
# +-------------------------------------------------------------------------+
# | RDB_Host        The remote database hostname.                           |
# | RDB_Database    The remote database name, typically 'cacti'             |
# | RDB_Port        The remote database port to use                         |
# | RDB_User        The remote database user, typically 'cactiuser'         |
# | RDB_Pass        The remote database password.                           |
# +-------------------------------------------------------------------------+

DB_Host		localhost
DB_Database	cactidb
DB_User		cactiuser
DB_Pass		cactipwd
DB_Port		3306
#DB_UseSSL    0
#DB_SSL_Key
#DB_SSL_Cert
#DB_SSL_CA

RDB_Host      localhost
RDB_Database  cacti
RDB_User      cactiuser
RDB_Pass      cactiuser
RDB_Port      3306
#RDB_UseSSL    0
#RDB_SSL_Key
#RDB_SSL_Cert
#RDB_SSL_CA

spine
ln -s /usr/local/spine/bin/spine /sbin/spine
echo -e "SPINE install completed successfully. \n"
#
# ===== RESTART SERVICES ======
#
echo -e "Restarting services ... \n"
systemctl restart 'httpd' 'mariadb' 'snmpd'
systemctl status 'httpd' 'mariadb' 'snmpd'
echo -e "Cacti installation is now complete... \n"
echo -e "You should now be able to login @ http://localhost/cacti ..."
echo -e "  GOOD-BYE \n"
#



