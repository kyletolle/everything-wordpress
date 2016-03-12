require 'everything/wordpress'

module Everything
  module Wordpress
    class CLI < Thor
      desc "publish POST_DIR", "publish the blog in the directory POST_DIR to Wordpress"
      def publish(post_dir)
        Publisher.new(post_dir).publish
      end
    end
  end
end

