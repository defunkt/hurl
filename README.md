Hurl
====

It rocks.

http://hurl.it/
  
Installation
------------
  
* Ruby 1.8.6+
* Python 2.5+

First install xmllint:

    * Homebrew
    brew install xmllint
    
    * Gentoo
    emerge dev-libs/libxml2

Next install the Python eggs:

    sudo easy_install simplejson Pygments
    
Then the Rubygems:

    sudo gem install yajl-ruby sinatra curb
    
And finally Redis.

    * Homebrew
    brew install redis; redis-server /usr/local/etc/redis.conf
    
    * Gentoo
    emerge redis

    * Other
    rake -f vendor/redis-rb/tasks/redis.tasks.rb redis:install   

Run Locally
-----------

$ shotgun config.ru

Visit http://localhost:9393/ in your browser.
