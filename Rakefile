namespace :redis do
  desc "Start Redis for development"
  task :start do
    system "redis-server"
  end
end

namespace :hurl do
  desc "Start Hurl for development"
  task :start do
    if installed? :shotgun
      system "shotgun config.ru"
    else
      system "rackup config.ru"
    end
  end

  def installed?(app)
    not `which #{app}`.chomp.empty?
  end
end

desc "Start everything."
multitask :start => [ 'redis:start', 'hurl:start' ]
