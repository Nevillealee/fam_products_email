class InventoryDifference
  PRODUCT_IDS =
    [
      175540207634, 175535685650, # In The Zone: 3 item, 5 item
      175541518354, 175541026834, # Set The Pace: 3 item, 5 item
      175542632466, 175542304786  # All Star: 3 item, 5 item
    ].freeze

  PRODUCT_COLLECTION_MAP =
    {
      '175540207634' => 3913220114,
      '175535685650' => 3913187346,
      '175541518354' => 3913285650,
      '175541026834' => 3913252882,
      '175542632466' => 3913351186,
      '175542304786' => 3913318418
    }.freeze

  def create_csv
    CSV.open("inventory_difference.csv", "a+") do |csv|
      csv << ['Product and Size', 'Inventory', 'Subscriptions'] # Header
      PRODUCT_IDS.each do |product_id|
        csv << [Product.find(product_id).title]
        custom_collection(product_id).products.each do |collection_product|
          insert_rows(collection_product, product_id, csv)
        end
        csv << [] # empty row separator
      end
    end
  end

  private

  def custom_collection(product_id)
    CustomCollection.find(PRODUCT_COLLECTION_MAP[product_id.to_s])
  end

  def insert_rows(collection_product, product_id, csv)
    rows = collection_product.variants.map do |variant|
      ["#{collection_product.title}: #{variant.title}", variant.inventory_quantity, subscription_quantity(product_id, variant.title, collection_product)]
    end

    rows.each do |row|
      csv << row
    end
  end

  def subscription_quantity(product_id, size, collection_product)
    return product_type_subscriptions_in_size_sum("tops", size, product_id) if /tops/.match?(collection_product.product_type.downcase)
    return product_type_subscriptions_in_size_sum("sports-bra", size, product_id) if /bra/.match?(collection_product.product_type.downcase)
    return product_type_subscriptions_in_size_sum("leggings", size, product_id) if /leggings/.match?(collection_product.product_type.downcase)
    'N/A'
  end

  def product_type_subscriptions_in_size_sum(product_type, size, product_id)
    subscriptions = Subscription.where(shopify_product_id: product_id).select(&:active?)
    subscription_counts_per_size = product_counts

    subscriptions.each do |subscription|
      subscription_counts_per_size[product_type] += 1 if subscription.sizes[product_type] == size
    end

    subscription_counts_per_size[product_type]
  end

  def product_counts
    {
      "leggings" => 0,
      "sports-bra" => 0,
      "tops" => 0
    }
  end
end
