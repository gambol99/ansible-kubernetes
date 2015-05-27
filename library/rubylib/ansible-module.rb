#
#   Author: Rohith
#   Date: 2015-05-19 15:54:47 +0100 (Tue, 19 May 2015)
#
#  vim:ts=2:sw=2:et:filetype=rb
#
require 'json'

module Ansible
  class ModuleLibrary
    private
    def self.output
      result['changed'] ||= false
      puts JSON.pretty_generate(result.merge({
        :time => Time.now,
      }))
    end

    def self.fail(message)
      puts "error: #{message}"
      exit 1
    end

    def self.module_spec(&block)
      instance_eval(&block)
    end

    def self.option(name, options)
      opt_name = name.to_s
      options[:type]     ||= :string
      options[:required] ||= false
      # step: validate the option
      [:type, :required].each do |x|
        raise ArgumentError, "option: '#{opt_name}' does not have a '#{x}' field" unless options.has_key?(x)
      end
      # step: ensure we have the required
      if options[:required] and arguments[opt_name].nil?
        raise ArgumentError, "option: '#{name}' is a required option"
      end
      # step: we validate the type
      validate(opt_name, arguments[opt_name], options[:type]) if arguments[opt_name]
    end

    def self.validate(name, value, type)
      case type
      when :integer
        raise ArgumentError, "the optios: #{name} value: #{value} should be a integer value" unless value.is_a?(Integer)
      when :hash
        raise ArgumentError, "the option: #{name} value should be a hash value" unless value.is_a?(Hash)
      when :list
        raise ArgumentError, "the option: #{name} value should be a list value" unless value.is_a?(Array)
      when :string
        raise ArgumentError, "the option: #{name} value should be a string value" unless value.is_a?(String)
      when :file
        raise ArgumentError, "the option: #{name} value should be a file thats exist" unless File.exist?(value)
        raise ArgumentError, "the option: #{name} value should be a file" unless File.file?(value)
      end
    end

    def self.arguments(filename = ARGV.first)
      return {} if filename.nil?
      @arguments ||= JSON.parse(File.read(filename))
    end

    def self.result
      @result || {}
    end

    def self.changed
      result['changed'] = false
    end

    def self.argument
      @arguments
    end
  end
end

