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
            current_posts = @wp.getPosts(filter: { number: 200, offset: offset })
            break if current_posts.empty?
            all_posts.concat current_posts
            offset += current_posts.count
            print '.'
          end
          all_posts
        end
      end
    end
  end
end

