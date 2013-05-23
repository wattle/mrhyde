

## Overview ## 

This is a fork of jekyll that is geared toward webcomic / design portfolio type site. It adds a couple fun little plugins to support multiple comics / episodes / etc...

Includes / Should include:
* Comic listing page
* Comic episode listings
* Google analytics integration
* Blog support
* SEO tagging for comics / listings / etc...
* Sass and Coffeescript compiling


## Getting Started ##

Install Jekyll:
* `gem install jekyll`

Directory Structure:
* plugins - plugins that provide the build functionality
* content - comic / blog content
** blog - blog articles for the site
** sketchbook - random image / page generation 
** comics - comics root, add a directory per comic 

For each comic:
* Add a directory under comics with an index.markdown in it.
* Update the index.markdown with the details of the comic name


## TODO ##
* Add comic generation based on name that will create directory and index
* Add sketchbook generation? Link up with a tumblr account?
* Push to S3 / create aws site with cloudfront / s3 / route 52
 
