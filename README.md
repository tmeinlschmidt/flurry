# Flurry

Fetch Flurry app recommendations through their API. 

See ``http://support.flurry.com/index.php?title=API/Code/GetRecommendations`` for more info.

## Installation

Add this line to your application's Gemfile:

    gem 'flurry'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flurry

## Usage

    @client = Flurry::Client.new(:api_access_code => 'my_api_access_code', :api_key => 'my_api_key')
    @recommendation = @client.fetch_recommendations(:udid => 'asfereffajnfasfafafawfafaoweb', :mac => 'D9:2A:1A:0C:FD:0B', :ip => '127.0.0.2')

recommendations are then in ``@recommendations.recommendations`` array

## Available options for Client

* ``api_access_code`` - your API Access code, **required**
* ``api_key`` - your API key, **required**
* ``api_host`` - default set to ``api.flurry.com``
* ``api_url`` - default set to ``/appCircle/v2/getRecommendations``
* ``api_port`` - 80 or 443 for SSL
* ``agent`` - optionally Agent string, sent with request

## Available options for fetching recommendations

all options are required

* ``udid`` - non-modified UDID from device, 
* ``mac`` - MAC address of the device
* ``ip`` - IP address of the user

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
