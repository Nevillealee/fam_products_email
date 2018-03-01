require_relative 'config/environment'
require 'resque/tasks'
require "sinatra/activerecord/rake"

desc 'do full or partial pull of subscription table and associated tables and add to DB'
task :subscription_pull, [:args] do |t, args|
  SubscriptionCache.new.handle_subscriptions(*args)
end

desc 'do full or partial pull of customers and add to DB'
task :customer_pull, [:args] do |t, args|
  CustomerCache.new.handle_customers(*args)
end

namespace :customer_service do
  desc 'save the customer name and email to a csv for all customers of a given size'
  task :save_customer_data, [:size] do |_t, size|
    subscriptions = Subscription.all.select do |subscription|
      subscription.active? && subscription.sizes.any? { |k, v| v == size.size }
    end
    customers = subscriptions.map(&:customer)

    CSV.open("customers.csv", "a+") do |csv|
      csv << ['first_name', 'last_name', 'email'] # headers

      customers.each do |customer|
        csv << [customer.first_name, customer.last_name, customer.email]
      end
    end
  end

  desc 'creates a csv with customer_email, bad_order_number, correct_product_title, top_size, leggings_size, and bra_size'
  task :create_bad_orders_csv do |_t|
    BadOrders.new.create_csv
  end
end

namespace :db do
  desc 'some description'
  task :load_config do
    require "./app"
  end
end
