require 'rubygems'
require 'bundler/setup'

require 'thor'
require 'yaml'
require 'rubypress'

require_relative 'config'

module Everything
  class Post
    class Directory
      def initialize(post_dir_name)
        @post_dir_name = post_dir_name
      end

      def full_path
        glob_path      = File.join everything_path, '**', @post_dir_name
        possible_dirs  = Dir.glob glob_path
        full_post_path = possible_dirs.first

        unless full_post_path
          puts "Couldn't find a directory for the post #{@post_dir_name}."
          return
        end

        unless File.directory? full_post_path
          puts "Expected a directory but #{full_post_path} wasn't a directory."
          return
        end

        full_post_path
      end

      private

      def everything_path
        Config.everything_path
      end
    end

    def initialize(post_dir_name)
      @directory = Directory.new(post_dir_name).full_path
    end
  end

  class Wordpress < Thor
    desc "publish POST_DIR", "publish the blog in the directory POST_DIR to Wordpress"
    def publish(post_dir)

      full_post_path = Everything::Post::Directory.new(post_dir).full_path

      # Find yaml file and make sure it's a public file.
      yaml_path = File.join full_post_path, 'index.yaml'
      metadata = YAML.load_file yaml_path
      is_public_post = metadata['public']
      unless is_public_post
        puts "Expected a public post, but #{post_dir}'s metadata didn't declare it to be public."
        return
      end

      markdown_path = File.join full_post_path, 'index.md'
      markdown_text = File.read markdown_path

      partitioned_text = markdown_text.partition("\n\n")
      blog_title = partitioned_text.first.sub("# ", '')
      markdown_content = partitioned_text.last

      wp = Rubypress::Client.new(host: Config.wordpress_host, username: Config.wordpress_username, password: Config.wordpress_password)

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

      everything_wordpress_path = Config.everything_wordpress_path
      post_metadata_path = File.join everything_wordpress_path, "#{post_dir}.yaml"

      if File.exist? post_metadata_path
        post_metadata_yaml = YAML.load_file post_metadata_path
        post_id = post_metadata_yaml['post_id']
        status = wp.editPost(blog_id: 0, post_id: post_id, content: content)

        post_metadata_yaml["updated_at"] = Time.now.to_i

        File.open(post_metadata_path, 'w') do |f|
          f.write post_metadata_yaml.to_yaml
        end

        puts "Successfully updated #{post_dir}"

      else

        status = wp.newPost(blog_id: 0, content: content)

        post_metadata = {
          "post_id" => status,
          "created_at" => Time.now.to_i,
          "updated_at" => Time.now.to_i
        }

        File.open(post_metadata_path, 'w') do |f|
          f.write post_metadata.to_yaml
        end

        puts "Successfully published #{post_dir}"
      end
    end
  end
end

Everything::Wordpress.start(ARGV)

