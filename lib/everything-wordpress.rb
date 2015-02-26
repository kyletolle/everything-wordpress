require 'rubygems'
require 'bundler/setup'

require 'dotenv'
dotenv_path = File.join File.expand_path(File.dirname(__FILE__)), '../' , '.env'
Dotenv.load dotenv_path

require 'thor'
require 'yaml'
require 'rubypress'

module Everything
  class Wordpress < Thor
    desc "publish POST_DIR", "publish the blog in the directory POST_DIR to Wordpress"
    def publish(post_dir)

      Dir.chdir ENV['EVERYTHING_PATH']
      glob_path = File.join '**', post_dir
      possible_dirs = Dir.glob glob_path
      full_post_dir = possible_dirs.first

      unless full_post_dir
        puts "Couldn't find a directory for the post #{full_post_dir}."
        return
      end

      unless File.directory? full_post_dir
        puts "Expected a directory but #{full_post_dir} wasn't a directory."
        return
      end

      # Find yaml file and make sure it's a public file.
      yaml_path = File.join full_post_dir, 'index.yaml'
      metadata = YAML.load_file yaml_path
      is_public_post = metadata['public']
      unless is_public_post
        puts "Expected a public post, but #{post_dir}'s metadata didn't declare it to be public."
        return
      end

      markdown_path = File.join full_post_dir, 'index.md'
      markdown_text = File.read markdown_path

      partitioned_text = markdown_text.partition("\n\n")
      blog_title = partitioned_text.first.sub("# ", '')
      markdown_content = partitioned_text.last

      wp = Rubypress::Client.new(host: ENV['WORDPRESS_HOST'], username: ENV['WORDPRESS_USERNAME'], password: ENV['WORDPRESS_PASSWORD'])

      content =
        {
          post_status:  "publish",
          post_date:    Time.now,
          post_title:   blog_title,
          post_name:    File.join('', post_dir),
          post_content: markdown_content,
          post_author:  1,
          terms_names:
            {
            category: metadata['categories']
            }
      }

      status = wp.newPost(blog_id: 0, content: content)

      puts "The post should have been successfully published and the ID is:"
      puts status
    end
  end
end

Everything::Wordpress.start(ARGV)

