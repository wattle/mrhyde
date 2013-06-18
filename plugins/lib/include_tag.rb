module Jekyll

 class IncludeTag < Liquid::Tag
  
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

    def render_with_data(context, template_data)
      template = load_template(@template_file, context)
      Liquid::Template.parse(template).render(template_data).gsub(/\t/, '')
    end
  end

end