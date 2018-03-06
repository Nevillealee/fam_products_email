require 'pry'
require 'dotenv'
require 'resque'
require 'httparty'

class CustomerCache
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

  def handle_customers(option)
    params = {"option_value" => option, "connection" => @uri, "header_info" => @my_header, "sleep_recharge" => @sleep_recharge}
    if option == "full_pull"
      puts "Doing full pull of customers"
      puts "handle_customers uri: #{@uri.inspect}"

      # delete tables and do full pull
      Resque.enqueue(PullCustomer, params)
    else
      puts "sorry, cannot understand option #{option}, doing nothing."
    end
  end

  class PullCustomer
    @queue = "pull_customer"

    def self.perform(params)
      puts "PullCustomer#perform params: #{params.inspect}"
      get_customers_full(params)
    end

    def self.get_customers_full(params)
      puts "EllieHelper#get_customers_full params: #{params}"
      option_value = params['option_value']
      uri = params['connection']
      sleep_recharge = params['sleep_recharge']
      puts sleep_recharge
      puts "sleep recharge: #{sleep_recharge}"
      puts "uri"
      myuri = URI.parse(uri)
      my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
      header_info = params['header_info']
      puts "header info: #{header_info}"

      if option_value == "full_pull"
        # delete all customer_tables
        puts "Deleting customer table"
        customers_delete = "delete from customers"
        customers_reset = "ALTER SEQUENCE customers_id_seq RESTART WITH 1"
        my_conn.exec(customers_delete)
        my_conn.exec(customers_reset)
        puts "Deleted all customer table information and reset the id sequence"
        my_conn.close
        num_customers = background_count_customers(header_info)
        puts "We have #{num_customers} to download"
        background_load_full_customers(sleep_recharge, num_customers, header_info, uri)
      else
        puts "Sorry can't understand what the option_value #{option_value} means"
      end
    end

    def self.background_count_customers(my_header)
      # GET /customers/count
      customer_count = HTTParty.get("https://api.rechargeapps.com/customers/count", :headers => my_header)
      my_count = customer_count.parsed_response
      num_customers = my_count['count']
      num_customers = num_customers.to_i
      puts "EllieHelper#background_count_customers #{num_customers}"
      num_customers
    end

    def self.background_load_full_customers(sleep_recharge, num_customers, my_header, uri)
      puts "starting download"
      myuri = URI.parse(uri)
      my_conn =  PG.connect(myuri.hostname, myuri.port, nil, nil, myuri.path[1..-1], myuri.user, myuri.password)
      my_insert = "insert into customers (customer_id, customer_hash, shopify_customer_id, email, created_at, updated_at, first_name, last_name, billing_address1, billing_address2, billing_zip, billing_city, billing_company, billing_province, billing_country, billing_phone, processor_type, status) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)"
      my_conn.prepare('statement1', "#{my_insert}")

      start = Time.now
      page_size = 250
      num_pages = (num_customers/page_size.to_f).ceil
      1.upto(num_pages) do |page|
        customers = HTTParty.get("https://api.rechargeapps.com/customers?limit=250&page=#{page}", :headers => my_header)
        my_customers = customers.parsed_response['customers']
        # logger.debug "#{'#' * 5} CUSTOMERS #{'#' * 40}\n#{customers.pretty_inspect}"
        my_customers.each do |mycust|
          puts mycust
          customer_id = mycust['id']
          hash = mycust['hash']
          shopify_customer_id = mycust['shopify_customer_id']
          email = mycust['email']
          created_at = mycust['created_at']
          updated_at = mycust['updated_at']
          first_name = mycust['first_name']
          last_name = mycust['last_name']
          billing_address1 = mycust['billing_address1']
          billing_address2 = mycust['billing_address2']
          billing_zip = mycust['billing_zip']
          billing_city = mycust['billing_city']
          billing_company = mycust['billing_company']
          billing_province = mycust['billing_province']
          billing_country = mycust['billing_country']
          billing_phone = mycust['billing_phone']
          processor_type = mycust['processor_type']
          status = mycust['status']
          my_conn.exec_prepared('statement1', [customer_id, hash, shopify_customer_id, email, created_at, updated_at, first_name, last_name, billing_address1, billing_address2, billing_zip, billing_city, billing_company, billing_province, billing_country, billing_phone, processor_type, status])
        end

        puts "Done with page #{page}"
        current = Time.now
        duration = (current - start).ceil
        puts "Running #{duration} seconds"
        puts "Sleeping #{sleep_recharge}"
        sleep sleep_recharge.to_i
      end
      puts "All done"
      my_conn.close
    end
  end
end
