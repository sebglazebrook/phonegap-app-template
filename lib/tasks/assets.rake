require 'haml' # to avoid "WARN: tilt autoloading 'haml' in a non thread-safe way"
require 'sprockets'
require 'sprockets-helpers'
require 'uglifier'
require 'rake/sprocketstask'
require 'haml_coffee_assets'

PUBLIC_DIR = File.join File.dirname(__FILE__), '../../public'

class OptionalDigestSprocketsManifest < Sprockets::Manifest

  def initialize index, output, options = {:omit_digest_for => []}
    super(index, output)
    @omit_digest_for = options[:omit_digest_for]
  end

  # Taken from https://github.com/sstephenson/sprockets/blob/37e80b651935ed5388abeacc35bf4c6ffc10bd8f/lib/sprockets/manifest.rb#L110
  # in order to override the way files are written out.
  # Specifically, we don't want a digest in the output file.

  # Taken from
  #   manifest.rb:110
  #
  # Compile and write asset to directory. The asset is written to a
  # fingerprinted filename like
  # `application-2e8e9a7c6b0aafa0c9bdeec90ea30213.js`. An entry is
  # also inserted into the manifest file.
  #
  #   compile("application.js")
  #
  def compile(*args)
    unless environment
      raise Error, "manifest requires environment for compilation"
    end

    paths = environment.each_logical_path(*args).to_a +
        args.flatten.select { |fn| Pathname.new(fn).absolute? if fn.is_a?(String)}

    paths.each do |path|
      if asset = find_asset(path)
        files[asset.digest_path] = {
            'logical_path' => asset.logical_path,
            'mtime'        => asset.mtime.iso8601,
            'size'         => asset.bytesize,
            'digest'       => asset.digest
        }
        assets[asset.logical_path] = asset.digest_path

        #target = File.join(dir, asset.digest_path)
        asset_path = digest_omitted?(asset) ? asset.logical_path : asset.digest_path
        target = File.join(dir, asset_path)

        # if File.exist?(target)
        #   logger.debug "Skipping #{target}, already exists"
        # else
        logger.info "Writing #{target}"
        asset.write_to target
        # end

        save
        asset
      end

    end
  end

  def digest_omitted? asset
    @omit_digest_for.any? { |pattern| pattern.match asset.pathname.to_s }
  end

end

# This sprockets task provides the assets task.
Rake::SprocketsTask.new(:assets) do |t|

  environment = Sprockets::Environment.new do |env|

    %w[javascripts stylesheets images html templates].each do |path|
      env.append_path "app/#{path}"
    end
    env.register_engine '.haml', Tilt::HamlTemplate
    env.append_path File.dirname(HamlCoffeeAssets.helpers_path)
    env.append_path 'vendor/assets/javascripts'
    env.append_path 'vendor/assets/font-awesome-4.0.3'
    env.append_path 'vendor/assets/stylesheets'
  end

  t.environment = environment
  t.manifest = lambda do
    OptionalDigestSprocketsManifest.new(t.index, t.output,
                                        :omit_digest_for => [
                                            %r{index\.html},
                                            %r{error-page\.html},
                                            %r{/vendor}
                                        ]
    )
  end
  t.output      = ENV['PHONEGAP_ASSET_PATH'] || PUBLIC_DIR
  t.assets      = environment.each_logical_path.to_a.select { |a| a.match(/(^[^_\/]|\/[^_])[^\/]*$/) }


  Sprockets::Helpers.configure do |config|
    config.environment = environment
    config.manifest    = Sprockets::Manifest.new(environment, t.output)
    config.digest = true
    config.prefix = ''
  end

end

task :assets => [:clobber_assets]
