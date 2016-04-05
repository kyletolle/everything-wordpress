require 'everything/wordpress'

module Everything
  module Wordpress
    class CLI < Thor
      desc 'publish POST_DIR', 'publish the blog in the directory POST_DIR to Wordpress'
      def publish(post_dir)
        Publisher.new(post_dir).publish
      end

      desc 'migrate_metadata', 'migrate the legacy post metadata to the new post metadata'
      def migrate_metadata
        MetadataMigrator.new.migrate_to_new_metadata
      end

      desc 'import', 'import all the blogs in wordpress to everything'
      def import
        Importer.new.save_posts_from_wordpress
      end

      desc 'consolidate_existing', 'consolidate blog posts that currently exist in everything to a single blog folder'
      def consolidate_existing
        ExistingPosts.new.consolidate
      end
    end
  end
end

