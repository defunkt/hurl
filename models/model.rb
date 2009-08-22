module Hurl
  class Model
    #
    # class methods
    #

    def self.create(attributes = {})
      new(attributes).save
    end

    def self.key(*parts)
      "hurl:#{name}:#{parts.join(':')}"
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
        instance_variable_set "@#{key}", value
      end
      @errors = {}
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
      {}
    end

    def to_json
      Yajl::Encoder.encode(to_hash)
    end
  end
end
