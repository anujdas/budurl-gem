require 'rubygems'
require 'mimic'
require 'json'

class BudurlMock

  API_KEY_ERROR = 100
  LONG_URL_ERROR = 200
  SHORT_URL_ERROR = 400

  def initialize
    self.clear
  end

  [:api_keys, :short_to_long_urls].each do |var|
    class_eval %{
      def self.#{var.to_s}
        @@#{var}
      end
    }
  end

  def self.clear
    # valid api keys
    @@api_keys = []

    # url mappings: short_url => {link, api_key, count, dates => {date => count, ...}}
    @@short_to_long_urls = {}

    # next unused short_url
    @@next_hash = 0
  end

  def self.hash_from_short_url(url)
    url.match(/^http:\/\/Ez\.com\/(\d{4})$/)[1]
  end

  def self.short_url_from_hash(hash)
    "http://Ez.com/#{hash}"
  end

  def self.find_by_long_url(long_url)
    short_url = @@short_to_long_urls.select{|k,v| v[:link] == long_url}.last
    short_url ? short_url[0] : nil
  end

  def self.error_response(code)
    {:success => 0, :error_code => code, :error_message => "Error"}
  end

  Mimic.mimic do
    get '/links/shrink' do
      if !@@api_keys.include?(params[:api_key])
        response = BudurlMock.error_response(API_KEY_ERROR)
      elsif params[:long_url].empty?
        response = BudurlMock.error_response(LONG_URL_ERROR)
      else
        if params[:dupe_check] != '1' || !(short_url = BudurlMock.find_by_long_url(params[:long_url]))
          short_url = BudurlMock.short_url_from_hash("%04d" % @@next_hash += 1)
          @@short_to_long_urls[short_url] = {:link => params[:long_url],
                                             :api_key => params[:api_key],
                                             :count => 0,
                                             :date => {}}
        end
        response = {:success => 1,
                    :link => short_url,
                    :hash => BudurlMock.hash_from_short_url(short_url),
                    :link_preview => short_url + '?'}
      end

      return [200, response.to_json]
    end

    get '/links/expand' do
      if !@@api_keys.include?(params[:api_key])
        response = BudurlMock.error_response(API_KEY_ERROR)
      elsif params[:link].nil?
        return [200, nil]
      else
        url = @@short_to_long_urls[params[:link]]
        if url.nil?
          response = BudurlMock.error_response(SHORT_URL_ERROR)
        else
          response = {:success => 1,
                      :long_url => url[:link]}
        end
      end

      return [200, response.to_json]
    end

    get '/clicks/count' do
      if !@@api_keys.include?(params[:api_key])
        response = BudurlMock.error_response(API_KEY_ERROR)
      elsif params[:link].nil?
        return [200, nil]
      elsif !(url = @@short_to_long_urls[params[:link]])
        response = BudurlMock.error_response(SHORT_URL_ERROR)
      elsif params[:api_key] != url[:api_key]
        response = BudurlMock.error_response(API_KEY_ERROR)
      else
        response = {:success => 1,
                    :link => params[:link],
                    :hash => BudurlMock.hash_from_short_url(params[:link]),
                    :count => url[:count]}
        response.merge!(:dates => url[:dates]) if params[:daily] == '1'
      end

      return [200, response.to_json]
    end
  end
end
