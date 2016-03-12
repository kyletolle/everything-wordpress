require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'yaml'
# require 'kramdown'
#

expanded_file_path = File.expand_path(File.dirname(__FILE__))
dotenv_path = File.join(expanded_file_path, '../../' , '.env')
Dotenv.load dotenv_path

module Everything
  module Wordpress
  end
end

require_relative 'wordpress/client'
require_relative 'wordpress/post'
require_relative 'wordpress/post/metadata'
require_relative 'wordpress/post/legacy_metadata'
require_relative 'wordpress/publisher'
