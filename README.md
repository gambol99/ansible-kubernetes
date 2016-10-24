## **CoreOS Kubernetes**

The respository holds a ansible installation for deployment of below on CoreOS

  - kubernetes framework
  - ceph storage layer
  - glusterfs storage

Note: all the services are actually deployed via fleet, through the unit files are first templated and customized per role and or location. 

#### **Ansible**

A small container is deployed via fleet during the cloudinit process allowing us to run ansible on the boxes. We then map into various areas of the host filesystem so we may drop files, configs, certs etc etc.

#### **Sites**
----

The location / sites data (found in /sites/<location>/vars/<location>.yml) is the datacenter / region specific information - username, password, networks, dns, provider details is region specific; The design being your playbooks and roles are abstract with the location data permitting the same code to be reused across multiple environments, providers and regions. Note, these are passed into the play via -e location=<location>

#### **Bastion hosts**
----

Dropped into the base directory is a ssh.config which is used to configure the bastion setup; all command and plays being run by Ansible are routed by bastion host. For the dev and vagrant i'm just reusing a actual box to act as bastion as I can't be asked to waste the memory a separate host.

#### **Dynamic Inventory**
-----

Dynamic inventory for vagrant and vcloud has been written and inventory directory. Both of these along with EC2 the inventory/group.yml to perform the groups and groups of groups and keeps things simple.

##### **Groups**

Inside the inventory/ directory is a group.yml which is used to place the hosts into ansible groups, it effectively does nothing more than using regexes and hostnames and placing them into the appointed group.  

#### **Building in vagrant**
----

    # for a kubernetes deployment
    [jest@starfury ansible-kubernetes]$ make sbx
    # the sbx-play with run the ansible playbook again
    [jest@starfury ansible-kubernetes]$ make sbx-play
    # build the ceph storage layer
    [jest@starfury ansible-kubernetes]$ make ceph

Take a look at the Makefile to see whats happening.

#### **Etcd Discovery**

Assuming your using CoreOS a discovery token will automatially genereated for you under the var/location/sbx.discovery.yml on the first vagrant up.
