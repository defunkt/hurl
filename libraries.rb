require 'tempfile'
require 'open3'
require 'uri'
require 'albino'
require 'base64'
require 'digest'

begin
  require 'sinatra/base'
rescue LoadError
  abort "** Please `gem install sinatra`"
end

begin
  require 'yajl'
rescue LoadError
  abort "** Please `gem install yajl-ruby`"
end

begin
  require 'curb'
rescue LoadError
  abort "** Please `gem install curb`"
end

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/redis-rb/lib'
require 'redis'

require 'models/model'
require 'models/user'
