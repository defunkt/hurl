Hurl
====

Kinda like Curl. Created for the [Rails Rumble 2009][1] in 48 hours by
Leah Culver and Chris Wanstrath.

Live site: <http://hurl.it/>


Installation
------------

* Ruby 1.8.6+
* Python 2.5+

First install xmllint:

    * Homebrew
    $ brew install xmllint

    * Gentoo
    $ emerge dev-libs/libxml2

Next install the Python eggs:

    $ easy_install simplejson Pygments

Then the Rubygems:

    $ gem install yajl-ruby sinatra curb mustache

And finally Redis.

    * Homebrew
    $ brew install redis

    * Gentoo
    $ emerge redis

    * Other
    $ rake -f vendor/redis-rb/tasks/redis.tasks.rb redis:install


Run Locally
-----------

    $ redis-server
    $ rackup config.ru

Visit <http://localhost:9292> in your browser.


Development
-----------

We recommend Shotgun.

    $ gem install shotgun
    $ shotgun config.ru

Then visit <http://localhost:9292> in your browser.


Authors
-------

* [Leah Culver](http://leahculver.com)
* [Chris Wanstrath](http://ozmm.org)

[1]: http://r09.railsrumble.com/
