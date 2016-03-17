module Everything
  module Wordpress
    class MetadataMigrator
      def initialize
        @legacy_metadata_path = '/Users/kyle/Dropbox/everything-wordpress'
      end

      def migrate_to_new_metadata
        legacy_metadata_file_names.each do |legacy_metadata_file_name|
          piece_name = File.basename(legacy_metadata_file_name, '.yaml')

          puts "Migrating metadata for post `#{piece_name}`"
          legacy_metadata = Post::LegacyMetadata.new(piece_name)
          legacy_metadata.load_metadata

          post = Post.new(piece_name)

          new_metadata = post.metadata

          if new_metadata.old_categories_exist?
            categories = new_metadata.delete_old_categories
            new_metadata.categories = categories
          end

          unless new_metadata.already_published?
            created_event = created_event_from_legacy(legacy_metadata)
            new_metadata.publish_events << created_event

            unless legacy_metadata.created_at == legacy_metadata.updated_at
              updated_event = updated_event_from_legacy(legacy_metadata)
              new_metadata.publish_events << updated_event
            end
          end

          new_metadata.save
        end
      end

    private

      def legacy_metadata_file_names
        legacy_file_glob = File.join(@legacy_metadata_path, '*.yaml')
        Dir.glob(legacy_file_glob)
      end

      def created_event_from_legacy(legacy_metadata)
        {
          'event'   => 'created',
          'post_id' => legacy_metadata.post_id,
          'at'      => legacy_metadata.created_at
        }
      end

      def updated_event_from_legacy(legacy_metadata)
        {
          'event'   => 'updated',
          'post_id' => legacy_metadata.post_id,
          'at'      => legacy_metadata.updated_at
        }
      end
    end
  end
end
