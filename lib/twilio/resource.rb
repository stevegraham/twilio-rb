require 'active_support/core_ext/string/inflections' # Chill! we only use the bits of AS we need!

module Twilio
  module Resource
    def initialize(attrs ={})  #:nodoc:
      @attributes = Hash[attrs.map { |k,v| [k.to_s.camelize, v.to_s] }]
      normalize_http_verbs!
      escape_send_digits! if attributes.include? 'SendDigits'
      normalize_if_machine_parameter!
    end

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
        attributes.update Hash[res.parsed_response.map { |k,v| [k.camelize, v] }] # params are camelized in requests, yet underscored in the repsonse. inconsistency FTW!
      end
    end

    def normalize_http_verbs! #:nodoc:
      # Twilio accepts a HTTP method for use with various callbacks. The API documentation
      # indicates that the HTTP verbs are to be passed as upcase.
      attributes.each { |k,v| v.upcase! if k =~ /Method$/ }
    end

    def escape_send_digits! #:nodoc:
      # A pound, i.e. "#" has special meaning in a URL so it must be escaped
      attributes.update 'SendDigits' => CGI.escape(attributes['SendDigits'])
    end

    def normalize_if_machine_parameter! #:nodoc:
      attributes['IfMachine'].capitalize! if attributes['IfMachine']
    end

    def method_missing(meth, *args, &blk) #:nodoc
      meth = meth.to_s.camelize
      if meth.to_s =~ /\=$/
        add_attr_writer meth
        send meth, args.first
      elsif attributes.include? meth = meth.gsub('=', '')
        add_attr_reader meth
        send meth
      else
        super
      end
    end

    def add_attr_writer(attribute) #:nodoc
      metaclass.class_eval do
        attribute = attribute.to_s.gsub(/\=$/, '')
        define_method("#{attribute}=") { |value| attributes[attribute] = value } unless respond_to? "#{attribute}="
      end
    end

    def add_attr_reader(attribute) #:nodoc
      metaclass.class_eval do
        define_method(attribute) { attributes[attribute] } unless respond_to? attribute
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
        end

        def post(url, opts)
          super url, opts.merge(:basic_auth => { :username => Twilio::ACCOUNT_SID, :password => Twilio::AUTH_TOKEN })
        end
      end
    end
  end
end