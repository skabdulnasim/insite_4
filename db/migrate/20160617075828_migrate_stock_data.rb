class MigrateStockData < ActiveRecord::Migration
  def up
  	_stocks = Stock.all
  	_stocks.each do |stock|
  		puts stock.id
  		if stock.has_attribute?('wastage')
        say "Migrating data of #{stock.id}"
        _new_defination = StockDefination.new
        _new_defination[:stock_id] = stock.id
        _new_defination[:sku] = stock.sku
        _new_defination[:weight] = stock.weight
        _new_defination[:received_product_unit] = stock.received_product_unit
        _new_defination[:making_cost] = stock.making_cost
        _new_defination[:sell_price] = stock.sell_price
        _new_defination[:wastage] = stock.wastage
        _new_defination.save!
			end
  	end
    if column_exists? :stocks, :weight
      remove_column :stocks, :weight 
    end
    if column_exists? :stocks, :received_product_unit
      remove_column :stocks, :received_product_unit
    end
    if column_exists? :stocks, :sell_price
      remove_column :stocks, :sell_price
    end
    if column_exists? :stocks, :making_cost
      remove_column :stocks, :making_cost
    end
    if column_exists? :stocks, :wastage
      remove_column :stocks, :wastage
    end

  end

  def down
  	StockDefination.delete_all
  end
end
