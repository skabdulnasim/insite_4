class AddAmountToCashes < ActiveRecord::Migration
  def change
    add_column :cashes, :amount, :integer
  end
end
