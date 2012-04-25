require 'rubygems'
require 'rspec'
require 'budurl'
require 'budurl/client'
require File.dirname(__FILE__) + '/../helpers/budurl_mock'

require 'ruby-debug'

describe Budurl::Client do

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

  it 'initialises with the correct API key' do
    @budurl.instance_variable_get(:@default_query_opts).should == {:api_key => API_KEY}
  end

  it 'returns a Budurl::Client object' do
    @budurl.should be_an_instance_of(Budurl::Client)
  end

  describe '#shorten' do
    it 'successfully shortens a URL' do
      url = @budurl.shorten(LONG_URL)

      url.link.should == BudurlMock.find_by_long_url(LONG_URL)
      url.hash.should == BudurlMock.hash_from_short_url(url.link)
      url.long_url.should be_nil
    end

    it 'creates unique short URLs if dupe_check is off' do
      create_short_url(LONG_URL, SHORT_URL)
      url = @budurl.shorten(LONG_URL)

      url.link.should_not == SHORT_URL
      url.hash.should_not == BudurlMock.hash_from_short_url(SHORT_URL)
      url.long_url.should be_nil
    end

    it 'returns the last address if dupe_check is on' do
      create_short_url(LONG_URL, SHORT_URL)
      url = @budurl.shorten(LONG_URL, :dupe_check => 1)

      url.link.should == SHORT_URL
      url.hash.should == BudurlMock.hash_from_short_url(SHORT_URL)
      url.long_url.should be_nil
    end

    it 'creates a new short URL if dupe_check is on but no duplicates exist' do
      url = @budurl.shorten(LONG_URL, :dupe_check => 1)

      url.link.should == BudurlMock.find_by_long_url(LONG_URL)
      url.hash.should == BudurlMock.hash_from_short_url(url.link)
      url.long_url.should be_nil
    end

    it 'reports Error 200 when called without a URL' do
      lambda { @budurl.shorten(nil) }.should raise_error(Budurl::Error, /200/)
    end

    it 'reports Error 100 when called with an invalid API key' do
      BudurlMock.api_keys.delete(API_KEY)
      lambda { @budurl.shorten(LONG_URL) }.should raise_error(Budurl::Error, /100/)
    end
  end

  describe '#expand' do
    it 'successfully expands an extant short URL' do
      create_short_url(LONG_URL, SHORT_URL)
      url = @budurl.expand(SHORT_URL)

      url.long_url.should == LONG_URL
      url.link.should be_nil
      url.hash.should be_nil
    end

    it 'reports Error 400 when passed an invalid short URL' do
      lambda { @budurl.expand(SHORT_URL) }.should raise_error(Budurl::Error, /400/)
    end
  end

  describe '#clicks' do
    it 'produces a total click count' do
      create_short_url(LONG_URL, SHORT_URL, :count => 10)
      count = @budurl.clicks(SHORT_URL)

      count.should be_an_instance_of(Hash)
      count['link'].should == SHORT_URL
      count['hash'].should == BudurlMock.hash_from_short_url(SHORT_URL)
      count['count'].should == 10
      count['dates'].should be_nil
    end

    it 'produces a day-to-day click count hash with the correct options' do
      dates = {'2012-01-01' => 3, '2012-01-02' => 4, '2012-01-03' => 3}
      create_short_url(LONG_URL, SHORT_URL, :count => 10, :dates => dates)
      count = @budurl.clicks(SHORT_URL, :daily => 1)

      count.should be_an_instance_of(Hash)
      count['link'].should == SHORT_URL
      count['hash'].should == BudurlMock.hash_from_short_url(SHORT_URL)
      count['count'].should == 10
      count['dates'].should be_an_instance_of(Hash)
      count['dates'].should == dates
    end

    it 'reports Error 400 when passed an invalid short URL' do
      lambda { @budurl.clicks(SHORT_URL) }.should raise_error(Budurl::Error, /400/)
    end

    it 'reports Error 100 when passed a short URL not belonging to us' do
      create_short_url(LONG_URL, SHORT_URL, :api_key => '00000')
      lambda { @budurl.clicks(SHORT_URL) }.should raise_error(Budurl::Error, /100/)
    end

    it 'reports Error 100 when called with an invalid API key' do
      BudurlMock.api_keys.delete(API_KEY)
      lambda { @budurl.clicks(SHORT_URL) }.should raise_error(Budurl::Error, /100/)
    end
  end
end
