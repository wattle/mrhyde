require_relative "./lib/include_tag"

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

    # Recursively traverse directories to find posts, pages and static files
    # that will become part of the site according to the rules in
    # filter_entries.
    #
    # dir - The String relative path of the directory to read. Default: ''.
    #
    # Returns nothing.
    def read_directories(dir = '')
      base = File.join(self.source, dir)

      # TODO override filter entries to filter out layouts and such
      # plus allow for me to look at normal dirs below
      entries = Dir.chdir(base) { filter_entries(Dir.entries('.')) }

      self.read_posts(dir)

      if self.show_drafts
        self.read_drafts(dir)
      end

      self.posts.sort!

      # limit the posts if :limit_posts option is set
      if limit_posts > 0
        limit = self.posts.length < limit_posts ? self.posts.length : limit_posts
        self.posts = self.posts[-limit, limit]
      end

      entries.each do |f|
        next if f == self.config['layouts']

        f_abs = File.join(base, f)
        f_rel = File.join(dir, f)
        if File.directory?(f_abs)
          next if self.dest.sub(/\/$/, '') == f_abs
          read_directories(f_rel)
        else
          first3 = File.open(f_abs) { |fd| fd.read(3) }
          # Process if YAML header found on top of file
          if first3 == "---"
            # Switch object based on directory name?
            # TODO also add filtering on the directories?
            if dir =~ /comics\/(.+)\/pages/ 
              pages << Episode.new(self, self.source, dir, f, $1 )
            elsif dir =~ /comics\/(.+)/
              pages << Comic.new(self, self.source, dir, f, $1)
            else
              pages << Page.new(self, self.source, dir, f)
            end  
          else
            # otherwise treat it as a static file
            static_files << StaticFile.new(self, self.source, dir, f)
          end
        end
      end
    end

  end

  class Comic < Page

    attr_accessor :data, :content
    attr_accessor :comicdata

    def initialize(site, base, dir, name, url_key)
      @site = site
      @comicdata = self.read_yaml(File.join(base, dir), name)
      @comicdata['content'] = markdownify(self.content)
      @comicdata['key'] = url_key
      # TODO englishize?
      @comicdata['comic'] = url_key
      @comicdata['link'] = "/comics/#{url_key}"
      super site, base, dir, name
      self.data = @comicdata
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


  class ComiclistTag < IncludeTag
    def initialize(tag_name, markup, tokens)
      @comics = ComicList.comics
      @template_file = markup.strip
      super
    end

    def render(context)
      output = super
      render_with_data(context, 'comics' => @comics)
    end

  end


end

Liquid::Template.register_tag('comiclist', Jekyll::ComiclistTag)