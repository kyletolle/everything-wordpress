module Everything
  module Wordpress
    class Post
      class Metadata
        def initialize(piece)
          @piece = piece

          @piece.metadata.raw_yaml['wordpress'] ||= {}
        end

        def already_published?
          !wordpress_metadata['publish_events'].nil?
        end

        def publish_events
          @publish_events ||= begin
            wordpress_metadata['publish_events'] ||= []
            wordpress_metadata['publish_events']
          end
        end

        def add_created_event(post_id)
          created_event = {
            'post_id' => post_id,
            'event'   => 'created',
            'at'      => Time.now.to_i
          }

          publish_events << created_event
        end

        def add_updated_event
          post_id = publish_events.first
          updated_event = {
            'post_id' => post_id,
            'event'   => 'updated',
            'at'      => Time.now.to_i
          }

          publish_events << updated_event
        end

        def inspect
          @piece.metadata.raw_yaml.inspect
        end

        def save
          # TODO: Need a hook in everything-core to save metadata files back to
          # disk.
          raise NotImplementedError
        end

      private

        def wordpress_metadata
          @wordpress_metadata ||= @piece.metadata['wordpress']
        end
      end
    end
  end
end
