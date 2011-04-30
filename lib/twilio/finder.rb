module Twilio
  module Finder
    def find(id)
      res  = get "/Accounts/#{Twilio::ACCOUNT_SID}/#{resource_fragment}/#{id}.json"
      hash = res.parsed_response
      if (200..299).include? res.code
        hash['api_version'] = hash['api_version'].to_s # api_version parsed as a date by http_party
        new hash
      end
    end

    def count(opts={})
      opts   = prepare_dates opts
      params = prepare_params opts

      get("/Accounts/#{Twilio::ACCOUNT_SID}/#{resource_fragment}.json#{params}").parsed_response['total']
    end

    def all(opts={})
      opts   = prepare_dates opts
      params = prepare_params opts

      handle_response get "/Accounts/#{Twilio::ACCOUNT_SID}/#{resource_fragment}.json#{params}"
    end

    private

    def resource_fragment # :nodoc:
      # All Twilio resources follow a convention, except SMS :(
      klass_name = name.demodulize
      resource   = klass_name == 'SMS' ? "#{klass_name}/Messages" : klass_name.pluralize
    end

    def prepare_dates(opts) # :nodoc:
      opts.map do |k,v|
        if [:updated_before, :created_before, :updated_after, :created_after].include? k
          k = k.to_s
          # Fancy schmancy-ness to handle Twilio <= URI operator for dates
          comparator = k =~ /before$/ ? '<=' : '>='
          "Date" << k.gsub(/\_\w+$/, '').capitalize << comparator << v.to_s
        else
          "#{k.to_s.camelize}=#{v}"
        end
      end
    end

    def prepare_params(opts)
      # call URI twice, once to handle colon - otherwise a colon in the query var forces request to xml
      # see: http://getsatisfaction.com/twilio/topics/json_request_returning_xml_if_query_vars_contains_a_colon
      "?#{URI.encode(URI.encode(opts.join('&')), ":")}" unless opts.empty?
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
