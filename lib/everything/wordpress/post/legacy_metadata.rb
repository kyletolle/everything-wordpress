module Everything
  module Wordpress
    class Post
      class LegacyMetadata
        def initialize(post_name)
          @post_name = post_name
          @metadata = Hash.new do |hash, key|
            raise "You forgot to load or create the metadata"
          end
        end

        def file_exists?
          File.exist?(metadata_file_path)
        end

        def create_metadata(post_id)
          if @metadata.empty?
            @metadata = {
              'post_id'    =>    post_id,
              'created_at' => Time.now.to_i,
              'updated_at' => Time.now.to_i
            }
          end
        end

        def load_metadata
          if @metadata.empty?
            @metadata = YAML.load_file(metadata_file_path)
          end
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
          Fastenv.everything_wordpress_metadata_path
        end

        def metadata_file_path
          File.join(metadata_dir, "#{@post_name}.yaml")
        end
      end
    end
  end
end
