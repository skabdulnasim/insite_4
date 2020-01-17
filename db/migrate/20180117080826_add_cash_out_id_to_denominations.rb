class AddCashOutIdToDenominations < ActiveRecord::Migration
  def change
    add_column :denominations, :cash_out_id, :integer
  end
end
