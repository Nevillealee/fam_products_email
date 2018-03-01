require_relative 'config/environment'
require "sinatra/activerecord/rake"

namespace :test do
  desc 'some description'
  task :products do
      SHOPIFY_INIT.pull_products
  end
end
