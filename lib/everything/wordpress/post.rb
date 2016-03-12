module Everything
  module Wordpress
    class Post
      def initialize(post_dir)
        @piece = Everything::Piece.find_by_name_recursive(post_dir)
      end

      def content
        ensure_piece_is_public!

          {
            post_status:  "publish",
            post_title:   @piece.title,
            post_name:    @piece.name,
            post_content: @piece.body,
            post_author:  1,
            terms_names:  { category: @piece.metadata['categories'] }
          }
      end

    private

      def ensure_piece_is_public!
        expected_public_piece_message = "Expected a public post, but #{@piece.title}'s metadata didn't declare it to be public."
        raise expected_public_piece_message unless @piece.public?
      end
    end
  end
end

