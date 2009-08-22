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
    url, method, auth = params.values_at(:url, :method, :auth)
    curl = Curl::Easy.new(url)

    requests = []
    curl.on_debug do |type, data|
      # track request headers
      requests << data if type == Curl::CURLINFO_HEADER_OUT
    end

    curl.follow_location = true if params[:follow_redirects]

    # ensure a method is set
    method = method.to_s.empty? ? 'GET' : method

    # basic auth
    if auth == 'basic'
      username, password = params.values_at(:basic_username, :basic_password)
      encoded = Base64.encode64("#{username}:#{password}")
      curl.headers['Authorization'] = "Basic #{encoded}"
    end

    # arbitrary headers
    add_headers_from_arrays(curl, params["header-keys"], params["header-vals"])

    fields = []
    if method == 'POST'
      params["param-keys"].each_with_index do |name, i|
        fields << Curl::PostField.content(name, params["param-vals"][i])
      end
    end

    begin
      curl.send("http_#{method.downcase}", *fields)
      json :header  => pretty_print_headers(curl.header_str),
           :body    => pretty_print(curl.content_type, curl.body_str),
           :request => pretty_print_requests(requests, fields)
    rescue => e
      json :error => "error: #{e}"
    end
  end


  #
  # http helpers
  #

  # accepts two arrays: keys and values
  # the elements in keys must map to the
  # elements in values
  #
  # empty values means the key is ignored
  def add_headers_from_arrays(curl, keys, values)
    keys, values = Array(keys), Array(values)

    keys.each_with_index do |key, i|
      next if values[i].to_s.empty?
      curl.headers[key] = values[i]
    end
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
    colorize :js => shell("python -msimplejson.tool", :stdin => content)
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

  # accepts an array of request headers and formats them
  def pretty_print_requests(requests = [], fields = [])
    headers = requests.map do |request|
      pretty_print_headers request
    end

    headers.join + fields.join('&')
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

  # shell "cat", :stdin => "file.rb"
  def shell(cmd, options = {})
    ret = ''
    Open3.popen3(cmd) do |stdin, stdout, stderr|
      if options[:stdin]
        stdin.puts options[:stdin].to_s
        stdin.close
      end
      ret = stdout.read.strip
    end
    ret
  end
end
