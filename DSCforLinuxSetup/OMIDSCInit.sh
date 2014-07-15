#!/bin/bash

# Courtesy of PowerShell Magazine writer Ravikanth C
# http://www.powershellmagazine.com/2014/05/21/installing-and-configuring-dsc-for-linux/

apt-get -y install build-essential pkg-config python python-dev libpam-dev libssl-dev

mkdir /root/downloads
cd /root/downloads
 
wget https://collaboration.opengroup.org/omi/documents/30532/omi-1.0.8.tar.gz
tar -xvf omi-1.0.8.tar.gz
 
cd omi-1.0.8
./configure | tee /tmp/omi-configure.txt
make | tee /tmp/omi-make.txt
make install | tee /tmp/omi-make-install.txt

cd /root/downloads
 
wget https://github.com/MSFTOSSMgmt/WPSDSCLinux/releases/download/v1.0.0-CTP/PSDSCLinux.tar.gz
tar -xvf PSDSCLinux.tar.gz
cd dsc/
mv * /root/downloads/
 
cd /root/downloads
make | tee /tmp/dsc-make.txt
make reg | tee /tmp/dsc-make-reg.txt