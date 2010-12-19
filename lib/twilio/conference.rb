module Twilio
  class Conference
    include Twilio::Resource
    extend Twilio::Finder

    def participants
      res = self.class.get "/Accounts/#{Twilio::ACCOUNT_SID}/Conferences/#{sid}/Participants.json"
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