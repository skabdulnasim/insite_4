class AddBillColumnsToOrderDetails < ActiveRecord::Migration
  def change
    add_column :order_details, :product_id, :integer
    add_column :order_details, :product_name, :string
    add_column :order_details, :procurement_cost, :float
    add_column :order_details, :product_price, :float
    add_column :order_details, :customization_price, :float
    add_column :order_details, :unit_price_without_tax, :float
    add_column :order_details, :tax_amount, :float
    add_column :order_details, :tax_details, :text
    add_column :order_details, :unit_price_with_tax, :float
    add_column :order_details, :discount, :float
    add_column :order_details, :subtotal, :float
  end
end
