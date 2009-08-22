require 'sinatra/base'

class Hurl < Sinatra::Base
  get '/' do
    "hi world!"
  end
end
