class ChangeUnitCurrencyValueToUnitCurrencyPrice < ActiveRecord::Migration
  def up
  	rename_column :menu_products,:unit_currency_value,:unit_currency_price
  end

  def down
  end
end
