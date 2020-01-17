class AddTitleToBillDiscounts < ActiveRecord::Migration
  def change
    add_column :bill_discounts, :title, :string
  end
end
