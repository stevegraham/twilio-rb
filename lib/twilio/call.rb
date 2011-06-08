module Twilio
  class Call
    include Twilio::Resource
    include Twilio::Persistable
    extend Twilio::Finder

    class << self
      alias old_create create
      def create(attrs={})
        attrs = attrs.with_indifferent_access
        attrs.each { |k,v| v.upcase! if k.to_s =~ /method$/ }
        attrs[:send_digits] = CGI.escape(attrs[:send_digits]) if attrs[:send_digits]
        attrs['if_machine'].try :capitalize
        old_create attrs
      end

      private
      def prepare_params(opts) # :nodoc:
        pairs = opts.map do |k,v|
          if [:started_before, :started_after, :ended_before, :ended_after].include? k
            k = k.to_s
            # Fancy schmancy-ness to handle Twilio <= URI operator for dates
            comparator = k =~ /before$/ ? '<=' : '>='
            delineator = k =~ /started/ ? 'Start' : 'End' 
            CGI.escape(delineator << "Time" << comparator << v.to_s)
          else
            "#{k.to_s.camelize}=#{CGI.escape v.to_s}"
          end
        end
        "?#{pairs.join('&')}"
      end
    end

    # Cancels a call if its state is 'queued' or 'ringing'
    def cancel!
      update_attributes :status => 'cancelled'
    end

    def complete!
      update_attributes :status => 'completed'
    end

    # Update Handler URL
    def url=(url)
      # If this attribute exists it is assumed the API call to create a call has been made, so we need to tell Twilio.
      update_attributes :url => url if self[:status]
      self[:url] = url
    end
  end
end