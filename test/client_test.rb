require_relative "test_helper"

class Flurry::ClientTest < Test::Unit::TestCase

  def test_initialize
    client =
      Flurry::Client.new(
        :api_access_code => "access_code",
        :api_key => "api_key"
      )

    assert_equal("access_code", client.api_access_code)
    assert_equal("api_key", client.api_key)
  end

  def test_no_api_access_code
    assert_raise Flurry::ApiAccessCodeNotSet do
      Flurry::Client.new
    end
  end
  
  def test_no_api_key
    assert_raise Flurry::ApiKeyNotSet do
      Flurry::Client.new(:api_access_code => "access_code")
    end
  end

  # missing UDID
  def test_udid_not_found
    @client = Flurry::Client.new(:api_access_code => 'access_code', :api_key => 'my_key')
    assert_equal(false, @client.fetch_recommendations(:mac => 'abcd', :ip => '192'))
  end

  # missing mac
  def test_uid_not_found
    @client = Flurry::Client.new(:api_access_code => 'access_code', :api_key => 'my_key')
    assert_equal(false, @client.fetch_recommendations(:udid => 'sadfadsfas', :ip => '192'))
  end

  # missing ip
  def test_uid_not_found
    @client = Flurry::Client.new(:api_access_code => 'access_code', :api_key => 'my_key')
    assert_equal(false, @client.fetch_recommendations(:udid => 'sadfadsfas', :mac => 'abcd'))
  end

  # invalid api_host
  def test_invalid_api_host
    @client = Flurry::Client.new(:api_access_code => 'access_code', :api_key => 'my_key', :api_host => 'dummy.host')
    assert_raise Flurry::UnknownError do
      @client.fetch_recommendations(:udid => 'sadfadsfas', :mac => 'abcd', :ip => '192')
    end
  end

  # invalid api_port
  def test_invalid_port
    @client = Flurry::Client.new(:api_access_code => 'access_code', :api_key => 'my_key', :api_port => 123)
    assert_raise Flurry::UnknownError do
      @client.fetch_recommendations(:udid => 'sadfadsfas', :mac => 'abcd', :ip => '192')
    end
  end

  # test valid response
  def test_valid_request
    data = File.read("#{FIXTURES}/data.txt")
    FakeWeb.allow_net_connect = 'http://api.example.com'
    FakeWeb.register_uri(:get, "http://api.example.com/appCircle/v2/getRecommendations?apiAccessCode=4CWRDCC8PDJC99R8BSPC&apiKey=ZM7M97D79X3D5258M2BF&iosUdid=ea750fdbc619ca406d066d7ed158d54483fc382f&sha1Mac=CF41A96B9A6E4FE2942B4A51F360D7FD722E38B2&platform=IPHONE&ipAddress=92.240.181.8", :body => data, :content_type => "application_json")

    @client = Flurry::Client.new(:api_access_code => '4CWRDCC8PDJC99R8BSPC', :api_key => 'ZM7M97D79X3D5258M2BF', :api_host => 'api.example.com')

    @recommendation = @client.fetch_recommendations(:udid => 'ea750fdbc619ca406d066d7ed158d54483fc382f', :mac => 'D9:2A:1A:0C:FD:0B', :ip => '92.240.181.8')

    assert_equal(5, @recommendation.recommendations.count)
    assert_equal(['Jiri Techet', 'Charlie Elliott', 'ADS Software Group, Inc.', 'Caffeine Fish LLC', 'Travis croxford'], @recommendation.recommendations.map(&:publisherName))
    assert_equal('12/5/12 2:40 PM', @recommendation.generatedDate)
  end

  # any error
  def test_invalid_udid
    FakeWeb.allow_net_connect = 'http://api.example.com'
    FakeWeb.register_uri(:get, "http://api.example.com/appCircle/v2/getRecommendations?apiAccessCode=4CWRDCC8PDJC99R8BSPC&apiKey=ZM7M97D79X3DF&iosUdid=ea750fdbc619ca406d066d7ed158d54483fc382f&sha1Mac=CF41A96B9A6E4FE2942B4A51F360D7FD722E38B2&platform=IPHONE&ipAddress=92.240.181.8", :body => '{"code":100, "message":"API Key not found"}', :content_type => "application_json", :status => ["400","Error"])

    @client = Flurry::Client.new(:api_access_code => '4CWRDCC8PDJC99R8BSPC', :api_key => 'ZM7M97D79X3DF', :api_host => 'api.example.com')
    assert_raise Flurry::ApiError do
      @recommendation = @client.fetch_recommendations(:udid => 'ea750fdbc619ca406d066d7ed158d54483fc382f', :mac => 'D9:2A:1A:0C:FD:0B', :ip => '92.240.181.8')
    end
  end

end
