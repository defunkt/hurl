module Hurl
  module Helpers
    def logged_in?
      !!@user
    end

    # creates the hurls shown on the front page if they're not in the db
    def setup_default_hurls
      default_hurls.each do |name, params|
        save_hurl(params)
      end
    end

    def default_hurls
      return @default_hurls if @default_hurls
      path = File.expand_path(File.dirname(__FILE__) + '/hurls.yaml')
      @default_hurls = YAML.load_file(path)
    end

    # sha(hash) => '01578ad840f1a7eba2bd202351119e635fde8e2a'
    def sha(thing)
      Digest::SHA1.hexdigest(thing.to_s)
    end

    def login_partial
      instance = Mustache.new
      instance.template_file = Hurl::App.views + '/login.mustache'
      instance.to_html
    end

    # increment a single stat
    def stat(name)
      Hurl.redis.incr("Hurl:stats:#{name}")
    end

    # returns a hash of stats. symbol key, integer value
    # { :stat_name => stat_value.to_i }
    def stats
      stats = {
        :keys => Hurl.redis.keys('*').size
      }

      Hurl.redis.keys("Hurl:stats:*").each do |key|
        stats[key.sub('Hurl:stats:', '').to_sym] = Hurl.redis.get(key).to_i
      end

      stats
    end

    # for sorting hashes with symbol keys
    def sort_hash(hash)
      hash.to_a.sort_by { |a, b| a.to_s }
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
