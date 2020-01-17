class AddDefaultValueToStockProduction < ActiveRecord::Migration
   def up
    StockProduction.find_each do |stock_production|
      unless stock_production.start_date
      	stock_production.update_column(:start_date, stock_production.created_at)

      	puts "update start_date"
      end
      unless stock_production.end_date
      	stock_production.update_column(:end_date, stock_production.created_at)
      	puts "updated end_date"
      end
    end
  end
end
