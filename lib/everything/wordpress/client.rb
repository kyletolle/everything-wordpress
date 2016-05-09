require_relative 'client/pager'

module Everything
  module Wordpress
    class Client
      def initialize
        @wp ||= Rubypress::Client.new(
            host:     Fastenv.wordpress_host,
            username: Fastenv.wordpress_username,
            password: Fastenv.wordpress_password
          )
      end

      def new_post(params)
        @wp.newPost(params)
      end

      def edit_post(params)
        @wp.editPost(params)
      end

      def get_posts
        Pager.new(@wp).fetch_all_posts
      end

      def get_media
        Pager.new(@wp).fetch_all_media
      end
    end
  end
end
