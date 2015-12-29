#!/bin/bash
#manca la parte dello snapshot
#VBoxManage clonevm workspace_manager_1447841632728_98965 --snapshot snap1 --mode machineandchildren --name nova-clone --register
VBoxManage modifyvm nova-clone --natpf1 delete tcp6080
VBoxManage modifyvm nova-clone --natpf1 delete tcp8080
VBoxManage modifyvm nova-clone --natpf1 delete ssh
VBoxManage modifyvm nova-clone --natpf1 "ssh,tcp,127.0.0.1,22223,,22"
VBoxManage snapshot nova-clone restore snap1
VBoxManage startvm nova-clone --type headless
ssh vagrant@127.0.0.1 -p 2223 -i .vagrant/machines/manager/virtualbox/private_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o IdentitiesOnly=yes <<END
ls -a
sudo dhclient -v -r eth1
sudo dhclient -v eth1
#test Nova
cd /opt/stack/nova
ls -a
sudo rm -rf .venv
sudo yes | sudo ./run_tests.sh -d
ls -a
END
VBoxManage controlvm nova-clone acpipowerbutton
