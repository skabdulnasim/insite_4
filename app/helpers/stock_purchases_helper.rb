module StockPurchasesHelper

	def show_mrp(business_type,stock)
		if business_type == "by_mrp"
			return stock.first.stock_defination.sell_price
		elsif business_type == "by_catalog"
			if stock.last.stock_price.present?
				return stock.last.stock_price.mrp
			else			
				return stock.first.price
			end	
		else
			return stock.first.stock_defination.making_cost
		end
	end

	def show_unit(product_unit_id)
		unit = ProductUnit.find(product_unit_id)
		return unit.short_name
	end

	def menu_price(unit_id,product_id)
		menu_cards = MenuCard.set_unit(unit_id)
		sell_price = 0
    menu_cards.each do |mc|
      if MenuProduct.by_menu_card(mc.id).set_product(product_id).present?
        mp = MenuProduct.by_menu_card(mc.id).set_product(product_id).first
        sell_price = mp.sell_price 
      end 
    end 
    return sell_price
	end	
	
	def get_available_bins(row_id)
		count = 0
		row = WarehouseMetum.find(row_id)
		row.warehouse_racks.each do |rack|
			rack.bins.each do |bin|
				count += 1 if bin.status=="available"
			end
		end
		return count
	end
	def get_product_quantity(bin_id)
		product_quantity = BinProduct.where("bin_id=?",bin_id).pluck("product_quantity").first
		return product_quantity
	end
end
