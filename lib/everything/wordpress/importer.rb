require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/string/inflections'

module Everything
  module Wordpress
    class Importer
      def get_posts
        client = Client.new

        all_posts = client.get_posts

        all_posts.each do |post|
          WordpressPost.new(post).save_as_piece
        end
      end
    end

    class WordpressPost
      def initialize(wordpress_post)
        @wordpress_post = wordpress_post
      end

      def save_as_piece
        piece = Everything::Piece.new(piece_path)
        piece.raw_markdown = to_content
        piece.raw_yaml = to_metadata
        piece.save
        piece
      end

    private

      def piece_path
        File.join Everything.path, 'blog_import', piece_name
      end

      def piece_name
        post_name = @wordpress_post['post_name']
        if post_name && post_name != ''
          post_name
        else
          @wordpress_post['post_title'].parameterize
        end
      end

      def to_metadata
        {
          'public'    => public_piece?,
          'wordpress' => unmodified_data.merge(dates).merge(categories)
        }.to_yaml
      end

      def public_piece?
        @wordpress_post['post_status'] == 'publish'
      end

      def unmodified_data
        unmodified_attributes = %w(
          comment_status custom_fields guid link menu_order ping_status
          post_author post_excerpt post_format post_id post_mime_type post_name
          post_parent post_password post_status post_thumbnail post_title
          post_type sticky
        )

        @wordpress_post.slice(*unmodified_attributes)
      end

      def dates
        dates_attributes = %w(
          post_date post_date_gmt post_modified post_modified_gmt
        )

        @wordpress_post.slice(*dates_attributes).tap do |h|
          h.each do |key, date|
            h[key] = date.to_time.to_i
          end
        end
      end

      def categories
        {
          'categories' => @wordpress_post['terms'].map{ |term| term['name'] }
        }
      end

      def to_content
        <<MD
#{markdown_title}

#{@wordpress_post['post_content']}

MD
      end

      def markdown_title
        "# #{@wordpress_post['post_title']}"
      end
    end
  end
end
