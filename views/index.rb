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
  end
end
