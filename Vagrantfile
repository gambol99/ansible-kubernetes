#
#   Author: Rohith
#   Date: 2015-04-23 00:50:22 +0100 (Thu, 23 Apr 2015)
#
#  vim:ts=2:sw=2:et
#
# -*- mode: ruby -*-dd
# vi: set ft=ruby :

require 'yaml'
require 'net/http'
require 'erb'

VAGRANT_DEFAULT_PROVIDER = 'virtualbox'
ENVIRONMENT_CONFIG       = "./config.yml"
ETCD_DISCOVERY_TOKEN     = "./vars/location/sbx.discovery.yml"

def boxes
  require ArgumentError, "unable to find the vagrant config" unless File.exist?(ENVIRONMENT_CONFIG)
  YAML.load(File.read(ENVIRONMENT_CONFIG))['boxes'] || {}
end

#
# We could be nicer here and actually check the expiration of the token
# Note: I'm not sure if this is the best way of doing it ... so i'm open to suggestions
#
def discovery_token(filename = ETCD_DISCOVERY_TOKEN)
  token = nil
  if File.exist?(filename)
    token = YAML.load(File.open(filename))['etcd_discovery_token']
  else 
    # step: we need to grab a new token
    token = Net::HTTP.get(URI.parse('https://discovery.etcd.io/new'))
    # step: save the token for later use -
    File.open(filename, "w") { |fd| fd.write({ 'etcd_discovery_token' => token }.to_yaml) }
    token
  end
end

Vagrant.configure(2) do |config|
  boxes.each_pair do |hostname, host|
    @hostname = hostname.split('.').first
    @domain   = hostname.split('.')[1..20].join('.')
    vbox      = host['virtualbox']

    is_coreos = @hostname =~ /^(core|mincore)/

    #
    # Cloudinit configuration
    #
    cloudinit ||= ""
    if is_coreos
      # step: do we need a discovery token
      @discovery = discovery_token
      cloudinit  = ERB.new(File.read(vbox['cloudinit']), nil, '-' ).result( binding ) if is_coreos
    end

    config.vm.define hostname do |x|
      x.vm.hostname  = hostname
      x.vm.box       = host['virtualbox']['box'] 
      x.vm.box_url   = host['virtualbox']['url']

      #
      # Virtualbox related configuration
      #
      x.vm.provider :virtualbox do |virtualbox,override|
        virtualbox.gui   = vbox['gui'] || false
        virtualbox.name  = hostname
        vbox['resources'].each_pair do |key,value|
          virtualbox.customize [ "modifyvm", :id, "--#{key}", value ]
        end

        if is_coreos
          config.vm.provision :shell, :inline => cloudinit, :privileged => true
        end

        config.vm.provision "ansible" do |ansible|
          ansible.playbook = "provision-vagrant.yml" 
          ansible.sudo     = true
          ansible.extra_vars = {
            "hostname"  => hostname,
            "location"  => "sbx",     
            "iface"     => "enp0s8",
            "is_coreos" => false,
          }
          if is_coreos
            ansible.extra_vars.merge!({
              "ansible_ssh_user"           => "core",
              "ansible_python_interpreter" => "PATH=/home/core/bin:$PATH python",
              "iface"                      => "eth1",
              "is_coreos"                  => true,
            })
          end
        end 

        # step: the override for virtualbox
        override.vm.network :private_network, ip: vbox['ip']
      end
    end
  end
end
