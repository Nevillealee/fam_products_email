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
    CSV.open("inventory_difference_refactor.csv", "a+") do |csv|
      PRODUCT_IDS.each do |product_id|
        custom_collection(product_id).products.each do |collection_product|
          csv << current_inventory_quantity_per_variant_row(collection_product, product_id)
        end
        csv << [] # empty row separator
      end
    end
  end

  private

  def custom_collection(product_id)
    CustomCollection.find(PRODUCT_COLLECTION_MAP[product_id.to_s])
  end

  def current_inventory_quantity_per_variant_row(collection_product, product_id)
    collection_product.variants.map do |variant|
      "#{collection_product.title}: #{variant.title}, inventory_quantity: #{variant.inventory_quantity}, subscriptions: #{subscription_quantity(product_id, variant.title, collection_product)}"
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

  # def active_subscriptions_per_size_per_product_type_row(product_id)
  #   [
  #     subscription_quantity_per_size(product_id, 'XS'),
  #     subscription_quantity_per_size(product_id, 'S'),
  #     subscription_quantity_per_size(product_id, 'M'),
  #     subscription_quantity_per_size(product_id, 'L'),
  #     subscription_quantity_per_size(product_id, 'XL')
  #   ]
  # end

  # def subscription_quantity_per_size(product_id, size)
  #   subscription_counts_per_size = product_counts
  #   subscriptions = Subscription.where(shopify_product_id: product_id).select(&:active?)
  #
  #   subscriptions.each do |subscription|
  #     subscription_counts_per_size["leggings"] += 1 if subscription.sizes["leggings"] == size
  #     subscription_counts_per_size["sports-bra"] += 1 if subscription.sizes["sports-bra"] == size
  #     subscription_counts_per_size["tops"] += 1 if subscription.sizes["tops"] == size
  #   end
  #
  #   subscription_counts_per_size.to_a
  #                               .map { |count| count.join(' ') }
  #                               .flatten
  #                               .join(', ')
  #                               .prepend("#{size} ACTIVE SUBSCRIPTIONS: ")
  # end

  def product_counts
    {
      "leggings" => 0,
      "sports-bra" => 0,
      "tops" => 0
    }
  end
end
