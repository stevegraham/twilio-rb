module Twilio
  module Config
    def setup &blk
      instance_eval &blk
    end

    def method_missing(meth, *args, &blk)
      const = meth.to_s.upcase
      Twilio.const_set(const, args.first) unless Twilio.const_defined? const
    end

    extend self
  end
end