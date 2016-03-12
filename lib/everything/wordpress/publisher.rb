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
          client.editPost(post.publish_params)

          post.update_metadata

          puts "Successfully updated #{post.name}"

        else
          new_post_id = client.newPost(post.publish_params)

          post.update_metadata(new_post_id)

          puts "Successfully published #{post.name}"
        end
      end
    end
  end
end
