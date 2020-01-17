class AddIsUnitCurrencyToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :is_unit_currency, :string,:default => "No"
    add_column :menu_products, :unit_currency_value, :float, :default => 0
  end
end
