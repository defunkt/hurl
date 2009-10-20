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
    `which #{app}`; $?.success?
  end

  desc "Generate GitHub pages."
  task :pages => :check_dirty do
    require "mustache"
    require "rdiscount"
    view = Mustache.new
    view.template = File.read("docs/index.mustache")
    view[:content] = Markdown.new(File.read("README.md")).to_html
    File.open("new_index.html", "w") do |f|
      f.puts view.render
    end
    system "git checkout gh-pages"
    system "git pull origin gh-pages"
    system "mv new_index.html index.html"
    system "git commit -a -m 'auto update docs'"
    system "git push origin gh-pages"
    system "git checkout master"
  end

  task :check_dirty do
    if `git status -a` && $?.success?
      abort "dirty index - not publishing!"
    end
  end
end

desc "Start everything."
multitask :start => [ 'redis:start', 'hurl:start' ]
