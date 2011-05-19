Hurl
====

Hurl was created for the Rails Rumble 2009 in 48 hours.
Now Hurl is an open source project for your enjoyment.

<http://hurl.it/>


Installation
------------

Hurl requires Ruby 1.8.6+

First download hurl and cd into the directory:

    git clone git://github.com/defunkt/hurl
    cd hurl

Or download [the zip](http://github.com/defunkt/hurl/zipball/master).

Next make sure you have [RubyGems](https://rubygems.org/pages/download) installed.

Then install [Bundler](http://gembundler.com/):

    gem install bundler

Now install Hurl's dependencies:

    bundle install


Run Locally
-----------

    bundle exec shotgun config.ru

Now visit <http://localhost:9393>


Proxy Support
-------------

Run hurl through a proxy by just adding the URL and port of the proxy.

Use a public proxy from: http://www.hidemyass.com/proxy-list/

or create a proxy tunnel to a secure server: 

	ssh -D <port> -f -C -v -N <username>@<some.proxy.server>



For example, if I used HideMyAss IP and Port, the UI would look like this:

[![Hide My Ass](https://img.skitch.com/20110519-fq6rercxgy4xt5wtkxt5y3q3s8.jpg)](https://img.skitch.com/20110519-fq6rercxgy4xt5wtkxt5y3q3s8.jpg)

and if I use a proxy tunnel with socks5 and port 9999 with the ssh command above, the UI would look like this:

[![Proxy](https://img.skitch.com/20110519-frcu27a2rd455381mb4s3a5a4g.jpg)](https://img.skitch.com/20110519-frcu27a2rd455381mb4s3a5a4g.jpg)


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
