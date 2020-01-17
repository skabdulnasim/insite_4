class AddCallDeatilsToUnits < ActiveRecord::Migration
  def change
    add_column :units, :pincode, :text
    add_column :units, :phone, :text
  end
end
