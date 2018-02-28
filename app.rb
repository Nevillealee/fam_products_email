require 'dotenv'
require 'sinatra'
require "sinatra/reloader"
require 'active_support/all'
require "sinatra/activerecord"

class FamProductsEmail < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure do
    enable :logging
    enable :sessions
    Dotenv.load
    set :server, :puma
  end

  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    'Hello World'
  end
end
