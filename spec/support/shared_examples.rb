require 'active_support/core_ext/string'

def resource_name
  described_class.name.demodulize
end

RSpec.shared_examples "a collection resource" do
  before do
    Twilio::Config.setup \
      account_sid: 'AC228ba7a5fe4238be081ea6f3c44186f3',
      auth_token:  '79ad98413d911947f0ba369d295ae7a3'
  end

  def resource_uri(options={})
    options[:account_sid] ||= Twilio::Config.account_sid

    sid = options.key?(:sid) ? "/#{options.delete(:sid)}" : ""
    url = "https://#{options[:account_sid]}:#{Twilio::Config.auth_token}" +
      "@api.twilio.com/2010-04-01/#{resource_name.pluralize}#{sid}.json"

    options[:query] ? url + '?' + options[:query] : url
  end

  def stub_api_call(options)
    request_params = { headers: {'User-Agent'=>"twilio-rb/#{Twilio::VERSION}"} }
    defaults       = { method: :get }

    request_params.update options.delete(:with) if options.key?(:with)
    defaults.update options

    stub_request(defaults[:method], resource_uri(defaults)).
      with(request_params).
      to_return body: canned_response(defaults[:returning]), status: 200
  end

  let(:post_body) { "FriendlyName=REST%20test" }
  let(:fixture_name) { "list_#{resource_name.underscore.pluralize}" }

  before { stub_api_call returning: fixture_name }

  describe '.count' do
    it "returns the #{resource_name.humanize} count" do
      expect(described_class.count).to eq(6)
    end

    context 'with query params' do
      let(:query)   { 'FriendlyName=example' }
      let(:request) { stub_api_call query: query, returning: fixture_name }

      before { request }

      it 'accepts options to refine the search' do
        described_class.count friendly_name: 'example'

        expect(request).to have_been_made
      end
    end
  end

  describe '.all' do
    let(:response) { described_class.all }
    let(:representation) do
      JSON.parse(canned_response(fixture_name))[resource_name.underscore.pluralize]
    end

    it 'returns a collection of objects with a length corresponding to the response' do
      expect(response.length).to eq(1)
    end

    it 'returns a collection containing instances of Twilio::Account' do
      expect(response.grep described_class).to eq(response)
    end

    it 'exposes all resource properties as instance methods' do
      representation.each_with_index do |obj, i|
        obj.each do |attr, value|
          expect(response[i].send(attr)).to eq(value)
        end
      end
    end

    context 'with query params' do
      let(:query)   { 'FriendlyName=example&Page=5' }
      let(:request) { stub_api_call returning: fixture_name, query: query }

      before { request }

      it 'accepts options to refine the search' do
        described_class.all page: 5, friendly_name: 'example'
        expect(request).to have_been_made
      end
    end
  end

  describe '.create' do
    let(:subject) { described_class.create friendly_name: 'REST test' }
    let(:fixture_name) { resource_name.downcase }

    let(:request) do
      stub_api_call \
        method: :post, with: { body: post_body }, returning: fixture_name
    end

    before { request }

    it 'creates a new incoming account on the account' do
      subject
      expect(request).to have_been_made
    end

    it { is_expected.to be_a(described_class) }

    it 'has instance methods corresponding to the resource properties' do
      JSON.parse(canned_response(fixture_name)).map do |property, value|
        expect(subject.send(property)).to eq(value)
      end
    end
  end

  describe '.find' do
    context 'for a valid account' do
      let(:sid)     { resource_name[0..1].upcase + '2a0747eba6abf96b7e3c3ff0b4530f6e' }
      let(:subject) { described_class.find sid }

      before { stub_api_call returning: fixture_name, sid: sid }

      it "returns an instance of #{described_class}" do
        expect(subject).to be_a(described_class)
      end

      it 'has instance methods corresponding to the resource properties' do
        JSON.parse(canned_response(fixture_name)).map do |property, value|
          expect(subject.send(property)).to eq(value)
        end
      end
    end

    context 'for a string that does not correspond to a real account' do
      before do
        stub_request(:get, resource_uri(sid: 'phony')).to_return :status => 404
      end

      it 'returns nil' do
        expect(described_class.find 'phony').to be_nil
      end
    end
  end

  describe '#update_attributes' do
    let(:subject) { described_class.create friendly_name: 'REST test' }
    let(:params)  { { friendly_name: 'REST test' } }
    let(:fixture_name) { resource_name.downcase }

    before do
      stub_api_call method: :post, with: { body: post_body }, returning: fixture_name
    end

    let(:request) do
      stub_api_call \
        method: :post, with: { body: post_body },
        sid: subject.sid,
        returning: fixture_name
      end

    context 'when the resource has been persisted' do
      it 'updates the API account the new parameters' do
        request
        subject.update_attributes params
        expect(request).to have_been_made
      end
    end
  end
end
