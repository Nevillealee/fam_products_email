module CUSTOMCOLLECTION
  ACTIVE_COLLECTION = []

  def self.init
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    active_custom_collection_count = ShopifyAPI::CustomCollection.count
    nb_pages = (active_custom_collection_count / 250.0).ceil

    # Initalize ACTIVE_COLLECTION with all active custom collections from Ellie.com
    1.upto(nb_pages) do |page| # throttling conditon
      ellie_active_url =
        "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin/custom_collections.json?limit=250&page=#{page}"
      @parsed_response = HTTParty.get(ellie_active_url)

      ACTIVE_COLLECTION.push(@parsed_response['custom_collections'])
      p "active custom collections set #{page} loaded, sleeping 3"
      sleep 3
    end
    p 'active custom collections initialized'
    # combine hash arrays from each page
    # into single custom collection array
    ACTIVE_COLLECTION.flatten!
  end

  def self.pull
    init
    p 'calling pull custom collections'
    ACTIVE_COLLECTION.each do |object|
      p "saving: #{object['handle']}"
      CustomCollection.find_or_initialize_by(id: object['id']).update(object)
    end
    p 'task complete'
  end
end
