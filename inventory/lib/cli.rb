#
#   Author: Rohith
#   Date: 2015-04-20 14:42:38 +0100 (Mon, 20 Apr 2015)
#
#  vim:ts=2:sw=2:et
#
require 'yaml'
require 'optparse'
require 'utils'

module Ansible
  class Inventory
    include Ansible::Utils
    
    ROOT_DIR = File.dirname(File.expand_path $0)
    GROUP_INVENTORY  = "#{ROOT_DIR}/groups.yml"

    def initialize
      parser.parse!
      send options[:command] if options[:command]
    end

    private

    def credentials(stack = options[:stack])
      @credentials ||= YAML.load(File.open(options[:credentials]))[options[:stack]] || {}
    end

    #
    # GROUP Methods
    #
    def group?(name)
      groups.map { |x| x['name'] }.include?(name)
    end

    def group_inventory(&block)
      groups.each do |x| 
        yield x['name'], x['hosts'], x['groups'] 
      end
    end

    def groups
      ## @@TODO we should validate the group entries at this point??
      @groups ||= YAML.load(File.read(GROUP_INVENTORY))['groups'] || []
    end

    def options
      @options ||= {
        :command     => :list,
        :stack       => nil,
        :credentials => 'inventory/.credentials.yml'
      }
    end

    def parser
      @parser ||= OptionParser.new do|opts|
        opts.banner = "Usage: #{__FILE__} [options]"
        opts.on('-s STACK', '--stack STACK', 'the provider stack your interested in' ) { |x| options[:stack] = x }
        opts.on('-l', '--list', 'generate the ansible inventory configuration') do
          options[:command] = :list
        end
      end
    end
  
  end
end