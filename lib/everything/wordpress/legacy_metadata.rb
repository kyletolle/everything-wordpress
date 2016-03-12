module Everything
  module Wordpress
    class LegacyMetadata
      def initialize(post_name)
        @post_name = post_name
      end

      def file_exists?
        File.exist?(metadata_file_path)
      end

      def create_metadata(post_id)
        @metadata ||= {
          'post_id'    =>    post_id,
          'created_at' => Time.now.to_i,
          'updated_at' => Time.now.to_i
        }
      end

      def load_metadata
        @metadata ||= YAML.load_file(metadata_file_path)
      end

      def post_id
        @metadata['post_id']
      end

      def created_at
        @metadata['created_at']
      end

      def updated_at
        @metadata['updated_at']
      end

      def update_time
        @metadata['updated_at'] = Time.now.to_i
      end

      def save
        File.open(metadata_file_path, 'w') do |f|
          f.write @metadata.to_yaml
        end
      end

    private
      def metadata_dir
        Fastenv.everything_wordpress_path
      end

      def metadata_file_path
        File.join(metadata_dir, "#{@post_name}.yaml")
      end
    end
  end
end
