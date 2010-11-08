module Views
  class Index < Layout
    def previous_hurl
      if prev = prev_hurl
        [ :hurl => prev.to_s ]
      end
    end

    def next_hurl
      if nxt = super
        [ :hurl => nxt.to_s ]
      end
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

    def hide_request_and_response?
      @view.nil?
    end


    #
    # @hurl related
    #

    def hurl?
      @hurl && @hurl.any?
    end

    def hurl_post_body
      @hurl['post-body'] if @hurl
    end

    def hurl_url
      @hurl['url'] if @hurl
    end

    def method_is_GET?
      @hurl['method'] == 'GET'
    end

    def method_is_HEAD?
      @hurl['method'] == 'HEAD'
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

    def hurl_permalink
      @view_id ? "/hurls/#{@hurl['id']}/#{@view_id}" : "#"
    end

    def follows_redirects?
      @hurl['follows_redirects']
    end


    #
    # view related
    #

    def view_permalink
      @view_id ? "/views/#{@view_id}" : "#"
    end

    def view_request
      @view['request'] if @view
    end

    def view
      return unless @view
      [ :header => @view['header'], :body => @view['body'] ]
    end
  end
end
