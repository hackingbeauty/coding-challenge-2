require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'json'
require 'oauth'
require 'json'

### Configuration
configure do   
  config = YAML::load(File.read('config.yml'))
  config.each_pair do |key, value|
    set(key.to_sym, value)
  end
end

get '/' do
  consumer = OAuth::Consumer.new(settings.yelp_consumer_key, settings.yelp_consumer_secret, {:site => "http://#{settings.yelp_api_host}"})
  access_token = OAuth::AccessToken.new(consumer, settings.yelp_token, settings.yelp_token_secret)
  path = "/v2/search?term=restaurants&location=san%20francisco"
  hash = JSON.parse(access_token.get(path).body) #convert JSON to ruby Hash
  @top_restaurants = hash.fetch("businesses")
  @restaurant_categories = ""
  @most_recent_reviews = ""
  haml :index
end
