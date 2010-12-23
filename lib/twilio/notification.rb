module Twilio
  class Notification
    include Twilio::Resource
    include Twilio::Deletable
    extend Twilio::Finder

    class << self
      private
      def prepare_dates(opts)
        opts.map do |k,v|
          if [:created_before, :created_after].include? k
            k = k.to_s
            # Fancy schmancy-ness to handle Twilio <= URI operator for dates
            comparator = k =~ /before$/ ? '<=' : '>='
            "MessageDate" << comparator << v.to_s
          else
            "#{k.to_s.camelize}=#{v}"
          end
        end
      end
    end
  end
end
