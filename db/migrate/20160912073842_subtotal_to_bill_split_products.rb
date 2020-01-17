class SubtotalToBillSplitProducts < ActiveRecord::Migration
  def change
  	add_column :bill_split_products, :order_detail_id, :integer  	
  	add_column :bill_split_products, :subtotal, :float  	
  	add_column :bill_split_products, :tax_amount, :float  	
  end
end
