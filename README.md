Hurl
====

Hurl was created for the Rails Rumble 2009 in 48 hours.
Now Hurl is an open source project for your enjoyment.

<http://hurl.it/>


Installation
------------

* Ruby 1.8.6+
* Python 2.5+

First download hurl and cd into the directory:

    git clone git://github.com/defunkt/hurl
    cd hurl

Or download in either
[zip](http://github.com/defunkt/hurl/zipball/master) or
[tar](http://github.com/defunkt/hurl/tarball/master) formats.

Then install xmllint:

    * Homebrew
    brew install libxml2

    * Gentoo
    emerge dev-libs/libxml2

    * Ubuntu/Debian
    apt-get install libxml2-utils

Next install the Python eggs:

    easy_install Pygments

Then the RubyGems (you may need to `gem install bundler`):

    bundle install


Run Locally
-----------

    bundle exec shotgun config.ru

Now visit <http://localhost:9393>


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
