module Hurl
  class Model
    attr_accessor :id

    #
    # class methods
    #

    def self.create(attributes = {})
      new(attributes).save
    end

    def self.indices
      @indices ||= []
    end

    def self.index(field)
      indices << field

      sing = (class << self; self end)
      sing.send(:define_method, "find_by_#{field}") do |value|
        from_json redis.get(key(field, value))
      end
    end

    def self.inherited(subclass)
      subclass.index :id
    end

    def self.key(*parts)
      "#{name}:v1:#{parts.join(':')}"
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

    def errors
      @errors
    end

    def save
      if valid?
        @saved = true
        self.class.indices.each do |index|
          redis.set(key(index, send(index)), to_json)
        end
      end
      self
    end

    def id
      @id ||= generate_id
    end

    def generate_id
      redis.incr key(:id)
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
