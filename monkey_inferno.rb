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
  hash_of_restaurants = JSON.parse(settings.yelp_json_response)
  hash_of_reviews  = JSON.parse(settings.yelp_json_response_for_reviews)
  @restaurants = hash_of_restaurants.fetch("businesses")
  @categories = get_categories(@restaurants)
  @recent_business_reviews = get_latest_reviews(hash_of_reviews)
  haml :index
end

def get_categories(restaurants)
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

def get_latest_reviews(hash_of_reviews)
  reviews = hash_of_reviews.fetch("businesses")
end
