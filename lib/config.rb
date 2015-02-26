require 'dotenv'
dotenv_path = File.join File.expand_path(File.dirname(__FILE__)), '../' , '.env'
Dotenv.load dotenv_path

class Config
  def self.method_missing(method_sym, *arguments, &block)
    method_string = method_sym.to_s.upcase
    value = ENV[method_string]

    unless value
      raise ArgumentError, "Couldn't find the #{method_string} environment variable"
    end

    value
  end
end

