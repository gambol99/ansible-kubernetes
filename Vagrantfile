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
require 'fileutils'

VAGRANT_DEFAULT_PROVIDER = 'virtualbox'
ENVIRONMENT_CONFIG       = "./config.yml"
EXTRA_DISKS              = "./extra_disks"
ETCD_DISCOVERY_TOKEN     = "./sites/sbx/vars/sbx.discovery.yml"
DOCKER_MIRROR            = "DOCKER_MIRROR"
VAGRANT_PLUGINS = [
  'vagrant-hostsupdater'
]       

def boxes
  require ArgumentError, "unable to find the vagrant config" unless File.exist?(ENVIRONMENT_CONFIG)
  YAML.load(File.read(ENVIRONMENT_CONFIG))['boxes'] || {}
end

#
# Are we running a local docker mirror?
#
def docker_mirror?
  !ENV[DOCKER_MIRROR].nil?
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

#
# We use the users public key and inject into the cloudinit
#
def public_key
  @key ||= File.read("#{ENV['HOME']}/.ssh/id_rsa.pub")
end

def extra_disk(name, hostname)
  FileUtils.mkdir_p('./extra_disks') if File.exist?(EXTRA_DISKS)
  "#{EXTRA_DISKS}/#{name}-#{hostname}.vdi"
end 

#
# Check for the vagrant plugins
#
VAGRANT_PLUGINS.each do |x|
  raise "This vagrant environment requires #{x} plugin installed!" unless  Vagrant.has_plugin?(x)
end

Vagrant.configure(2) do |config|
  boxes.each_pair do |hostname, host|
    @hostname   = hostname.split('.').first
    @domain     = hostname.split('.')[1..20].join('.')
    @public_key = public_key
    vbox        = host['virtualbox']
    
    is_coreos   = vbox['box'] =~ /^core/
    
    #
    # Cloudinit configuration
    #
    cloudinit ||= ""
    if is_coreos
      # step: do we need a discovery token
      @discovery = discovery_token
      @fleet     = host['fleet'] || {}
      cloudinit  = ERB.new(File.read(vbox['cloudinit']), nil, '-' ).result( binding )
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
        
        #
        # Extra disks and storage
        # 
        ( vbox['disks'] || [] ).each_with_index do |disk,index|
          disk_filename = extra_disk(disk['name'], hostname)
          unless File.exist?(disk_filename)
            virtualbox.customize ['createhd', '--filename', disk_filename, '--size', disk['size'] ]
            virtualbox.customize [ 'storageattach', :id, 
              '--storagectl', 'IDE Controller', '--port', 1, '--device', index, 
              '--type', 'hdd', '--medium', disk_filename ]
          end
        end

        # step: apply the customizaitions
        (vbox['resources'] || {} ).each_pair do |key,value|
          virtualbox.customize [ "modifyvm", :id, "--#{key}", value ]
        end

        # step: the override for virtualbox
        override.vm.network :private_network, ip: vbox['ip']
      end
      
      # step: perform a fake cloudinit on the box  
      config.vm.provision :shell, :inline => cloudinit, :privileged => true if is_coreos
      
      config.vm.provision "ansible" do |ansible|
        ansible.playbook = "provision-vagrant.yml" 
        ansible.sudo     = true
        ansible.extra_vars = {
          "hostname"  => hostname,
          "location"  => 'sbx',     
          "iface"     => 'enp0s8',
          "is_coreos" => false,
        }
        if is_coreos
          ansible.extra_vars.merge!({
            "ansible_ssh_user" => "core",
            "iface"            => "eth1",
            "is_coreos"        => true,
          })
        end
      end 
    end
  end
end
