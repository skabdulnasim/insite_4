class ChangeColumnTypeInAcceptedCurrencies < ActiveRecord::Migration
  def up
  	 change_column :accepted_currencies, :multiplier, :float
  end

  def down
  end
end
