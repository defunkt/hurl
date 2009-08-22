module Hurl
  class User < Model
    attr_accessor :email, :password, :crypted_password
    SALT = '==asdaga3hg8hwg98w4h9hg8ohsrg8hsklghsdgl=='

    # find_by_email
    index :email

    #
    # each user has an associated list
    # of hurls
    #

    def add_hurl(hurl)
      json = Yajl::Encoder.encode([ Time.now.to_i, hurl])
      redis.lpush(key(id, :hurls), json)
    end

    def list_hurls
      redis.lrange(key(id, :hurls), 0, 100)
    end


    #
    # authentication
    #

    def self.authenticate(email, password)
      return unless user = find_by_email(email)

      if user.crypted_password == crypted_password(password)
        user
      end
    end

    def self.crypted_password(password)
      Digest::SHA1.hexdigest("--#{password}-#{SALT}--")
    end

    def password=(password)
      @password = password
      @crypted_password = self.class.crypted_password(password)
    end


    #
    # instance methods
    #

    def to_s
      email
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

    def to_hash
      return {
        'id'               => id,
        'email'            => email,
        'crypted_password' => crypted_password
      }
    end
  end
end
