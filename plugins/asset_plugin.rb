# # TODO create a generator for coffeescript and sass
module Jekyll


  #class SassGenerator
  #  def self.generate(site)
  #    puts " Generating Sass?"
  #    dir = site.config['sass_dir'] || 'css'
  #    base = File.join(site.source, dir)
  #    entries  = Dir.chdir(base) { site.filter_entries(Dir['**/*.sass']) }
  #    entries.each do |f|
  #      basename = File.basename("#{base}/#{f}", ".sass")
  #      system "sass #{base}/#{basename}.sass > #{File.join(site.dest, dir)}/#{basename}.css"
  #    end
  #  end
  #end

  class CoffeeGenerator
    def self.generate(site)
      puts " Generating Coffee?"
    end
  end
  
  # TODO generate assets
  class GenerateAssets < Generator
    safe true
    priority :low

    def generate(site)
      #SassGenerator.generate(site)
      CoffeeGenerator.generate(site)
    end
  end
end  
# 
# # TODO the following:
# # - for production need version tagging / cache busting
# # - add version number to generated files?
# 
# 
# SOURCE_DIR  = ROOT.join("app","assets")
# 
# CSS_DIR     = BUILD_DIR.join('css')
# SASS_DIR    = SOURCE_DIR.join('css')
# 
# SCRIPT_DIR  = 'javascripts'
# JS_DIR      = BUILD_DIR.join(SCRIPT_DIR)
# COFFEE_DIR  = SOURCE_DIR.join(SCRIPT_DIR)
# 
# 
# namespace :sass do
#   desc "Convert all Sass files to CSS."
#   task :compile do
#     files = Dir.entries(SASS_DIR).find_all do |f| 
#       File.extname("#{SASS_DIR}/#{f}") == ".sass" &&
#       File.basename("#{SASS_DIR}/#{f}") !~ /^[.]/
#     end
# 
#     files.each do |filename|
#       basename = File.basename("#{SASS_DIR}/#{filename}", ".sass")
#       system "sass #{SASS_DIR}/#{basename}.sass > #{CSS_DIR}/#{basename}.css"
#     end
#   end
# end
# 
# 
# # TODO Have it loop through the root of assets/js for bundle names
# BUNDLES     = %w( comics.js )
# 
# namespace :assets do
#   task :compile do
# 
#     Rake::Task["sass:compile"].invoke
# 
#     require 'handlebars_assets'
#     # Sass.load_paths.push SOURCE_DIR.join('css')
#     sprockets = Sprockets::Environment.new(ROOT) do |env|
#        env.logger = LOGGER
#        # Handlebar support
#        env.append_path HandlebarsAssets.path
#     end
#     # TODO fix this
#     HandlebarsAssets::Config.template_namespace = 'JST'
#     # TODO figure out how to combine with modules?
#     HandlebarsAssets::Config.compiler = 'templates.js' 
#     HandlebarsAssets::Config.compiler_path = SOURCE_DIR.join('templates')
# 
#     sprockets.append_path(SOURCE_DIR.join(SCRIPT_DIR).to_s)
#     sprockets.append_path(SOURCE_DIR.join('templates').to_s)
#     
#     # Build the bunldles
#     BUNDLES.each do |bundle|
#       assets = sprockets.find_asset(bundle)
#       prefix, basename = assets.pathname.to_s.split('/')[-2..-1]
# 
#       FileUtils.mkpath BUILD_DIR.join(prefix)
#       realname = basename.to_s.split(".")[0..1].join(".")
#       assets.write_to(BUILD_DIR.join(prefix, realname))
#     end
#   end
# end