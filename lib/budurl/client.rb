module Budurl
  def self.new(api_key, uri = BUDURL_PRO_BASE_URI)
    Budurl::Client.new(api_key, uri)
  end

  class Client
    include HTTParty

    format :json

    # Returns a Budurl client which can be used to query API services.
    # uri is the base uri for the BudURL API.
    def initialize(api_key, uri)
      self.class.base_uri uri
      @default_query_opts = { :api_key => api_key }
    end

    # Returns a Budurl::Url object containing a shorturl.
    # opts allow duplicate checking, notes, etc. For all options,
    # see the BudURL API: http://budurl.com/page/budurlpro-api
    def shorten(url, opts = {})
      query_opts = {:long_url => url}.merge(opts)
      response = get('/links/shrink', :query => query_opts)
      Budurl::Url.new(self, response)
    end

    # Returns a Budurl::Url object containing a longurl.
    def expand(short_url)
      query_opts = {:link => short_url}
      response = get('/links/expand', :query => query_opts)
      Budurl::Url.new(self, response)
    end

    # Returns a hash containing click counts since creation.
    # opts allow daily click counts and date filters. For all options,
    # see the BudURL API: http://budurl.com/page/budurlpro-api
    def clicks(short_url, opts = {})
      query_opts = {:link => short_url}.merge(opts)
      response = get('/clicks/count', :query => query_opts)
    end

    def get(uri, opts = {})
      opts[:query] ||= {}
      opts[:query].merge!(@default_query_opts)
      response = self.class.get(uri, opts).parsed_response
      if response.nil?
        raise Error.new('No response from server.', 0)
      elsif response['success'] == 1
        response
      else
        raise Error.new(response['error_message'], response['error_code'])
      end
    end
    private :get
  end

  # This class encapsulates BudURL API errors into a usable form.
  class Error < StandardError
    attr_reader :code

    def initialize(message, code)
      @code = code
      super("#{code} - #{message}")
    end
  end
end

