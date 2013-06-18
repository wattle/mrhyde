require_relative "./lib/include_tag"

# Title: Panel list tag for Jekyll
# Author: driedtoast - http://github.com/driedtoast
#
# Syntax {% panels [template_prefix] %}
#
# Example:
# {% panels panel- %}
module Jekyll

 class PanelListTag < IncludeTag
     def initialize(tag_name, markup, tokens)
      @template_file = markup.strip
      super
    end

    def render(context)
      output = super
      page = context.environments.first['page']
      comic = page['comic']
      episode = page['key']

      @template_file = "#{@template_file}#{page['type']}.html"

      @panels = EpisodeList.episode_map["#{comic}:#{episode}"]
      if @panels 
        firstpanel = @panels[0]
        show_multiple =  @panels.size > 1
        render_with_data(context, 'panels' => @panels, 'starter_panel' => firstpanel, 'show_multiple' => show_multiple)
      else 
        output
      end

    end
  end

  class LatestPanelTag < IncludeTag
     def initialize(tag_name, markup, tokens)
      @template_file = markup.strip
      super
    end

    def render(context)
      output = super
      page = context.environments.first['page']
      comic = page['comic']
      
      @episodes = EpisodeList.episodes()[comic]

      if @episodes && (episode = @episodes[0]) && (@panels = EpisodeList.episode_map["#{comic}:#{episode.episodedata['key']}"] )
        @template_file = "#{@template_file}#{episode.episodedata['type']}.html"
        firstpanel = @panels[0]
        show_multiple =  @panels.size > 1
        render_with_data(context, 'panels' => @panels, 'starter_panel' => firstpanel, 'show_multiple' => show_multiple)
      else 
        output
      end

    end
  end

end

Liquid::Template.register_tag('panels', Jekyll::PanelListTag)
Liquid::Template.register_tag('latestpanel', Jekyll::LatestPanelTag)