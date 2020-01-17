class CreateBillSplitProducts < ActiveRecord::Migration
  def change
    create_table :bill_split_products do |t|
      t.integer :bill_split_id
      t.integer :product_id
      t.float :quantity
      t.float :price

      t.timestamps
    end
    remove_column :bill_splits, :product_details
  end
end
