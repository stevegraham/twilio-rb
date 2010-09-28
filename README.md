
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

`Twilio::Call#cancel!` and `Twilio::Call#complete!` will raise `Twilio::InvalidStateError` if the call has not been "saved". 
`Twilio::Call#url=` will updated its state with the new URL ready for when `Twilio::Call#save` is called.

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

## Building TwiML documents

A TwiML document is an XML document. The best way to build XML in Ruby is with Builder, and so it follows that we should use builder for TwiML. `Twilio::TwiML.build` behaves like builder except element names are capitalised for you and attributes are camelized for you as well. This is so you may continue to write beautiful code.

The following Ruby code:

<pre>Twilio::TwiML.build do |res| 
  res.say    'Hey man! Listen to this!', :voice => 'man'
  res.play   'http://foo.com/cowbell.mp3'
  res.say    'What did you think of that?!', :voice => 'man'
  res.record :action => "http://foo.com/handleRecording.php",
             :method => "GET", :max_length => "20",
             :finish_on_Key => "*"
  res.gather :action => "/process_gather.php", :method => "GET" do |g|
    g.say 'Now hit some buttons!'
  end
  res.say    'Awesome! Thanks!', :voice => 'man'
  res.hangup
end</pre>

Therefore emits the following TwiML document:

<pre><?xml version="1.0" encoding="UTF-8"?>
&lt;Response&gt;
  &lt;Say voice="man"&gt;Hey man! Listen to this!&lt;/Say&gt;
  &lt;Play&gt;http://foo.com/cowbell.mp3&lt;/Play&gt;
  &lt;Say voice="man"&gt;What did you think of that?!&lt;/Say&gt;
  &lt;Record maxLength="20" method="GET" action="http://foo.com/handleRecording.php" finishOnKey="*"/&gt;
  &lt;Gather method="GET" action="/process_gather.php"&gt;
    &lt;Say&gt;Now hit some buttons!&lt;/Say&gt;
  &lt;/Gather&gt;
  &lt;Say voice="man"&gt;Awesome! Thanks!&lt;/Say&gt;
  &lt;Hangup/&gt;
&lt;/Response&gt;
</pre>

This specialised behaviour only affects `Twilio::TwiML.build` and does not affect Builder in general.
