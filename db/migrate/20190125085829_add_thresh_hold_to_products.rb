class AddThreshHoldToProducts < ActiveRecord::Migration
  def change
    add_column :products, :thresh_hold, :float
  end
end
