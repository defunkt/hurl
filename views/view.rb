module Views
  class View < Mustache
    include Hurl::Helpers

    self.path = File.dirname(__FILE__) + '/../templates'

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
