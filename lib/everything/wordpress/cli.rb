require 'everything/wordpress'

module Everything
  module Wordpress
    class CLI < Thor
      desc "publish POST_DIR", "publish the blog in the directory POST_DIR to Wordpress"
      def publish(post_dir)
        Publisher.new(post_dir).publish
      end

      desc "migrate_metadata", "migrate the legacy post metadata to the new post metadata"
      def migrate_metadata
        MetadataMigrator.new.migrate_to_new_metadata
      end
    end
  end
end

