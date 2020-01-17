class ChangeInCountryCurrencies < ActiveRecord::Migration
  def up
  	rename_column :country_currencies, :sybmol,:symbol
  end

  def down
  end
end
