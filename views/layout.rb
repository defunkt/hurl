module Views
  class Layout < Mustache
    include Hurl::Helpers

    def no_flash
      not @flash
    end

    def flash
      @flash
    end
  end
end
