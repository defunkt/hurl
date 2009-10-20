Hurl
====

Kinda like Curl.

Hurl was created for the Rails Rumble 2009 in 48 hours by [Leah Culver][2] and [Chris Wanstrath][3].
Now Hurl is an open source project for your enjoyment. 

<http://hurl.it/>


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

If any of the gems can't be found (*cough* mustache *cough*) you need
to setup Gemcutter:

    $ gem install gemcutter
    $ gem tumble

Now try to install the gems again.

And finally Redis.

    * Homebrew
    $ brew install redis

    * Gentoo
    $ emerge redis

    * Other
    $ rake -f vendor/redis-rb/tasks/redis.tasks.rb redis:install

  
Get Hurl
--------

Clone with Git:

    $ git clone git://github.com/defunkt/hurl

Download in either [zip](http://github.com/defunkt/hurl/zipball/master) or [tar](http://github.com/defunkt/hurl/tarball/master) formats.


Run Locally
-----------

    $ rake start

If you have [shotgun](http://github.com/rtomayko/shotgun) installed:

Visit <http://localhost:9393> in your browser.

If not:

Visit <http://localhost:9292> in your browser.


Issues
------

Find a bug? Want a feature? Submit an [issue here](http://github.com/defunkt/hurl/issues). Patches welcome! 


Authors
-------

* [Leah Culver][2]
* [Chris Wanstrath][3]


[1]: http://r09.railsrumble.com/
[2]: http://github.com/leah
[3]: http://github.com/defunkt