require 'fileutils'

module Hurl
  class DB
    DIR = File.expand_path("db")

    def self.find(id)
      decode File.read(dir(id) + id) if id && id.is_a?(String)
    rescue Errno::ENOENT
      nil
    end

    def self.save(id, content)
      File.open(dir(id) + id, 'w') do |f|
        f.puts encode(content)
      end

      true
    end

  private
    def self.dir(id)
      FileUtils.mkdir_p DIR + '/' + id[0...2].to_s + '/' + id[2...4].to_s + '/'
    end

    def self.encode(object)
      Zlib::Deflate.deflate Yajl::Encoder.encode(object)
    end

    def self.decode(object)
      Yajl::Parser.parse(Zlib::Inflate.inflate(object)) rescue nil
    end
  end
end
