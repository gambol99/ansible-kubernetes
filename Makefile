#
#   Author: Rohith
#   Date: 2015-04-23 00:59:48 +0100 (Thu, 23 Apr 2015)
#
#

AUTHOR=gambol99

.PHONY: build ansible sbx kube-play mesos-play kube kuberbetes mesos

ansible:
	docker build -t ${AUTHOR}/ansible .

develop:
	vagrant up /gluster101/
	vagrant up /core101/
	make develop-play

develop-play:
	./run -s develop -i vagrant -p configure.yml

clean:
	vagrant destroy -f
	rm -f ./sites/sbx/vars/sbx.discovery.yml

halt:
	vagrant halt

sbx:
	export VAGRANT_DEFAULT_PROVIDER=virtualbox
	vagrant up /bastion101/
	vagrant up /core101/
	vagrant up /core102/
	vagrant up /gluster101/ 
	make sbx-play

sbx-play:
	./run -s sbx -i vagrant -p configure.yml

eu1:
	ansible-playbook -i inventory/aws_eu1 -e location=eu1 playbooks/kubernetes.yml
	ansible-playbook -i inventory/aws_eu1 -e location=eu1 provision-kubernetes.yml

aws:
	source .aws
	ansible-playbook -i inventory/ec2.py -e location=eu1 -e cluster=all playbooks/provision-marathon
