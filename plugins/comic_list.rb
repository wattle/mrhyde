# Title: Comic list tag for Jekyll
# Author: driedtoast - http://github.com/driedtoast
#
# Syntax {% comiclist [template] %}
#
# Example:
# {% comiclist comic_list.html %}
module Jekyll

  class Site
    attr_accessor :comics
  end

  class Comic
    include Convertible

    attr_accessor :data, :content
    attr_accessor :comicdata

    def initialize(site, base, dir, name, url_key)
      @site = site
      @comicdata = self.read_yaml(File.join(base, dir), name)
      @comicdata['content'] = markdownify(self.content)
      @comicdata['key'] = url_key
      @comicdata['link'] = "/comics/#{url_key}"
    end

    def publish?
      @comicdata['published'].nil? or @comicdata['published'] != false
    end

    # Convert a Markdown string into HTML output.
    #
    # input - The Markdown String to convert.
    #
    # Returns the HTML formatted String.
    def markdownify(input)
      converter = @site.getConverterImpl(Jekyll::Converters::Markdown)
      converter.convert(input)
    end
  end


  class ComicList
    @@comics = []

    def self.create(site)
      dir = site.config['comics_dir'] || 'comics'
      comic_page_dir = site.config['comic_page_dir'] || 'pages'
      base = File.join(site.source, dir)
      public_base = File.join(site.dest, dir)
      return unless File.exists?(base)

      entries  = Dir.chdir(base) { site.filter_entries(Dir['**/*']) }
      # Reverse chronological order
      entries.each do |f|
          if File.directory?("#{base}/#{f}") && f !~ /.+\/#{comic_page_dir}$/
            comic = Comic.new(site, site.source, "#{dir}/#{f}", 'index.markdown', f)
            @@comics << comic.comicdata if comic.publish?
            comic_dir = "#{public_base}/#{f}"
            unless File.exists?("#{public_base}")
              # TODO make dir
              Dir.mkdir("#{public_base}")
            end 
            unless File.exists?(comic_dir)
              # TODO make dir 
              Dir.mkdir(comic_dir)
            end
          elsif File.directory?("#{base}/#{f}") && f =~ /(.+)\/#{comic_page_dir}$/
            EpisodeList.create(site, "#{dir}/#{$1}/#{comic_page_dir}", $1)            
          end
      end
      site.comics = @@comics
    end

    def self.comics
      @@comics
    end
  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the category pages.
  class GenerateComics < Generator
    safe true
    priority :low

    def generate(site)
      ComicList.create(site)
    end
  end


  class ComiclistTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @comics = ComicList.comics
      @template_file = markup.strip
      super
    end

    def load_template(file, context)
      includes_dir = File.join(context.registers[:site].source, 'includes')

      if File.symlink?(includes_dir)
        return "Includes directory '#{includes_dir}' cannot be a symlink"
      end

      if file !~ /^[a-zA-Z0-9_\/\.-]+$/ || file =~ /\.\// || file =~ /\/\./
        return "Include file '#{file}' contains invalid characters or sequences"
      end

      Dir.chdir(includes_dir) do
        choices = Dir['**/*'].reject { |x| File.symlink?(x) }
        if choices.include?(file)
          source = File.read(file)
        else
          "Included file '#{file}' not found in _includes directory"
        end
      end

    end

    def render(context)
      output = super
      template = load_template(@template_file, context)

      Liquid::Template.parse(template).render('comics' => @comics).gsub(/\t/, '')
    end
  end


end

Liquid::Template.register_tag('comiclist', Jekyll::ComiclistTag)