# # TODO create a generator for coffeescript and sass
module Jekyll


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
      CoffeeGenerator.generate(site)
    end
  end
end  