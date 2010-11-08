require 'fileutils'

module Hurl
  class DB
    DIR = File.expand_path("db")

    def self.dir(id)
      FileUtils.mkdir_p DIR + '/' + id[0...2].to_s + '/' + id[2...4].to_s + '/'
    end

    def self.find(id)
      File.read dir(id) + id
    rescue Errno::ENOENT
      nil
    end

    def self.save(id, content)
      File.open(dir(id) + id, 'w') do |f|
        f.puts content
      end

      true
    end
  end
end
