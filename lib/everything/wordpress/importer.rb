#TODO: Go through all the old pieces and add a category for the folder they were
#in, if that feels like it'd help categorize them a bit more!
#
# TODO: Can I also download and save all the comments written on these posts?
#
require_relative './imported_post'
require_relative './imported_media'

module Everything
  module Wordpress
    class Importer
      def each_post(&block)
        all_posts.each do |post|
          yield post
        end
      end

      def save_posts_from_wordpress
        each_post do |post|
          ImportedPost.new(post).save_as_piece
        end
      end

      def each_media(&block)
        all_media.each do |media|
          yield media
        end
      end

      def save_media_from_wordpress
        each_media do |media|
          ImportedMedia.new(media).save_as_media
        end
      end

    private

      def all_posts
        @all_posts ||= begin
          Client.new.get_posts
        end
      end

      def all_media
        @all_media ||= begin
          Client.new.get_media
        end
      end
    end
  end
end
