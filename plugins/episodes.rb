# Title: Comic Episode list tag for Jekyll
# Author: driedtoast - http://github.com/driedtoast
#
# Syntax {% episodes [template] %}
#
# Example:
# {% episodes episode_list.html %}
module Jekyll

  class Episode
    include Convertible

    attr_accessor :data, :content
    attr_accessor :episodedata

    def initialize(site, base, dir, url_key)
      @site = site
      puts " CREATING NAME #{name} - Episodoe"
      @episodedata = self.read_yaml(File.join(base, dir), name)
      @episodedata['content'] = markdownify(self.content)
      @episodedata['key'] = url_key
      @episodedata['link'] = "/"
    end

    def publish?
      @episodedata['published'].nil? or @episodedata['published'] != false
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


  class EpisodeList
    @@episodes = []

    def self.create(site)
      dir = site.config['comics_dir'] || 'comics'
      base = File.join(site.source, dir)
      public_base = File.join(site.dest, dir)
      return unless File.exists?(base)

      entries  = Dir.chdir(base) { site.filter_entries(Dir['**/*']) }

      # Reverse chronological order
      entries = entries.reverse
      entries.each do |f|
          # if File.directory?(f)
          unless File.directory?("#{base}/#{f}") || f == "index.markdown"
            puts " getting episode #{f}"
            episode = Episode.new(site, site.source, "#{dir}/#{f}", f)
            @@episodes << episode.comicdata if episode.publish?
            comic_dir = "#{public_base}/#{f}"
            unless File.exists?("#{comic_dir}/#{f}")
              Dir.mkdir("#{comic_dir}/#{f}")
            end 
            # TODO Need to push episode files into this 
          end
      end
    end

    def self.episodes
      @@episodes
    end
  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the category pages.
  class GenerateEpisodes < Generator
    safe true
    priority :low

    def generate(site)
      # EpisodeList.create(site)
    end
  end


  class EpisodelistTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @template_file = markup.strip
      super
    end

    def load_template(file, context)
      #includes_dir = File.join(context.registers[:site].source, 'includes')
      #if File.symlink?(includes_dir)
      #  return "Includes directory '#{includes_dir}' cannot be a symlink"
      #end

      #if file !~ /^[a-zA-Z0-9_\/\.-]+$/ || file =~ /\.\// || file =~ /\/\./
      #  return "Include file '#{file}' contains invalid characters or sequences"
      #end
      puts " Loading file #{file}"
      #Dir.chdir(includes_dir) do
      #  choices = Dir['**/*'].reject { |x| File.symlink?(x) }
      #  if choices.include?(file)
      #    source = File.read(file)
      #  else
      #    "Included file '#{file}' not found in _includes directory"
      #  end
      #end
      " Loading  #{@template_file}"
    end

    def render(context)
      @episodes = EpisodeList.episodes
      comic_url = context.environments.first['page']['url']
      if comic_url =~ /^\/comics\/(.+)\/index.html$/
        comic_name = $1
        puts comic_name
        comic_meta = nil
        context.registers[:site].comics.each do |comic|
          if comic['key'] == comic_name
            comic_meta = comic
            break
          end
        end
        puts comic_meta
        output = super
        template = load_template(@template_file, context)
        Liquid::Template.parse(template).render('episodes' => @episodes).gsub(/\t/, '')
        # TODO load the comic dir and the files in them via the episodes list
        # and create a list similar to comic_list.html

      end
    end
  end


end

Liquid::Template.register_tag('episodes', Jekyll::EpisodelistTag)