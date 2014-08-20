require './boot'
require 'dev_assets'
require 'static_assets'

PROJECT_ROOT = File.expand_path(File.dirname(__FILE__))

map '/' do
  app = ENV['PHONEGAP_STATIC_ASSETS'] ? MobileClient::StaticAssets.new : MobileClient::DevAssets.new
  run app
end
