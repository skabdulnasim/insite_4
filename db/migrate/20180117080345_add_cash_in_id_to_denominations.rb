class AddCashInIdToDenominations < ActiveRecord::Migration
  def change
    add_column :denominations, :cash_in_id, :integer
  end
end
