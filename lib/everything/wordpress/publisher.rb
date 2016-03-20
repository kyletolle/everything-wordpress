module Everything
  module Wordpress
    class Publisher
      def initialize(post_name)
        @client = Client.new
        @post = Post.new(post_name)
      end

      attr_reader :client, :post

      def publish
        if post.already_published?
          client.edit_post(post.publish_params)

          post.update_metadata

          puts "Successfully updated #{post.name}"

        else
          new_post_id = client.new_post(post.publish_params)

          post.update_metadata(new_post_id)

          puts "Successfully published #{post.name}"
        end
      end
    end
  end
end
