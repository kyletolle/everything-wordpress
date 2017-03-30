require 'forwardable'
require_relative 'post/metadata'
require_relative 'post/legacy_metadata'

# TODO: This class will need to be upgraded to match the new wordpress metadata
# format.

module Everything
  module Wordpress
    class Post
      extend Forwardable

      def initialize(post_name)
        @piece = Everything::Piece.find_by_name_recursive(post_name)
      end

      def_delegators :@piece, :name

      def already_published?
        legacy_metadata.file_exists?
      end

      def publish_params
        if already_published?
          legacy_metadata.load_metadata
          edit_params

        else
          new_params
        end
      end

      def update_metadata(post_id=nil)
        if already_published?
          legacy_metadata.update_time
        else
          legacy_metadata.create_metadata(post_id)
        end

        legacy_metadata.save
      end

      def metadata
        @metadata ||= Metadata.new(@piece)
      end

    private

      def ensure_piece_is_public!
        expected_public_piece_message = "Expected a public post, but `#{@piece.name}`'s metadata didn't declare it to be public."
        raise expected_public_piece_message unless @piece.public?
      end

      def legacy_metadata
        @legacy_metadata ||= Post::LegacyMetadata.new(name)
      end

      def new_params
        {
          blog_id: 0,
          content: content
        }
      end

      def edit_params
        new_params.merge(post_id: legacy_metadata.post_id)
      end

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
    end
  end
end

