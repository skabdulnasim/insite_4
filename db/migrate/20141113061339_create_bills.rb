class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.float :bill_amount
      t.float :tax_amount
      t.float :discount
      t.float :grand_total
      t.integer :unit_id
      t.text :status
      t.integer :user_id
      t.integer :table_id

      t.timestamps
    end
  end
end
