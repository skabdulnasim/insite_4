class AddTinNoAddToStores < ActiveRecord::Migration
  def change
    add_column :stores, :tin_no, :string
    add_column :stores, :tan_no, :string
  end
end
