class CreateBillReprints < ActiveRecord::Migration
  def change
    create_table :bill_reprints do |t|
      t.integer :bill_id
      t.integer :user_id
      t.text :reprint_reason
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
