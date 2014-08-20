require 'haml' # to avoid "WARN: tilt autoloading 'haml' in a non thread-safe way"
require 'sprockets'
require 'sprockets-helpers'
require 'uglifier'
require 'haml_coffee_assets'

module MobileClient

  Sprockets::Helpers.configure do |config|
    config.digest = true
    config.prefix = ''
    config.debug = true
  end

  class DevAssets < Sprockets::Environment

    def initialize
      super
      append_path File.dirname(HamlCoffeeAssets.helpers_path)
      append_path File.join( PROJECT_ROOT, 'vendor', 'assets')
      append_path File.join( PROJECT_ROOT, 'vendor', 'assets', 'fonts')
      append_path File.join( PROJECT_ROOT, 'vendor', 'assets', 'javascripts')
      append_path File.join( PROJECT_ROOT, 'app', 'javascripts')
      append_path File.join( PROJECT_ROOT, 'app', 'images')
      append_path File.join( PROJECT_ROOT, 'app', 'stylesheets')
      append_path File.join( PROJECT_ROOT, 'app', 'html')
      register_engine '.haml', Tilt::HamlTemplate
    end

    def call env
      path = Rack::Utils.unescape(env['PATH_INFO'])

      if '/' == path # handle request for index
        [200, {'Content-Type' => 'text/html'}, [self['index.html'].to_s]]
      elsif '/diagnostic/version' == path
        [200, {'Content-Type' => 'plain/text'}, [File.read(File.join(root, 'fixtures' ,'diagnostic', 'version'))]]
      else
        super(env)
      end
    end

  end
end