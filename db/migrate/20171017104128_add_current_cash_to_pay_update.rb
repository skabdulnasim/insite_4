class AddCurrentCashToPayUpdate < ActiveRecord::Migration
  def change
    add_column :pay_updates, :current_cash, :float
  end
end
