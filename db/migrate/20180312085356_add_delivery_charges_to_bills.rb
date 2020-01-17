class AddDeliveryChargesToBills < ActiveRecord::Migration
  def change
    add_column :bills, :delivery_charges, :float
  end
end
