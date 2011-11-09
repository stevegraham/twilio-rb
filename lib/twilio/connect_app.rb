module Twilio
  class ConnectApp
    include Twilio::Resource
    extend  Twilio::Finder

    mutable_attributes :friendly_name, :authorize_redirect_url, :deauthorize_callback_url, :deauthorize_callback_method, :permissions, :description, :company_name, :homepage_url
  end
end
