#
#   Author: Rohith
#   Date: 2015-04-23 00:59:48 +0100 (Thu, 23 Apr 2015)
#
#

AUTHOR=gambol99

.PHONY: build ansible sbx kube-play mesos-play kube kuberbetes mesos

ansible:
	docker build -t ${AUTHOR}/ansible .

clean:
	vagrant destroy -f
	rm -f ./vars/location/sbx.discovery.yml

clean-mesos:
	vagrant destroy -f /mesos/

clean-kubernetes:
	vagrant destroy -f /master/
	vagrant destroy -f /minion/

clean-kube: clean-kubernetes

halt:
	vagrant halt

kuberbetes:
	vagrant up /master/ --parallel
	vagrant up /minion/ --parallel
	vagrant up /gluster/ --parallel
	make kube-play

kube: kuberbetes

kcore:
	vagrant up /bastion101/
	vagrant up /mincore101/
	vagrant up /mincore102/
	vagrant up /gluster/ 
	make kcore-play

eu1:
	ansible-playbook -i inventory/aws_eu1 -e location=eu1 playbooks/kubernetes.yml
	ansible-playbook -i inventory/aws_eu1 -e location=eu1 provision-kubernetes.yml

kube-play:
	ansible-playbook -i inventory/vagrant -e location=sbx -e cluster=all provision-kubernetes.yml

kcore-play:
	ansible-playbook -i inventory/vagrant -e location=sbx -e cluster=all provision-kube.yml

mesos:
	vagrant up /mesos/
	make mesos-play

mesos-play:
	ansible-playbook -i inventory/vagrant -e location=sbx -e cluster=all provision-marathon.yml

aws:
	source .aws
	ansible-playbook -i inventory/ec2.py -e location=eu1 -e cluster=all playbooks/provision-marathon
