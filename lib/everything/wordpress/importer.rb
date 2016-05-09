require_relative './imported_post'

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

    private

      def all_posts
        @all_posts ||= begin
          Client.new.get_posts
        end
      end
    end
  end
end
