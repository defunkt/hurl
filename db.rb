require 'fileutils'

module Hurl
  class DB
    DIR = File.expand_path(ENV['HURL_DB_DIR'] || "db")

    def self.find(scope, id)
      decode File.read(dir(scope, id) + id) if id && id.is_a?(String)
    rescue Errno::ENOENT
      nil
    end

    def self.save(scope, id, content)
      File.open(dir(scope, id) + id, 'w') do |f|
        f.puts encode(content)
      end

      true
    end

  private
    def self.dir(scope, id)
      FileUtils.mkdir_p "#{DIR}/#{scope}/#{id[0...2]}/#{id[2...4]}/"
    end

    def self.encode(object)
      Zlib::Deflate.deflate Yajl::Encoder.encode(object)
    end

    def self.decode(object)
      Yajl::Parser.parse(Zlib::Inflate.inflate(object)) rescue nil
    end
  end
end
