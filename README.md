Hurl
====

It rocks.

http://hurl.it/
  
Dependencies
------------
  
* Ruby 1.8.6
* Python
* simplejson ( `easy_install simplejson` )
* Pygments ( `easy_install Pygments` )
* xmllint ( `emerge dev-libs/libxml2` )
* Yajl-Ruby ( `gem install yajl-ruby` )
* Sinatra ( `gem install sinatra` )
* Curb ( `gem install curb` )
* Redis ( `rake -f vendor/redis-rb/tasks/redis.tasks.rb redis:install` )

Run Locally
-----------

$ shotgun config.ru

Visit http://localhost:9393/ in your browser.

Deployment
----------

$ git commit -a -m "my changes"
$ rake deploy

As long as you have push access to the repository, `rake deploy`
will work dandy.