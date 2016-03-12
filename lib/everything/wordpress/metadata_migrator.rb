module Everything
  module Wordpress
    class MetadataMigrator
      def initialize
        @legacy_metadata_path = '/Users/kyle/Dropbox/everything-wordpress'
      end

      # TODO: The outline for what we need to do.
      # Get the names of all the old wordpress metadata files.
      # For each of those files:
      #   - Get the piece for that wordpress metadata
      #   - Read in the legacy metadata post_id, created_at, and updated_at
      #   - If the new metadata does not already exist, write the new metadata
      #     to the piece's metadata file.
      #   - Save the changes to the metadata file.
      def migrate_to_new_metadata
        legacy_file_glob = File.join(@legacy_metadata_path, '*.yaml')
        legacy_metadata_file_names = Dir.glob(legacy_file_glob)
        legacy_metadata_file_names.each do |legacy_metadata_file_name|
          piece_name = File.basename(legacy_metadata_file_name, '.yaml')
          puts "Migrating metadata for post `#{piece_name}`"
          legacy_metadata = Post::LegacyMetadata.new(piece_name)
          legacy_metadata.load_metadata
          # puts "Legacy:post_id:#{legacy_metadata.post_id},created_at:#{legacy_metadata.created_at},updated_at:#{legacy_metadata.updated_at}"
          post = Post.new(piece_name)

          new_metadata = post.metadata
          # p "New:#{new_metadata.inspect}"
          if new_metadata.already_published?
            puts 'Skipping post since it already has new metadata format'
          else
            puts "We need to add new created and updated events to the post metadata..."
            created_event = {
              'post_id' => legacy_metadata.post_id,
              'event'   => 'created',
              'at'      => legacy_metadata.created_at
            }
            new_metadata.publish_events << created_event
            if legacy_metadata.created_at == legacy_metadata.updated_at
              puts "###############"
              puts "This post has not been updated."
            else
              updated_event = {
                'post_id' => legacy_metadata.post_id,
                'event'   => 'updated',
                'at'      => legacy_metadata.updated_at
              }
              new_metadata.publish_events << updated_event
            end
          end
          puts "New:#{new_metadata.inspect}"
          puts
          # new_metadata.save

          # TODO: We also need to move the categories array into the wordpress
          # hash.
        end


      end
    end
  end
end
