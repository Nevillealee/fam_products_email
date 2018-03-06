namespace :auto do
  desc "links products/customcollections on ellie staging"
  task :run =>
  ['ellie:products',
    'ellie:custom_collections',
    'ellie:collects',
    'customcollection:save_stages',
    'subscription_pull[full_pull]',
    'customer_pull[full_pull]',
    'customer_service:inventory_difference_csv',
    'email:send'] do
    p 'Process complete'
  end
end
