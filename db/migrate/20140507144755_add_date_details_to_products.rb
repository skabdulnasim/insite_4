class AddDateDetailsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :manufacturing_date, :datetime
    add_column :products, :expiry_date, :datetime
  end
end
