module Views
  class Layout < Mustache
    include Hurl::Helpers

    def no_flash
      not @flash
    end

    def flash
      @flash
    end

    def bundled?
      File.exist?("#{RACK_ROOT}/public/css/bundle.css") &&
        File.exist?("#{RACK_ROOT}/public/js/bundle.js")
    end
  end
end
