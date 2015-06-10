## **Cloud Provisoning**

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

Inside the inventory/ directory is a group.yml which is used to place the hosts into groups. Technically, I could grab this information from metadata in vcloud or tags in ec2 etc. Since I started testing with vcloud, the API is god awfully slow and this each host requires another api call I couldn't be asked to wait that long. So I use the regexes in the groups.yml aross vcloud, vagrant and ec2 to define the hostgroups

#### **Building in vagrant**
----

    # for a kubernetes deployment
    [jest@starfury ansible-vcloud]$ make sbx

    [jest@starfury ansible-vcloud]$ make sbc-play

Take a look at the Makefile to see whats happening.

#### ** Etcd Discovery **

Assuming your using CoreOS a discovery token will automatially genereated for you under the var/location/sbx.discovery.yml on the first vagrant up.
