#!/bin/bash
branch=$1
cbt_repo=$2

ssh-keygen -t rsa -N '' -f .ssh/id_rsa
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
echo "$(hostname -i) head" | sudo tee -a /etc/hosts
ssh-keyscan -H head | sudo tee -a .ssh/known_hosts

# Partition and label ephemeral SSDs
osd_id=0
for dev in xvdb xvdc;do
  part_id=1
  sudo parted -s -a optimal /dev/${dev} mklabel gpt
  sudo parted -s -a optimal /dev/${dev} mkpart primary xfs 0% 5G
  sudo parted -s -a optimal /dev/${dev} name ${part_id} osd-device-${osd_id}-journal
  part_id=$(expr $part_id + 1)
  sudo parted -s -a optimal /dev/${dev} mkpart primary xfs 5G 20G
  sudo parted -s -a optimal /dev/${dev} name ${part_id} osd-device-${osd_id}-data
  part_id=$(expr $part_id + 1)
  osd_id=$(expr $osd_id + 1)
  sudo parted -s -a optimal /dev/${dev} mkpart primary xfs 20G 25G
  sudo parted -s -a optimal /dev/${dev} name ${part_id} osd-device-${osd_id}-journal
  part_id=$(expr $part_id + 1)
  sudo parted -s -a optimal /dev/${dev} mkpart primary xfs 25G 100%
  sudo parted -s -a optimal /dev/${dev} name ${part_id} osd-device-${osd_id}-data
  osd_id=$(expr $osd_id + 1)
done

git clone -b ${branch} ${cbt_repo}
ceph_net=$(ip a | grep $(hostname -I) | cut -f3 | awk '{print $2}' | xargs ipcalc -p -n | tac | cut -d= -f2 | tr '\n' '/' | sed 's/\/$/\n/g' | sed 's#/#\\\/#g')
mon_ip=$(hostname -I|awk '{print $1}')
sed -i "s/--public_network--/${ceph_net}/g" cbt/example/wip-mark-testing/ceph.conf
sed -i "s/--mon_ip--/${mon_ip}/g" cbt/example/ceph.conf cbt/example/wip-mark-testing/runtests.xfs.yaml
