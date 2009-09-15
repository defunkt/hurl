module Hurl
  module Helpers
    def logged_in?
      !!@user
    end

    def stats
      {}
    end

    def next_hurl
      return unless logged_in?

      if @hurl
        hurls = @user.hurls
        hurls.each_with_index do |hurl, i|
          if hurl['id'] == @hurl['id']
            return i-1 >= 0 ? hurls[i-1]['id'] : nil
          end
        end
        nil
      end
    end

    def prev_hurl
      return unless logged_in?

      if @hurl.empty? && @user.any_hurls?
        @user.latest_hurl_id
      elsif @hurl.any?
        hurls = @user.hurls
        hurls.each_with_index do |hurl, i|
          if hurl['id'] == @hurl['id']
            return hurls[i+1] ? hurls[i+1]['id'] : nil
          end
        end
        nil
      end
    end

  end
end
