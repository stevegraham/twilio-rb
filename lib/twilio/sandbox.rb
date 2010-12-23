module Twilio
  module Sandbox
    include Twilio::Resource
    @attributes = {}.with_indifferent_access

    def attributes
      @attributes.empty? ? reload! : @attributes
    end

    def reload!
      handle_response get path
    end

    %w<voice_url voice_method sms_url sms_method>.each do |meth|
      define_method "#{meth}=" do |arg|
        update_attributes meth => arg 
      end
    end

    private
    def path
      "/Accounts/#{Twilio::ACCOUNT_SID}/Sandbox.json"
    end
    extend self
  end
end