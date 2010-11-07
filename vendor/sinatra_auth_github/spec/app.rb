require 'pp'

module Example
  class App < Sinatra::Base
    enable :sessions

    set  :github_options, { :client_id => ENV['GH_CLIENT_ID'],
                            :secret    => ENV['GH_SECRET'],
                            :scopes    => 'user,offline_access,repo' }

    register Sinatra::Auth::Github

    before do
      authenticate!
    end

    helpers do
      def repos
        github_request("repos/show/#{github_user.login}")
      end
    end

    get '/' do
      "Hello There, #{github_user.name}!#{github_user.token}\n#{repos.inspect}"
    end

    get '/logout' do
      logout!
      redirect '/'
    end
  end
end
