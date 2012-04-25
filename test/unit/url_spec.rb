require 'rubygems'
require 'rspec'
require 'budurl'
require 'budurl/url'
require File.dirname(__FILE__) + '/../helpers/budurl_mock'

require 'ruby-debug'

describe Budurl::Url do

  MIMIC_BASE_URI = 'http://127.0.0.1:11988'
  API_KEY = '12345'

  SHORT_URL = 'http://Ez.com/1234'
  LONG_URL = 'http://www.example.com'

  def create_short_url(long_url, short_url, opts={})
    data = {:link => long_url,
            :api_key => API_KEY,
            :count => 0,
            :dates => {}}.merge(opts)
    BudurlMock.short_to_long_urls[short_url] = data
  end

  before :all do
    @budurl = Budurl.new(API_KEY, MIMIC_BASE_URI)
  end

  before :each do
    BudurlMock.clear
    BudurlMock.api_keys << API_KEY
  end

  it 'saves the calling Budurl client internally' do
    url = Budurl::Url.new(@budurl)
    url.instance_variable_get(:@client).should be_an_instance_of(Budurl::Client)
  end

  it 'internalizes relevant information from a hash' do
    data = {'success' => '1',
            'link' => SHORT_URL,
            'long_url' => LONG_URL,
            'hash' => BudurlMock.hash_from_short_url(SHORT_URL)}
    url = Budurl::Url.new(@budurl, data)

    url.link.should == SHORT_URL
    url.long_url.should == LONG_URL
    url.hash.should == BudurlMock.hash_from_short_url(SHORT_URL)
  end

  describe '#clicks' do
    it 'returns the click count for a short URL' do
      create_short_url(LONG_URL, SHORT_URL, :count => 10, :dates => {'2012-01-01' => 10})

      data = {'success' => '1',
              'link' => SHORT_URL,
              'long_url' => LONG_URL,
              'hash' => BudurlMock.hash_from_short_url(SHORT_URL)}
      url = Budurl::Url.new(@budurl, data)

      url.clicks.should == 10
    end

    it 'returns the daily click counts for a URL with daily = true' do
      create_short_url(LONG_URL, SHORT_URL, :count => 10, :dates => {'2012-01-01' => 10})

      data = {'success' => '1',
              'link' => SHORT_URL,
              'long_url' => LONG_URL,
              'hash' => BudurlMock.hash_from_short_url(SHORT_URL)}
      url = Budurl::Url.new(@budurl, data)

      url.clicks(true).should == {'2012-01-01' => 10}
    end

    it 'raises Error 0 for a long URL with no short URL associated' do
      data = {'success' => '1',
              'link' => SHORT_URL,
              'long_url' => LONG_URL,
              'hash' => BudurlMock.hash_from_short_url(SHORT_URL)}
      url = Budurl::Url.new(@budurl)

      lambda { url.clicks }.should raise_error(Budurl::Error, /0/)
      lambda { url.clicks(true) }.should raise_error(Budurl::Error, /0/)
    end
  end
end
