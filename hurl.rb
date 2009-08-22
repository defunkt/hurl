require 'libraries'

class Hurl < Sinatra::Base
  dir = File.dirname(File.expand_path(__FILE__))

  set :views,  "#{dir}/views"
  set :public, "#{dir}/public"
  set :static, true

  def initialize(*args)
    super
    @redis = Redis.new(:host => '127.0.0.1', :port => 6379)
  end


  #
  # routes
  #

  get '/' do
    erb :index
  end

  post '/' do
    url, method = params.values_at(:url, :method)
    curl = Curl::Easy.new(url)

    curl.follow_location = true if params[:follow_redirects]

    # ensure a method is set
    method = method.to_s.empty? ? 'GET' : method

    begin
      curl.send "http_#{method.downcase}"
      json :header => pretty_print_headers(curl.header_str),
           :body   => pretty_print(curl.content_type, curl.body_str)
    rescue => e
      json :error => "error: #{e}"
    end
  end


  #
  # sinatra helper methods
  #

  # render a json response
  def json(hash = {})
    headers['Content-Type'] = 'application/json'
    Yajl::Encoder.encode(hash)
  end

  # colorize :js => '{ "blah": true }'
  def colorize(hash = {})
    Albino.colorize(hash.values.first, hash.keys.first)
  end


  #
  # pretty printing
  #

  def pretty_print(type, content)
    type = type.to_s

    if type.include? 'json'
      pretty_print_json(content)
    elsif type.include? 'xml'
      colorize :xml => content
    elsif type.include? 'html'
      colorize :html => content
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

    colorize :js => ret
  end

  def pretty_print_headers(content)
    lines = content.split("\n").map do |line|
      if line =~ /^(.+?):(.+)$/
        "<span class='nt'>#{$1}</span>:<span class='s'>#{$2}</span>"
      else
        "<span class='nf'>#{line}</span>"
      end
    end

    "<div class='highlight'><pre>#{lines.join}</pre></div>"
  end
end
