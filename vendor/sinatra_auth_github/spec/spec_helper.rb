Bundler.require(:default, :runtime, :test)

require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra', 'auth', 'github')

require 'pp'

Webrat.configure do |config|
  config.mode = :rack
  config.application_port = 4567
end

Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)

  def app
    Example.app
  end
end
