#!/bin/bash

# This bash script is used to install the LibreNMS application, and should be run with 
# root privileges.
#
#
# ======= MARIA DB REPO ========
#
echo -e " Checking Maria DB Repository References \n"
	mariadb=/etc/yum.repos.d/MariaDB.repo
	if  [ -f "$mariadb" ];
	then
		echo -e " MariaDB Repo exists... \n"
	else
		echo -e " Creating MariaDB Repo... \n"
		cat <<- EOF >> /etc/yum.repos.d/MariaDB.repo
		# MariaDB 10.3 CentOS repository list - created 2021-06-17 14:57 UTC
		# http://downloads.mariadb.org/mariadb/repositories/
		[mariadb]
		name = MariaDB
		baseurl = http://yum.mariadb.org/10.3/centos7-amd64
		gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
		gpgcheck=1
		EOF
		echo -e " MariaDB Repo installed successfully...\n"
	fi
#