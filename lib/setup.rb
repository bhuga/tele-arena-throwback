require "bundler/setup"
Bundler.require(:default)
Dotenv.load
#require "active_support/dependencies"
require "active_support/inflector"
lib = File.expand_path("../", __FILE__)
puts "adding #{lib} to load path"
$:.unshift lib
require "connection"
#ActiveSupport::Dependencies.autoload_paths = [lib]
