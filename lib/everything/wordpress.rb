require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'yaml'
# require 'kramdown'
#

dotenv_path = File.join File.expand_path(File.dirname(__FILE__)), '../' , '.env'
Dotenv.load dotenv_path

module Everything
  module Wordpress
  end
end

require_relative 'wordpress/post'
require_relative 'wordpress/publisher'
