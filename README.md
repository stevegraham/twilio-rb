# Twilio.rb

Interact with the Twilio API in a nice Ruby way.

Twilio.rb is the only library that encapsulates Twilio resources as Ruby objects, has 100% test coverage, and supports the whole API.

It offers an ActiveRecord style API, i.e. one that most Ruby developers are familiar using to manipulate Ruby objects with.

## Installation

The library has been packaged as a gem and is available from rubygems.org. The version that this readme pertains to is 2.0.0.

<pre>gem install twilio-rb</pre>

Please use the Github issue tracker to report any issues or bugs you uncover.

## Usage

Require the library in your script as

<pre>require 'twilio-rb'</pre>

or using bundler:

<pre>gem 'twilio-rb'</pre>

## Configuration

Configuration for this library is achieved with `Twilio::Config.setup`. One needs to setup with an Account SID and an Auth Token, e.g.

<pre># This should be in an initializer or similar
Twilio::Config.setup \
  :account_sid  => 'AC0000000000000000000000000000',
  :auth_token   => '000000000000000000000000000000'
</pre>

Any method that calls the Twilio API will raise `Twilio::ConfigurationError` if either Account SID or Auth Token are not configured.

# Getting started

## Summary

Twilio resources are represented as Ruby objects. List resources are represented by classes, e.g. `Twilio::SMS` and operations on list resources are performed using class methods, e.g. `Twilio::SMS.create`. Resource instances are represented by instances of those classes, and operations on those resource instances are performed using instance methods.

Resources that can be created via the API, using the HTTP POST verb can be done so in the library using the `.create` class method, e.g.

<pre>Twilio::Call.create :to => '+16465551234', :from => '+19175550000',
                    :url => "http://example.com/call_handler"</pre>

Resources that can be removed via the API, using the HTTP DELETE verb can be done so in the library using the `#destroy` instance method, e.g.

<pre>
# Delete all log entries
Twilio::Notification.all.each &:destroy
</pre>

Object representations instantiated by the library respond to all methods that match attributes on its corresponding resource. The method names are those of the parameters in snake case (underscored), i.e. as they are returned in the JSON representation.

The Twilio API documentation itself is the canonical reference for which resources have what properties, and which of those can be updated by the API. Please refer to the Twilio REST API documentation for that information.

## Accessing resource instances

Resource instances can be accessed ad hoc passing the resource sid to the `.find` class method on the resource class, e.g.

<pre>call = Twilio::Call.find 'CAe1644a7eed5088b159577c5802d8be38'</pre>

This will return an instance of the resource class, in this case `Twilio::Call`, with the attributes of the resource. These attributes are accessed using dynamically defined getter methods, where the method name is the attribute name underscored, i.e. as they are returned in a JSON response from the API.

Sometimes these method name might collide with native Ruby methods, one such example is the `method` parameter colliding with `Object#method`. Native Ruby methods are never overridden by the library as they are lazily defined using `method_missing`. To access these otherwise unreachable attributes, there is another syntax for accessing resource attributes:

<pre>
call = Twilio::Call.find 'CAe1644a7eed5088b159577c5802d8be38'
call[:method] # With a symbol or
call['method'] # or with a string. Access is indifferent.
</pre>

## Querying list resources

List resources can be accessed ad hoc by calling the `.all` class method on the resource class, e.g.

<pre>calls = Twilio::Call.all</pre>

This will return a collection of objects, each a representation of the corresponding resource.

### Using filter parameters to refine a query

The `.all` class method will ask Twilio for all resource instances on that list resource, this can easily result in a useless response if there are numerous resource instances on a given resource. The `.all` class method accepts a hash of options for parameters to filter the response, e.g.

<pre>Twilio::Call.all :to => '+19175550000', :status => 'complete'</pre>

Twilio does some fancy stuff to implement date ranges, consider the API request:

<pre>GET /2010-04-01/Accounts/AC5ef87.../Calls?StartTime&gt;=2009-07-06&EndTime&lt;=2009-07-10</pre>

This will return all calls started after midnight July 06th 2009 and completed before July 10th 2009. Any call started and ended within that time range matches those criteria and will be returned. To make the same request using this library:

<pre>
require 'date'
start_date, end_date = Date.parse('2009-07-06'),  Date.parse('2009-07-10')

Twilio::Call.all :started_after => start_date, :ended_before => end_date
</pre>

All option parameters pertaining to dates accept a string or any object that returns a RFC 2822 date when `#to_s` is called on it, e.g. an instance of `Date`. If a date parameter is not a range but absolute, one can of course use the normal option, e.g.

<pre>Twilio::Call.all :start_time => start_date</pre>

The key names for these Date filters are inconsistent across resources, in the library they are:

