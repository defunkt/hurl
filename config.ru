require 'rubygems'
require 'hurl'

# rack sucks
if %w( chris leahculver ).include? `whoami`.chomp
  require 'thin'
  Rack::Handler::Thin.run Hurl.new
else
  run Hurl.new
end
