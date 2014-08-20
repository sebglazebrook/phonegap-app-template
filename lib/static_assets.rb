module MobileClient
  class StaticAssets < Rack::Directory
    def initialize
      super public_dir
    end

    def call(env)
      path = Rack::Utils.unescape(env['PATH_INFO'])

      if '/' == path
        [200, {'Content-Type' => 'text/html'}, [File.read(File.join(root, 'index.html'))]]
      else
        super(env)
      end
    end

    private

    def public_dir
      File.join File.dirname(__FILE__), '../public'
    end
  end
end