require 'sinatra/base'

begin
  require 'redis'
rescue LoadError
  nil
end

class Hurl < Sinatra::Base
  dir = File.dirname(File.expand_path(__FILE__))

  set :views, "#{dir}/views"
  set :public, "#{dir}/public"
  set :static, true

  def initialize(*args)
    super
    if defined? Redis
      @redis = Redis.new(:host => '127.0.0.1', :port => 6379)
    end
  end

  get '/' do
    erb :index
  end
end
