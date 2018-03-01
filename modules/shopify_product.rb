module PRODUCT
  ACTIVE_PRODUCT = []

  def self.init
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    active_product_count = ShopifyAPI::Product.count
    nb_pages = (active_product_count / 250.0).ceil

    # Initalize ACTIVE_PRODUCT with all active products from Ellie.com
    1.upto(nb_pages) do |page| # throttling conditon
      ellie_active_url =
        "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin/products.json?limit=250&page=#{page}"
      @parsed_response = HTTParty.get(ellie_active_url)
      # appends each product hash to ACTIVE_PRODUCT array
      ACTIVE_PRODUCT.push(@parsed_response['products'])
      p "active products set #{page} loaded, sleeping 3"
      sleep 3
    end
    p 'active products initialized'
    # combine hash arrays from each page
    # into single product array
    ACTIVE_PRODUCT.flatten!
  end

  def self.pull
    init
    p 'calling pull products'
    ACTIVE_PRODUCT.each do |object|
      p "saving: #{object['title']}"
      Product.find_or_initialize_by(id: object['id']).update(object.merge('variants' => []))
      object['variants'].each do |variant|
        ProductVariant.find_or_initialize_by(id: variant['id']).update(variant)
      end
    end
    p 'task complete'
  end
end
