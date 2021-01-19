module Everything
  module Wordpress
    class Client
      class Pager
        def initialize(wp)
          @wp = wp
        end

        def fetch_all_posts
          all_posts = []
          offset = 0
          loop do
            posts_options = { filter: { number: 200, offset: offset } }
            current_posts = @wp.getPosts(posts_options)
            break if current_posts.empty?
            all_posts.concat current_posts
            offset += current_posts.count
            print '.'
          end
          all_posts
        end

        def fetch_all_media
          all_media = []
          offset = 0

          loop do
            media_options = { filter: { number: 200, offset: offset } }
            current_media = @wp.getMediaLibrary(media_options)
            break if current_media.empty?
            # Note: For some reason, pagination of media doesn't seem to work.
            # We always get the first page again and again. So, we shortcircuit
            # if the first media of the page we've fetched is the same as the
            # very first media we had.
            break if all_media.count > 0 &&
              current_media.first['attachment_id'] ==
                all_media.first['attachment_id']
            all_media.concat current_media
            offset += current_media.count
            print '.'
          end

          puts
          all_media
        end
      end
    end
  end
end

