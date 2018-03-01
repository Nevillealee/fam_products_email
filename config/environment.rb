require 'dotenv'
Dotenv.load

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'] || :development

require 'pp'

Dir['./models/*.rb'].each { |file| require file }
Dir['./modules/*.rb'].each { |file| require file }
