module Twilio
  class Recording
    include Twilio::Resource
    include Twilio::Deletable
    extend Twilio::Finder

    def mp3
      API_ENDPOINT + path.gsub(/\.json$/, '.mp3')
    end
  end
end
