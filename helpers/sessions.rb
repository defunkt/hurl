module Hurl
  module Helpers
    # Poor man's session handling.
    module Sessions
      def load_session
        if session_id = session['sid']
          @session = find_session(session_id)
        end
      end

      def find_session(id)
        Yajl::Parser.parse(redis.get(id)) rescue nil
      end

      def create_session(object)
        json = Yajl::Encoder.encode(object)
        id = generate_session_id
        redis.set(id, json)
        session['sid'] = id
      end

      def clear_session
        if session_id = session['sid']
          redis.del(session_id)
          session.delete('sid')
        end
      end

      def generate_session_id
        sha(Time.now.to_s + rand(10_000).to_s)
      end
    end
  end
end
