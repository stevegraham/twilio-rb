require 'active_support/core_ext/string'

module Twilio
  class AssociationProxy
    instance_methods.each { |meth| undef_method meth unless meth.to_s =~ /^__/ || meth.to_s == 'object_id' }
    def initialize(delegator, target)
      @delegator, @target = delegator, target
      @delegator_name = @delegator.class.name.demodulize.downcase
    end

    def inspect
      @target.all :"#{@delegator_name}_sid" => @delegator.sid
    end

    def method_missing(meth, *args, &blk)
      options = args.empty? ? args.<<({})[-1] : args[-1]
      options.update :"#{@delegator_name}_sid" => @delegator.sid
      @target.__send__ meth, *args, &blk
    end
  end
end

