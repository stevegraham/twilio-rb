require 'active_support/core_ext/string/inflections' # Chill! we only use the bits of AS we need!

module Twilio
  module Resource
    # Convenience for accessing attributes. Attributes can be accessed either using the
    # preferred symbol style, e.g. :if_machine or using the Twilio stringified attribute
    # style, e.g. 'IfMachine'
    # Kind of like ActiveSupport::HashWithIndifferentAccess on crack.
    def [](key)
      accessor = key.is_a?(Symbol) ? key.to_s.camelize : key
      attributes[accessor]
    end

    def []=(key,value)
      accessor = key.is_a?(Symbol) ? key.to_s.camelize : key
      attributes[accessor] = value
    end

    private

    def handle_response(res) # :nodoc:
      if res.code.to_s =~ /^(4|5)\d\d/
        raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
      else
        @attributes.update Hash[res.parsed_response.map { |k,v| [k.camelize, v] }] # params are camelized in requests, yet underscored in the repsonse. inconsistency FTW!
      end
    end

    def method_missing(id, *args, &blk) #:nodoc
      meth = id.to_s.camelize
      if meth =~ /\=$/
        add_attr_writer meth
        send meth, args.first
      elsif meth =~ /^#{meth}\?/i
        add_predicate meth
        send meth
      elsif attributes.include? meth = meth.gsub('=', '')
        add_attr_reader meth
        send meth
      else
        super
      end
    end

    def add_predicate(attribute)
      metaclass.class_eval do
        define_method(attribute) { self[:status] =~ /^#{attribute.downcase.gsub '?', ''}/i ? true : false }
      end
    end

    def add_attr_writer(attribute) #:nodoc
      metaclass.class_eval do
        attribute = attribute.to_s.gsub(/\=$/, '')
        define_method("#{attribute}=") { |value| self[attribute] = value } unless respond_to? "#{attribute}="
      end
    end

    def add_attr_reader(attribute) #:nodoc
      metaclass.class_eval do
        define_method(attribute) { self[attribute] } unless respond_to? attribute
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
        def create(attrs={})
          new(attrs).tap { |c| c.save }
        end if instance_of? Class # Don't want this mixed into singleton objects e.g. Twilio::Account 
        
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