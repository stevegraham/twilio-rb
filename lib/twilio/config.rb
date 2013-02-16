require 'active_support/core_ext/module'

module Twilio
  module Config
    mattr_accessor :account_sid, :auth_token

    def setup(opts={}, &blk)
      if block_given?
        instance_eval &blk
        warn 'The block syntax for configuration is deprecated. Use an options hash instead, e.g. Twilio::Config.setup account_sid: "AC00000000000000000000000", auth_token: "xxxxxxxxxxxxxxxxxxx"'
      else
        opts.map do |k,v|
          send("#{k}=", v)
        end
      end

    end

    def method_missing(meth, *args, &blk)
      const = meth.to_s.upcase
      Twilio.const_set(const, args.first) unless Twilio.const_defined? const
    end

    extend self
  end
end
