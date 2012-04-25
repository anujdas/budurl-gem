module Budurl
  def self.new(api_key, uri = BUDURL_PRO_BASE_URI)
    Budurl::Client.new(api_key, uri)
  end

  class Client
    include HTTParty

    format :json

    def initialize(api_key, uri)
      self.class.base_uri uri
      @default_query_opts = { :api_key => api_key }
    end

    def shorten(url, opts = {})
      query_opts = {:long_url => url}.merge(opts)
      response = get('/links/shrink', :query => query_opts)
      Budurl::Url.new(self, response)
    end

    def expand(short_url)
      query_opts = {:link => short_url}
      response = get('/links/expand', :query => query_opts)
      Budurl::Url.new(self, response)
    end

    def clicks(short_url, opts = {})
      query_opts = {:link => short_url}.merge(opts)
      response = get('/clicks/count', :query => query_opts)
    end

    def get(uri, opts = {})
      opts[:query] ||= {}
      opts[:query].merge!(@default_query_opts)
      response = self.class.get(uri, opts).parsed_response
      if response['success'] == 1
        response
      else
        raise Error.new(response['error_message'], response['error_code'])
      end
    end
  end

  class Error < StandardError
    attr_reader :code

    def initialize(message, code)
      @code = code
      super("#{code} - #{message}")
    end
  end
end

