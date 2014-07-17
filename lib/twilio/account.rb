module Twilio
  class Account
    include Twilio::Resource
    include Twilio::Persistable
    extend  Twilio::Associations
    extend  Twilio::Finder

    mutable_attributes :friendly_name, :status

    has_many :calls, :sms, :recordings, :conferences, :incoming_phone_numbers,
      :notifications, :outgoing_caller_ids, :transcriptions

    class << self
      private
      def resource_path(account_sid)
        "/Accounts"
      end
    end

  end
end
