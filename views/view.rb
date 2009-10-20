module Views
  class View < Mustache
    include Hurl::Helpers

    def view_request
      @view['request']
    end

    def view_header
      @view['header']
    end

    def view_body
      @view['body']
    end
  end
end
