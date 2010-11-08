require 'hurl'

begin
  require 'env' 
rescue LoadError
  nil
end

run Hurl::App.new
