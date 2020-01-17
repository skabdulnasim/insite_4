class CreateBillTaxAmounts < ActiveRecord::Migration
  def change
    create_table :bill_tax_amounts do |t|
      t.integer :bill_id
      t.integer :tax_class_id
      t.float :tax_amount
      t.timestamps
    end
  end
end
