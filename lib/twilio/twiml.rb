module Twilio
  module TwiML
    def build &blk
      xm = Builder::XmlMarkup.new(:indent => 2)
      xm.instance_eval do
        def method_missing(meth, *args, &blk)
          # camelize options
          if args.last.kind_of? Hash
            args[-1] = Hash[args.last.map { |k,v| [k.to_s.camelize(:lower), v]}]
          end
          # let builder do the heavy lifting
          super(meth.to_s.capitalize, *args, &blk)
        end
      end
      xm.instruct!
      xm.response &blk
    end
    extend self
  end
end