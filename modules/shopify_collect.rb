module COLLECT
  ACTIVE_COLLECT = []

  def self.init
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    active_collect_count = ShopifyAPI::Collect.count
    nb_pages = (active_collect_count / 250.0).ceil

    # Initalize ACTIVE_PRODUCT with all active products from Ellie.com
    1.upto(nb_pages) do |page| # throttling conditon
      ellie_active_url =
        "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin/collects.json?limit=250&page=#{page}"
      @parsed_response = HTTParty.get(ellie_active_url)

      ACTIVE_COLLECT.push(@parsed_response['collects'])
      p "active collects set #{page} loaded, sleeping 3"
      sleep 3
    end
    p 'active collects initialized'
    # combine hash arrays from each page
    # into single collect array
    ACTIVE_COLLECT.flatten!
  end

  def self.pull
    init
    p 'calling pull collects'
    ACTIVE_COLLECT.each do |object|
      p "saving: #{object['id']}"
      Collect.find_or_initialize_by(id: object['id']).update(object)
    end
    p 'task complete'
  end
end
