#!/bin/bash
#manca la parte dello snapshot
#VBoxManage clonevm workspace_manager_1447841632728_98965 --snapshot snap1 --mode machineandchildren --name swift-clone --register
VBoxManage modifyvm swift-clone --natpf1 delete tcp6080
VBoxManage modifyvm swift-clone --natpf1 delete tcp8080
VBoxManage modifyvm swift-clone --natpf1 delete ssh
VBoxManage modifyvm swift-clone --natpf1 "ssh,tcp,127.0.0.1,2225,,22"
VBoxManage snapshot swift-clone restore snap1
VBoxManage startvm swift-clone --type headless
ssh vagrant@127.0.0.1 -p 2225 -i .vagrant/machines/manager/virtualbox/private_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o IdentitiesOnly=yes <<END
ls -a
sudo dhclient -v -r eth1
sudo dhclient -v eth1
#test Swift
cd /opt/stack/swift
ls -a
sudo rm -rf .venv
sudo rm -rf ./nosetests_swift.xml
sudo yes | sudo tox -e py27 -- --with-xunit --xunit-file="nosetests_swift.xml" --cover-xml
sudo mv ./coverage.xml ./coverage_swift.xml
ls -a
sudo mv ./nosetests_swift.xml /vagrant
sudo mv ./coverage_swift.xml /vagrant
END
VBoxManage controlvm swift-clone acpipowerbutton
