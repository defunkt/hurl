require 'open3'
require 'albino'

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
    url, method = params.values_at(:url, :method)
    curl = Curl::Easy.new(url)

#     curl.follow_location = true

    # ensure a method is set
    method = method.to_s.empty? ? 'GET' : method

    begin
      curl.send "http_#{method.downcase}"
      json :header => curl.header_str,
           :body   => pretty_print(curl.content_type, curl.body_str)
    rescue => e
      json :error => "error: #{e}"
    end
  end

  # render a json response
  def json(hash = {})
    headers['Content-Type'] = 'application/json'
    Yajl::Encoder.encode(hash)
  end

  def pretty_print(type, content)
    if type.include? 'json'
      pretty_print_json(content)
    elsif type.include? 'xml'
      Albino.colorize(content, :xml)
    elsif type.include? 'html'
      Albino.colorize(content, :html)
    else
      content.inspect
    end
  end

  def pretty_print_json(content)
    ret = ''
    cmd = "python -msimplejson.tool"
    Open3.popen3(cmd) do |stdin, stdout, stderr|
      stdin.puts content
      stdin.close
      ret = stdout.read.strip
    end

    Albino.colorize(ret, :js)
  end
end
