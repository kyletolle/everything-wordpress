require 'forwardable'

class Client
  extend Forwardable

  def initialize
    @wp ||= Rubypress::Client.new(
        host:     Fastenv.wordpress_host,
        username: Fastenv.wordpress_username,
        password: Fastenv.wordpress_password
      )
  end

  def_delegators :@wp, :newPost, :editPost
end
