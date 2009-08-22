module Hurl
  class User < Model
    attr_accessor :email, :password
    SALT = '==asdaga3hg8hwg98w4h9hg8ohsrg8hsklghsdgl=='

    #
    # class methods
    #

    def self.authenticate(email, password)
      return unless user = find_by_email(email)

      if user.password == crypted_password(password)
        user
      end
    end

    def self.crypted_password(password)
      Digest::SHA1.hexdigest("--#{password}-#{SALT}--")
    end

    def self.find_by_email(email)
      from_json redis.get(key(email))
    end


    #
    # instance methods
    #

    def password=(password)
      @password = self.class.crypted_password(password)
    end

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
        'email'    => email,
        'password' => password
      }
    end
  end
end
