namespace :redis do
  desc "Start Redis for development"
  task :start do
    system "redis-server"
  end
end

namespace :hurl do
  desc "Start Hurl for development"
  task :start do
    system "shotgun config.ru"
  end
end

desc "Start everything."
multitask :start => [ 'redis:start', 'hurl:start' ]
