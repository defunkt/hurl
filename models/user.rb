module Hurl
  class User
    attr_accessor :email, :password

    #
    # class methods
    #

    def self.create(attributes = {})
      email, password = attributes.values_at(:email, :password)
      new(:email => email, :password => password).save
    end

    def self.find_by_email(email)
      from_json redis.get(key(email))
    end

    def self.key(*parts)
      "hurl:user:#{parts.join(':')}"
    end

    def key(*parts)
      self.class.key(*parts)
    end

    def self.redis
      Hurl.redis
    end

    def redis
      Hurl.redis
    end


    #
    # instance methods
    #

    def initialize(attributes = {})
      attributes.each do |key, value|
        send "#{key}=", value
      end
      @errors = {}
    end

    def to_s
      email
    end

    def errors
      @errors
    end

    def save
      if valid?
        @saved = true
        redis.set(key(email), to_json)
      end
      self
    end

    def saved?
      @saved
    end

    def saved=(saved)
      @saved = saved
    end

    def valid?
      saved? || validate
    end

    def validate
      if email.to_s.strip.empty?
        errors[:email] = " is empty"
      elsif password.to_s.strip.empty?
        errors[:password] = " is empty"
      elsif self.class.find_by_email(email)
        errors[:email] = " already exists"
      elsif email !~ /^[^@]+@[^@]+$/
        errors[:email] = " isn't an email address"
      end

      errors.empty?
    end


    #
    # serialization
    #

    # used to initialize an instance which has
    # already been persisted
    def self.from_hash(hash)
      new(hash.merge(:saved => true))
    end

    def self.from_json(json)
      from_hash Yajl::Parser.parse(json) rescue nil
    end

    def to_hash
      return {
        'email'    => email,
        'password' => password
      }
    end

    def to_json
      Yajl::Encoder.encode(to_hash)
    end
  end
end
