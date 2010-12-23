require 'active_support/core_ext/string' # Chill! we only use the bits of AS we need!
require 'active_support/core_ext/hash'

module Twilio
  module Resource
    def initialize(attrs ={})  #:nodoc:
      @attributes = attrs.with_indifferent_access
    end

    def [](key)
      attributes[key]
    end

    def []=(key,value) # :nodoc:
      attributes[key] = value
    end

    def update_attributes(attrs={})
      state_guard do
        handle_response self.class.post path, :body => Hash[attrs.map { |k,v| [k.to_s.camelize, v]}]
      end
    end

    private
    def state_guard
      if frozen?
        raise RuntimeError, "#{self.class.name.demodulize} has already been destroyed"
      else
        yield
      end
    end

    def path # :nodoc:
      "/Accounts/#{Twilio::ACCOUNT_SID}/#{self.class.name.demodulize + 's'}/#{self[:sid]}.json"
    end

    def handle_response(res) # :nodoc:
      if (400..599).include? res.code
        raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
      else
        @attributes.update(res.parsed_response)
      end
    end

    def method_missing(id, *args, &blk) #:nodoc
      meth = id.to_s
      if meth =~ /\=$/
        add_attr_writer meth
        send meth, args.first
      elsif meth =~ /^#{meth}\?$/i
        add_predicate meth
        send meth
      elsif attributes.keys.include? meth 
        add_attr_reader meth
        send meth
      else
        super
      end
    end

    def add_predicate(attribute)
      metaclass.class_eval do
        define_method(attribute) { self['status'] =~ /^#{attribute.gsub '?', ''}/i ? true : false }
      end
    end

    def add_attr_writer(attribute) #:nodoc
      metaclass.class_eval do
        define_method(attribute) { |value| self[attribute.to_s.gsub(/\=$/, '').to_sym] = value } unless respond_to? attribute
      end
    end

    def add_attr_reader(attribute) #:nodoc
      metaclass.class_eval do
        define_method(attribute) { self[attribute] }  unless respond_to? attribute
      end
    end

    def metaclass #:nodoc
      class << self; self; end
    end

    def self.included(base)
      base.instance_eval do
        include HTTParty
        attr_reader :attributes
        format      :json
        base_uri    Twilio::API_ENDPOINT
      end

      class << base
        # decorate http methods with authentication
        %w<post get put delete>.each do |meth| 
          define_method(meth) do |*args| # splatted args necessary hack since <= 1.8.7 does not support optional block args 
            opts = args[1] || {}
            super args.first, opts.merge(:basic_auth => { :username => Twilio::ACCOUNT_SID, :password => Twilio::AUTH_TOKEN })
          end
        end
      end
    end
  end
end
