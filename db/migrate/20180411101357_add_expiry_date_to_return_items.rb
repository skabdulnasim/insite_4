class AddExpiryDateToReturnItems < ActiveRecord::Migration
  def change
  	add_column :return_items, :color_name, :string
    add_column :return_items, :expiry_date, :date
  end
end
