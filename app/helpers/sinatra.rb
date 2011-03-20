module Hurl
  module Helpers
    # Random Sinatra DSL helpers.
    # Quite generic.
    module Sinatra
      # render a json response
      def json(hash = {})
        content_type 'application/json'
        Yajl::Encoder.encode(hash)
      end

      # colorize :js => '{ "blah": true }'
      def colorize(hash = {})
        tokens = CodeRay.scan(hash.values.first, hash.keys.first)
        tokens.html.div.sub('CodeRay', 'highlight')
      end

      # shell "cat", :stdin => "file.rb"
      def shell(cmd, options = {})
        ret = ''
        Open3.popen3(cmd) do |stdin, stdout, stderr|
          if options[:stdin]
            stdin.puts options[:stdin].to_s
            stdin.close
          end
          ret = stdout.read.strip
        end
        ret
      end
    end
  end
end
