module Everything
  module Wordpress
    class Publisher
      attr_reader :post_dir
      def initialize(post_dir)
        @post_dir = post_dir
      end

      def publish
        post = Post.new(post_dir)

        #post_html = Kramdown::Document.new(post.body).to_html

        everything_wordpress_path = Fastenv.everything_wordpress_path
        post_metadata_path = File.join everything_wordpress_path, "#{post_dir}.yaml"

        if File.exist? post_metadata_path
          post_metadata_yaml = YAML.load_file post_metadata_path
          post_id = post_metadata_yaml['post_id']
          status = wp.editPost(
              blog_id: 0,
              post_id: post_id,
              content: post.content
            )

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

    private

      def wp
        @wp ||= Rubypress::Client.new(
            host:     Fastenv.wordpress_host,
            username: Fastenv.wordpress_username,
            password: Fastenv.wordpress_password
          )
      end
    end
  end
end
