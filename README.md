
# Twilio.rb

Interact with the Twilio API in a nice Ruby way

## Installation

The library has been packaged as a gem and is available from rubygems.org

<pre>gem install twilio-rb</pre>

## Usage

Require the library in your script as

<pre>require 'twilio'</pre>

## Configuration

Configuration for this library is encapsulated within `Twilio::Config`. One needs to setup with an Account SID and an Auth Token, e.g.

<pre># This should be in an initializer or similar
Twilio::Config.setup do
  account_sid   'AC0000000000000000000000000000'
  auth_token    '000000000000000000000000000000'
end</pre>

Any method that calls the Twilio API will raise `Twilio::ConfigurationError` if either Account SID or Auth Token are not configured.

## The Account object

The Twilio API in its current incarnation supports one Twilio account per Account SID, and so the Twilio::Account object correspondingly is a singleton object.

To access properties of the account the property name should be called as a method on the object itself, e.g.

<pre>Twilio::Account.friendly_name</pre>

The first time a method is invoked on the object an API call is made to retrieve the data. The methods themselves are not defined until they are called, i.e. lazy evaluation. This strategy means that addtional properties added to subsequent versions of the API should not break the library.

To reload the data when needed `Twilio::Account.reload!` will make another API call and update its own internal state.

Predicate methods i.e. those ending in `?` map directly to the status of the account, e.g. `Twilio::Account.suspended?` returns true if Twilio have suspended your account. Again, all of these methods are defined on the fly.

The only account property that can be modified via the REST API is the friendly name, e.g.

<pre>Twilio::Account.friendly_name = "I'm so vain, I had to change my name!"</pre>

This will update the API immediately with a PUT request.

Please refer to the Twilio REST API documentation for an up to date list of properties.

## Making a telephone call

The API used to make a telephone call is similar to interacting with an ActiveRecord model object.
<pre>Twilio::Call.create :to => '+16465551234', :from => '+19175550000', 
                    :url => "http://example.com/call_handler"</pre>

The parameter keys should be given as underscored symbols. They will be converted internally to camelized strings prior to an API call being made.

Please see the Twilio REST API documentation for an up to date list of supported parameters. 

If the request was successful, an instance of `Twilio::Call` wil be returned

### Modifying a live telephone call

Once a call has been been created it can be modified with the following methods:

`Twilio::Call#cancel!` will terminate the call if its state is `queued` or `ringing`
`Twilio::Call#complete!` will terminate the call even if its state is `in-progress`
`Twilio::Call#url=` will immediately redirect the call to a new handler URL

`Twilio::Call#cancel!` and `Twilio::Call#complete!` will raise `Twilio::InvalidStateError` if the call has not been "saved". 
`Twilio::Call#url=` will updated its state with the new URL ready for when `Twilio::Call#save` is called.

## Finding an existing telephone call

To retrieve an earlier created call, there is the `Twilio::Call.find` method, which accepts a call SID, e.g.

<pre>call = Twilio::Call.find 'CAa346467ca321c71dbd5e12f627deb854'</pre>

This returns an instance of `Twilio::Call` if a call with the given SID was found, otherwise nil is returned 

## Sending an SMS message

The API used to send an SMS message is similar to interacting with an ActiveRecord model object.
<pre>Twilio::SMS.create :to => '+16465551234', :from => '+19175550000', 
                   :body => "Hey baby, how was your day? x"</pre>

The parameter keys should be given as underscored symbols. They will be converted internally to camelized strings prior to an API call being made.

Please see the Twilio REST API documentation for an up to date list of supported parameters.

If the request was successful, an instance of `Twilio::SMS` wil be returned

## Finding an existing telephone SMS message

To retrieve an earlier created SMS message, there is the `Twilio::SMS.find` method, which accepts a SMS message SID, e.g.

<pre>call = Twilio::SMS.find 'SM90c6fc909d8504d45ecdb3a3d5b3556e'</pre>

This returns an instance of `Twilio::SMS` if a SMS message with the given SID was found, otherwise nil is returned

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
