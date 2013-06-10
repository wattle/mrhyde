require_relative "./lib/include_tag"
# Title: Comic Episode list tag for Jekyll
# Author: driedtoast - http://github.com/driedtoast
#
# Syntax {% episodes [template] %}
#
# Example:
# {% episodes episode_list.html %}
module Jekyll

  class Episode < Page

    attr_accessor :data, :content
    attr_accessor :episodedata

    def initialize(site, base_dir, dir, url_key, comic)
      @site = site
      if url_key =~ /(.+)\.markdown|\.md/
        @episodedata = self.read_yaml(File.join(base_dir, dir), "#{url_key}")
        @episodedata['content'] = markdownify(self.content)
        @episodedata['key'] = $1
        @url = @episodedata['link'] = "/comics/#{comic}/#{$1}/index.html"
        @episodedata['comic'] = comic
      end
      data = @episodedata

      super site, base_dir, dir, url_key
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
    @@episodes = {}
    @@episode_map = {}

    def self.create(site, dir, comic )
      base = File.join(site.source, dir)
      public_base = File.join(site.dest, dir)
      return unless File.exists?(base)

      entries  = Dir.chdir(base) { site.filter_entries(Dir['**/*']) }

      # Reverse chronological order
      entries = entries.reverse
      entries.each do |f|
          if f =~ /(.+)\.markdown|\.md/
            episode_name = $1
            episode = Episode.new(site, site.source, dir, f, comic)
            if episode.publish?
              @@episodes[comic] ||= [] 
              @@episodes[comic] << episode.episodedata
            end

            #if base =~ /(.+)\/pages/
            #  comic_dir = "#{$1}/#{episode_name}"
            #  puts " Creating directory #{comic_dir}"
            #  Dir.mkdir("#{comic_dir}") unless File.exists?("#{comic_dir}")
            #end
          # add images below 
          elsif f.downcase =~ /(.+)_.+-(\d+)\.[png|jpg|gif]/
            episode_name = $1
            (@@episode_map["#{comic}:#{episode_name}"] ||= []) << f
            #if base =~ /(.+)\/pages/
            #  comic_dir = "#{$1}/#{episode_name}"
            #  Dir.mkdir("#{comic_dir}") unless File.exists?("#{comic_dir}")
            #end
          end
      end
    end

    def self.episodes
      @@episodes
    end
  end


  class EpisodelistTag < IncludeTag
    def initialize(tag_name, markup, tokens)
      @template_file = markup.strip
      super
    end

    def render(context)
      output = super
      comic_url = context.environments.first['page']['url']
      if comic_url =~ /^\/comics\/(.+)\/index.html$/
        comic_name = $1
        @episodes = EpisodeList.episodes[comic_name]
        comic_meta = nil
        context.registers[:site].comics.each do |comic|
          if comic['key'] == comic_name
            comic_meta = comic
            break
          end
        end
        
        render_with_data(context, 'episodes' => @episodes, 'comic' => comic_meta )
      end
    end
  end


end

Liquid::Template.register_tag('episodes', Jekyll::EpisodelistTag)