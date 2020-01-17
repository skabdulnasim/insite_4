class AddPayToPayUpdate < ActiveRecord::Migration
  def change
    add_column :pay_updates, :pay, :float
  end
end
