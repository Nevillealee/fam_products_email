require "sinatra/activerecord/rake"
require_relative 'config/environment'

namespace :email do
  desc 'some description'
  task :some_task do |_t|
    puts 'hello world'
  end
end

namespace :db do
  desc 'some description'
  task :load_config do
    require "./app"
  end
end
