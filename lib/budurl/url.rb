require 'date'

module Budurl
  class Url

    attr_accessor :link, :long_url, :hash

    def initialize(client, response = nil)
      @client = client

      if response && response.is_a?(Hash)
        @link = response['link']
        @long_url = response['long_url']
        @hash = response['hash']
      end
    end

    def clicks(daily=false, date_from=nil, date_to=nil)
      opts = { :daily => daily ? 1 : 0 }
      opts.merge!(:date_from => date_from.to_s) if date_from
      opts.merge!(:date_to => date_to.to_s) if date_to

      response = @client.clicks(@link, opts)
      daily ? response['dates'] : response['count']
    end
  end
end
