class AddExpiryDateToLots < ActiveRecord::Migration
  def change
    add_column :lots, :expiry_date, :date
  end
end
