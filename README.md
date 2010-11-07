Hurl
====

Hurl was created for the Rails Rumble 2009 in 48 hours.
Now Hurl is an open source project for your enjoyment.

<http://hurl.it/>


Installation
------------

* Ruby 1.8.6+
* Python 2.5+

First install xmllint:

    * Homebrew
    $ brew install libxml2

    * Gentoo
    $ emerge dev-libs/libxml2

    * Ubuntu/Debian
    $ apt-get install libxml2-utils

Next install the Python eggs:

    $ easy_install simplejson Pygments

Then the RubyGems:

    $ gem install yajl-ruby sinatra curb rack
    $ gem install mustache --source=http://gemcutter.org

And finally Redis.

    * Homebrew
    $ brew install redis

    * Gentoo
    $ emerge redis

    * Other
    $ rake -f vendor/redis-rb/tasks/redis.tasks.rb redis:install


Get Hurl
--------

Browse the source on GitHub: <http://github.com/defunkt/hurl>

Clone with Git:

    $ git clone git://github.com/defunkt/hurl

Or download in either
[zip](http://github.com/defunkt/hurl/zipball/master) or
[tar](http://github.com/defunkt/hurl/tarball/master) formats.


Run Locally
-----------

    $ rake start

If you have [shotgun][4] installed: <http://localhost:9393>

If not: <http://localhost:9292>


Issues
------

Find a bug? Want a feature? Submit an [issue
here](http://github.com/defunkt/hurl/issues). Patches welcome!


Screenshot
----------

[![Hurl](http://img.skitch.com/20091020-xtiqtj4eajuxs43iu5h3be7upj.png)](http://hurl.it)


Authors
-------

* [Leah Culver][2]
* [Chris Wanstrath][3]


[1]: http://r09.railsrumble.com/
[2]: http://github.com/leah
[3]: http://github.com/defunkt
[4]: http://github.com/rtomayko/shotgun
