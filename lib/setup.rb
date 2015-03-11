require "bundler/setup"
Bundler.require(:default)
Dotenv.load
require "active_support/inflector"
require "active_support/core_ext/object/try"

lib = File.expand_path("../", __FILE__)
puts "adding #{lib} to load path"
$:.unshift lib
require "connection"

require "io/console"
