

  module Twilio
  module Config
    attr_writer :account_sid, :auth_token

    def account_sid
      if @account_sid
        @account_sid
      else
        raise Twilio::ConfigurationError.new \
          "Cannot complete request. Please set account_sid with Twilio::Config.setup first!"
      end
    end

    def auth_token
      if @auth_token
        @auth_token
      else
        raise Twilio::ConfigurationError.new \
          "Cannot complete request. Please set auth_token with Twilio::Config.setup first!"
      end
    end

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
