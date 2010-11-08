module Hurl
  class User < Model
    attr_accessor :login, :github_user
    index :login

    #
    # each user has an associated list
    # of hurls
    #

    def add_hurl(hurl)
      redis.sadd(hurls_key, hurl)
      redis.set(hurls_key(hurl), Time.now.to_i)
    end

    def remove_hurl(hurl)
      redis.srem(hurls_key, hurl)
      redis.del(hurls_key(hurl))
    end

    def unsorted_hurls
      redis.smembers(hurls_key)
    end

    def any_hurls?
      redis.scard(hurls_key).to_i > 0
    end

    def latest_hurl
      hurls(0, 1).first
    end

    def second_to_last_hurl_id
      any_hurls? and hurls(0, 2).size == 2 and hurls(0, 2)[1]['id']
    end

    def latest_hurl_id
      any_hurls? and latest_hurl['id']
    end

    def hurls(start = 0, limit = 100)
      @hurls ||= hurls!(start, limit)
    end

    def hurls!(start = 0, limit = 100)
      return [] unless any_hurls?

      hurls = redis.sort hurls_key,
        :by    => "#{hurls_key}:*",
        :order => 'DESC',
        :get   => "*",
        :limit => [start, limit]

      # convert hurls to ruby objects
      hurls.map! { |hurl| Hurl.decode(hurl) }

      # find and set the corresponding timestamps for
      # each hurl (scoped to this user)
      keys = hurls.map { |h| hurls_key(h['id']) }
      redis.mget(keys).each_with_index do |date, i|
        hurls[i]['date'] = Time.at(date.to_i)
      end
      hurls
    end


    #
    # instance methods
    #

    def to_s
      login
    end

    def validate
      true
    end

    def to_hash
      return {
        'id'    => id,
        'login' => login
      }
    end

    def gravatar_url
      "http://www.gravatar.com/avatar/%s" % github_user.attribs['gravatar_id']
    end

    def hurls_key(*parts)
      key(id, :hurls, *parts)
    end
  end
end
