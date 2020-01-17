class AddBusinessTypeToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :business_type, :string
  end
end
