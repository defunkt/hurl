require 'libraries'

module Hurl
  def self.redis
    @redis
  end

  def self.redis=(redis)
    @redis = redis
  end

  class App < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/views"
    set :public, "#{dir}/public"
    set :static, true

    enable :sessions

    def initialize(*args)
      super
      Hurl.redis = Redis.new(:host => '127.0.0.1', :port => 6379)
      @debug = true
    end

    def redis
      Hurl.redis
    end


    #
    # routes
    #

    before do
      if load_session
        @user = User.find_by_email(@session['email'])
      end
      @flash = session.delete('flash')
    end

    helpers do
      def logged_in?
        !!@user
      end

      def next_hurl
        return unless logged_in?

        if @hurl
          hurls = @user.hurls
          hurls.each_with_index do |hurl, i|
            if hurl['id'] == @hurl['id']
              return i-1 >= 0 ? hurls[i-1]['id'] : nil
            end
          end
          nil
        end
      end

      def prev_hurl
        return unless logged_in?

        if @hurl.empty? && @user.any_hurls?
          @user.latest_hurl_id
        elsif @hurl.any?
          hurls = @user.hurls
          hurls.each_with_index do |hurl, i|
            if hurl['id'] == @hurl['id']
              return hurls[i+1] ? hurls[i+1]['id'] : nil
            end
          end
          nil
        end
      end
    end

    get '/' do
      @hurl = {}
      erb :index
    end

    get '/hurls/?' do
      redirect('/') and return unless logged_in?
      @hurls = @user.hurls
      erb :hurls
    end

    get '/hurls/:id/?' do
      @hurl = find_hurl_or_view(params[:id])
      @hurl ? erb(:index) : not_found
    end

    delete '/hurls/:id/?' do
      redirect('/') and return unless logged_in?

      if @hurl = find_hurl_or_view(params[:id])
        @user.remove_hurl(@hurl['id'])
      end
      request.xhr? ? "ok" : redirect('/')
    end

    get '/hurls/:id/:view_id/?' do
      @hurl = find_hurl_or_view(params[:id])
      @view = find_hurl_or_view(params[:view_id])
      @view_id = params[:view_id]
      @hurl && @view ? erb(:index) : not_found
    end

    get '/views/:id/?' do
      @view = find_hurl_or_view(params[:id])
      @view ? erb(:view, :layout => false) : not_found
    end

    get '/about/?' do
      erb :about
    end

    get '/logout/?' do
      clear_session
      session['flash'] = 'see you later!'
      redirect '/'
    end

    post '/login/?' do
      email, password = params.values_at(:email, :password)

      if User.authenticate(email, password)
        create_session(:email => email)
        json :success => true
      else
        json :error => 'incorrect email or password'
      end
    end

    post '/signup/?' do
      email, password = params.values_at(:email, :password)
      user = User.create(:email => email, :password => password)

      if user.valid?
        create_session(:email => email)
        session['flash'] = 'welcome to hurl!'
        json :success => true
      else
        json :error => user.errors.to_s
      end
    end

    post '/' do
      return json(:error => "rate limit'd :(") if rate_limited?

      url, method, auth = params.values_at(:url, :method, :auth)
      curl = Curl::Easy.new(url)

      sent_headers = []
      curl.on_debug do |type, data|
        # track request headers
        sent_headers << data if type == Curl::CURLINFO_HEADER_OUT
      end

      curl.follow_location = true if params[:follow_redirects]

      # ensure a method is set
      method = (method.to_s.empty? ? 'GET' : method).upcase

      # update auth
      add_auth(auth, curl, params)

      # arbitrary headers
      add_headers_from_arrays(curl, params["header-keys"], params["header-vals"])

      # arbitrary params
      fields = make_fields(method, params["param-keys"], params["param-vals"])

      begin
        debug { puts "#{method} #{url}" }

        curl.send("http_#{method.downcase}", *fields)

        debug do
          puts sent_headers.join("\n")
          puts fields.join('&') if fields.any?
          puts curl.header_str
        end

        header  = pretty_print_headers(curl.header_str)
        body    = pretty_print(curl.content_type, curl.body_str)
        request = pretty_print_requests(sent_headers, fields)

        json :header    => header,
             :body      => body,
             :request   => request,
             :hurl_id   => save_hurl(params),
             :prev_hurl => @user ? @user.second_to_last_hurl_id : nil,
             :view_id   => save_view(header, body, request)
      rescue => e
        json :error => e.to_s
      end
    end


    #
    # error handlers
    #

    not_found do
      erb :"404"
    end

    error do
      erb :"500"
    end


    #
    # http helpers
    #

    # update auth based on auth type
    def add_auth(auth, curl, params)
      if auth == 'basic'
        username, password = params.values_at(:username, :password)
        encoded = Base64.encode64("#{username}:#{password}").strip
        curl.headers['Authorization'] = "Basic #{encoded}"
      end
    end

    # headers from non-empty keys and values
    def add_headers_from_arrays(curl, keys, values)
      keys, values = Array(keys), Array(values)

      keys.each_with_index do |key, i|
        next if values[i].to_s.empty?
        curl.headers[key] = values[i]
      end
    end

    # post params from non-empty keys and values
    def make_fields(method, keys, values)
      return [] unless method == 'POST'

      fields = []
      keys, values = Array(keys), Array(values)
      keys.each_with_index do |name, i|
        value = values[i]
        next if name.to_s.empty? || value.to_s.empty?
        fields << Curl::PostField.content(name, value)
      end
      fields
    end

    def save_view(header, body, request)
      hash = { 'header' => header, 'body' => body, 'request' => request }
      id = Digest::SHA1.hexdigest(hash.to_s)
      json = Yajl::Encoder.encode(hash)
      redis.set(id, json)
      id
    end

    def save_hurl(params)
      id = Digest::SHA1.hexdigest(params.to_s)
      json = Yajl::Encoder.encode(params.merge(:id => id))
      redis.set(id, json)
      @user.add_hurl(id) if @user
      id
    end

    def find_hurl_or_view(id)
      saved = redis.get(id)
      Yajl::Parser.parse(saved) rescue nil
    end

    # has this person made too many requests?
    def rate_limited?
      tries = redis.get(key="tries:#{@env['REMOTE_ADDR']}").to_i

      if tries > 10
        true
      else
        # give the key a new value and tell it to expire in 30 seconds
        redis.set(key, tries+1)
        redis.expire(key, 30)
        false
      end
    end


    #
    # pretty printing
    #

    def pretty_print(type, content)
      type = type.to_s

      if type =~ /json|javascript/
        pretty_print_json(content)
      elsif type.include? 'xml'
        pretty_print_xml(content)
      elsif type.include? 'html'
        colorize :html => content
      else
        content.inspect
      end
    end

    def pretty_print_json(content)
      colorize :js => shell("python -msimplejson.tool", :stdin => content)
    end

    def pretty_print_xml(content)
      temp = Tempfile.new(['xmlcontent', '.xml'])
      temp.print content
      temp.flush
      colorize :xml => shell("xmllint --format #{temp.path}")
    ensure
      temp.close!
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

    # debug { puts "hi!" }
    def debug
      yield if @debug
    end


    #
    # poor man's session handling
    #

    def load_session
      if session_id = session['sid']
        @session = find_session(session_id)
      end
    end

    def find_session(id)
      Yajl::Parser.parse(redis.get(id)) rescue nil
    end

    def create_session(object)
      json = Yajl::Encoder.encode(object)
      id = generate_session_id
      redis.set(id, json)
      session['sid'] = id
    end

    def clear_session
      if session_id = session['sid']
        redis.del(session_id)
        session.delete('sid')
      end
    end

    def generate_session_id
      Digest::SHA1.hexdigest(Time.now.to_s + rand(10_000).to_s)
    end
  end
end
