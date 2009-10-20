module Views
  class Hurls < Mustache
    include Hurl::Helpers

    def hurls
      @user.hurls.map do |hurl|
        hurl['auth'] = hurl['auth'] == 'none' ? 'no auth' : 'HTTP basic'
        hurl
      end
    end

    def any_hurls?
      hurls.any?
    end

    def no_hurls
      not any_hurls?
    end
  end
end
