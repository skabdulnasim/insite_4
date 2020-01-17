class CreateBillDiscounts < ActiveRecord::Migration
  def change
    create_table :bill_discounts do |t|
      t.references :bill, index: true
      t.float :discount_amount
      t.string :remarks

      t.timestamps
    end
  end
end
