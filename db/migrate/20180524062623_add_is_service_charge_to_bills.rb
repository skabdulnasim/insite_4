class AddIsServiceChargeToBills < ActiveRecord::Migration
  def change
    add_column :bills, :is_service_charge, :string
  end
end
