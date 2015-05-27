#
#   Author: Rohith
#   Date: 2015-04-20 14:42:38 +0100 (Mon, 20 Apr 2015)
#
#  vim:ts=2:sw=2:et
#
require 'json'

module Ansible
  module Utils
    def validate_filename(filename)
      raise ArgumentError, "unable to find the group inventory file: #{filename}"  unless File.exist?(filename)
      raise ArgumentError, "the group inventory file: #{filename} is not a file"   unless File.file?(filename)
      raise ArgumentError, "the group inventory file: #{filename} is not readable" unless File.readable?(filename)
      filename
    end

    def filter_group_hosts(regex, lists = [])
      lists.select { |hostname| hostname =~ /#{regex}/ }
    end

    def inventory
      @inventory ||= {
        '_meta' => {
          'hostvars' => {}
        }
      }
    end

    def hostvars
      meta['hostvars']
    end

    def meta
      inventory['_meta']
    end

    def pretty_print(content)
      puts JSON.pretty_generate(content)
    end
  end
end
