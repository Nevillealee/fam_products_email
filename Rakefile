require 'sinatra/activerecord'
require "sinatra/activerecord/rake"

namespace :email do
  desc 'some description'
  task :some_task do |_t|
    puts 'hello world'
  end
end

namespace :db do
  task :load_config do
    require "./app"
  end
end