<pre>
Twilio::SMS.all :created_before => date, :created_after => date, :sent_before => date, :sent_after # :"created_#{when}" and :"sent_#{when}" are synonymous
Twilio::Notification.all :created_before => date, :created_after => date
Twilio::Call.all :started_before => date, :started_after => date, :ended_before => date, :ended_after => date
</pre>

### Pagination

The Twilio API paginates API responses and by default it will return 30 objects in one response, this can be overridden to return up to a maximum of 1000 per response using the `:page_size` option, If more than 1000 resources instances exist, the `:page` option is available, e.g.

<pre>Twilio::Call.all :started_after => start_date, :ended_before => end_date, :page_size => 1000, :page => 7</pre>

To determine how many resources exist, the `.count` class method exists, which accepts the same options as `.all` in order to constrain the query e.g.

<pre>Twilio::Call.count :started_after => start_date, :ended_before => end_date</pre>

It returns an integer corresponding to how many resource instances exist with those conditions.

## Updating resource attributes

Certain resources have attributes that can be updated with the REST API. Instances of those resources can be updated using either a setter method with a name that corresponds to the attribute, or by using the `#update_attributes`.

<pre>
call = Twilio::Call.all(:status => 'in-progress').first

call.url = 'http://example.com/in_ur_apiz_hijackin_ur_callz.xml'
call.update_attributes :url => 'http://example.com/in_ur_apiz_hijackin_ur_callz.xml'
</pre>

These are both equivalent, i.e. they immediately make an API request and update the state of the object with the API response. The first one in fact uses the second one internally and is just a shortcut. Use the second when there is more than one attribute to be updated in the same HTTP request.

## Making a telephone call

The API used to make a telephone call is similar to interacting with an ActiveRecord model object.
<pre>Twilio::Call.create :to => '+16465551234', :from => '+19175550000',
                    :url => "http://example.com/call_handler"</pre>

The parameter keys should be given as underscored symbols. They will be converted internally to camelized strings prior to an API call being made.

Please see the Twilio REST API documentation for an up to date list of supported parameters.

If the request was successful, an instance of `Twilio::Call` wil be returned

### Modifying a live telephone call

As well as the the aforementioned setter methods, once a call has been been created it can be modified with the following convenience methods:

`Twilio::Call#cancel!` will terminate the call if its state is `queued` or `ringing`
`Twilio::Call#complete!` will terminate the call even if its state is `in-progress`
`Twilio::Call#url=` will immediately redirect the call to a new handler URL

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

## Finding an existing SMS message

To retrieve an earlier created SMS message, there is the `Twilio::SMS.find` method, which accepts a SMS message SID, e.g.

<pre>call = Twilio::SMS.find 'SM90c6fc909d8504d45ecdb3a3d5b3556e'</pre>

This returns an instance of `Twilio::SMS` if a SMS message with the given SID was found, otherwise nil is returned

# Twilio Client

To generate capability tokens for use with Twilio Client you can use `Twilio::CapabilityToken.create`

<pre>
Twilio::CapabilityToken.create \
  allow_incoming: 'unique_identifier_for_this_user',
  allow_outgoing: 'your_application_sid'
</pre>

You can create capability tokens on arbitrary accounts, e.g. subaccounts. Just pass in those details:

<pre>
Twilio::CapabilityToken.create \
  account_sid:    'AC00000000000000000000000',
  auth_token:     'XXXXXXXXXXXXXXXXXXXXXXXXX',
  allow_incoming: 'unique_identifier_for_this_user',
  allow_outgoing: 'your_application_sid'
</pre>

You can also pass arbitrary parameters into your outgoing privilege, these are sent from Twilio as HTTP request params when it hits your app endpoint for TwiML.

<pre>
Twilio::CapabilityToken.create allow_outgoing: ['your_application_sid', { :foo => 'bar' }]
</pre>

By default tokens expire exactly one hour from the time they are generated. You can choose your own token ttl like so:

<pre>
Twilio::CapabilityToken.create \
  allow_incoming: 'unique_identifier_for_this_user',
  allow_outgoing: 'your_application_sid',
  expires:        10.minutes.from_now
</pre>

# Twilio Connect

With Twilio Connect you can attribute Twilio usage to accounts of customers that have authorized you to perform API calls on there behalf. twilio-rb supports Twilio Connect. To make an API call using a Twilio Connect account, two extra parameters are required, `account_sid` and `connect`

<pre>
Twilio::SMS.create to: '+12125551234', from: '+6165550000', body: 'this will not be billed to the application developer',
  account_sid: CONNECT_ACCOUNT_SID, connect: true
</pre>

# Associations

Certain resources themselves have subresources, e.g. a call can have many recordings. It would be very convenient to access these via an association proxy, so instead of:

