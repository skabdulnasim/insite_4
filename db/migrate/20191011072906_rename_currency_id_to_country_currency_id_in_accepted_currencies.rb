class RenameCurrencyIdToCountryCurrencyIdInAcceptedCurrencies < ActiveRecord::Migration
  def up
  	rename_column :accepted_currencies,:currency_id,:country_currency_id
  end

  def down
  end
end
