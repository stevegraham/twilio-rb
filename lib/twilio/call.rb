module Twilio
  class Call
    include Twilio::Resource

    def initialize(attrs ={})  #:nodoc:
      @attributes = Hash[attrs.map { |k,v| [k.to_s.camelize, v.to_s] }]
      normalize_http_verbs!
      escape_send_digits! if attributes.include? 'SendDigits'
      normalize_if_machine_parameter!
    end

    # Dials the call
    def save
      handle_response self.class.post "/Accounts/#{Twilio::ACCOUNT_SID}/Calls.json", :body => attributes
    end

    # Cancels a call if its state is 'queued' or 'ringing'    
    def cancel!
      state_guard { modify_call 'Status' => 'cancelled' }
    end
    
    def complete!
      state_guard { modify_call 'Status' => 'completed' }
    end
    
    # Update Handler URL
    def url=(url)
      # If this attribute exists it is assumed the API call to create a call has been made, so we need to tell Twilio.
      modify_call "url" => url if self[:status]
      self[:url] = url
    end

    private

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

    def state_guard(&blk)
      if self[:status] # If this attribute exists it is assumed the API call to create a call has been made, and the object is in the correct state to make request.
        blk.call
      else
        raise Twilio::InvalidStateError.new 'Call is in invalid state to perform this action.'
      end
    end

    def modify_call(params)
      handle_response self.class.post "/Accounts/#{Twilio::ACCOUNT_SID}/Calls/#{self[:sid]}.json", :body => params
    end
  end
end
