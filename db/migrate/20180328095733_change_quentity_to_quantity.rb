class ChangeQuentityToQuantity < ActiveRecord::Migration
  def up
  	rename_column :purchase_order_metum_descrptions, :quentity, :quantity
  end
end
