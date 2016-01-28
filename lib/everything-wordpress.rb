require 'rubygems'
require 'bundler/setup'

require 'dotenv'
dotenv_path = File.join File.expand_path(File.dirname(__FILE__)), '../' , '.env'
Dotenv.load dotenv_path

require 'thor'
require 'yaml'
require 'rubypress'
require 'fastenv'

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
        Fastenv.everything_path
      end
    end

    class Metadata
      def initialize(full_path)
        yaml_path = File.join full_path, 'index.yaml'
        @metadata = YAML.load_file yaml_path
      end

      def [](value)
        @metadata[value]
      end
    end

    class Content
      def initialize(full_path)
        markdown_path  = File.join full_path, 'index.md'
        @markdown_text = File.read markdown_path
      end

      def title
        partitioned_text.first.sub('# ', '')
      end

      def body
        partitioned_text.last
      end

      private

      def partitioned_text
        @partitioned_text ||= @markdown_text.partition("\n\n")
      end
    end

    def initialize(post_dir_name)
      @post_dir_name = post_dir_name
      @directory     = Directory.new(@post_dir_name).full_path
      @metadata      = Metadata.new(@directory)
      @content       = Content.new(@directory)

      unless public_post?
        message = "Expected a public post, but #{post_dir_name}'s metadata didn't declare it to be public."
        puts message
        raise message
      end
    end

    def name
      File.join('', @post_dir_name)
    end

    def title
      @content.title
    end

    def body
      @content.body
    end

    def categories
      @metadata['categories']
    end

    private

    def public_post?
      @metadata['public']
    end
  end

  class Wordpress < Thor
    desc "publish POST_DIR", "publish the blog in the directory POST_DIR to Wordpress"
    def publish(post_dir)

      wp = Rubypress::Client.new(host: Fastenv.wordpress_host, username: Fastenv.wordpress_username, password: Fastenv.wordpress_password)

      post = Everything::Post.new(post_dir)

      content =
        {
          post_status:  "publish",
          post_title:   post.title,
          post_name:    post.name,
          post_content: post.body,
          post_author:  1,
          terms_names:  { category: post.categories }
      }

      everything_wordpress_path = Fastenv.everything_wordpress_path
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

