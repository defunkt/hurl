module Hurl
  module Helpers
    #
    # http helpers
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
      content_type 'application/json'
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

    # sha(hash) => '01578ad840f1a7eba2bd202351119e635fde8e2a'
    def sha(thing)
      Digest::SHA1.hexdigest(thing.to_s)
    end

    def encode(object)
      Hurl.encode object
    end

    def decode(object)
      Hurl.decode object
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
      sha(Time.now.to_s + rand(10_000).to_s)
    end

    # creates the hurls shown on the front page if they're not in the db
    def setup_default_hurls
      default_hurls.each do |name, params|
        save_hurl(params)
      end
    end

    def default_hurls
      return @default_hurls if @default_hurls
      path = File.expand_path(File.dirname(__FILE__) + '/hurls.yaml')
      @default_hurls = YAML.load_file(path)
    end

    #
    # view helpers
    #

    def logged_in?
      !!@user
    end

    def login_partial
      instance = Mustache.new
      instance.template = File.read(Hurl::App.views + '/login.mustache')
      instance.to_html
    end

    # increment a single stat
    def stat(name)
      Hurl.redis.incr("Hurl:stats:#{name}")
    end

    # returns a hash of stats. symbol key, integer value
    # { :stat_name => stat_value.to_i }
    def stats
      stats = {
        :keys => Hurl.redis.keys('*').size
      }

      Hurl.redis.keys("Hurl:stats:*").each do |key|
        stats[key.sub('Hurl:stats:', '').to_sym] = Hurl.redis.get(key).to_i
      end

      stats
    end

    # for sorting hashes with symbol keys
    def sort_hash(hash)
      hash.to_a.sort_by { |a, b| a.to_s }
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
end
