module Views
  class Layout < Mustache
    include Hurl::Helpers

    def no_flash
      not @flash
    end

    def flash
      @flash
    end

    def deployed_sha
      @deployed_sha ||= `git rev-parse --short HEAD`
    end
  end
end
