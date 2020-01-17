class RemovePayFromPayUpdate < ActiveRecord::Migration
  def up
    remove_column :pay_updates, :pay
  end

  def down
    add_column :pay_updates, :pay, :float
  end
end
