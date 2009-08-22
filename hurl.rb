begin
  require 'sinatra/base'
rescue LoadError
  abort "** Please `gem install sinatra`"
end

begin
  require 'curb'
rescue LoadError
  abort "** Please `gem install curb`"
end

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/redis-rb/lib'
require 'redis'

class Hurl < Sinatra::Base
  dir = File.dirname(File.expand_path(__FILE__))

  set :views,  "#{dir}/views"
  set :public, "#{dir}/public"
  set :static, true

  def initialize(*args)
    super
    @redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  end

  get '/' do
    erb :index
  end

  post '/' do
    url, method, body = params.values_at(:url, :method, :body)
    curl = Curl::Easy.new(url)
    if method
      curl.send "http_#{method.downcase}"
    else
      curl.http_get
    end
    curl.body_str
  end
end
