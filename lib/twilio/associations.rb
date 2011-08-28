require 'active_support/core_ext/string'

module Twilio
  module Associations
    def has_many(*collection)
      collection.each do |objects|
        define_method(objects) do
          klass = Twilio.const_get objects.to_s.singularize.camelize
          Twilio::AssociationProxy.new self, klass
        end
      end
    end
  end
end
