require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'yaml'

dotenv_path = File.join File.expand_path(File.dirname(__FILE__)), '../' , '.env'
Dotenv.load dotenv_path


module Everything
  class Wordpress < Thor
    desc "publish POST_DIR", "publish the blog in the directory POST_DIR to Wordpress"
    def publish(post_dir)

      wp = Rubypress::Client.new(host: Fastenv.wordpress_host, username: Fastenv.wordpress_username, password: Fastenv.wordpress_password)

      post = Everything::Piece.find_by_name_recursive(post_dir)
      unless post.public?
        message = "Expected a public post, but #{post_dir_name}'s metadata didn't declare it to be public."
        puts message
        raise message
      end

      content =
        {
          post_status:  "publish",
          post_title:   post.title,
          post_name:    post.name,
          post_content: post.body,
          post_author:  1,
          terms_names:  { category: post.metadata['categories'] }
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

