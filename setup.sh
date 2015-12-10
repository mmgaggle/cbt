#!/bin/bash

# Setup Repos
sudo yum install -y wget
sudo rpm --import 'https://download.ceph.com/keys/release.asc'
wget https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
wget https://download.ceph.com/rpm-hammer/el7/noarch/ceph-release-1-1.el7.noarch.rpm
sudo rpm -i *release*.rpm
sudo yum check-update

# Update packages
sudo yum -y install deltarpm 
sudo yum -y update
sudo yum install -y psmisc util-linux coreutils xfsprogs e2fsprogs findutils \
  git perf blktrace lsof redhat-lsb sysstat screen python-yaml dstat ntp fio \
  iftop collectl iperf3 ceph-deploy ceph

# Install PDSH packages (not in EPEL)
MIRROR="http://mirror.hmc.edu/fedora/linux/releases/22/Everything/x86_64/os/Packages"
wget ${MIRROR}/p/pdsh-2.31-3.fc22.x86_64.rpm
wget ${MIRROR}/p/pdsh-rcmd-ssh-2.31-3.fc22.x86_64.rpm
sudo yum localinstall -y *.rpm

# Remote tty restriction, disable selinux/firewall
sudo sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers
sudo setenforce 0
( awk '!/SELINUX=/' /etc/selinux/config ; echo "SELINUX=disabled" ) > /tmp/x
sudo mv /tmp/x /etc/selinux/config
rpm -qa firewalld | grep firewalld && sudo systemctl stop firewalld && sudo systemctl disable firewalld

# Setup NTP for mons
sudo systemctl start ntpd.service
sudo systemctl enable ntpd.service

# Remove mounts created by, and prevent future cloud-init mounts
sudo sed -i '/ - mounts/d' /etc/cloud/cloud.cfg
sudo sed -i '/\/dev\/xvdb/d' /etc/fstab
