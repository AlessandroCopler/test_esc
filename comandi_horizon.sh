#!/bin/bash
#manca la parte dello snapshot
#VBoxManage clonevm workspace_manager_1447841632728_98965 --snapshot snap1 --mode machineandchildren --name horizon-clone --register
VBoxManage modifyvm horizon-clone --natpf1 delete tcp6080
VBoxManage modifyvm horizon-clone --natpf1 delete tcp8080
VBoxManage modifyvm horizon-clone --natpf1 delete ssh
VBoxManage modifyvm horizon-clone --natpf1 "ssh,tcp,127.0.0.1,2224,,22"
VBoxManage snapshot horizon-clone restore snap1
VBoxManage startvm horizon-clone --type headless
ssh vagrant@127.0.0.1 -p 2224 -i .vagrant/machines/manager/virtualbox/private_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o IdentitiesOnly=yes <<END
ls -a
sudo dhclient -v -r eth1
sudo dhclient -v eth1
#test Horizon
cd /opt/stack/horizon
ls -a
sudo rm -rf .venv
sudo rm -rf ./nosetests_horizon.xml
sudo yes | sudo tox -e py27 -- --with-xunit --xunit-file="nosetests_horizon.xml" -c
sudo mv ./coverage.xml ./coverage_horizon.xml
ls -a
sudo mv ./nosetests_horizon.xml /vagrant
sudo mv ./coverage_horizon.xml /vagrant

END
VBoxManage controlvm horizon-clone acpipowerbutton
