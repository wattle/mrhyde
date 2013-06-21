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
        @episodedata = self.read_yaml(File.join(base_dir, dir), "#{url_key}") || {}
        @episodedata['content'] = markdownify(self.content)
        @episodedata['key'] = $1
        @url = @episodedata['link'] = "/comics/#{comic}/#{$1}/index.html"
        @episodedata['comic'] = comic  
      end

      super site, base_dir, dir, url_key
      self.data = @episodedata
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
              if (idx = @@episodes[comic].length - 1) >= 0
                prev = @@episodes[comic][idx]
                prev['prev'] = {
                  'title' => episode.episodedata['title'],
                  'link' => episode.episodedata['link'] 
                }
                @@episodes[comic][idx] = prev
                episode.episodedata['next'] = {
                  'title' => prev['title'],
                  'link' => prev['link'] 
                }
              end
              @@episodes[comic] << episode.episodedata
            end
          # add images below 
          elsif f.downcase =~ /(.+)_.+-(\d+)\.[png|jpg|gif]/
            episode_name = $1
            (@@episode_map["#{comic}:#{episode_name}"] ||= []) << "#{dir}/#{f}"
          end
      end
    end

    def self.episodes
      @@episodes
    end

    def self.episode_map
      @@episode_map
    end
  end


  class EpisodelistTag < IncludeTag
    def initialize(tag_name, markup, tokens)
      @template_file = markup.strip
      super
    end

    def render(context)
      output = super
      if comic_name = context.environments.first['page']['comic']
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


  class EpisodeTransitionTag < IncludeTag
    def initialize(tag_name, markup, tokens)
      @template_file = markup.strip
      super
    end

    def render_type(name, output, context)
      page = context.environments.first['page']
      comic_url = page['url']
      if comic_url =~ /^\/comics\/(.+)\/.+\/index.html$/
        comic_name = $1
        @episodes = EpisodeList.episodes[comic_name]
        @episodes.each do |episode|
          if episode['key'] == page['key']
            @to = episode[name]
            break
          end
        end
      end

      if @to
        data = render_with_data(context, name => @to)
      else 
        output
      end
    end  

  end

  class EpisodeNextTag < EpisodeTransitionTag
    def render(context)
      output = super
      render_type('next', output , context)
    end 
  end
 
  class EpisodePreviousTag < EpisodeTransitionTag
    def render(context)
      output = super
      render_type('prev', output, context)
    end 
  end

end

Liquid::Template.register_tag('episodes', Jekyll::EpisodelistTag)
Liquid::Template.register_tag('nextepisode', Jekyll::EpisodeNextTag)
Liquid::Template.register_tag('prevepisode', Jekyll::EpisodePreviousTag)