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
    end
  end
end
