class ChangePhoneNoTypeInDeliveryBoys < ActiveRecord::Migration
  def up
    change_column :delivery_boys, :phone_no, :varchar, :limit => 20
  end

  def down
    change_column :delivery_boys, :phone_no, :integer
  end
end
