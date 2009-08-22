task :default => :deploy

desc "Sync changes and deploy the app!"
task :deploy do
  `git pull origin master && git push origin master`
  `curl -s http://hurl.r09.railsrumble.com:4000/ &> /dev/null`
end
