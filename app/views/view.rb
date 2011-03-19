module Views
  class View < Layout
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
