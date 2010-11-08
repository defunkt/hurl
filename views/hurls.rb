module Views
  class Hurls < Layout
    def hurls
      @user.hurls.map do |hurl|
        hurl['auth'] = hurl['auth'] == 'none' ? 'no auth' : 'HTTP basic'
        hurl
      end
    end
  end
end