<pre>
calls = Twilio::Call.all
recordings = Twilio::Recording.all :call_sid => calls.last.sid
</pre>

You might prefer:

<pre>
calls = Twilio::Call.all
recordings = calls.recordings.all
</pre>

twilio-rb now supports these association proxies

# Subaccounts

The Twilio REST API supports subaccounts that is discrete accounts owned by a master account. twilio-rb supports this too.o

## Subaccount creation

You can create new subaccounts by using `Twilio::Account.create`

## Performing actions on resources belonging to subaccounts

There are three ways to perform an operation on an account other than the master account: you can pass in the subaccount sid

<pre>Twilio::SMS.create :to => '+19175551234' :from => '+16465550000',
  :body => 'This will be billed to a subaccount, sucka!' :account_sid => 'ACXXXXXXXXXXXXXXXXXXXXXXXX'</pre>

You can also pass in an object that responds to sid, i.e. an instance of Twilio::Account

<pre>Twilio::SMS.create :to => '+19175551234' :from => '+16465550000',
  :body => 'This TOO will be billed to a subaccount, sucka!' :account => my_subaccount_object</pre>

By using an association proxy. By chaining the list resource methods, e.g. find, create, etc, on the association proxy, they are scoped to that account

<pre>
bobs_account = Twilio::Account.find :friendly_name => "Bob's subaccount"

# This will send a SMS message on Bob's subaccount
bobs_account.sms.create :to => '+16465551234', :from => '+19175550000', :body => "Bob is paying for this text. What a guy!"
</pre>

# Building TwiML documents

A TwiML document is an XML document. The best way to build XML in Ruby is with Builder, and so it follows that we should use builder for TwiML. `Twilio::TwiML.build` behaves like builder except element names are capitalized for you and attributes are camelized for you as well. This is so you may continue to write beautiful code.

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

This specialized behaviour only affects `Twilio::TwiML.build` and does not affect Builder in general.

# Rails 3 integration

Twilio.rb has Rails integration out of the box. It adds a new mime type :voice and a template handler for TwiML views.
So now your Rails app can respond_to :voice. Insane!

<pre>
class FooController &lt; ApplicationController
  respond_to :html, :voice

  def index
   ...
  end
end
</pre>

coupled with the following view file `app/views/foo/index.voice`

<pre>
res.say 'Damn this library is so ill dude!'
</pre>

It's now easier than ever to integrate Twilio in your Rails app cleanly and easily.

## Manipulating conference participants

The participants list resource is a subresource of a conference resource instance:

<pre>conference = Twilio::Conference.find 'CFbbe46ff1274e283f7e3ac1df0072ab39'</pre>

Conference participants are accessed via the `#participants` instance method, e.g.

<pre>participants = conference.participants</pre>

The muted state can be toggled using the `#mute!` instance method, e.g. toggle the mute state off all participants:

<pre>participants.each &:mute!</pre>

Participants can be removed from the conference using the '#destroy instance method'

# Singleton resources

The Twilio API in its current incarnation has one singleton (scoped per account) resource, correspondingly there is Twilio::Sandbox singleton objects.

To access properties of a singleton object the property name should be called as a method on the object itself, e.g.

<pre>Twilio::Sandobox.friendly_name</pre>

The first time a method is invoked on the object an API call is made to retrieve the data. The methods themselves are not defined until they are called, i.e. lazy evaluation. This strategy means that additional properties added to subsequent versions of the API should not break the library.

Please refer to the Twilio REST API documentation for an up to date list of properties that the sandbox resource implements

# Searching for and purchasing available phone numbers

The Twilio API allows a user to search for available phone numbers in Twilio's inventory. e.g. to find a number in the 917 area code containing '7777':

<pre>Twilio::AvailablePhoneNumber.all :area_code => '917', :contains => '7777'</pre>

A collection of Twilio::AvailablePhoneNumber objects will be returned. e.g. To purchase the first one:

<pre>numbers = Twilio::AvailablePhoneNumber.all :area_code => '917', :contains => '7777'
numbers.first.purchase! :voice_url => 'http://example.com/twiml.xml'</pre>

Which is a shortcut for:

<pre>numbers = Twilio::AvailablePhoneNumber.all :area_code => '917', :contains => '7777'
Twilio::IncomingPhoneNumber.create :phone_number => numbers.first.phone_number, :voice_url => 'http://example.com/twiml.xml'</pre>

# Recordings

A recording resource instance has an extra instance method: `#mp3` this returns a publicly accessible URL for the MP3 representation of the resource instance.

# Contributors

* Stevie Graham
* TJ Singleton
* Christopher Durtschi
* Dan Imrie-Situnayake
* John Trupiano
* Aaron Lerch
