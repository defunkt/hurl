RACK_ENV  = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
RACK_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

# std lib
require 'open3'
require 'uri'
require 'base64'
require 'digest'
require 'zlib'
require "rexml/document"

# bundled gems
require 'sinatra/base'
require 'yajl'
require 'curb'
require 'mustache/sinatra'
require 'sinatra/auth/github'
require 'coderay'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# hurl
require 'helpers'

require 'models/db'
require 'models/user'

require 'views/layout'
