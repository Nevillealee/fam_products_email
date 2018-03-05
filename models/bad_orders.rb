class BadOrders
  def initialize
    data = CSV.read(
      "saved_bad_orders.csv",
      encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all
    )
    @hashed_data = data.map(&:to_hash)
  end

  def create_csv
    CSV.open("bad_orders_complete_data.csv", "a+") do |csv|
      csv << ['email', 'bad_order_id', 'product_title', 'leggings_size',
              'sports_bra_size', 'top_size'] # headers

      @hashed_data.each do |datum|
        customer = Customer.find_by_email(datum[:email_address])
        subscriptions = Subscription.where(customer_id: customer.customer_id)
        active_subscriptions = subscriptions.select(&:active?)

        active_subscriptions.each do |subscription|
          csv << [customer.email, datum[:order_number],
                  subscription.product_title, subscription.sizes["leggings"],
                  subscription.sizes["sports-bra"], subscription.sizes["tops"]]
        end
      end
    end
  end
end
