class AddRetailItemFieldsToOrderDetails < ActiveRecord::Migration
  def change
    unless column_exists? :order_details, :weight
      add_column :order_details, :weight, :float
    end        
    unless column_exists? :order_details, :product_unit_id
      add_column :order_details, :product_unit_id, :integer
      add_index :order_details, :product_unit_id
    end        
    unless column_exists? :order_details, :store_id
      add_column :order_details, :store_id, :integer
      add_index :order_details, :store_id
    end                
  end
end
