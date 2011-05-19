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
  # hash = JSON.parse(access_token.get(path).body) #convert JSON to ruby Hash
  hash = JSON.parse(settings.yelp_json_response)
  @restaurants = hash.fetch("businesses")
  @categories = get_categories(@restaurants)
  
  puts "===="
  p @categories
  
  @most_recent_reviews = ""
  haml :index
end

def get_categories(restaurants)
  # p restaurants
  categories = {}
  restaurants.each do |restaurant|
    category = restaurant["categories"][0][0]
    arr = []
    arr << restaurant
    h = {}
    if categories.has_key?(category)
      previous_category = categories[category][0]
      arr << previous_category
    end
    h["restaurants"] = arr      
    categories[category] = arr
  end
  return categories
end
