module Twilio
  module Finder
    def find(id, opts={})
      opts        = opts.with_indifferent_access
      # Support subaccounts by optionally passing in an account_sid or account object
      account_sid = opts.delete('account_sid') || opts.delete('account').try(:sid) || Twilio::ACCOUNT_SID
      res  = get "/Accounts/#{account_sid}/#{resource_name}/#{id}.json"
      hash = res.parsed_response
      if (200..299).include? res.code
        hash['api_version'] = hash['api_version'].to_s # api_version parsed as a date by http_party
        new hash
      end
    end

    def count(opts={})
      opts        = opts.with_indifferent_access
      # Support subaccounts by optionally passing in an account_sid or account object
      account_sid = opts.delete('account_sid') || opts.delete('account').try(:sid) || Twilio::ACCOUNT_SID
      params      = prepare_params opts if opts.any?
      get("/Accounts/#{account_sid}/#{resource_name}.json#{params}").parsed_response['total']
    end

    def all(opts={})
      opts        = opts.with_indifferent_access
      # Support subaccounts by optionally passing in an account_sid or account object
      account_sid = opts.delete('account_sid') || opts.delete('account').try(:sid) || Twilio::ACCOUNT_SID
      params      = prepare_params opts if opts.any?
      handle_response get "/Accounts/#{account_sid}/#{resource_name}.json#{params}"
    end

    private

    def resource_name
      name.demodulize.pluralize
    end

    def prepare_params(opts) # :nodoc:
      pairs = opts.map do |k,v|
        if %w(updated_before created_before updated_after created_after).include? k
          # Fancy schmancy-ness to handle Twilio <= URI operator for dates
          comparator = k =~ /before$/ ? '<=' : '>='
          CGI.escape("Date" << k.gsub(/\_\w+$/, '').capitalize << comparator << v.to_s)
        else
          "#{k.to_s.camelize}=#{CGI.escape v.to_s}"
        end
      end
      "?#{pairs.join('&')}"
    end

    def handle_response(res) # :nodoc:
      if (400..599).include? res.code
        raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
      else
        key = name.demodulize == 'SMS' ? 'sms_messages' : name.demodulize.underscore.pluralize
        res.parsed_response[key].map do |p|
          p['api_version'] = p['api_version'].to_s # api_version parsed as a date by http_party
          new p
        end
      end
    end

  end
end
