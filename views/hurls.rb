module Views
  class Hurls < Mustache
    include Hurl::Helpers

    def hurls
      @hurls.map do |hurl|
        {
          :id     => hurl.id,
          :url    => hurl.url,
          :method => hurl.method,
          :auth   => hurl.auth == 'none' ? 'no auth' : 'HTTP basic',
          :date   => hurl.date
        }
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
