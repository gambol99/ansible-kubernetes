## **Cloud Provisoning**
#### **Locations**
----

The location data, found in /var/location/<location>.yml is the datacenter / region specific information - username, password, networks, dns, provider details is region specific; The design being your playbooks and roles are abstract with the location data permitting the same code to be reused across multiple environments, providers and regions. Note, these are passed into the play via -e location=<location>

#### **Bastion hosts**
----

Dropped into the base directory is a ssh.config which is used to configure the bastion setup; all command and plays being run by Ansible are routed by bastion host. For the dev and vagrant i'm just reusing a actual box to act as bastion as I can't be asked to waste the memory a separate host.

#### **Dynamic Inventory**
-----

Dynamic inventory for vagrant and vcloud has been written and inventory directory. Both of these along with EC2 the inventory/group.yml to perform the groups and groups of groups and keeps things simple.


##### **Groups**

Inside the inventory/ directory is a group.yml which is used to place the hosts into groups. Technically, I could grab this information from metadata in vcloud or tags in ec2 etc. Since I started testing with vcloud, the API is god awfully slow and this each host requires another api call I couldn't be asked to wait that long. So I use the regexes in the groups.yml aross vcloud, vagrant and ec2 to define the hostgroups

##### **VMware Vcloud Inventory**

The inventory requires a .credentials file to be dropped into the inventory (gitignored)

    [jest@starfury ansible-vcloud]$ cat inventory/.credentials.yml
    #
    #   Author: Rohith
    #   Date: 2015-05-05 13:46:44 +0100 (Tue, 05 May 2015)
    #
    #  vim:ts=2:sw=2:et
    #

    dev:
      username <vcloud username>
      password: <well you know>
      api: api.vcd.portal.skyscapecloud.com
      vdc: <vdc>
      organization: <organization>
    <STACK>
      <OPTIONS ETCD>

    I then use linking i.e. to pass the stack variable

    [jest@starfury ansible-vcloud]$ cat inventory/vcloud_dev
    # !/bin/bash
    inventory/vcloud -s dev --list

    And to test it's working;

    [jest@starfury ansible-vcloud]$ inventory/vcloud_dev
    {
      "_meta": {
        "hostvars": {
          "docker101.dev.example.com": {
            "provider": "vcloud",
            "location": "dev",
            "iface": "ens32"
          },
          "docker103.dev.example.com": {
            "provider": "vcloud",
            "location": "dev",
            "iface": "ens32"
          },
          "docker102.dev.example.com": {
            "provider": "vcloud",
            "location": "dev",
            "iface": "ens32"
          },
          "master101.dev.example.com": {
            "provider": "vcloud",
            "location": "dev",
            "iface": "ens32"
          }
        }
      },
      "bastion": [
        "docker101.dev.example.com"
      ],

#### **Building in vagrant**
----

    # for a marathon / mesos cluster
    [jest@starfury ansible-vcloud]$ make mesos
    # for a kubernetes deployment
    [jest@starfury ansible-vcloud]$ make kube

    # Rerun the ansible builds
    [jest@starfury ansible-vcloud]$ make mesos-play
    [jest@starfury ansible-vcloud]$ make kube-play

Take a look at the Makefile to see whats happening.

#### ** Storage Layer **

A GlusterFS storage layer is configured underneath to provide persistency for various container frameworks (note: this is automatically injected as an endpoint service for kubernetes)  

#### ** HTTP/s Router **

A HTTP router (roles/gateway/http_router) has been added to the build, allowing to reuse the host 80/443 ports across multiple HTTP services; the configuration is automatically generated and configured by annontation in deployed kubernetes services. Note, i'm presently added a integeration piece for the vulcand so hopely will be able to remove this.


#### ** CoreOS ** 

Support for CoreOS has been adedd - if you wich to check kubernetes on CoreOS run make kcore. The deployment of infrastructure is handled in numerious ways depending on how and where you've setup the kubernetes master. You can deploy units via standard ansiable play, i.e. generate the unit file copy to the box and start up, or you can deploy via fleetctl and delegated to by default the master or whomever you wish. Note, the master does not have to be part of the cluster if you don't wish. 

#### ** Etcd Discovery **

Assuming your using CoreOS a discovery token will automatially genereated for you under the var/location/sbx.discovery.yml on the first vagrant up.
