module Twilio
  class Recording
    include Twilio::Resource
    include Twilio::Deletable
    extend Twilio::Finder

    def mp3
      API_ENDPOINT + path.gsub(/\.json$/, '.mp3')
    end

    def wav
      API_ENDPOINT + path.gsub(/\.json$/, '.wav')
    end
  end
end
