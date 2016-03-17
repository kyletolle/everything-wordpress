module Everything
  module Wordpress
    class Post
      class Metadata
        def initialize(piece)
          @piece = piece

          @yaml = @piece.metadata.raw_yaml
          @yaml['wordpress'] ||= {}
        end

        def already_published?
          !@yaml['wordpress']['publish_events'].nil?
        end

        def publish_events
          @publish_events ||= begin
            @yaml['wordpress']['publish_events'] ||= []
            @yaml['wordpress']['publish_events']
          end
        end

        def add_created_event(post_id)
          created_event = {
            'event'   => 'created',
            'post_id' => post_id,
            'at'      => Time.now.to_i
          }

          publish_events << created_event
        end

        def add_updated_event
          post_id = publish_events.first
          updated_event = {
            'event'   => 'updated',
            'post_id' => post_id,
            'at'      => Time.now.to_i
          }

          publish_events << updated_event
        end

        def old_categories_exist?
          !@yaml['categories'].nil?
        end

        def delete_old_categories
          @yaml.delete('categories')
        end

        def categories=(value)
          @yaml['wordpress']['categories'] = value
        end

        def inspect
          @piece.metadata.raw_yaml.inspect
        end

        def save
          @piece.raw_yaml = @yaml.to_yaml+"\n"
          @piece.metadata.save
        end
      end
    end
  end
end
