# Twilio.rb

Interact with the Twilio API in a nice Ruby way

## Configuration

Configuration for this library is encapsulated within `Twilio::Config`. One needs to setup with an Account SID and an Auth Token, e.g.

<pre># This should be in an initializer or similar
Twilio::Config.setup do
  account_sid   'AC0000000000000000000000000000'
  auth_token    '000000000000000000000000000000'
end</pre>

Any method that calls the Twilio API will raise `Twilio::ConfigurationError` if either Account SID or Auth Token are not configured.

## Making a telephone call

The API used to make a telephone call is similar to interacting with an ActiveRecord model object.
<pre>Twilio::Call.create :to => '+16465551234', :from => '+19175550000', 
                    :url => "http://example.com/call_handler"</pre>
or
<pre>call = Twilio::Call.new :to => '+16465551234', :from => '+19175550000', 
                        :url => "http://example.com/call_handler"

call.save</pre>

The parameter keys should be given as underscored symbols. They will be converted internally to camelized strings prior to an API call being made.

Please see the Twilio REST API documentation for an up to date list of supported parameters. 
### Modifying a live telephone call
Once a call has been been created it can be modified with the following methods:

`Twilio::Call#cancel!` will terminate the call if its state is `queued` or `ringing`
`Twilio::Call#complete!` will terminate the call even if its state is `in-progress`
`Twilio::Call#url=` will immediately redirect the call to a new handler URL

`Twilio::Call#cancel!` and `Twilio::Call#complete!` will raise `Twilio::InvalidStateError` if the call has not been "saved". `Twilio::Call#url=` will updated its state with the new URL ready for when `Twilio::Call#save` is called.

## Sending an SMS message

The API used to send an SMS message is similar to interacting with an ActiveRecord model object.
<pre>Twilio::SMS.create :to => '+16465551234', :from => '+19175550000', 
                   :body => "Hey baby, how was your day? x"</pre>
or
<pre>sms = Twilio::SMS.new :to => '+16465551234', :from => '+19175550000', 
                      :body => "Hey baby, how was your day? x"

sms.save</pre>

The parameter keys should be given as underscored symbols. They will be converted internally to camelized strings prior to an API call being made.

Please see the Twilio REST API documentation for an up to date list of supported parameters.