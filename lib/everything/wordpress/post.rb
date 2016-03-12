require 'forwardable'

module Everything
  module Wordpress
    class Post
      extend Forwardable

      def initialize(post_name)
        @piece = Everything::Piece.find_by_name_recursive(post_name)
      end

      def_delegators :@piece, :name

      def content
        ensure_piece_is_public!

        {
          post_status:  "publish",
          post_title:   @piece.title,
          post_name:    @piece.name,
          post_content: @piece.body,
          post_author:  1,
          terms_names:  {
            category: @piece.metadata['categories']
          }
        }
      end

      def new_params
        {
          blog_id: 0,
          content: content
        }
      end

      def metadata
        @piece.metadata['wordpress']
      end

      def categories
        metadata['categories']
      end

    private

      def ensure_piece_is_public!
        expected_public_piece_message = "Expected a public post, but `#{@piece.name}`'s metadata didn't declare it to be public."
        raise expected_public_piece_message unless @piece.public?
      end
    end
  end
end

