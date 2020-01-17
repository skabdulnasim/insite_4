class AddUnitCurrencyToUnits < ActiveRecord::Migration
  def change
    add_column :units, :unit_currency, :string
    add_column :units, :conversion_rate, :float
  end
end
