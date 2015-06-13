#
#   Author: Rohith
#   Date: 2015-04-23 00:59:48 +0100 (Thu, 23 Apr 2015)
#
#

AUTHOR=gambol99
CORE_BOXES=core101 core102
STORE_BOXES=store101 store102
GLUSTER_BOXES=gluster101 gluster102
PWD=$(shell pwd)

.PHONY: build ansible sbx sbx-play ceph ceph-play stop-mirror

ansible:
	sudo docker build -t ${AUTHOR}/ansible .

develop:
	vagrant up /core101/
	make develop-play

mirror:
	export DOCKER_MIRROR="YES"
	sudo docker run -d -p 5000:5000 \
    --name docker-mirror \
    -e STANDALONE=false \
    -e MIRROR_SOURCE=https://registry-1.docker.io \
    -e MIRROR_SOURCE_INDEX=https://index.docker.io \
    registry

develop-play:
	./run -s develop -i vagrant -p configure.yml

clean:
	vagrant destroy -f
	rm -f ./sites/sbx/vars/sbx.discovery.yml
	rm -rf ./extra_disks

halt:
	vagrant halt

gluster:
	$(foreach I, $(CORE_BOXES), \
		vagrant up /$(I)/ ; \
	)
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
