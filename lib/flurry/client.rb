require 'net/http'
require 'net/https'
require 'uri'

module Flurry
  
  class ApiAccessCodeNotSet < Exception;end
  class ApiKeyNotSet < Exception;end
  class ApiError < Exception;end
  class UnknownError < Exception;end

  class Client

    attr_reader :api_access_code
    attr_reader :api_key
    attr_reader :api_host       # api.flurry.com
    attr_reader :api_url        # appCircle/v2/getRecommendations
    attr_reader :api_port       # 80 || 443
    attr_reader :raw_data
    attr_reader :query
    attr_reader :agent          # custom agent string

    def initialize(options = {})
      @api_access_code = options.delete(:api_access_code) || (raise Flurry::ApiAccessCodeNotSet)
      @api_key = options.delete(:api_key) || (raise Flurry::ApiKeyNotSet)
      @api_host = options.delete(:api_host) || 'api.flurry.com'
      @api_url = options.delete(:api_url) || '/appCircle/v2/getRecommendations'
      @api_port = options.delete(:api_port) || 80
      @agent = options.delete(:agent)
    end

    # mandatory params
    # iosUdid   - :udid
    # sha1Mac   - :mac
    # platform  - :platform (IPHONE, IPAD, AND)
    # ipAddress - :ip
    def fetch_recommendations(options = {})
      return false unless ([:udid, :mac, :ip] & options.keys).count == 3
      
      query_options = {
        :apiAccessCode => @api_access_code,
        :apiKey => @api_key,
        :iosUdid => options.delete(:udid),
        :sha1Mac => encode_mac(options.delete(:mac)),
        :platform => (options.delete(:platform) || 'IPHONE').upcase,
        :ipAddress => options.delete(:ip)
      }

      @query = to_query(query_options)
      
      http = Net::HTTP.new(@api_host, @api_port)
      http.use_ssl = (@api_port.to_i == 443)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      begin
        path = "#{@api_url}?#{@query}"

        response = http.get(path, headers)
      rescue Exception => e
        raise Flurry::UnknownError, e.message
      end

      @raw_data = JSON.parse(response.body)
      
      if response.code.to_i == 200
        result = decode
        
        return result unless @raw_data.empty?
      else
        raise Flurry::ApiError, message: "#{@raw_data['code']} - #{@raw_data['message']}"
      end

      false
    end

    # SHA1 encode of mac address
    # D9:2A:1A:0C:FD:0B should become CF41A96B9A6E4FE2942B4A51F350D7FD722E38B2
    def encode_mac(mac_address)
      Digest::SHA1.hexdigest(mac_address).upcase
    end
    
    private

    def to_query(data = {})
      data.map{|k,v| "#{k.to_s}=#{URI.escape(v.to_s)}"}.join('&')
    end

    # parse json and make object
    def decode
      Flurry::Feed.new(@raw_data)
    end

    # fetch headers
    def headers
      {'User-Agent'   => "Flurry-#{@agent}",
       'Accept'       => "application/json"}
    end
  end

end
