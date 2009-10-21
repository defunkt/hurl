require 'libraries'

module Hurl
  def self.redis
    return @redis if @redis
    @redis = Redis.new(:host => '127.0.0.1', :port => 6379, :thread_safe => true)
  end

  def self.redis=(redis)
    @redis = redis
  end

  def self.encode(object)
    Zlib::Deflate.deflate Yajl::Encoder.encode(object)
  end

  def self.decode(object)
    Yajl::Parser.parse(Zlib::Inflate.inflate(object)) rescue nil
  end

  class App < Sinatra::Base
    register Mustache::Sinatra
    helpers Hurl::Helpers

    dir = File.dirname(File.expand_path(__FILE__))

    set :views,     "#{dir}/templates"
    set :mustaches, "#{dir}/views"
    set :public,    "#{dir}/public"
    set :static,    true

    enable :sessions

    def initialize(*args)
      super
      @debug = ENV['DEBUG']
      setup_default_hurls
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

    get '/' do
      @hurl = {}
      mustache :index
    end

    get '/hurls/?' do
      redirect('/') and return unless logged_in?
      @hurls = @user.hurls
      mustache :hurls
    end

    get '/hurls/:id/?' do
      @hurl = find_hurl_or_view(params[:id])
      @hurl ? mustache(:index) : not_found
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
      @hurl && @view ? mustache(:index) : not_found
    end

    get '/views/:id/?' do
      @view = find_hurl_or_view(params[:id])
      @view ? mustache(:view, :layout => false) : not_found
    end

    get '/test.json' do
      content_type 'application/json'
      File.read('test/json')
    end

    get '/test.xml' do
      content_type 'application/xml'
      File.read('test/xml')
    end

    get '/about/?' do
      mustache :about
    end

    get '/stats/?' do
      mustache :stats
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
        stat :users
        session['flash'] = 'welcome to hurl!'
        json :success => true
      else
        json :error => user.errors.to_s
      end
    end

    post '/' do
      return json(:error => "Calm down and try my margarita!") if rate_limited?

      url, method, auth = params.values_at(:url, :method, :auth)

      return json(:error => "That's... wait.. what?!") if invalid_url?(url)
      
      url = expand_url_template(url, params[:url_params]) if params[:url_params]

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
    
    post '/url-template' do
      template = Addressable::Template.new params[:url]
      
      json :variables => template.variables,
           :defaults  => template.variable_defaults
    end


    #
    # error handlers
    #

    not_found do
      mustache :"404"
    end

    error do
      mustache :"500"
    end


    #
    # route helpers
    #

    # is this a url hurl can handle. basically a spam check.
    def invalid_url?(url)
      url.include? 'hurl.it'
    end

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
      id = sha(hash.to_s)
      json = encode(hash)
      redis.set(id, json)
      id
    end

    def save_hurl(params)
      id = sha(params.to_s)
      json = encode(params.merge(:id => id))
      was_set = redis.setnx(id, json)
      stat :hurls if was_set
      @user.add_hurl(id) if @user
      id
    end

    def find_hurl_or_view(id)
      decode redis.get(id)
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
    
    def expand_url_template(url, data)
      Addressable::Template.new(url).expand(data)
    end
  end
end
