module Twilio
  class Conference
    include Twilio::Resource
    extend Twilio::Finder

    def participants
      account_sid = self[:account_sid] if self[:connect_app_sid]
      res = self.class.get "/Accounts/#{self[:account_sid]}/Conferences/#{sid}/Participants.json", :account_sid => account_sid
      if (400..599).include? res.code
        raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
      else
        res.parsed_response['participants'].map do |p|
          p['api_version'] = p['api_version'].to_s # api_version parsed as a date by http_party
          Twilio::Participant.new p
        end
      end
    end
  end
end
