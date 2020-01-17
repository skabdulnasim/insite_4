class InsertUserSale < ActiveRecord::Migration
  def up
  	# if AppConfiguration.get_config_value('incentive_commission') == "enabled"
  	# 	order_details = OrderDetail.valid_item
  	# 	order_details.each do |o_d|
  	# 		puts o_d.inspect
	  #     month = o_d.order.recorded_at.strftime("%m/%Y")
	  #     commission_rule_output = CommissionRuleOutput.by_resource_month_product(o_d.order.deliverable_id, month, o_d.product_id)
	  #     _owner_commission = commission_rule_output.count>0 ? commission_rule_output.first.owner_commission_amount : 0
	  #     _thirdparty_commission = commission_rule_output.count>0 ? commission_rule_output.first.csm_commission_amount : 0
	  #     if o_d.order.deliverable_type.downcase == "resource"
	  #       @user_sale = UserSale.by_user_id(o_d.order.consumer_id).by_product_id(o_d.product_id).by_resource_id(o_d.order.deliverable_id).by_recorded_at(o_d.order.recorded_at)
	  #       if @user_sale.present? && @user_sale.count > 0
	  #       	puts "update data"
	  #         _quantity = @user_sale[0].quantity.to_f + o_d.quantity.to_f
	  #         _price_with_tax = @user_sale[0].price_with_tax.to_f + (o_d.quantity.to_f * o_d.unit_price_with_tax.to_f)
	  #         _price_without_tax = @user_sale[0].price_without_tax.to_f + (o_d.quantity.to_f * o_d.unit_price_without_tax.to_f)
	  #         @user_sale[0].update_attributes(:quantity => _quantity, :price_with_tax => _price_with_tax, :price_without_tax => _price_without_tax, :owner_commission => _owner_commission, :thirdparty_commission => _thirdparty_commission)
	  #       else
	  #       	puts "new data"
	  #         _user_sale = UserSale.new
	  #         _user_sale["user_id"] = o_d.order.consumer_id
	  #         _user_sale["product_id"] = o_d.product_id
	  #         _user_sale["resource_id"] = o_d.order.deliverable_id
	  #         _user_sale["quantity"] = o_d.quantity
	  #         _user_sale["price_with_tax"] = o_d.quantity * o_d.unit_price_with_tax
	  #         _user_sale["price_without_tax"] = o_d.quantity * o_d.unit_price_without_tax
	  #         _user_sale["recorded_at"] = o_d.order.recorded_at
	  #         _user_sale["owner_commission"] = _owner_commission
	  #         _user_sale["thirdparty_commission"] = _thirdparty_commission
	  #         _user_sale.save
	  #       end
	  #     end
	  #   end  
   #  end
  
  end
end
