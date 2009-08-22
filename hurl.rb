require 'sinatra/base'

class Hurl < Sinatra::Base
  def initialize(*args)
    super
    @redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  end

  get '/' do
    "hi world! #{@redis}"
  end
end
