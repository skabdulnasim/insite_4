class CreateBillSplits < ActiveRecord::Migration
  def change
    create_table :bill_splits do |t|
      t.integer :bill_id, :null => false
      t.integer :unit_id, :null => false
      t.integer :user_id, :null => false
      t.string :split_type
      t.float :bill_amount, :null => false
      t.float :tax_amount
      t.float :discount
      t.float :grand_total, :null => false
      t.text :product_details

      t.timestamps
    end
  end
end
