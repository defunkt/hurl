module Views
  class Stats < Mustache
    include Hurl::Helpers

    self.path = File.dirname(__FILE__) + '/../templates'

    def hurl_stats
      stat_value_hash stats
    end

    def redis_stats
      stat_value_hash Hurl.redis.info
    end

  private
    def stat_value_hash(stats)
      sort_hash(stats).map do |stat, value|
        { :stat => stat, :value => value }
      end
    end
  end
end
