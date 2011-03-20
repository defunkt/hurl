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
        tokens  = CodeRay.scan(hash.values.first, hash.keys.first)
        colored = tokens.html.div.sub('CodeRay', 'highlight')
        colored.gsub(/(https?:\/\/[^< "']+)/, '<a href="\1" target="_blank">\1</a>')
      end
    end
  end
end
