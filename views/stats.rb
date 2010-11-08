module Views
  class Stats < Layout
    def hurl_stats
      return [
        count(:users),
        count(:views),
        count(:hurls)
      ]
    end

    def count(thing)
      files = Dir["#{Hurl::DB::DIR}/#{thing}/**/**"].reject do |file|
        File.directory?(file)
      end

      { :stat => thing, :value => files.size }
    end

    def disk_stats
      [ :stat => 'db-size', :value => `du -sh db`.split(' ')[0] ]
    end
  end
end
