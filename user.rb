module Hurl
  class User
    attr_accessor :id, :login, :github_user

    def initialize(github_user)
      @github_user = github_user
      @login       = github_user.login
      @id          = github_user.attribs['id']
    end

    #
    # each user has an associated list
    # of hurls
    #

    def add_hurl(hurl)
      hurls << hurl
      DB.save db_file, hurls.uniq
    end

    def remove_hurl(hurl)
      hurls.delete(hurl)
      DB.save db_file, hurls
    end

    def latest_hurl
      hurls(0, 1).first
    end

    def second_to_last_hurl_id
      hurls.any? and hurls(0, 2).size == 2 and hurls(0, 2)[1]['id']
    end

    def latest_hurl_id
      hurls.any? and latest_hurl['id']
    end

    def db_file
      Digest::MD5.hexdigest(id.to_s)
    end

    def hurls(start = 0, limit = 100)
      DB.find(db_file) || []
    end
    alias_method :unsorted_hurls, :hurls

    def hurls!(start = 0, limit = 100)
      return [] unless hurls.any?

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

    def login
      @login ||= github_user.login
    end

    def gravatar_url
      "http://www.gravatar.com/avatar/%s" % github_user.attribs['gravatar_id']
    end
  end
end
