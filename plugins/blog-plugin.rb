module Jekyll
  # Monkey patch the postings 
  class Post

    # Get the full path to the directory containing the post files
    def containing_dir(source, dir)
      return File.join(source, dir, 'blog')
    end

    def path
      self.data['path'] || File.join(@dir, 'blog', @name).sub(/\A\//, '')
    end
  end
end