module Everything
  module Wordpress
    class ExistingPosts
      def consolidate
        Importer.new.each_post do |post|
          piece_name = post['post_name']
          next if piece_name == ''

          existing_piece = find_piece(piece_name)

          next unless existing_piece
          next if piece_already_in_blog_folder?(existing_piece)

          move_piece_to_blog_folder(existing_piece)
        end
      end

    private
      def find_piece(piece_name)
        Everything::Piece.find_by_name_recursive(piece_name)
      rescue ArgumentError
        nil
      end

      def piece_already_in_blog_folder?(piece)
        dirname = Pathname.new(piece.full_path).dirname.to_s
        dirname == blog_folder
      end

      def move_piece_to_blog_folder(piece)
        `git mv #{piece.full_path} #{blog_folder}`
      end

      def blog_folder
        @blog_folder ||= File.join(Everything.path, 'blog')
          .tap { |dir| FileUtils.mkdir_p(dir) }
      end
    end
  end
end
