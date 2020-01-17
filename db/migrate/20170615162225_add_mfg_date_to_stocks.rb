class AddMfgDateToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :mfg_date, :date
  end
end
