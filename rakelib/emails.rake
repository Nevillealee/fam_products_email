namespace :email do
  desc 'Send email of csv for inventory report'
  task :send do
      EMAIL.send
      sleep 5
      File.delete('./inventory_difference.csv')
  end
end
