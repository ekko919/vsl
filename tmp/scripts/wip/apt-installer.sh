#!/bin/bash
read -p "Package Name: " pkg
which $pkg > /dev/null 2>&1
if [ $? == 0 ]
then
echo "$pkg is already installed. "
else
read -p "$pkg is not installed. Answer yes/no if want installation_ " request
if  [ $request == "yes" ]
then
apt install -y $pkg
fi
fi