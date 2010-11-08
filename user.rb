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

    def add_hurl(id)
      hurls << id
      hurls.uniq!
      DB.save db_file, hurls
    end

    def remove_hurl(id)
      hurls.delete(id)
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
      @hurls ||= hurls!(start = 0, limit = 100)
    end
    alias_method :unsorted_hurls, :hurls

    def hurls!(start = 0, limit = 100)
      Array(DB.find(db_file)).map do |id|
        id ? DB.find(id) : nil
      end.compact
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
