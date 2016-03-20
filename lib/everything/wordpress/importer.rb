module Everything
  module Wordpress
    class Importer
      def get_posts
        client = Client.new

        all_posts = client.get_posts
        puts all_posts.class
        puts all_posts.count

        all_posts.each do |post|
          post.each do |post_key, post_value|
            puts "#{post_key} is a #{post_value.class}"
          end
        end
        puts
        # File.write('all_posts.yaml', all_posts.to_yaml)
        # File.write('all_posts.json', JSON.generate(all_posts))
      end
    end
  end
end
