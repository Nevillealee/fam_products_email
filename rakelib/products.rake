namespace :test do
  desc 'some description'
  task :products do
      SHOPIFY_INIT.pull_products
  end
end
