require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/string/inflections'

module Everything
  module Wordpress
    class ImportedPost
      @@unknown_piece_count = 0

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
        @piece_path ||= File.join Everything.path, 'europe_blog_import', piece_name
      end

      def piece_name
        post_name = @wordpress_post['post_name']
        post_title = @wordpress_post['post_title']
        if post_name && post_name != ''
          post_name
        elsif post_title && post_title != ''
          post_title.parameterize
        else
          "unknown-#{@@unknown_piece_count += 1}"
        end
      end

      def to_metadata
        {
          'public'    => published_post?,
          'wordpress' => merged_metadata
        }.to_yaml
      end

      def merged_metadata
        unmodified_data
          .merge(dates)
          .merge(categories)
          .merge(published)
          .merge(publish_events)
      end

      def published_post?
        @wordpress_post['post_status'] == 'publish'
      end

      def published
        {
          'published' => published_post?
        }
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

      def publish_events
        return {} if @wordpress_post['post_date_gmt'].nil?

        new_publish_events = []

        post_id = @wordpress_post['post_id']

        created_time = @wordpress_post['post_date_gmt'].to_time.to_i
        updated_time = @wordpress_post['post_modified_gmt'].to_time.to_i

        created_event = {
          'event'   => 'created',
          'post_id' => post_id,
          'at'      => created_time
        }
        new_publish_events << created_event

        unless created_time == updated_time
          updated_event = {
            'event'   => 'updated',
            'post_id' => post_id,
            'at'      => updated_time
          }

          new_publish_events << updated_event
        end

        {
          'publish_events' => new_publish_events
        }
      end

      def to_content
        <<MD
#{markdown_title}

#{markdown_body}

MD
      end

      def markdown_title
        "# #{@wordpress_post['post_title']}"
      end

      def markdown_body
        post_content = @wordpress_post['post_content']

        if post_content.match(/<p>/)
          Kramdown::Document
            .new(@wordpress_post['post_content'], input: 'html')
            .to_kramdown
        else
          post_content
        end
      end
    end
  end
end
