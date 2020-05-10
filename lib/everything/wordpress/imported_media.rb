require 'json'
require 'open-uri'

module Everything
  module Wordpress
    class ImportedMedia
      def initialize(wordpress_media)
        @wordpress_media = wordpress_media

        @wordpress_media['date_created_gmt'] =
          @wordpress_media['date_created_gmt'].to_time.to_i
      end

      def save_as_media
        FileUtils.mkdir_p media_path
        File.write(wordpress_metadata_path, wordpress_metadata_json)

        download_media
      end

    private

      def wordpress_metadata_json
        JSON.pretty_generate(@wordpress_media)
      end

      def wordpress_metadata_path
        @media_json_path ||= File.join media_path, 'wordpress_metadata.json'
      end

      def media_path
        @media_path ||= File.join media_dir, media_name
      end

      def media_dir
        @media_dir ||= File.join Everything.path, 'europe_blog_import', 'media'
      end

      def media_name
        "attachment_#{attachment_id}"
      end

      def attachment_id
        @wordpress_media['attachment_id']
      end

      def wordpress_base_uploads_url
        'http://kyleandchuckgotoeurope.com/wp-content/uploads/'
      end

      def download_media
        case @wordpress_media['type']
        when 'image/jpeg', 'image/png', 'image/gif'
          download_images
        when 'audio/mpeg'
          download_audio
        end
      end

      def download_images
        urls_to_download = [
          @wordpress_media['link'],
          @wordpress_media['thumbnail'],
        ]

        metadata = @wordpress_media['metadata']
        if metadata && metadata != ""
          relative_image_path = metadata['file']
          urls_to_download << File
            .join(wordpress_base_uploads_url, relative_image_path)
          image_dirname = File.dirname(relative_image_path)

          sizes = metadata['sizes']
          if sizes
            if sizes['large']
              urls_to_download << File
                .join(wordpress_base_uploads_url,
                      image_dirname,
                      sizes['large']['file'])
            end
            if sizes['medium']
              urls_to_download << File
                .join(wordpress_base_uploads_url,
                      image_dirname,
                      sizes['medium']['file'])
            end
            if sizes['post-thumbnail']
              urls_to_download << File
                .join(wordpress_base_uploads_url,
                      image_dirname,
                      sizes['post-thumbnail']['file'])
            end
            if sizes['thumbnail']
              urls_to_download << File
                .join(wordpress_base_uploads_url,
                      image_dirname,
                      sizes['thumbnail']['file'])
            end
          end
        end

        urls_to_download = urls_to_download.uniq

        fetch_urls(urls_to_download)
      end

      def download_audio
        urls_to_download = [
          @wordpress_media['link'],
          @wordpress_media['thumbnail'],
        ]

        fetch_urls(urls_to_download.uniq)
      end

      def fetch_urls(urls_to_fetch)
        urls_to_fetch.each do |url_to_fetch|
          file_basename = File.basename(url_to_fetch)
          local_file_path = File.join(media_path, file_basename)
          if File.exist?(local_file_path)
            print 's'
            # puts "File `#{file_basename}` already exists"

          else
            open(url_to_fetch) do |file_data|
              File.open(local_file_path, 'wb') do |file|
                print 'd'
                file.puts file_data.read
              end
            end
          end
        end
      end
    end
  end
end
