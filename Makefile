#
#   Author: Rohith
#   Date: 2015-04-23 00:59:48 +0100 (Thu, 23 Apr 2015)
#
#

AUTHOR=gambol99
CORE_BOXES=core101 core102
STORE_BOXES=store101 store102

.PHONY: build ansible sbx kube-play mesos-play kube kuberbetes mesos

ansible:
	docker build -t ${AUTHOR}/ansible .

develop:
	vagrant up /core101/
	make develop-play

develop-play:
	./run -s develop -i vagrant -p configure.yml

clean:
	vagrant destroy -f
	rm -f ./sites/sbx/vars/sbx.discovery.yml
	rm -rf ./extra_disks

halt:
	vagrant halt

gluster:
	vagrant up /gluster101/
	vagrant up /gluster102/
	make sbx-play

all:
	make sbx
	make ceph 
	
sbx:
	export VAGRANT_DEFAULT_PROVIDER=virtualbox
	$(foreach I, $(CORE_BOXES), \
		vagrant up /$(I)/ ; \
	)
	make sbx-play

sbx-play:
	./run -s sbx -i vagrant -p configure.yml

ceph:
	$(foreach I, $(STORE_BOXES), \
		vagrant up /$(I)/ ; \
	)
	make sbx-play

ceph-play: sbx-play
