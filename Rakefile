require_relative 'config/environment'
require "sinatra/activerecord/rake"

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

namespace :test do
  desc 'some description'
  task :products do
      SHOPIFY_INIT.pull_products
  end
end
