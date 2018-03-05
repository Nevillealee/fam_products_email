require 'pry'
require 'dotenv'
require 'resque'
require 'httparty'

class SubscriptionCache
  def initialize
    Dotenv.load
    recharge_regular = ENV['RECHARGE_ACCESS_TOKEN']
    @sleep_recharge = ENV['RECHARGE_SLEEP_TIME']
    @my_header = {
      "X-Recharge-Access-Token" => recharge_regular
    }
    @uri = URI.parse(ENV['DATABASE_URL'])
    @conn = PG.connect(@uri.hostname, @uri.port, nil, nil, @uri.path[1..-1], @uri.user, @uri.password)
  end

  def handle_subscriptions(option)
    params = { "option_value" => option, "connection" => @uri, "header_info" => @my_header, "sleep_recharge" => @sleep_recharge }
    if option == "full_pull"
      puts "Doing full pull of subscription table and associated tables"

      # delete tables and do full pull
      Resque.enqueue(PullSubscription, params)
    else
      puts "sorry, cannot understand option #{option}, doing nothing."
    end
  end
end

class PullSubscription
  @queue = "pull_subscriptions"
  def self.perform(params)
    get_sub_full(params)
  end

  def self.get_sub_full(params)
    option_value = params['option_value']
    uri = params['connection']
    sleep_recharge = params['sleep_recharge']
    myuri = URI.parse(uri)
    my_conn = PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
    header_info = params['header_info']

    if option_value == "full_pull"
      # delete all order tables
      puts "Deleting subscription table and associated tables"
      subs_delete = "delete from subscriptions"
      subs_reset = "ALTER SEQUENCE subscriptions_id_seq RESTART WITH 1"
      my_conn.exec(subs_delete)
      my_conn.exec(subs_reset)
      sub_line_items_delete = "delete from sub_line_items"
      sub_line_items_reset = "ALTER SEQUENCE sub_line_items_id_seq RESTART WITH 1"
      my_conn.exec(sub_line_items_delete)
      my_conn.exec(sub_line_items_reset)
      puts "All done deleting and resetting subscription and associated tables"
      num_subs = background_count_subscriptions(header_info)
      puts "We have #{num_subs} full subscriptions"

      background_load_full_subs(sleep_recharge, num_subs, header_info, uri)
    else
      puts "Can't understand option #{option_value} doing nothing"
    end
  end

  def self.background_count_subscriptions(header_info)
    subscriptions = HTTParty.get("https://api.rechargeapps.com/subscriptions/count", :headers => header_info)
    my_response = JSON.parse(subscriptions)
    my_count = my_response['count'].to_i
    my_count
  end

  def self.background_load_full_subs(sleep_recharge, num_subs, header_info, uri)
    myuri = URI.parse(uri)
    conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)

    my_insert = "insert into subscriptions (subscription_id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, price, quantity, status, shopify_product_id, shopify_variant_id, sku, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, raw_line_item_properties, expire_after_specific_number_charges) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21)"
    conn.prepare('statement1', "#{my_insert}")
    my_line_item_insert = "insert into sub_line_items (subscription_id, name, value) values ($1, $2, $3)"
    conn.prepare('statement2', "#{my_line_item_insert}")
    my_temp_array = Array.new

    start = Time.now

    page_size = 250
    num_pages = (num_subs/page_size.to_f).ceil
    1.upto(num_pages) do |page|
      mysubs = HTTParty.get("https://api.rechargeapps.com/subscriptions?limit=250&page=#{page}", :headers => header_info)
      local_sub = mysubs['subscriptions']
      local_sub.each do |sub|
        if !sub['properties'].nil? && sub['properties'] != []
          puts sub.inspect
          id = sub['id']
          address_id = sub['address_id']
          customer_id = sub['customer_id']
          created_at = sub['created_at']
          updated_at = sub['updated_at']
          #handle nils for these
          next_charge_scheduled_at = sub['next_charge_scheduled_at']
          cancelled_at = sub['cancelled_at']


          product_title = sub['product_title']
          variant_title = sub['variant_title']
          price = sub['price']
          quantity = sub['quantity']
          shopify_product_id = sub['shopify_product_id']
          shopify_variant_id = sub['shopify_variant_id']
          sku = sub['sku']
          status = sub['status']
          order_interval_unit = sub['order_interval_unit']
          order_interval_frequency  = sub['order_interval_frequency']
          charge_interval_frequency = sub['charge_interval_frequency']
          cancellation_reason = sub['cancellation_reason']

          order_day_of_week = sub['order_day_of_week']

          order_day_of_month = sub['order_day_of_month']

          properties  = sub['properties'].to_json
          expire_after = sub['expire_after_specific_number_of_charges'].to_i
          conn.exec_prepared('statement1', [id, address_id, customer_id, created_at, updated_at, next_charge_scheduled_at, cancelled_at, product_title, price, quantity, status, shopify_product_id, shopify_variant_id, sku, order_interval_unit, order_interval_frequency, charge_interval_frequency, order_day_of_month, order_day_of_week, properties, expire_after ])

          puts sub['properties'].inspect
          my_temp_array = sub['properties']
          my_temp_array.each do |temp|
            temp_name = temp['name']
            temp_value = temp['value']
            puts "#{temp_name}, #{temp_value}"
            conn.exec_prepared('statement2', [id, temp_name, temp_value])
          end
        end
      end
      current = Time.now
      duration = (current - start).ceil
      puts "Been running #{duration} seconds"
      puts "Done with page #{page}"
      puts "Sleeping #{sleep_recharge}"
      sleep sleep_recharge.to_i
    end
    puts "All done with full download of subscriptions"
    conn.close
  end
end
