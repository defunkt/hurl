module Views
  class Index < Mustache
    include Hurl::Helpers

    def hurl_url
    end

    def previous_hurl
      if prev = prev_hurl
        { :hurl => prev.to_s }
      end
    end

    def no_previous_hurl
      not previous_hurl
    end

    def next_hurl
      if nxt = super
        { :hurl => nxt.to_s }
      end
    end

    def no_next_hurl
      not next_hurl
    end

    def no_next_hurl_and_logged_in
      logged_in? && @hurl.any?
    end

    def no_next_hurl_and_anonymous
      no_next_hurl && !logged_in?
    end

    def method_is_GET?
      @hurl['method'] == 'GET'
    end

    def method_is_POST?
      @hurl['method'] == 'POST'
    end

    def method_is_PUT?
      @hurl['method'] == 'PUT'
    end

    def method_is_DELETE?
      @hurl['method'] == 'DELETE'
    end

    def hurl_param_keys
      return if @hurl['param-keys'].nil?
      arr = []
      @hurl['param-keys'].each_with_index do |name, i|
        arr << { :name => name, :value => @hurl['param-vals'][i] }
      end
      arr
    end

    def no_hurl_param_keys
      hurl_param_keys.nil? || hurl_param_keys.empty?
    end

    def hurl_header_keys
      return if @hurl['header-keys'].nil?
      arr = []
      @hurl['header-keys'].each_with_index do |name, i|
        arr << { :name => name, :value => @hurl['header-vals'][i] }
      end
      arr
    end

    def no_hurl_header_keys
      hurl_header_keys.nil? || hurl_header_keys.empty?
    end

    def hurl_basic_auth?
      @hurl['auth'] == 'basic'
    end

    def hurl_username
      @hurl['username']
    end

    def hurl_password
      @hurl['password']
    end

    def help_blurb_hidden?
      logged_in? or not @hurl.empty?
    end

    def try_it_hidden?
      not @hurl.empty?
    end

    def default_hurls
      super.sort.map do |name, params|
        dname = name.downcase
        { :name => name, :sha => sha(params), :class => dname.split(' ')[0] }
      end
    end
  end
end
