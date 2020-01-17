module StoreManagement
  #Getting stock details of a product for a store
  def self.get_product_stock_details(product_id,store_id)
    _stock = StockUpdate.current_stock(store_id, product_id)
    return _stock
  end

  # Get the current stock of all particular product in all units.
  def self.get_products_stock_details_in_all_units()
    _all_products = Product.get_all
    _all_units = Unit.all
    @main_arr = Array.new
    _all_products.each do |product|
      total = 0
      _sub_arr = {}
      _all_units.each do |unit|        
        all_stores = Store.unit_stores(unit.id).physical.primary
        all_stores.each do |as|
          total_count = StockUpdate.current_stock(as.id,product.id)
          total = total + total_count
        end         
      end
      _sub_arr[:name] = product.name
      _sub_arr[:current_stock] = total
      _sub_arr[:basic_unit] = product.basic_unit
      @main_arr.push _sub_arr
    end
    return @main_arr
  end

  ############# Function to reduce stock from store on outlet product sale (DEPRECATED) #############
  # def self.reduce_inventory_stock(_menu_product_id,_consumed_quantity, order_id)
  #   _consumed_quantity = _consumed_quantity.to_f
  #   _menu_product = MenuProduct.find(_menu_product_id)
  #   _product_id = _menu_product.product_id

  #   _outlet_store = _menu_product.store_id
  #   _product_stock = StockUpdate.current_stock(_outlet_store, _product_id)
  #   if _product_stock.to_f >= _consumed_quantity
  #     _total_price = 0
  #     available_stocks = Stock.product_debit_options(_outlet_store, _product_id)
  #     available_stocks.each do |as|
  #       if as.available_stock > _consumed_quantity && _consumed_quantity != 0
  #         #reduce available stock
  #         new_available_stock = (as.available_stock)- _consumed_quantity
  #         _price = Stock.get_stock_price(as.id,_consumed_quantity)
  #         _total_price = _total_price + _price
  #         Stock.consume_stock_debit(as.id,_consumed_quantity,nil,"Order")
  #       else
  #         if _consumed_quantity > 0
  #           #reduce available stock
  #           new_available_stock = 0
  #           _price = Stock.get_stock_price(as.id,as.available_stock)
  #           _total_price = _total_price + _price
  #           Stock.consume_stock_debit(as.id,as.available_stock,nil,"Order")
  #           _consumed_quantity = _consumed_quantity - as.available_stock            
  #         end
  #       end
  #     end
  #     _new_stock_debit = Stock.save_stock(_product_id,_outlet_store,_total_price,0,order_id,'order',0,_consumed_quantity,nil)
  #     _new_stock_debit.save
  #     return _new_stock_debit
  #   else
  #     return 0    
  #   end      
  # end

  def self.get_stock_details(product_id,unit_id)
    total = 0  
    product_name = Product.where("id" => product_id)
    all_stores = Store.unit_stores(unit_id).physical.primary
    all_stores.each do |as|
     total_count2 = StockUpdate.current_stock(as.id, product_id)
     total = total + total_count2 
    end
    main_arr = {}
    main_arr[:total_stock] = total.round(2)
    main_arr[:product_unit] = product_name[0].basic_unit
    main_arr[:product_name] = product_name[0].name    
    return main_arr
  end  

end