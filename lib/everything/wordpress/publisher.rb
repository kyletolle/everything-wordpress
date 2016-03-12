module Everything
  module Wordpress
    class Publisher
      def initialize(post_name)
        @client = Client.new
        @post = Post.new(post_name)
      end

      def publish
        publish_metadata = LegacyMetadata.new(@post.name)
        new_post_params = @post.new_params

        if publish_metadata.file_exists?
          publish_metadata.load_metadata

          edit_post_params = new_post_params
            .merge(post_id: publish_metadata.post_id)
          @client.editPost(edit_post_params)

          publish_metadata.update_time
          publish_metadata.save

          puts "Successfully updated #{@post.name}"

        else
          new_post_id = @client.newPost(new_post_params)

          publish_metadata.create_metadata(new_post_id)
          publish_metadata.save

          puts "Successfully published #{@post.name}"
        end
      end
    end
  end
end
