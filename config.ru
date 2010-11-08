begin
  require 'env' 
rescue LoadError
  nil
end

require 'hurl'

run Hurl::App.new
