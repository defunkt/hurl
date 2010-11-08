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

    def latest_hurl
      hurls(0, 1).first
    end

    def second_to_last_hurl_id
      hurls.any? and hurls(0, 2).size == 2 and hurls(0, 2)[1]['id']
    end

    def latest_hurl_id
      hurls.any? and latest_hurl['id']
    end

    def add_hurl(id)
      hurl_ids = DB.find(:users, db_id) || {}
      hurl_ids[id] = Time.now
      DB.save(:users, db_id, hurl_ids)
    end

    def remove_hurl(id)
      hurl_ids = DB.find(:users, db_id) || {}
      hurl_ids.delete(id)
      DB.save(:users, db_id, hurl_ids)
    end

    def db_id
      Digest::MD5.hexdigest(id.to_s)
    end

    def unsorted_hurls(start = 0, limit = 100)
      Array(DB.find(:users, db_id)).map do |id, date|
        DB.find(:hurls, id).merge('date' => Time.parse(date)) if id
      end.compact
    end

    def hurls(start = 0, limit = 100)
      unsorted_hurls(start, limit).sort_by { |h| -h['date'].to_i }
    end

    #
    # instance methods
    #

    def to_s
      login
    end

    def gravatar_url
      "http://www.gravatar.com/avatar/%s" % github_user.attribs['gravatar_id']
    end
  end
end
