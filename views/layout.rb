module Views
  class Layout < Mustache
    include Hurl::Helpers

    def anonymous?
      not logged_in?
    end

    def no_flash
      not @flash
    end

    def flash
      @flash
    end
  end
end
